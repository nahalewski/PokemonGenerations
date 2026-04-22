# Pokemon Generations Platform — Features & Web App Summary

## Web App Overview

Pokemon Generations is a cross-platform Pokemon roster management, battle strategy, banking, and social platform
built with Flutter (web, Android, iOS) and supported by companion tools including Pokemon Center Admin for macOS
and Aevora Exchange for market workflows. The stack is powered by a high-performance Node.js/Express backend.
The UI delivers a premium, dark futuristic aesthetic with glassmorphism interactions, animated Poke Ball
backgrounds, and a high-fidelity transparent HUD for battle interaction.

---

## Feature Breakdown

### Platform Suite
- **Pokemon Generations** — main trainer app across web and mobile
- **Pokemon Center Admin** — release, log, and service control center for operators
- **Aevora Exchange** — economy, market, and banking companion experience
- **pokemon_generations_backend** — live backend for auth, social systems, battle sync, and banking persistence

### Authentication & Profiles
- Local username/password authentication (bcrypt-hashed, stored per-user JSON on the server)
- Persistent login with SharedPreferences session token
- Profile picture upload (multer, served from `/profile-pics`)
- Display name, username, and cloud-synced profile data
- Profile screen with avatar, stats, and social actions

---

### Roster & Team Management
- Add any Pokémon from the full National Dex (queried via bundled Showdown Pokédex JSON)
- Per-Pokémon move selection with level-up & learnable move data from Showdown learnsets
- Held item assignment (54 bundled item sprites)
- Persistent local storage via Drift ORM (SQLite on native, IndexedDB on web)
- Cloud sync: push/pull roster and teams to/from the backend server
- Multiple named teams per user

---

