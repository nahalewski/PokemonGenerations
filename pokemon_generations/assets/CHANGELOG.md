# Changelog

All notable changes to the Pokemon Generations project will be documented in this file.

## [3.0.0+1] - 2026-04-21
### Added
- **AI Operations Suite**: Added a dedicated AI tab to the Pokemon Center Admin mac app with local Ollama chat, model controls, and a 5x5 automation grid.
- **Silph-Gold Union Automations**: Added admin-triggered workflows for daily briefings, home news updates, changelog generation, log summaries, checklist refreshes, market copy, and mail campaign drafting.
- **Daily Login Briefings**: Added backend-generated daily login briefings that can be delivered to player inboxes with per-day dedupe protection.
- **Inbox Alert Automation**: Added AI-assisted trade confirmation mail and low-vault balance alerts for banking and stock market activity.
- **Local AI Runtime Support**: Added backend endpoints for Ollama status checks, model installation, chat completions, and automation execution.

### Changed
- **Unified Production Ports**: Standardized the production stack to Main Site `8080`, Admin Web `8191`, Aevora Exchange `8192`, backend `8193`, and assets `8197`.
- **Command Center Launch Flow**: Pokemon Center Admin now builds and serves the Main Site, Admin Web, and Aevora Exchange alongside the unified Node backend.
- **Player Home Flow**: The Home screen can now fetch a daily login briefing after authentication when no live global broadcast is already active.
- **Version Alignment**: Production packages were aligned under `v3.0.0+1`, including the web dashboard release metadata.

### Fixed
- **Admin Launcher Compile Blockers**: Repaired stale launcher references that still pointed at removed `webAppPort` and `dashboardPort` constants.
- **Cloudflare Secret Handling**: Replaced hardcoded Cloudflare token usage with environment-backed configuration in the admin app.
- **Main App Networking Client**: Cleaned up a malformed duplicate `checkHealth` definition in the shared API client.
- **Deployment Tooling**: Added a missing `build_web.sh` pipeline for Aevora Exchange so the command center can build all web surfaces consistently.
