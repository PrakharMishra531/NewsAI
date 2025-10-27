import chromadb
import json
from sentence_transformers import SentenceTransformer
from langchain_text_splitters import RecursiveCharacterTextSplitter
from news_ai.core.config import (
    RAW_DATA_PATH, 
    DB_DIR, 
    EMBEDDING_MODEL,
    CHUNK_SIZE,
    CHUNK_OVERLAP
)

chroma_client = chromadb.PersistentClient(path=str(DB_DIR))
embedder = SentenceTransformer(EMBEDDING_MODEL)

# 1. Define the collection name from your config (or hardcode it here)
COLLECTION_NAME = "news_articles"

try:
    # 2. Explicitly DELETE the old collection
    print(f"Attempting to delete old collection: '{COLLECTION_NAME}'...")
    chroma_client.delete_collection(name=COLLECTION_NAME)
    print(f"Old collection '{COLLECTION_NAME}' deleted.")
except Exception as e:
    # This will fail on the very first run, which is fine.
    print(f"Warning: Could not delete collection (may not exist yet): {e}")

# 3. Create a new, empty collection
print(f"Creating new collection: '{COLLECTION_NAME}'...")
collection = chroma_client.create_collection(name=COLLECTION_NAME)


def embed_articles():
    """Load raw articles, CHUNK them, and embed the chunks."""
    with open(RAW_DATA_PATH, 'r', encoding='utf-8') as f:
        raw_articles = json.load(f)
    
    # Initialize a text splitter
    text_splitter = RecursiveCharacterTextSplitter(
        chunk_size=CHUNK_SIZE, 
        chunk_overlap=CHUNK_OVERLAP
    )
    
    documents = []
    metadatas = []
    ids = []
    
    for article in raw_articles:
        # 1. Chunk the full_text
        chunks = text_splitter.split_text(article["full_text"])
        
        # 2. Loop through each chunk and create a DB entry
        for i, chunk in enumerate(chunks):
            documents.append(chunk)
            
            # 3. The metadata MUST link back to the parent article
            metadatas.append({
                "id": article["id"], # for filtering
                "source_url": article["source_url"],
                "chunk_num": i 
            })
            
            # 4. The ID must be unique FOR EACH CHUNK
            ids.append(f"{article['id']}_chunk_{i}")
            
    if not documents:
        print("No documents to embed.")
        return 0

    # 5. Generate embeddings for the CHUNKS, not the articles
    embeddings = embedder.encode(documents).tolist()
    
    # 6. Upsert the CHUNKS
    collection.upsert(
        embeddings=embeddings,
        documents=documents,
        metadatas=metadatas,
        ids=ids
    )
    
    print(f"Embedded {len(ids)} chunks from {len(raw_articles)} articles.")
    return len(ids)

