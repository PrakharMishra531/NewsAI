from flask import Flask, request, jsonify
import sqlite3
from sqlite3 import Error
import logging
import time
import threading
import embedding

app = Flask(__name__)

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Database setup
def init_db():
    try:
        conn = sqlite3.connect('api_calls.db')
        cursor = conn.cursor()
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS user_requests (
                user_id TEXT PRIMARY KEY,
                call_count INTEGER NOT NULL
            )
        ''')
        conn.commit()
        conn.close()
    except Error as e:
        logger.error(f"Database error: {e}")

init_db()

def update_user_request_count(user_id):
    try:
        conn = sqlite3.connect('api_calls.db')
        cursor = conn.cursor()
        cursor.execute('''
            INSERT INTO user_requests (user_id, call_count)
            VALUES (?, 1)
            ON CONFLICT(user_id) DO UPDATE SET
                call_count = call_count + 1
        ''', (user_id,))
        conn.commit()
        
        cursor.execute('SELECT call_count FROM user_requests WHERE user_id = ?', (user_id,))
        call_count = cursor.fetchone()[0]
        conn.close()
        
        return call_count
    except Error as e:
        logger.error(f"Database error: {e}")
        return None


@app.route('/health', methods=['GET'])
def health_check():
    return "Server running..."


@app.route('/search', methods=['GET'])
def search_endpoint():
    start_time = time.time()
    
    user_id = request.args.get('user_id')
    if not user_id:
        return jsonify({"error": "User ID is required"}), 400
    
    # Checking and updating user request count
    call_count = update_user_request_count(user_id)
    
    if call_count is None:
        logger.error(f"Internal server error for user_id: {user_id}")
        return jsonify({"error": "Internal server error"}), 500
    
    if call_count > 5:
        logger.warning(f"Too many requests for user_id: {user_id}")
        return jsonify({"error": "Too many requests"}), 429
    

    text = request.args.get('text', '')
    top_k = int(request.args.get('top_k', 5))
    threshold = float(request.args.get('threshold', 0.2))

    answer = embedding.llm_response(query=text,topk = top_k,threshold=threshold)
    
    inference_time = time.time() - start_time
    logger.info(f"Request by user_id: {user_id} took {inference_time:.4f} seconds")
    
    response = {
        "inference_time": inference_time,
        "results": answer
    }
    return jsonify(response)


# Function running in different thread to do scraping of articles
def run_news_scraping():
    try:
        print("Scraping news...")
        print("converting text to vector Embeddings...")
        print("storing the embeddings in pinecone db...")
        embedding.convert_and_store_embeddings()  
        print("process completed")
        
    except Exception as e:
        logger.error(f"Error while scraping news: {e}")


if __name__ == '__main__':
    init_db()
    # Start the news scraping thread
    scraping_thread = threading.Thread(target=run_news_scraping, daemon=True)
    scraping_thread.start()
    
    app.run(debug=True)