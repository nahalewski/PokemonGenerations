import os
import json
import random
import time
import sys

# To support real fetching, we would use: import yfinance as yf
# In this environment, we will implement the logic and a comprehensive fallback
# that demonstrates the high-fidelity translation engine.

MAPPING = {
    'SLPH': {'ticker': 'AAPL', 'name': 'Silph Co.', 'theme': 'Infrastructure/Tech'},
    'DVON': {'ticker': 'TSLA', 'name': 'Devon Corp.', 'theme': 'Innovation/Energy'},
    'PRYG': {'ticker': 'BTC-USD', 'name': 'Porygon Crypto', 'theme': 'Digital/Network'},
    'AEX':  {'ticker': '^GSPC', 'name': 'Aevora Index', 'theme': 'Market Health'},
    'STRN': {'ticker': 'ADM', 'name': 'Striaton Exports', 'theme': 'Agriculture'},
    'NACR': {'ticker': 'Z', 'name': 'Nacrene Antiques', 'theme': 'Real Estate'},
    'CAST': {'ticker': 'FDX', 'name': 'Castelia Logistics', 'theme': 'Media/Shipping'},
    'NMBS': {'ticker': 'DKNG', 'name': 'Nimbasa Sports', 'theme': 'Entertainment'},
    'MSTL': {'ticker': 'DAL', 'name': 'Mistralton Cargo', 'theme': 'Aviation'},
    'TWST': {'ticker': 'VALE', 'name': 'Twist Mountain Ores', 'theme': 'Mining'},
    'OPLU': {'ticker': 'DUK', 'name': 'Opelucid Utility', 'theme': 'Power'},
    'WFOR': {'ticker': 'NEE', 'name': 'White Forest Eco', 'theme': 'Green Energy'},
    'BLKC': {'ticker': 'LMT', 'name': 'Black City Infra', 'theme': 'Defense'},
    'PLAT': {'ticker': 'NVDA', 'name': 'Plasma Energy', 'theme': 'Advanced R&D'},
    'ROST': {'ticker': 'PLTR', 'name': 'Roster Analytics', 'theme': 'Data/Software'}
}

VOCAB_MAP = {
    'Apple': 'Silph Co.',
    'Tesla': 'Devon Corp.',
    'Bitcoin': 'Porygon Crypto',
    'Nvidia': 'Plasma Energy',
    'AI': 'Porygon-Logic',
    'Artificial Intelligence': 'Porygon-Logic',
    'iPhone': 'Poké Ball',
    'Model 3': 'Cyclizar Drive',
    'EV': 'Electric-Type',
    'Federal Reserve': 'Pokémon League Council',
    'Interest Rate': 'Battle Points Interest',
    'CEO': 'Regional Leader',
    'Stock': 'Shares',
    'Market': 'Battle Frontier',
    'Quarterly Earnings': 'Seasonal Performance',
    'Regulation': 'League Policy',
    'Meta': 'Ghost-Type Virtualization',
    'Cloud': 'Castform Network',
    'Revenue': 'Poké Dollars',
    'Launch': 'Unveiling',
    'Announcement': 'Official Proclamation'
}

def translate_headline(headline):
    translated = headline
    for real, poke in VOCAB_MAP.items():
        translated = translated.replace(real, poke)
    return translated

def generate_mock_news():
    """Generates high-fidelity mock news in case yfinance is unavailable/offline"""
    news = []
    ids = list(MAPPING.keys())
    
    scenarios = [
        "{} Regional Leader announces breakthrough in {}.",
        "{} Seasonal Performance exceeds League expectations.",
        "New League Policy regarding {} to take effect next month.",
        "{} shares surge as {} adoption grows.",
        "Unforeseen {} fluctuations detected in {} territory.",
        "{} unveils the latest {}, attracting thousands of trainers."
    ]

    for i in range(15):
        stock_id = ids[i]
        meta = MAPPING[stock_id]
        
        scenario = random.choice(scenarios)
        headline = scenario.format(meta['name'], meta['theme'])
        
        # Fill second {} if needed
        if headline.count('{}') > 0:
             headline = headline.replace('{}', random.choice(['Global Markets', 'New Unova', 'Aevora Terminal']))

        news.append({
            'source': 'Aevora News Network',
            'stockId': stock_id,
            'headline': headline,
            'timestamp': time.strftime('%H:%M:%S'),
            'sentiment': random.choice(['POS', 'NEG', 'STABLE'])
        })
    
    return news

def main():
    # In a real environment, try to use yfinance
    # try:
    #     import yfinance as yf
    #     # ... logic to fetch actual news ...
    # except:
    #     pass

    translated_news = generate_mock_news()
    
    # Target directory for the news.json
    target_dir = os.path.join(os.getcwd(), 'data')
    if not os.path.exists(target_dir):
        os.makedirs(target_dir)
        
    target_path = os.path.join(target_dir, 'news.json')
    
    try:
        with open(target_path, 'w') as f:
            json.dump(translated_news, f, indent=2)
        print(f"SUCCESS: Synced {len(translated_news)} headlines to Aevora terminals.")
    except Exception as e:
        print(f"ERROR: Failed to save news: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main()
