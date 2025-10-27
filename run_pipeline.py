import time
from dotenv import load_dotenv


def main():
    """
    Orchestrates the entire data pipeline:
    1. Loads environment variables.
    2. Scrapes new articles.
    3. Summarizes scraped articles.
    4. Embeds articles into the vector store.
    """
    
    # 1. Load environment variables from .env file
    print("[PIPELINE] Loading environment variables...")
    load_dotenv()
    print("[PIPELINE] Environment variables loaded.")

    # Import pipeline components
    from news_ai.pipeline.scraper import save_raw_articles
    from news_ai.pipeline.summarizer import summarize_articles
    from news_ai.pipeline.embedder import embed_articles

    start_time = time.time()
    
    try:
        # --- Step 1: Scrape ---
        print("\n[PIPELINE] Step 1: Starting Scraper...")
        save_raw_articles()
        print("[PIPELINE] Step 1: Scraping complete.")
        
        # --- Step 2: Summarize ---
        print("\n[PIPELINE] Step 2: Starting Summarizer...")
        summarize_articles()
        print("[PIPELINE] Step 2: Summarization complete.")
        
        # --- Step 3: Embed ---
        print("\n[PIPELINE] Step 3: Starting Embedder...")
        chunks_embedded = embed_articles()
        print(f"[PIPELINE] Step 3: Embedding complete. {chunks_embedded} chunks processed.")
        
    except FileNotFoundError as e:
        print(f"\n[PIPELINE ERROR] A file was not found. Did a previous step fail?")
        print(f"Error details: {e}")
    except Exception as e:
        print(f"\n[PIPELINE ERROR] An unexpected error occurred: {e}")
    
    end_time = time.time()
    print(f"\n[PIPELINE] All steps finished in {end_time - start_time:.2f} seconds.")

if __name__ == "__main__":
    main()