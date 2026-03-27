# Next Steps

## Completed Recently

1. Replaced `pdf_text` with `flutter_pdf_text` to resolve Android build incompatibility on modern Gradle
2. Replaced `pdf_render` with `pdf_render_maintained` to restore modern Android build compatibility
3. Added lightweight Korean/English localization without introducing app-wide `intl` localization infrastructure
4. Added first-launch language selection with local persistence
5. Added first-launch privacy onboarding after language selection
6. Expanded localization coverage across the main user flow and lower-level helper copy
7. Added safer KRW/USD handling with manual currency selection when detection is uncertain
8. Added a lightweight Home calendar view with mixed-currency-safe summary handling
9. Added widget-test coverage for the Home calendar and mixed-currency summary UX
10. Connected crop/rotate review controls to real OCR/parsing preprocessing
11. Connected the existing Settings donation buttons to a real one-time store purchase flow with `in_app_purchase`
12. Added a lightweight in-app About section inside Settings
13. Prepared a Play Console brand/listing package with editable SVG assets, listing copy, and privacy policy drafts
14. Switched the global/default brand to `PaperBell` while keeping `담아알림 - 문서 리마인더` as the Korean localized listing
15. Added a static privacy-policy hosting package under `site/privacy/` for public Play Console URLs
16. Tightened the Home monthly calendar layout to prevent smaller-screen Android overflow in day cells and reminder indicators
17. Removed the duplicate inquiry email from the Settings app info section

## Current State

- The app remains local-first with no backend, auth, or cloud sync
- Camera, gallery, PDF, and Android share import are connected
- OCR works for images
- Text-based PDF parsing works
- Scanned-PDF OCR fallback works
- All parsing paths still feed the same normalization pipeline
- Manual confirmation fallback still exists and saving is never blocked
- Review crop/rotate changes now affect the actual recognition input:
  - images are transformed into a temp asset for OCR
  - PDFs can use edited raster OCR when needed
  - original source files remain untouched
- Korean and English UI are both available through the lightweight string system
- Settings now includes:
  - app info / about
  - donation
  - privacy notice
  - contact
  - language switching
- The inquiry email now appears only in the Contact section, not in the app info card
- The in-app title now follows locale:
  - English: `PaperBell`
  - Korean: `담아알림`
- Editable brand assets now exist for:
  - app icon source
  - Google Play icon export
  - Android adaptive icon foreground/background
  - feature graphic concept
- Play Console prep docs now exist for:
  - store listing copy
  - screenshot plan
  - alt text
  - privacy policy drafts
  - privacy-policy hosting guide
- Static HTML privacy pages now exist for:
  - `site/privacy/en/index.html`
  - `site/privacy/ko/index.html`
  - `site/privacy/assets/styles.css`
- The Home monthly calendar is now more compact and stable on smaller Android screen heights
- Donation uses one-time purchase ids:
  - `donation_coffee_small`
  - `donation_coffee_medium`
  - `donation_coffee_large`
- Store errors and unavailable states fail calmly and never block the rest of the app

## Highest-Priority Next Work

1. Capture sanitized real-app screenshots and export them into `store_assets/screenshots/` following `store_assets/source/capture_workflow.md`
2. Publish `site/privacy/` to a public, non-editable URL before Play Console submission
3. Plug the final privacy policy URLs into `lib/app/config/app_branding.dart`
4. Export the remaining SVG brand assets to final PNG deliverables for Android adaptive icons and iOS icon slots
5. Add a small UI-level test for the Settings donation section if purchase interaction changes again
6. Expand extraction heuristics with more real Korean household/admin document samples
7. Decide whether iOS share ingestion is worth the extra Share Extension complexity

## External Setup Notes

- Play Console in-app products still need to be created and activated for the three donation ids
- The privacy policy URLs in `docs/play_store_listing.md` are still placeholders and must be replaced with real public URLs
- The in-app privacy policy URL constants are intentionally null until the final public URLs are live
- If iOS support is needed, the same one-time products must also be created in App Store Connect
- Store-side pricing, test accounts, and review metadata are external operational tasks, not app-code tasks
