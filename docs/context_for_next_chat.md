# Context For Next Chat

Project: Flutter mobile MVP for turning household/admin documents into reminders.
Current brand direction:
- global app name: `PaperBell`
- default Play title: `PaperBell - Doc Reminder`
- Korean localized Play title: `담아알림 - 문서 리마인더`

## Current product shape

- Local-first only
- No backend
- No auth
- No cloud sync
- Calm Korean-first UX, with optional English
- Core flow is still:
  - import
  - review
  - extraction confirm
  - reminder save

## What is already implemented

- Flutter stable + Dart 3, Material 3, `go_router`, `flutter_riverpod`
- Local persistence with `sqflite`
- Local reminder scheduling with `flutter_local_notifications`
- Camera and gallery import through `image_picker`
- PDF import through `file_picker`
- Android share ingestion for shared images and PDFs
- Image OCR through `google_mlkit_text_recognition`
- Text-based PDF extraction through `flutter_pdf_text`
- Scanned/image-based PDF OCR fallback through `pdf_render_maintained` + ML Kit
- Unified normalization pipeline for image OCR, PDF text extraction, and scanned-PDF OCR fallback
- Manual confirmation fallback always remains available
- Saving is never blocked by failed extraction or preprocessing

## Recent milestones

- Replaced unmaintained `pdf_text` with `flutter_pdf_text` because the old PDFBox Android dependency no longer built on modern Android Gradle
- Replaced `pdf_render` with `pdf_render_maintained` because the old package still referenced the removed Flutter v1 Android embedding
- Added lightweight Korean/English localization with:
  - `lib/app/localization/app_strings.dart`
  - `lib/app/localization/strings_ko.dart`
  - `lib/app/localization/strings_en.dart`
  - `lib/app/localization/locale_controller.dart`
- Added first-launch language selection and persisted language choice locally
- Added one-time privacy onboarding after language selection
- Expanded Home with a lightweight list/calendar toggle and mixed-currency-safe monthly summary handling
- Added KRW/USD handling with manual currency selection when detection is uncertain
- Added Donation, Privacy Notice, Contact, and language switching inside Settings
- Added focused widget-test coverage for the Home calendar and mixed-currency summary behavior
- Fixed the Home monthly calendar layout so day cells and reminder indicators render more safely on smaller Android screens without bottom-overflow errors
- Removed the duplicate inquiry email from the Settings app info section, leaving the email only in the Contact section
- Reworked branding to be English-first for the global listing:
  - English locale app name: `PaperBell`
  - Korean locale app name: `담아알림`
- Added a lightweight in-app About section inside Settings
- Added Google Play listing preparation docs and editable SVG brand assets
- Added Korean/English privacy policy drafts plus static HTML privacy-policy hosting files
- Added a Play Store asset prep package under `store_assets/` with:
  - Korean feature graphic source/export wrapper
  - generated `1024 x 500` PNG feature graphic
  - screenshot capture templates
  - sanitized demo-data notes
  - export workflow notes

## New status from the latest pass

- Crop and rotate are now real preprocessing steps instead of preview-only controls
  - image imports apply rotation/crop to the actual OCR input image
  - the original source file remains untouched
  - transformed output is written to a temp file for OCR/parsing use
  - if preprocessing fails, the parser falls back calmly and manual confirmation still works
- PDF review edits now affect the rasterized OCR path when needed
  - edited PDFs can be reread from page images so rotation/crop changes are reflected
  - text-based PDF extraction remains intact when edits do not require raster OCR
  - scanned-PDF OCR fallback remains stable
- Remaining lower-level localization gaps were closed with the existing lightweight string system
  - preview labels
  - helper text
  - parser hints
  - preprocessing notices
  - import/share error copy
  - notification copy
- Donation buttons in Settings now use a real one-time purchase flow through `in_app_purchase`
  - product ids:
    - `donation_coffee_small`
    - `donation_coffee_medium`
    - `donation_coffee_large`
  - store unavailable, missing product, pending, success, cancel, and failure states show calm localized messages
  - the app remains fully usable without purchases
- Play Console prep now exists in-repo:
  - `docs/play_store_listing.md`
  - `docs/play_store_asset_pack.md`
  - `docs/privacy_policy_ko.md`
  - `docs/privacy_policy_en.md`
  - `docs/privacy_policy_hosting_guide.md`
  - `assets/branding/*.svg`
  - `site/privacy/en/index.html`
  - `site/privacy/ko/index.html`
  - `site/privacy/assets/styles.css`

