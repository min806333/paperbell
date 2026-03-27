# Privacy Policy Hosting Guide

This repository now includes a GitHub Pages-ready static privacy policy site for
the `min806333/paperbell` repository.

## Final public URLs

Once GitHub Pages is enabled and the workflow succeeds, the privacy policy pages
should be available at:

- `https://min806333.github.io/paperbell/privacy/ko/`
- `https://min806333.github.io/paperbell/privacy/en/`

These are suitable targets for Google Play Console as long as they are live and
publicly reachable.

## Included site structure

```text
site/
  index.html
  styles.css
  privacy/
    en/
      index.html
    ko/
      index.html
```

## Included deployment workflow

This repository now contains the GitHub Actions workflow:

- `.github/workflows/deploy-privacy-pages.yml`

The workflow uses the official GitHub Pages actions:

- `actions/configure-pages`
- `actions/upload-pages-artifact`
- `actions/deploy-pages`

It publishes the contents of `site/` directly, with no separate build step.

## How to enable GitHub Pages for this repository

1. Push these changes to the `main` branch of `https://github.com/min806333/paperbell`.
2. Open the repository on GitHub.
3. Go to `Settings > Pages`.
4. Under `Build and deployment`, set `Source` to `GitHub Actions`.
5. Open the `Actions` tab and confirm that `Deploy privacy site to GitHub Pages`
   runs successfully.

## Where to verify successful deployment

After the workflow finishes:

1. Open the workflow run in the GitHub `Actions` tab.
2. Confirm that the deploy job completed successfully.
3. Open the GitHub Pages environment link shown in the workflow summary.
4. Verify the final public pages:
   - `https://min806333.github.io/paperbell/privacy/ko/`
   - `https://min806333.github.io/paperbell/privacy/en/`

## Google Play requirements to verify

The privacy policy URL submitted to Google Play should be:

- active
- publicly accessible
- non-geofenced
- non-editable
- not a PDF

Before submitting, test the final URLs in:

- an incognito browser window
- a mobile browser
- a network that is not logged into GitHub

## Where to paste the final URLs in the Flutter app

After GitHub Pages is live, update these nullable constants in
`lib/app/config/app_branding.dart`:

- `privacyPolicyKoUrl = "https://min806333.github.io/paperbell/privacy/ko/"`
- `privacyPolicyEnUrl = "https://min806333.github.io/paperbell/privacy/en/"`

Because the app currently keeps these values nullable, no broken link is shown
before the public URLs are ready.

## Where to paste the final URL in Google Play Console

In Google Play Console, paste the public privacy policy URL in the app content
or store listing privacy policy field.

Recommended usage:

- default/global listing: `https://min806333.github.io/paperbell/privacy/en/`
- Korean localized listing: `https://min806333.github.io/paperbell/privacy/ko/`

## Notes

- The privacy policy pages are plain static HTML and CSS.
- No login is required.
- No editable external document link is used.
- No PDF is used.
