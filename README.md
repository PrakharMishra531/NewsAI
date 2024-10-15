# NewsAI

## Overview
**NewsAI** is your real-time news assistant, seamlessly pulling the latest stories from the Times of India every 24 hours and caching them for lightning-fast access. Ask any question, and NewsAI instantly searches through its vast, up-to-date knowledge base using powerful semantic search in Pinecone’s vector database. The most relevant insights are then delivered to your language model, providing rich, contextual responses in seconds—keeping you informed, always.

## Features
- **Web Scraping**: News articles scraped using BeautifulSoup from Times of India.
- **Embeddings**: Hugging Face embedder from LangChain creates vector embeddings.
- **Storage**: Pinecone database stores document embeddings for retrieval.
- **Caching**: Redis is used to cache results and speed up retrieval.
- **Rate Limiting**: SQLite3 manages user request data, ensuring users don’t exceed the set request limit.
- **API Endpoints**: 
  - `/health`: Verifies API activity.
  - `/search`: Accepts queries for retrieving documents based on similarity.

## Technologies Used

| Technology  | Logo                                                                 |
|-------------|----------------------------------------------------------------------|
| Python      | ![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white) |
| BeautifulSoup | ![BeautifulSoup](https://img.shields.io/badge/BeautifulSoup-333333?style=for-the-badge&logo=python&logoColor=white) |
| LangChain   | ![LangChain](https://img.shields.io/badge/LangChain-FFD43B?style=for-the-badge&logo=langchain&logoColor=blue) |
| Pinecone    | ![Pinecone](https://img.shields.io/badge/Pinecone-039BE5?style=for-the-badge&logo=pinecone&logoColor=white) |
| Redis       | ![Redis](https://img.shields.io/badge/Redis-DC382D?style=for-the-badge&logo=redis&logoColor=white) |
| Flask       | ![Flask](https://img.shields.io/badge/Flask-000000?style=for-the-badge&logo=flask&logoColor=white) |
| SQLite3     | ![SQLite3](https://img.shields.io/badge/SQLite-003B57?style=for-the-badge&logo=sqlite&logoColor=white) |


## Installation Steps

### Step 1: Clone the Repository

```bash
git clone https://github.com/your-repo/newsai.git
cd newsai
```

### Step 2: Create a Virtual Environment
```bash
virtualenv venv .\venv\Scripts\activate   # Windows # or source venv/bin/activate  # macOS/Linux
```
### Step 3: Install Dependencies
```bash
pip install -r requirements.txt
```

### Step 4: Install Redis

1. Download Redis from [Microsoft's GitHub Archive](https://github.com/MicrosoftArchive/redis/releases).
    
2. Navigate to the installation folder and start the Redis server:
```bash
    redis-server.exe redis.windows.conf
```
3. To check if the Redis server is running, use the following command:
```bash
    redis-cli ping
```
You should see `PONG` in the output.
    
4. When you're done with Redis, shut it down using:
```bash
    redis-cli shutdown
 ```
    

### Step 5: Run the Server

```bash
python main.py
```
### Step 6: Ping the Server

To check if the server is running, visit:
```
http://127.0.0.1:5000/health
```
### Step 7: Search News Articles

To use the news article context-based LLM, send a search request with the following parameters:

- `text`: The query text
- `top_k`: The number of results to fetch
- `threshold`: The minimum similarity score
Example URL:

```perl
	http://127.0.0.1:5000/search?user_id=user252&text=tell%20me%20about%20all%20the%20news%20you%20have%20from%20america&top_k=5&threshold=0.1
```
	
