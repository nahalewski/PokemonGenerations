import os
import subprocess
import json
import re
import concurrent.futures
CHANNEL_URL = "https://www.youtube.com/@Pokeli/playlists"
ROOT_DIR = "/Users/bennahalewski/Documents/PokeRoster/Pokemon Generations Official SoundTrack"
ALBUM_ART = "/Users/bennahalewski/Documents/PokeRoster/roster_iq/assets/music/album_art.png"
YT_DLP = "/opt/homebrew/bin/yt-dlp"
FFMPEG_BIN = "/opt/homebrew/bin/ffmpeg"
FFMPEG_DIR = "/opt/homebrew/bin"
MAX_WORKERS_PLAYLISTS = 2  # Reduced for stability
FAILURE_LOG = os.path.join(ROOT_DIR, "failures.log")

def clean_filename(name):
    # Keep alphanumeric, spaces, and basic punctuation
    return re.sub(r'[^\w\s\.\-]', '', name).strip()

def add_metadata(mp3_path, album_name):
    if not os.path.exists(ALBUM_ART): return
    temp_path = mp3_path + ".meta.mp3"
    try:
        cmd = [
            FFMPEG_BIN, "-y", "-i", mp3_path, "-i", ALBUM_ART,
            "-map", "0:0", "-map", "1:0", "-c", "copy",
            "-id3v2_version", "3",
            "-metadata", f"album={album_name}",
            "-metadata:s:v", "title=Album cover",
            "-metadata:s:v", "comment=Cover (front)",
            temp_path
        ]
        subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        os.replace(temp_path, mp3_path)
    except Exception as e:
        print(f"  [ERROR] Metadata fail: {mp3_path} | {e}")
    finally:
        if os.path.exists(temp_path): os.remove(temp_path)

def download_playlist(playlist_url, playlist_title):
    print(f"[PROCESS] Starting: {playlist_title}")
    folder_name = clean_filename(playlist_title) or playlist_url.split("=")[-1]
    target_dir = os.path.join(ROOT_DIR, folder_name)
    os.makedirs(target_dir, exist_ok=True)
    
    # Use a unique tmp dir per playlist to avoid file clashes
    tmp_dir = os.path.join(target_dir, ".tmp_dl")
    os.makedirs(tmp_dir, exist_ok=True)
    
    script_path = os.path.abspath(__file__)
    cmd = [
        YT_DLP,
        "--ffmpeg-location", FFMPEG_DIR,
        "--extract-audio", "--audio-format", "mp3", "--audio-quality", "0",
        "--output", f"{target_dir}/%(title)s.%(ext)s",
        "--no-continue", "--no-mtime",
        "--exec", f'python3 "{script_path}" --post-process "{{}}" "{playlist_title}"',
        "--paths", f"temp:{tmp_dir}",
        playlist_url
    ]
    
    env = os.environ.copy()
    env["PATH"] = f"{FFMPEG_DIR}:/usr/local/bin:/usr/bin:/bin:{env.get('PATH', '')}"
    
    try:
        subprocess.run(cmd, check=True, capture_output=True, text=True, env=env)
        print(f"[SUCCESS] Queue done: {playlist_title}")
    except Exception as e:
        print(f"[FAILURE] {playlist_title}: {e}")
        with open(FAILURE_LOG, "a") as f:
            f.write(f"Playlist: {playlist_title} | Error: {e}\n")
    finally:
        if os.path.exists(tmp_dir):
            try: import shutil; shutil.rmtree(tmp_dir)
            except: pass

def get_all_playlists():
    print("[INIT] Fetching playlists...")
    cmd = [YT_DLP, "--flat-playlist", "--dump-json", CHANNEL_URL]
    try:
        res = subprocess.run(cmd, capture_output=True, text=True, check=True)
        return [{"url": j["url"], "title": j.get("title", "Unknown")} 
                for j in [json.loads(l) for l in res.stdout.splitlines()]
                if j.get("_type") == "url" or "playlist" in j.get("url", "")]
    except Exception as e:
        print(f"[FATAL] Playlist fetch fail: {e}")
        return []

def main():
    if not os.path.exists(ROOT_DIR): os.makedirs(ROOT_DIR)
    open(FAILURE_LOG, "w").close()
    playlists = get_all_playlists()
    print(f"[INIT] Found {len(playlists)} playlists. Workers active.")
    with concurrent.futures.ThreadPoolExecutor(max_workers=MAX_WORKERS_PLAYLISTS) as executor:
        futures = [executor.submit(download_playlist, p["url"], p["title"]) for p in playlists]
        concurrent.futures.wait(futures)

import sys
if __name__ == "__main__":
    if "--post-process" in sys.argv:
        if len(sys.argv) >= 4:
            file_path, album_name = sys.argv[2], sys.argv[3]
            if file_path.endswith(".mp3"): add_metadata(file_path, album_name)
    else:
        main()
