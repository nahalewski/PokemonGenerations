# Pokémon Generations — Development Roadmap & Checklist

This checklist tracks the status of all proposed features and refinements for the **Pokémon Generations** ecosystem.

---

## ⏳ Pending Features (Not Started)
These items are queued for future development phases.
the idea of players having jobs for currency mabye reporting bugs like scavenger hunts to report the bugs found reward system or job called a lead debugger that pays a certain amount of poke dollars to send reports daily thats tracked by one login daily and two an apporved report by admin. for checks and blance system think of more jobs like lead programmer role where the player reports new features once implemented by the amdin they are sent a bonus plus their daily salary like the lead debugger. tracked by login daily and feature request sent daily approved by admin this needs to be a full system and a feature admin to get these speciallized report by the titled players who apply to the roles get interviewed off site by the admin thats in person by phone, text or email like in real life by me the admin bn200n. offer employees 401ks matching 6% make sure the bank matches to this sytem with a fully implemented tutorial feature for users called the banking handbook with a new generated image for the banking hand book to pop up a picture of a handbook in hi res pokemon gen v art style. and when the image is tapped or clicked if flips to have the text about the tutorial on it which the back side is just a white box the same size as the image generated. then implement the tutorial system. 

as admin label my self on my profile as leader developer and ceo of silph co. with a cool pokemon themed slogan with it where i make a heafty salary thats fitting of the economy system created and reflects real ceo slary to poke dollars and the 401k matching waht ever ceo 401ks get matched to and stock optins at the poke bank for me the ceo. research this implementation to mirror real world track players online time for their hourly rates of work to pay ratios but not by real hours in game as they cant stay logged in all day like a real job so there needs to be a smart ratio system of math generated for that. 



### 💰 Economy & Currency System
- [ ] **Core Currency Implementation**:
    - [ ] Initialize starting balance of 10,000 Poké Dollars for all players.
    - [ ] Add visible player currency indicator in the main UI.
- [ ] **Earning Logic**:
    - [ ] Implement payouts for Achievement milestones.
    - [ ] Implement CPU battle rewards generate a trainer sprite to pop up with a text box on screen with there message inside and how much the plyers winnings are in poke dollars (Only on wins, Limit 2 per day).
- [ ] **Admin Features**:
    - [ ] Add "Give Currency" tool in Pokémon Center Mac App for gifts/rewards.


### 👤 Profile & Social Expansion
- [ ] Fix profile picture display (currently defaulting to first letter).
- [ ] Anniversary tracking: Show "Time on Site" in Years/Months/Days format.
- [ ] **Achievement/Trophy System**:
    - [ ] Implement a 6-column scrollable grid for "Badges".
    - [ ] Badges should be hidden/empty until "Discovered" via gameplay.
    - [ ] Use high-fidelity assets from Pokémon GO asset repo for badge icons.
- [ ] **Player Marketplace**:
    - [ ] Add "For Sale Basket" in profiles using standard Poké Dollars pricing.
    - [ ] Enable live syncing for buying/selling between players.

### 🏥 Feature Modules
- [ ] **Battle Tower**:
    - [ ] 10 CPU trainer climb with incremental Poké Dollar rewards.
    - [ ] Large final prize for reaching the top.
    - [ ] **Roguelike Mode**: Limited resources, progress until total blackout.
- [ ] **Poké Mart**:
    - [ ] Spend Poké Dollars on utility items.
    - [ ] Define item rotation, pricing structure, and progression unlocks.
- [ ] **Pokémon Center**:
    - [ ] Design choice: Instant healing vs. Admin-led support hub.
    - [ ] Implement Healing, Rewards Inbox, and Event Claims.
- [ ] **The "PC" (User Storage)**:
- [ ] **Egg Hatching**:
    - [ ] Add floating "Egg" bubble in the PC UI with a semi-transparent background.
    - [ ] Implement 8-slot Incubator grid.
    - [ ] Time-based hatching tiers: 30m, 1h, 24h.
    - [ ] Automated transfer to PC upon hatching (Live server sync).

### 🖥️ Pokémon Center Mac App (Admin Improvements)
- [ ] **Global PC Box Manager (Home)**:
    - [ ] Fix PC box data fetch.
    - [ ] Implement combined Roster + PC Box viewer.
- [ ] **Stack Management & Monitoring**:
    - [ ] 5x3 service grid with real-time health meters (0-100%).
    - [ ] Color-coded health bars (Red to Green transition).
    - [ ] Live user count listing for the Public Web App.
- [ ] **Terminal Output Window**:
    - [ ] Enhance data formatting with color coordination (Green: OK, Yellow: Warning, Red: Critical).
    - [ ] Add search bar with color-coded filters and timestamps.

---

## 🚧 In Progress (Partially Implemented)
These items have core foundations but require further UI/UX refinement.

