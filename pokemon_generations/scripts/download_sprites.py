import json
import os
import urllib.request
import concurrent.futures
import time

DATABASE_PATH = 'assets/pokemon_database.json'
OUTPUT_DIR = 'assets/pokemon_images'
BASE_IMAGE_URL = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/{id}.png'
FALLBACK_IMAGE_URL = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/{id}.png'

def download_image(pokemon_id):
    output_path = os.path.join(OUTPUT_DIR, f"{pokemon_id}.png")
    
    # Skip if already exists
    if os.path.exists(output_path):
        return f"Skipped {pokemon_id}"

    # Try official-artwork first
    url = BASE_IMAGE_URL.format(id=pokemon_id)
    try:
        urllib.request.urlretrieve(url, output_path)
        return f"Success {pokemon_id} (Official)"
    except Exception as e:
        # Try fallback standard sprite
        url_fallback = FALLBACK_IMAGE_URL.format(id=pokemon_id)
        try:
            urllib.request.urlretrieve(url_fallback, output_path)
            return f"Success {pokemon_id} (Standard Fallback)"
        except Exception as e2:
            return f"Failed {pokemon_id}: {e2}"

def main():
    if not os.path.exists(OUTPUT_DIR):
        os.makedirs(OUTPUT_DIR)

    if not os.path.exists(DATABASE_PATH):
        print(f"Error: Database file not found at {DATABASE_PATH}")
        return

    with open(DATABASE_PATH, 'r') as f:
        data = json.load(f)
        results = data.get('results', [])

    print(f"Starting download for {len(results)} pokemon...")
    
    # Extract IDs from URLs
    ids = []
    for entry in results:
        url = entry['url']
        # e.g. https://pokeapi.co/api/v2/pokemon/1/
        pokemon_id = url.strip('/').split('/')[-1]
        ids.append(pokemon_id)

    # Use ThreadPoolExecutor for faster downloads
    start_time = time.time()
    with concurrent.futures.ThreadPoolExecutor(max_workers=20) as executor:
        completed = 0
        for info in executor.map(download_image, ids):
            completed += 1
            if completed % 50 == 0:
                print(f"Progress: {completed}/{len(ids)}...")

    end_time = time.time()
    print(f"Finished in {end_time - start_time:.2f} seconds.")

if __name__ == "__main__":
    main()
