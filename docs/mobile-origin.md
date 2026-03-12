# ai-authenticity-mobile

Mobile app for local image authenticity analysis.

## Current Scope
- Image analysis only in v1
- On-device feature extraction
- On-device inference
- No image upload for analysis
- Supabase only for licensing, quota, purchase restore, and basic anti-abuse

## Official Stack
- Flutter for UI and product layer
- Shared native core for analysis runtime
- Platform wrappers for iOS and Android

## Repository Structure
- `app/`: Flutter app layer and runtime-facing contracts
- `native/`: native core and platform wrappers
- `model-package/`: release-ready model artifacts and metadata
- `docs/`: product, business, and technical documentation
- `supabase/`: schema and function drafts for entitlement/quota control
- `tools/`: support scripts for packaging and validation

## Current Phase
The project is moving from definition into implementation planning with the stack now fixed.

## Quick Commands
- `make ios-dev`: run on a connected physical iPhone in development mode with safe local purchase mocks
- `make ios-profile`: run on a connected physical iPhone in profile mode, closer to real device behavior and forcing the real store path
- `make ios-store`: run on a connected physical iPhone while forcing the real store flow in debug
- `make ios-release`: build a release IPA, requires `SUPABASE_ANON_KEY`
- `make macos-dev`: run the macOS development host
- `make ios-sim-dev`: run the iOS simulator development host
