# Play Store Screenshot Capture Workflow

This workflow is designed to produce truthful Play Store screenshots from the
current Flutter UI without redesigning the product.

## Target device

- portrait phone capture
- preferred export size: `1080 x 1920`
- clean status bar
- Korean locale for the main listing

## Recommended capture order

1. `01_home_list_ko.png`
2. `02_home_calendar_ko.png`
3. `03_import_review_ko.png`
4. `04_extraction_confirm_ko.png`
5. `05_reminder_detail_ko.png`
6. `06_settings_privacy_ko.png`

## Capture steps

1. Start the app in Korean.
2. Load sanitized demo reminders similar to `demo_capture_data.md`.
3. Capture a clean portrait screenshot of the real screen.
4. Keep only the app UI and a clean status bar.
5. If a caption overlay is desired, place the screenshot under the matching SVG
   template in `source/screenshot_templates/`.
6. Export the final screenshot as PNG.

## Per-screen notes

### 01 Home list

- keep the summary card visible
- show 2 to 3 readable reminders
- avoid a crowded long list

### 02 Home calendar

- show the monthly calendar
- keep one selected date visible
- show the reminder card section below the calendar

### 03 Import review

- show the document preview card
- keep crop / rotate controls visible
- do not show noisy parsing progress states

### 04 Extraction confirm

- show title, date, amount, and category fields
- keep the document preview expansion collapsed or simple
- show calm editable fields, not an error-heavy state

### 05 Reminder detail

- keep the hero summary visible
- show date and amount context clearly
- if possible, leave the source document section partly visible

### 06 Settings / privacy

- scroll so app info, privacy, and contact tone are visible together
- include donation only if it stays calm and uncluttered

## Final check before upload

- no real personal information
- no broken text or overflow
- readable at mobile scale
- no fake feature callouts
- consistent spacing and color tone across the set
