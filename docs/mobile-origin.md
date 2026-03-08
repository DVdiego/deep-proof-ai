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
