import requests
from bs4 import BeautifulSoup
import redis

# Connect to Redis (assumes Redis is running on localhost at port 6379)
r = redis.Redis(host='localhost', port=6379, db=0)


# Get the top 3 latest news links from Times of India
def get_news_links():
    cache_key = 'news_links'

    # Checking if cached links exist
    cached_links = r.get(cache_key)

    if cached_links:
        print("Returning cached news links...")
        return eval(cached_links)

    url = "https://timesofindia.indiatimes.com"
    response = requests.get(url)
    soup = BeautifulSoup(response.content, 'html.parser')
    links = []
    for anchor in soup.find_all('a', href=True):
        link = anchor['href']
        if '/articleshow/' in link:
            links.append(url + link if link.startswith('/') else link)
    print("urls fetched from TOI...")

    # Caching the result in Redis for 1 hour (3600 seconds), storing it as a string
    r.setex(cache_key, 3600, str(links[:3]))
    return links[:3]  # Get the top 3 links




def scrape_news_content(urls):
    articles = []
    cache_ttl = 3600  # Fixed TTL of 1 hour (3600 seconds)
    
    for url in urls:
        # Checking if the article content is cached in Redis
        cached_content = r.get(url)
        if cached_content:
            print(f"Found cached content for {url}")
            articles.append(cached_content.decode('utf-8'))
            continue
        
        # Scraping the article if not cached
        response = requests.get(url)
        if response.status_code != 200:
            print(f"Failed to retrieve content from {url}")
            continue

        soup = BeautifulSoup(response.text, 'html.parser')
        article_body = soup.find('div', class_='_s30J clearfix')

        if not article_body:
            print(f"Could not find article content on {url}")
            continue

        paragraphs = article_body
        article_text = "\n".join([p.get_text() for p in paragraphs])
        articles.append(article_text)

        # Caching the scraped content in Redis with an expiration time (TTL)
        r.setex(url, cache_ttl, article_text)
        print(f"Cached content for {url}")

    print("news content scraped...")
    return articles



