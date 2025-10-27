import os
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent

# --- Data Paths ---
DATA_DIR = PROJECT_ROOT / "data"
RAW_DATA_PATH = DATA_DIR / "raw" / "raw_articles.json"
PROCESSED_DATA_PATH = DATA_DIR / "processed" / "feed_articles.json"

# --- DB Path ---
DB_DIR = PROJECT_ROOT / "chroma_db"

# --- Model IDs ---
EMBEDDING_MODEL = 'all-MiniLM-L6-v2'
SUMMARIZER_MODEL = 'facebook/bart-large-cnn'
LLM_MODEL = 'openai/gpt-oss-120b'

# --- RAG ---
CHUNK_SIZE = 500
CHUNK_OVERLAP = 50
TOP_K_RESULTS = 3

# --- API Keys ---
GROQ_API_KEY = os.environ.get("GROQ_API_KEY")