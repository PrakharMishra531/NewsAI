import chromadb
import json
from sentence_transformers import SentenceTransformer
from langchain_text_splitters import RecursiveCharacterTextSplitter
from news_ai.core.config import DB_DIR, EMBEDDING_MODEL, TOP_K_RESULTS

chroma_client = chromadb.PersistentClient(path=str(DB_DIR))
collection = chroma_client.get_or_create_collection(name="news_articles")
embedder = SentenceTransformer(EMBEDDING_MODEL)

def query_article(article_id: str, query_text: str):
    """
    Query a specific article using RAG.
    1. Embeds the USER'S QUERY.
    2. Searches ChromaDB for relevant CHUNKS.
    3. Filters to ONLY the specified article_id.
    """
    
    # 1. Embed the user's actual query text
    query_embedding = embedder.encode(query_text).tolist()
    
    # 2. Search using the query_embedding
    # 3. Filter using the metadata field "article_id"
    search_results = collection.query(
        query_embeddings=[query_embedding],
        n_results=TOP_K_RESULTS,
        where={"id": article_id} 
    )
    
    if not search_results['documents']:
        return {"error": "No relevant context found for this query."}
    
    # 4. Prepare the retrieved chunks as context
    context = "\n---\n".join(search_results['documents'][0])
    
    # 5. Return the context 
    return {
        "article_id": article_id,
        "context": context,
        "query": query_text,
    }