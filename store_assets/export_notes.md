# Store Asset Export Notes

This package prepares calm, truthful Google Play visuals for the current app
without redesigning the product.

## Feature graphic

- final concept file:
  - `feature_graphic/feature_graphic_ko_source.svg`
- export wrapper:
  - `feature_graphic/feature_graphic_ko_export.html`
- generated PNG:
  - `feature_graphic/feature_graphic_ko.png`
- target export:
  - `1024 x 500`
  - PNG

### Feature graphic concept

- Korean title: `담아알림`
- supporting label: `담아알림 - 문서 리마인더`
- supporting phrase:
  - `문서를 담아두고, 필요한 날 다시 확인하세요`
- visual motifs:
  - document card
  - reminder clock
  - subtle document summary panel

### Typography and spacing notes

- large title on the right with generous breathing room
- icon kept on the left as the primary visual anchor
- short supporting phrase only, to avoid a crowded store graphic
- soft green-gray and warm sand colors keep the tone calm and trustworthy

## Screenshot set

Recommended Play Store upload order:

1. `01_home_list_ko.png`
2. `02_home_calendar_ko.png`
3. `03_import_review_ko.png`
4. `04_extraction_confirm_ko.png`
5. `05_reminder_detail_ko.png`
6. `06_settings_privacy_ko.png`

### Screenshot intent

1. Home list:
   - communicate that saved reminders are readable and structured
2. Home calendar:
   - show lightweight date-based browsing without turning into a calendar app
3. Import review:
   - show document intake and review before extraction
4. Extraction confirm:
   - show automatic help with manual confirmation
5. Reminder detail:
   - show saved reminder context and source document connection
6. Settings / privacy:
   - communicate local-first and privacy-first behavior

## Included source files

- `source/demo_capture_data.md`
- `source/capture_workflow.md`
- `source/screenshot_templates/01_home_list_ko_template.svg`
- `source/screenshot_templates/02_home_calendar_ko_template.svg`
- `source/screenshot_templates/03_import_review_ko_template.svg`
- `source/screenshot_templates/04_extraction_confirm_ko_template.svg`
- `source/screenshot_templates/05_reminder_detail_ko_template.svg`
- `source/screenshot_templates/06_settings_privacy_ko_template.svg`

## Manual export steps still required

### Screenshots

1. Capture real app screens in Korean using sanitized demo data.
2. Save raw portrait captures at `1080 x 1920` when possible.
3. Optionally place each capture under the matching SVG template.
4. Export final PNG files into `screenshots/` using the filenames listed above.

## Why screenshots were left as source templates here

The repository now contains the exact screenshot order, captions, data guidance,
and composition templates. Actual final screenshot PNG export still depends on
running the current app UI in a capture device or emulator with sanitized demo
content, which is the most honest way to reflect the real product.