### Battle System
- **CPU Battle** — fight a randomly-selected opponent from your roster pool
- **Online PvP** — real-time multiplayer battle via backend session IDs and polling
- **Turn-based combat** — Move selection, bag usage, Pokémon switching, run action
- **High-Fidelity Battle HUD** — Transparent glassmorphism interaction menu with glowing selection states and holographic UI elements (v1.1.0)
- **Visual Spectator Arena** — Dedicated real-time monitoring window with active Pokémon sprites, animated HP synchronization, and live stadium feed (Admin Console)
- Damage calculation (Enhanced Gen 9 formula: base power × type effectiveness × stat modifiers)
- Best-lead suggestion (Algorithmic; picks the optimal opener vs opponent's lead)
- Battle FX service — move sounds mapped from Cobblemon OGG assets, particle textures per type
- Gamepad support (analog / D-pad navigation, button mapping with visual input sprites)
- Background battle music streamed from the server (128 battle tracks, no longer bundled)

---

### Team Analysis
- Full type coverage report (offensive and defensive)
- Individual Pokémon stat summaries (HP, Atk, Def, SpAtk, SpDef, Speed)
- Move type distribution across the team
- Weakness audit and recommended counter-types
- Local offline analysis using Showdown type-chart data when server is unavailable
- Battle history viewer (past match results and move sequences)

---

### Social & Multiplayer
- User directory (search + follow)
- Friend requests (send, accept, reject)
- Global live chat (filtered for profanity, 100-message rolling window)
- **High-Resolution Emoji System** — Native Pokémon emoji support in chat via `:name:` triggers
- Admin broadcast messages (server-wide announcements)
- PvP challenge system — send/receive battle invites with expiry timers
- User presence tracking (online/idle/offline states)
- Gift system — send items to friends; cloud-synced gift inbox

---

### Graphics & Visuals
- **Static mode** — Pokémon GO–style PNG icons (fast, low memory)
- **Animated mode** — Smogon battle GIFs (gen5ani sprites)
- **High-Fidelity 3D mode** — GLB models via the `model_viewer_plus` package (Cobblemon / Pokémon 3D API)
- Per-profile graphics toggle in Settings
- Battle background images per arena (14+ battle areas)
- 3D model viewer embedded inline in roster and battle screens

---

### Music Player (MusicS 2.0)
- **Premium Soundtrack Library** — 128 battle and region tracks streamed with zero-latency buffering
- **Regional Cover Art** — Custom high-fidelity artwork for Alola, Galar, Hoenn, Kalos, Sinnoh, and Unova
- **Responsive Experience** — Dynamic grid adapts to 8 columns on Desktop and 3 columns on Android
- **Fluid Scrolling** — Elastic, smooth scrolling physics optimized for mobile touchscreens
- **Visualizer Suits** — Multiple visual modes (Vinyl, Poké Ball Record, Synthwave) synced to the beat
- Sequential and shuffle playback with background persistence
- Hidden access via long-press on settings version chip

---

### Game Selection
- Supports all main-series Pokémon games (Gen 1–9+)
- Region filtering (Kanto, Johto, Hoenn, Sinnoh, Unova, Kalos, Alola, Galar, Paldea, etc.)
- Persisted selection; drives region-specific data filtering throughout the app
- Swap active game from Settings at any time

---

### Settings & Configuration
- Custom backend URL (self-host on any machine)
- Backend connectivity test
- Auto-check for APK updates on launch (Android-only OTA via backend `/app-update` endpoint)
- Manual APK update download with background progress (foreground notification via `UpdateDownloadListener`)
- Offline fallback mode (uses local heuristics when server is unreachable)
- Manual cloud data sync
- Bug / Feature / Feedback report dialog (sends to server; falls back to local log via `LoggingService`)
- Change log viewer (rendered Markdown of all version history)
- Graphics fidelity selector (Static / Animated / 3D)
- Clear cache (wipes local Drift database, SharedPreferences, temp files)

---

### APK Delivery (Android)
- Backend serves the latest built APK from `build/app/outputs/flutter-apk/`
- Version check at launch via `/app-update` endpoint (compares pubspec version + build number)
- Inline download progress bar; `MethodChannel` triggers the system package installer
- "Allow unknown sources" permission flow with deep-link to Android settings
- Web users see a promotion banner linking to `github.com/nahalewski/PokemonGenerations/releases`

---

### Asset Delivery System (new)
- On first launch (Android / iOS), shows a **full-screen asset download screen** after login:
  - Fetches `/api/asset-manifest` from the backend
  - Downloads and extracts any new or updated zip packages to the app's documents directory
  - Per-package and overall progress bars; Skip button for optional packages
- Subsequent launches: silent background check via `isFirstAssetLaunchProvider`
- Asset packages currently available via the backend:
  - `pokemon_icons_templarian` — 252 clean Pokemon PNG icons
  - `pokemon_icons_fraserxu` — 151 Gen-1 retro icons
  - `pokemmo_sprites` — PokeMMO web battle sprites
- Audio streams directly from `/assets/battle-audio/:filename` (no download required)
- Admin endpoint `POST /admin/build-asset-packages` re-zips source directories on demand

---

### Platform Support
| Platform | Auth | Battle | Music | Asset Download | APK Update |
|----------|------|--------|-------|----------------|------------|
| Android  | ✓    | ✓      | ✓ (stream) | ✓         | ✓          |
| iOS      | ✓    | ✓      | ✓ (stream) | ✓         | —          |
| Web      | ✓    | ✓      | ✓ (stream) | — (skipped) | — (link)  |

---

### Community Asset Credits
| Source | Usage |
|--------|-------|
| Smogon / pokemon-showdown | Battle sprites, move data, learnsets, items |
| Cobblemon | 3D model textures, move sound OGGs, particle textures |
| Pokémon 3D API | Optimized GLB battle models |
| PokeMiners | Pokémon GO staged PNG assets |
| TCGDex | Global TCG card image database |
| Poke-Types | Type icons and effectiveness chart data |
| Kotlin-Pokedex | UI component references |
| GraphQL-Pokemon | Structured data staging layer |
| Trainer Central | Futuristic UI design references |
| Templarian / slack-emoji-pokemon | 252 Pokemon icon set (downloaded package) |
| fraserxu / slack-pokemon-emoji | 151 Gen-1 retro icons (downloaded package) |
| maierfelix / PokeMMO | Web battle sprites and tilesets |
| serena2341 / whos-that-pokemon | Who's That Pokemon silhouette engine |

---

### Backend API Summary (Node.js / Express, port 8193)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Server status + latest APK metadata |
| GET | `/app-update` | APK version check |
| POST | `/register` | Create account |
| POST | `/login` | Authenticate |
| POST | `/auth/profile-picture` | Upload avatar |
| GET | `/pokemon` | Full Pokédex (Showdown data) |
| GET | `/moves` | Full move list |
| GET | `/items` | Item list |
| GET | `/roster` | User's saved roster |
| POST | `/roster` | Save roster |
| GET/POST | `/presets` | Team presets |
| POST | `/report` | Submit bug/feature/feedback |
| POST | `/analyze-team` | Server-side team analysis |
| POST | `/best-lead` | Best lead recommendation |
| POST | `/damage-range` | Damage calculation |
| GET | `/admin/battles/live` | Real-time battle telemetry (active pokemon + HP) |
| GET | `/admin/music/status` | Music listener analytics and duration tracking |
| POST | `/admin/news-update` | Submit news with automated date-archiving |
| GET | `/admin/telemetry/battles` | historical battle telemetry logs |
| GET | `/social/users` | User directory |
| GET | `/social/friends` | Friend list |
| POST | `/social/friend-request` | Send friend request |
| POST | `/social/friend-accept` | Accept friend request |
| GET/POST | `/social/chat` | Global live chat |
| GET/POST | `/social/broadcast` | Admin broadcast |
| POST | `/social/challenge` | Send PvP challenge |
| GET | `/social/challenges/pending` | Pending challenges |
| GET | `/api/asset-manifest` | Asset package manifest |
| GET | `/api/asset-packages/:file` | Download asset zip |
| POST | `/admin/build-asset-packages` | Re-build asset zips |
| GET | `/assets/battle-audio/:file` | Stream battle music MP3 |
| GET | `/assets/pokemon-icons/templarian/:file` | Serve Templarian icon |
| GET | `/assets/pokemon-icons/fraserxu/:file` | Serve fraserxu icon |
| GET | `/app/*` | Serve Flutter web build |
| GET | `/downloads/apk/*` | Serve APK file |
