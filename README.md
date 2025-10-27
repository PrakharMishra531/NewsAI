# NewsAI

## Overview
**NewsAI** is your intelligent news assistant that scrapes the latest stories from Times of India, summarizes them using advanced AI models, and enables contextual Q&A through a Retrieval-Augmented Generation (RAG) system. The application uses semantic search in a ChromaDB vector database to find relevant information and provides rich, contextual responses via a OpenAI OSS-120B large language model.

## Features
- **Web Scraping**: News articles scraped using BeautifulSoup from Times of India.
- **Summarization**: AI-powered summarization using BART model to create concise news summaries.
- **Embeddings**: SentenceTransformer creates vector embeddings for semantic search.
- **Storage**: ChromaDB stores document embeddings for efficient retrieval.
- **RAG Q&A**: Contextual question-answering system that leverages article content.
- **API Endpoints**: 
  - `/`: Root endpoint to verify API activity.
  - `/feed`: Retrieves the processed news feed with summaries.
  - `/query`: Accepts queries for retrieving answers based on article content.

## Technologies Used

| Technology  | Logo                                                                 |
|-------------|----------------------------------------------------------------------|
| Python      | ![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white) |
| FastAPI     | ![FastAPI](https://img.shields.io/badge/FastAPI-005571?style=for-the-badge&logo=fastapi&logoColor=white) |
| BeautifulSoup | ![BeautifulSoup](https://img.shields.io/badge/BeautifulSoup-333333?style=for-the-badge&logo=python&logoColor=white) |
| ChromaDB    | ![ChromaDB](https://img.shields.io/badge/ChromaDB-4555D6?style=for-the-badge&logo=chroma&logoColor=white) |
| Sentence Transformers | ![Sentence Transformers](https://img.shields.io/badge/Sentence--Transformers-FF6B6B?style=for-the-badge&logo=pytorch&logoColor=white) |
| Transformers | ![Transformers](https://img.shields.io/badge/Transformers-FFD700?style=for-the-badge&logo=huggingface&logoColor=white) |
| GROQ        | ![GROQ](https://img.shields.io/badge/GROQ-800080?style=for-the-badge&logo=google-cloud&logoColor=white) |
| LangChain   | ![LangChain](https://img.shields.io/badge/LangChain-FFD700?style=for-the-badge&logo=langchain&logoColor=blue) |

## Architecture
The application follows a modular architecture:
- **API Layer**: FastAPI endpoints for serving the news feed and handling Q&A requests
- **Core**: Configuration and shared utilities
- **Pipeline**: Data processing modules for scraping, summarizing, and embedding

## Installation Steps

### Step 1: Clone the Repository
```bash
git clone https://github.com/your-repo/newsai.git
cd newsai
```

### Step 2: Create a Virtual Environment
```bash
python -m venv venv
.\venv\Scripts\activate   # Windows
# or 
source venv/bin/activate  # macOS/Linux
```

### Step 3: Install Dependencies

```bash
pip install -r requirements.txt
```

### Step 4: Set up Environment Variables
Create a `.env` file in the project root with your GROQ API key:
```
GROQ_API_KEY=your_groq_api_key_here
```

### Step 5: Run the Pipeline
First, process the data by running the pipeline:
```bash
python run_pipeline.py
```

This will:
- Scrape news articles from Times of India
- Summarize the articles using BART model
- Create embeddings and store them in ChromaDB

### Step 6: Run the Server
```bash
uvicorn news_ai.api.main:app --reload
```

## Usage

### API Endpoints

1. **Get News Feed** - GET `/feed`
   ```bash
   curl http://127.0.0.1:8000/feed
   ```

2. **Query Articles** - POST `/query`
   ```bash
   curl -X POST http://127.0.0.1:8000/query \
   -H "Content-Type: application/json" \
   -d '{
     "article_id": "toi_123456",
     "query_text": "What is this article about?"
   }'
   ```

### Example Query Format
The `/query` endpoint expects a JSON body with:
- `article_id`: The ID of the specific article to query
- `query_text`: The question you want to ask about the article

## Project Structure
```
NewsAI/
├── run_pipeline.py          # Orchestrates the data pipeline
├── .env                    # Environment variables
├── chroma_db/              # ChromaDB vector store
├── data/                   # Raw and processed article data
│   ├── raw/                # Raw scraped articles
│   └── processed/          # Summarized articles for feed
└── news_ai/                # Main application package
    ├── api/                # FastAPI endpoints
    │   ├── main.py         # Main API router
    │   ├── retrieval.py    # RAG retrieval logic
    │   └── generation.py   # LLM generation logic
    ├── core/               # Core utilities
    │   └── config.py       # Configuration settings
    └── pipeline/           # Data processing modules
        ├── scraper.py      # Web scraping functionality
        ├── summarizer.py   # Article summarization
        └── embedder.py     # Embedding and vector storage
```