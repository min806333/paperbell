# Branding Export Notes

These SVG files are the editable source of record for the current brand concept.

## Source files

- `app_icon_source.svg`: main editable icon source
- `play_store_icon_512.svg`: store icon source for 512 export
- `android_adaptive_foreground.svg`: Android adaptive icon foreground
- `android_adaptive_background.svg`: Android adaptive icon background
- `feature_graphic.svg`: global default Google Play feature graphic with the `PaperBell` wordmark

## Recommended export targets

### Google Play

- App icon:
  - source: `play_store_icon_512.svg`
  - export: PNG
  - size: `512x512`
- Feature graphic:
  - source: `feature_graphic.svg`
  - export: PNG
  - size: `1024x500`

### Android adaptive icon

- Foreground:
  - source: `android_adaptive_foreground.svg`
  - export: PNG
  - size: `432x432`
- Background:
  - source: `android_adaptive_background.svg`
  - export: PNG
  - size: `432x432`

Then place the raster exports into the Android adaptive icon workflow used by the release process.

### iOS app icon set

Export the main icon source to PNG for these common sizes:

- `20x20`
- `29x29`
- `40x40`
- `58x58`
- `60x60`
- `76x76`
- `80x80`
- `87x87`
- `120x120`
- `152x152`
- `167x167`
- `180x180`
- `1024x1024`

## Localized graphics note

- Keep the icon artwork unchanged across locales
- If a Korean-localized feature graphic is needed later, duplicate `feature_graphic.svg`
- Replace only the wordmark and subtitle text
- Keep the composition, icon direction, and color palette unchanged

## Practical export flow

1. Open the SVG files in Figma, Illustrator, Inkscape, or another vector editor
2. Export the required PNG sizes listed above
3. Check the exports against light and dark storefront backgrounds
4. Verify that small-size icons still keep the document + reminder cue readable
5. Archive both the final PNG exports and the SVG source together

## Notes

- The icon intentionally avoids finance-specific or scanner-specific cues
- The document shape and reminder clock cue remain the core motif
- Colors stay soft and low-contrast for a calm, trustworthy feel
- PNG export was not auto-generated in-repo to avoid adding heavy graphics tooling
