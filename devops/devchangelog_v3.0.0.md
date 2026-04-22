# DevOps Changelog v3.0.0+1

Updated: 2026-04-21

## Rollout Summary
- Unified the local production service layout around `8080` for the Main Site, `8191` for Admin Web, `8192` for Aevora Exchange, `8193` for the unified Node backend, and `8197` for the asset server.
- Restored the Pokemon Center Admin launcher so the macOS command center can build and start all web targets and backend systems from one place.
- Added a local AI runtime integration layer powered by Ollama for changelog generation, player-facing briefings, inbox automation, and operational drafting.

## AI Operations
- Added a new AI Operations Suite tab to the Pokemon Center Admin mac app.
- Added local model status checks, recommended lightweight model installation, and a live chat panel for operator use.
- Added a 5x5 automation grid with modal forms for daily briefings, release notes, home news sync, alert scans, and content-generation workflows.

## Player Messaging
- Added daily login briefing generation with inbox-safe dedupe logic.
- Added Silph-Gold Union trade execution mail hooks.
- Added low-vault balance alert hooks tied to banking balance changes.

## Security / Ops Notes
- Cloudflare cache purge now reads credentials from environment variables instead of relying on committed secrets.
- Recommended local model target for the M1 Pro 32 GB machine profile: `qwen2.5:3b-instruct`.
- Aevora Exchange now includes its own web build script so it can participate in the same production launcher workflow as the other web apps.

## Remaining Validation
- Build and verify the production web artifacts for all three surfaces.
- Build the macOS admin app and the Android APK outputs.
- Generate and review the stock-market system PDF deliverable.