## Important files

- `lib/app/app.dart`
- `lib/app/bootstrap/app_bootstrap.dart`
- `lib/app/localization/app_strings.dart`
- `lib/app/localization/locale_controller.dart`
- `lib/features/import_flow/domain/document.dart`
- `lib/features/import_flow/domain/document_preprocessing.dart`
- `lib/features/import_flow/data/document_image_preprocessor.dart`
- `lib/features/import_flow/data/adapter_backed_document_parser_service.dart`
- `lib/features/import_flow/data/adapters/mlkit_document_parser_adapter.dart`
- `lib/features/import_flow/data/adapters/pdf_page_rasterizer_adapter.dart`
- `lib/features/import_flow/data/adapters/pdf_text_document_parser_adapter.dart`
- `lib/features/import_flow/presentation/document_review_screen.dart`
- `lib/features/import_flow/presentation/extraction_confirm_screen.dart`
- `lib/features/settings/presentation/settings_screen.dart`
- `lib/app/config/app_branding.dart`
- `lib/features/settings/application/donation_purchase_controller.dart`
- `lib/features/settings/data/in_app_purchase_donation_store_gateway.dart`
- `lib/features/reminders/presentation/home_screen.dart`

## Current behavior details

- Language flow:
  - if no saved language exists, the app shows first-launch language selection
  - once selected, language is stored locally and reused on later launches
- Privacy flow:
  - after language selection, a calm privacy notice dialog appears if the user has not dismissed it forever
  - `Confirm` closes it for the current run
  - `Do not show again` stores the dismissal
- Review preprocessing flow:
  - image rotation/crop changes now affect OCR input
  - PDF rotation/crop changes affect rasterized OCR when that path is used
  - failures fall back to the original asset with calm helper copy
  - manual confirmation and save remain available
- Home flow:
  - list remains the default view
  - calendar view supports date-based browsing on the same screen
  - mixed KRW/USD totals are not merged into one misleading number
  - the monthly calendar cell layout is more compact and stable on smaller Android screens
- Donation flow:
  - Settings loads store availability and product details on demand
  - each donation button starts a one-time consumable purchase
  - purchase updates complete through the platform purchase stream
  - if Play Console / App Store setup is incomplete, users see calm unavailable or missing-product messaging instead of a broken flow
- Brand / store prep flow:
  - the app title shown in-app follows locale:
    - English: `PaperBell`
    - Korean: `담아알림`
  - Settings includes a lightweight About section with app summary, version/build label, and a privacy notice entry
  - the inquiry email now appears only in the Contact section to avoid duplication
  - privacy policy URLs remain nullable in app config, so no broken public-policy link is shown before a real URL is configured
  - editable SVG assets are ready for icon and feature graphic export
  - Play Store listing copy and screenshot guidance live in docs
- static public-hosting privacy pages are prepared under `site/privacy/`
- Play Store visual prep now also exists under `store_assets/`
  - `feature_graphic/feature_graphic_ko_source.svg`
  - `feature_graphic/feature_graphic_ko_export.html`
  - `feature_graphic/feature_graphic_ko.png`
  - `source/screenshot_templates/*.svg`
  - `source/demo_capture_data.md`
  - `source/capture_workflow.md`
  - `screenshots/README.md`
  - `export_notes.md`

## Validation status

- `flutter pub get`: passing
- `flutter analyze --no-pub`: passing
- `flutter test --no-pub`: passing
- `flutter build apk --debug`: passing

## External setup still required

- Android Play Console products must exist for:
  - `donation_coffee_small`
  - `donation_coffee_medium`
  - `donation_coffee_large`
- iOS App Store Connect products must also be configured if iOS purchase support is expected
- Store-side review/test accounts and pricing are external setup and are not handled in this repo

## Highest-priority follow-up ideas

1. Add a small targeted widget or controller test for the Settings donation section UI if purchase UX changes again
2. Export the SVG branding assets to final PNG deliverables for Play Console, Android adaptive icons, and iOS app icons
3. Publish `site/privacy/` to a public non-editable URL and plug the final URLs into `lib/app/config/app_branding.dart`
4. Capture sanitized Play Store screenshots following `docs/play_store_asset_pack.md`
5. Expand extraction heuristics with more real Korean household/admin samples
6. Decide whether iOS share ingestion is worth the added Share Extension complexity
