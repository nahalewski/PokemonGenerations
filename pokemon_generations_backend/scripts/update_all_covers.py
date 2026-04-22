import os
import subprocess
import re

ROOT_DIR = "/Users/bennahalewski/Documents/PokeRoster/Pokemon Generations Official SoundTrack"
ART_DIR = "/Users/bennahalewski/Documents/PokeRoster/roster_iq/assets/music/themes"
FFMPEG = "/opt/homebrew/bin/ffmpeg"

# Mapping theme names to their generated image filename
THEME_ART = {
    "Paldea": "paldea_ost_cover_1776663818029.png",
    "Lumiose": "lumiose_ost_cover_1776663839536.png",
    "Galar": "galar_ost_cover_1776663935047.png",
    "Alola": "alola_ost_cover_1776663957405.png",
    "Hoenn": "hoenn_ost_cover_1776663991631.png",
    "Sinnoh": "sinnoh_ost_cover_1776664017624.png",
    "Kalos": "kalos_ost_cover_1776664047593.png",
    "Unova": "unova_ost_cover_1776664073067.png",
    "Retro": "retro_ost_cover_v2_1776664102160.png",
    "Origins": "origins_ost_cover_1776664130174.png",
    "Go": "pogo_ost_cover_1776664161557.png",
    "FallBack": "/Users/bennahalewski/Documents/PokeRoster/roster_iq/assets/music/album_art.png"
}

# Mapping folder keywords to themes
FOLDER_MAPPING = {
    "Scarlet": "Paldea", "Violet": "Paldea",
    "Legends Z-A": "Lumiose",
    "Sword": "Galar", "Shield": "Galar",
    "UltraSun": "Alola", "Ultra Moon": "Alola", "Sun Moon": "Alola",
    "Omega Ruby": "Hoenn", "Alpha Sapphire": "Hoenn", "ORAS": "Hoenn", "Hoenn": "Hoenn", "RSE": "Hoenn",
    "Brilliant Diamond": "Sinnoh", "Shining Pearl": "Sinnoh",
    "XY": "Kalos", "X/Y": "Kalos",
    "Black2": "Unova", "White2": "Unova",
    "4-Bit": "Retro", "8-Bit": "Retro", "Lets Go": "Retro",
    "Origins": "Origins",
    "Go Battle": "Go"
}

def get_art_for_folder(folder_name):
    for kw, theme in FOLDER_MAPPING.items():
        if kw.lower() in folder_name.lower():
            art_file = THEME_ART.get(theme)
            if art_file:
                path = os.path.join(ART_DIR, art_file)
                if os.path.exists(path): return path
    return THEME_ART["FallBack"]

def update_mp3(mp3_path, art_path, album_name):
    temp_path = mp3_path + ".new.mp3"
    try:
        cmd = [
            FFMPEG, "-y", "-i", mp3_path, "-i", art_path,
            "-map", "0:0", "-map", "1:0", "-c", "copy",
            "-id3v2_version", "3",
            "-metadata", f"album={album_name}",
            "-metadata:s:v", "title=Album cover",
            "-metadata:s:v", "comment=Cover (front)",
            temp_path
        ]
        subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        os.replace(temp_path, mp3_path)
        return True
    except Exception as e:
        print(f"    [ERR] {e}")
        if os.path.exists(temp_path): os.remove(temp_path)
        return False

def main():
    folders = [f for f in os.listdir(ROOT_DIR) if os.path.isdir(os.path.join(ROOT_DIR, f))]
    print(f"Starting batch update for {len(folders)} folders...")
    
    total_updated = 0
    for folder in sorted(folders):
        art_path = get_art_for_folder(folder)
        folder_path = os.path.join(ROOT_DIR, folder)
        mp3s = [f for f in os.listdir(folder_path) if f.endswith(".mp3")]
        
        if not mp3s: continue
        
        print(f"[PROCESS] {folder} ({len(mp3s)} songs) with {os.path.basename(art_path)}")
        for mp3 in mp3s:
            if update_mp3(os.path.join(folder_path, mp3), art_path, folder):
                total_updated += 1
                
    print(f"\n[DONE] Successfully updated {total_updated} songs with custom artwork.")

if __name__ == "__main__":
    main()
