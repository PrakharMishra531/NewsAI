from transformers import BartForConditionalGeneration, BartTokenizer
import torch
import json
import os
from news_ai.core.config import ( 
    SUMMARIZER_MODEL, 
    RAW_DATA_PATH, 
    PROCESSED_DATA_PATH
)

# --- Load models once at module level ---
try:
    model_name = SUMMARIZER_MODEL
    tokenizer = BartTokenizer.from_pretrained(model_name)
    DEVICE = "cuda" if torch.cuda.is_available() else "cpu"
    model = BartForConditionalGeneration.from_pretrained(model_name).to(DEVICE)
    print(f"Summarizer model '{model_name}' loaded to {DEVICE}.")
except Exception as e:
    print(f"FATAL: Could not load summarizer model. Error: {e}")
    tokenizer = None
    model = None

def summarize_bart(text):
    """Generates a summary for a single text using the loaded BART model."""
    if model is None or tokenizer is None:
        print("ERROR: Summarizer model not loaded. Returning original text.")
        return text

    # Tokenize input
    inputs = tokenizer(
        text,
        return_tensors="pt",
        max_length=1024,
        truncation=True,
        padding="longest"
    ).to(DEVICE)

    # Generate summary
    summary_ids = model.generate(
        inputs["input_ids"],
        max_length=120,          
        min_length=40,
        length_penalty=1.0,
        num_beams=4,
        early_stopping=False,    
        no_repeat_ngram_size=3,
        do_sample=False
    )
    # Decode full output
    summary = tokenizer.decode(summary_ids[0], skip_special_tokens=True)
    return summary


def summarize_articles():
    """Load raw articles, summarize each, and save feed with summaries"""
    
    output_dir = os.path.dirname(PROCESSED_DATA_PATH)
    os.makedirs(output_dir, exist_ok=True)

    try:
        with open(RAW_DATA_PATH, 'r', encoding='utf-8') as f:
            raw_articles = json.load(f)
    except FileNotFoundError:
        print(f"ERROR: Raw articles file not found at {RAW_DATA_PATH}. Run the scraper first.")
        return

    feed_articles = []
    
    print(f"Starting summarization for {len(raw_articles)} articles...")
    for i, article in enumerate(raw_articles):
        # Generate summary from full_text
        summary_text = summarize_bart(article["full_text"])
        
        # Create feed article (replace full_text with summary_text)
        feed_article = {
            "id": article["id"],
            "source_url": article["source_url"],
            "summary_text": summary_text,
            "image_url": article["image_url"]
        }
        feed_articles.append(feed_article)
        print(f"  > Summarized article {i+1}/{len(raw_articles)}")
    
    # Save feed articles 
    with open(PROCESSED_DATA_PATH, 'w', encoding='utf-8') as f:
        json.dump(feed_articles, f, indent=2, ensure_ascii=False)

    print(f"Saved {len(feed_articles)} summarized articles to {PROCESSED_DATA_PATH}")
    return feed_articles