- [ / ] **Poké-Career & Employment System**:
    - [x] Smart 1:20 Online-Time-to-Salary Ratio.
    - [x] 6% 401k Matching & Retirement logic.
    - [x] Identity: CEO of Silph Co. privileges for `bn200n`.
    - [x] [NEW] `technical_documentation.md` (System Manual).
- [ / ] **Economy & Global Banking**:
    - [x] Global Fortune 500 Leaderboard.
    - [x] Dynamic Tax System (Linked to BTC/NASDAQ).
    - [x] Interactive Banking Handbook (3D Flip Animation).
- [ / ] **Social Identity Expansion**:
    - [x] Discovery-based Achievement Grid (6-column).
    - [x] Account Anniversary Tracking (Y/M/D).
    - [x] For Sale Basket & Marketplace integration.
- [ / ] **Pokémon Center Mac App (Admin Refresh)**:
    - [x] Threaded Audit Log.
    - [ / ] 5x3 service grid with real-time health meters (0-100%).
    - [ / ] Administrative Terminal with color-coded logs and search filters.

### ✅ Completed Achievements
These features are fully implemented, secured, and deployed.

### 💰 Aevora Financial Suite & Career Portal
- [x] **Global Market Hours**: Enforced real-world Wall Street hours (9:30 AM — 4:00 PM ET) for all users.
- [x] **Uncapped Back-Pay**: Implemented server-side logic to catch up on missed salary payments during server downtime.
- [x] **White Pages Job Listing**: A high-fidelity career portal for professional path selection and daily salaries.
- [x] **Fortune 500 Leaderboard**: Social ranking system based on global Net Worth (Cash + Bank + Portfolio).
- [x] **Financial Prospectus & Manual**: Created a dedicated `Stock PDF` vault with comprehensive guides and API specs.

### 🎵 Music Player & Album Art
- [x] **Unique Artwork Deployment**: Replaced duplicate `cover.png` files with high-fidelity, AI-generated art for Gym Leaders, Legendaries, and more.
- [x] **Master Ball Synthwave Visualizer**: Implemented a futuristic Master Ball-themed record asset for all Synthwave tracks.
- [x] **Spinning Animation & Pulse**: Enhanced the vinyl player's rotation and pulse logic to work seamlessly with new high-res assets.

### 🎒 Bag & Inventory System
- [x] **New Dedicated Bag Screen**: Full-screen searchable grid for high-fidelity inventory management.
- [x] **Enhanced Item Actions**: Interactive action sheets supporting **USE**, **SELL** (for Poké Dollars), and **GIFT** (Social integration).
- [x] **Bag Preview**: Profile screen now features a "top-shelf" preview of recent items with a link to the full inventory.

### ⚔️ Battle Infrastructure & Admin
- [x] **Threaded Audit Log**: Redesigned Mac Admin App log with smart alignment (Player on Left, CPU on Right) and color-coded bubbles.
- [x] **Visual Branding & Tags**: Integrated "CPU" badges and profile avatar support into every battle event log.
- [x] **Battle Replay System**: Server-side storage for battle recordings with a 7-day TTL and 10-replay FIFO limit per user.
- [x] **Replay Theatre**: Dedicated UI for browsing and watching recent matches across the community.
- [x] **Real-Time Weather Sync**: GPS-based weather effects and atmospheric lighting integrated into the battle arena.
- [x] **Acoustic Sync**: 1,000+ soundtrack tracks synchronized for Night-time variants.
- [x] **Visual Spectate Mode**: Admins can visually monitor live matches via the Battle Monitor.

### 🛡️ Core Infrastructure & Security
- [x] **DevOps Compliance**: Automated `enforce_standards.py` script ensures codebase remains free of unauthorized gacha/P2W patterns.
- [x] **Secure API Configuration**: Moved sensitive keys (OWM) to a Git-ignored config file (`api_keys.dart`).
- [x] **Media Exclusions**: Established global `.gitignore` rules for `*.mp3`, `*.wav`, and `*.replay` assets.

### 📰 News & Communication
- [x] **Automated News Generation**: News updates are automatically parsed and displayed from dated markdown files in the public directory.
- [x] **Online/Offline User Tracking**: Real-time counters for active trainers implemented in the Admin Dashboard.
## v3.0.0+1 Implementation Checklist

- [x] Align production ports to `8191` (Web App), `8192` (Exchange), and `8193` (Backend)
- [x] Repair Pokemon Center Admin launcher constant mismatches
- [x] Add Aevora Exchange `build_web.sh`
- [x] Add Pokemon Center Admin AI Operations Suite tab
- [x] Add Ollama status, install, and chat support
- [x] Add 5x5 automation grid with popup workflows
- [x] Add backend AI routes for automation execution
- [x] Add daily login briefing generation with inbox-safe delivery logic
- [x] Add Silph-Gold trade confirmation mail automation
- [x] Add low-vault balance alert automation
- [x] Update release changelog and devops changelog files
- [x] Update shared news payload for the production rollout
- [ ] Build and verify all production artifacts
- [ ] Generate and verify the stock-market system PDF
- [ ] Push the rollout branch to GitHub
