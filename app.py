from flask import Flask, request, jsonify
import asyncio
import re
from urllib.parse import urljoin, urlparse
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.common.exceptions import WebDriverException
from lxml import html

app = Flask(__name__)

async def fetch_with_selenium(url):
    options = Options()
    options.add_argument("--headless")
    options.add_argument("--disable-gpu")
    options.add_argument("--disable-extensions")
    options.add_argument("--disable-images")
    options.add_argument("--disable-popup-blocking")
    options.add_argument("--blink-settings=imagesEnabled=false")
    driver = None
    try:
        driver = webdriver.Chrome(options=options)  # Убедитесь, что ChromeDriver установлен и доступен
        driver.get(url)
        await asyncio.sleep(2)
        content = driver.page_source
        return content
    except WebDriverException as e:
        print(f"Ошибка Selenium при загрузке {url}: {e}")
        return None
    finally:
        if driver:
            driver.quit()

async def search_page(url, keyword, depth, max_pages, current_depth, visited, results):
    if url in visited or len(results) >= max_pages or current_depth > depth:
        return

    visited.add(url)
    content = await fetch_with_selenium(url)
    if content:
        try:
            tree = html.fromstring(content)
            page_text = tree.text_content()

            if keyword.lower() in page_text.lower():
                sentences = re.split(r'(?<!\w\.\w.)(?<![A-Z][a-z]\.)(?<=\.|\?)\s', page_text)
                for sentence in sentences:
                    if keyword.lower() in sentence.lower() and len(results) < max_pages:
                        result = {
                            "context": sentence.strip(),
                            "title": tree.findtext(".//title") or "No Title",
                            "url": url
                        }
                        if result not in results:
                            results.append(result)

            if current_depth < depth:
                base_url = urlparse(url)
                for a in tree.xpath(".//a[@href]"):
                    link = urljoin(url, a.get("href"))
                    parsed_link = urlparse(link)
                    if parsed_link.netloc == base_url.netloc:
                        await search_page(link, keyword, depth, max_pages, current_depth + 1, visited, results)
        except Exception as e:
            print(f"Ошибка при обработке страницы {url}: {e}")

async def search_website(url, keyword, depth, max_pages):
    visited = set()
    results = []
    await search_page(url, keyword, int(depth), int(max_pages), 1, visited, results)
    return results

@app.route('/search', methods=['POST'])
async def search():
    data = request.get_json()
    url = data['url']
    keyword = data['keyword']
    depth = data['depth']
    max_pages = data['max_pages']

    results = await search_website(url, keyword, depth, max_pages)
    return jsonify(results)

@app.route('/')
def index():
    return app.send_static_file('index.html')

if __name__ == '__main__':
    app.run(debug=True, host="0.0.0.0", port=8080) # Для Render.com
