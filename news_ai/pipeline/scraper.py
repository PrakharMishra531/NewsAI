import requests
from bs4 import BeautifulSoup
import json 
import re
import os
from news_ai.core.config import RAW_DATA_PATH

def get_news_links():
    url = "https://timesofindia.indiatimes.com"
    response = requests.get(url)
    soup = BeautifulSoup(response.content, 'html.parser')
    links = []
    for anchor in soup.find_all('a', href=True):
        link = anchor['href']
        if '/articleshow/' in link:
            links.append(url + link if link.startswith('/') else link)
    print("urls fetched from TOI...")
    return links[:10]  



def scrape_news_content(urls):
    articles = []  # tuples: (text, image_url)
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36'
    }
    for url in urls:
        try:
            response = requests.get(url, headers=headers, timeout=10)
            if response.status_code != 200:
                print(f"Failed to retrieve content from {url}")
                continue

            soup = BeautifulSoup(response.content, 'html.parser')

            # --- Scrape article text ---
            article_body = soup.find('div', class_='_s30J clearfix')
            if not article_body:
                print(f"Could not find article content on {url}")
                continue

            article_text = article_body.get_text(separator='\n', strip=True)

            # --- Scrape image ---
            image_url = None
            image_div = soup.find('div', class_='wJnIp')
            if image_div:
                img_tag = image_div.find('img')
                if img_tag and img_tag.get('src'):
                    image_url = img_tag['src']
                    image_url = image_url.strip()

            articles.append((article_text, image_url))
            print(f"Scraped content for {url} ({len(article_text)} chars, image: {'✓' if image_url else '✗'})")

        except Exception as e:
            print(f"Error scraping {url}: {e}")

    print(f"news content scraped... ({len(articles)} articles)")
    return articles

def save_raw_articles():
    """Simple function to run pipeline and save raw articles"""
    os.makedirs('data/raw', exist_ok=True)
    
    news_links = get_news_links()
    raw_data = scrape_news_content(news_links)
    
    articles = []
    for i, (article_text, image_url) in enumerate(raw_data):
        url = news_links[i] if i < len(news_links) else f"news_{i}"
        match = re.search(r'/articleshow/(\d+)', url)
        article_id = f"toi_{match.group(1)}" if match else f"news_{i}"
        
        article_data = {
            "id": article_id,
            "source_url": url,
            "full_text": article_text,
            "image_url": image_url
        }
        articles.append(article_data)
    
    with open(RAW_DATA_PATH, 'w', encoding='utf-8') as f:
        json.dump(articles, f, indent=2, ensure_ascii=False)

    print(f"Saved {len(articles)} articles to {RAW_DATA_PATH}")
    return articles


 