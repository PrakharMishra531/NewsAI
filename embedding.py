from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_huggingface import HuggingFaceEmbeddings
import scrapper
from pinecone import Pinecone, ServerlessSpec
from dotenv import load_dotenv
import os
from pinecone.core.openapi.shared.exceptions import PineconeApiException
from langchain_groq import ChatGroq
from langchain.chains import RetrievalQAWithSourcesChain
from langchain_community.vectorstores import Pinecone as LangchainPinecone
from typing import List, Dict
import redis
import hashlib
import json

load_dotenv()
api_key = os.getenv('PINECONE_API_KEY')
groq_api_key = os.getenv('GROQ_API_KEY')

embeddings = HuggingFaceEmbeddings()

index_name = "legal-force-index"



class Document:
    def __init__(self, page_content: str, metadata: Dict = None):
        self.page_content = page_content
        self.metadata = metadata if metadata is not None else {}

def text_split():
    urls = scrapper.get_news_links()  # Fetching the news article URLs
    data = scrapper.scrape_news_content(urls)  # Scraping the article content 
    
    # Converting the list of article content strings into a list of Document objects
    documents = [Document(page_content=content, metadata={'source': url}) for content, url in zip(data, urls)]
    
    #splitting the content ot accomodate the Huggingface model(sentence transformer)
    text_splitter = RecursiveCharacterTextSplitter(
        separators=['\n\n', '\n', '.', ','],
        chunk_size=300  # Adjust the chunk size based on your needs
    )
    split_text = text_splitter.split_documents(documents)
    print("text split completed...")
    return split_text



#setup pinecone db to store embeddings
def pinecone_db_setup(indexName):
    try:
        if index_name not in pc.list_indexes():
            pc.create_index(
                name=index_name,
                dimension=768,  # 768 is the dimension of the embeddings from HuggingFace model
                metric="cosine",
                spec=ServerlessSpec(
                    cloud="aws",
                    region="us-east-1"
                )
            )
            print(f"Index '{index_name}' created.")
        else:
            print(f"Index '{index_name}' already exists.")
    
    except PineconeApiException as e:
        if e.status == 409:
            print(f"Index '{index_name}' already exists. Skipping creation.")
        else:
            raise e

    index = pc.Index(index_name)
    return index

# Convert the text to embeddings using sentence transformers and store them in Pinecone
def convert_and_store_embeddings():
    split_text = text_split()  
    for i, doc in enumerate(split_text):
        doc_content = doc.page_content
        # Generating embedding for each document
        doc_embedding = embeddings.embed_query(doc_content)
        # Upserting the document with its embedding and metadata
        index.upsert(vectors=[(f"doc_{i}", doc_embedding, {"text": doc_content, "source": "timesofIndia"})])
    print("Embeddings stored in pinecone db...")


pc = Pinecone(api_key=api_key)
index = pinecone_db_setup(indexName=index_name)
index = pc.Index(index_name)


# Initialize Redis client globally
redis_client = redis.Redis(host='localhost', port=6379, db=0)

def generate_cache_key(query, topk, threshold):
    # Generate a unique cache key based on query, topk, and threshold
    key = f"{query}|{topk}|{threshold}"
    return hashlib.sha256(key.encode()).hexdigest()

def llm_response(query, topk, threshold):
    # Generate a cache key
    cache_key = generate_cache_key(query, topk, threshold)
    
    # Check if the result is already cached
    cached_result = redis_client.get(cache_key)
    if cached_result:
        print("Cache hit!")
        return json.loads(cached_result)


    # Initializing LLM - Mixtral 7B model from Groq inference API
    llm = ChatGroq(temperature=0.3, groq_api_key=groq_api_key, model_name="mixtral-8x7b-32768")
    
    print("Fetching documents...\nGiving context to Mixtral LLM...")
    # Fetching documents
    query_embedding = embeddings.embed_query(query)
    query_response = index.query(
        top_k=topk,
        include_metadata=True,
        vector=query_embedding
    )
    doc_matches = query_response['matches']
    
    # Filter documents based on threshold
    filtered_docs = [
        doc for doc in doc_matches
        if doc['score'] >= threshold
    ]

    # Formating the documents for LLM
    formatted_docs = "\n".join(
        [f"Source: {doc['metadata'].get('source', 'unknown')}\nText: {doc['metadata'].get('text', '')}"
         for doc in filtered_docs]
    )

    prompt_template = """
    You are a helpful assistant. Based on the provided documents, try to give an exact answer with facts from the document.Answer the following question:

    Documents:
    {documents}

    Question:
    {question}

    Answer:
    """
    formatted_prompt = prompt_template.format(
        documents=formatted_docs,
        question=query
    )
    
    # Initializing the vector store
    vectorstore = LangchainPinecone(index, embedding=embeddings.embed_query, text_key="text")

    # Creating and using the RetrievalQA chain
    chain = RetrievalQAWithSourcesChain.from_llm(llm=llm, retriever=vectorstore.as_retriever())
    result = chain({"question": query, "prompt": formatted_prompt}, return_only_outputs=True)
    
    # Cache the result with a TTL (e.g., 1 hour)
    redis_client.setex(cache_key, 3600, json.dumps(result))
    return result

