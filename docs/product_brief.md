# Product Brief

## Product

- Name: 생활 행정 비서 (Life Admin Assistant)
- Positioning: calm, trustworthy, privacy-first mobile app for everyday life administration
- Core job: turn imported photos, screenshots, and PDFs into reminders with minimal manual input
- MVP promise: a user should be able to import a document and save a reminder in under 30 seconds

## MVP Scope

- Import entry points for camera, gallery, PDF, and share flow
- Document review / preprocess step
- OCR/parser abstraction layer
- One-screen extraction confirm and edit flow
- Local reminder creation
- Home dashboard with upcoming items
- Archive / search
- Settings / privacy

## Not In MVP

- Cloud sync
- Authentication
- Payment execution
- Bank/card linking
- Family/team collaboration

## Product Principles

- The main object is the upcoming task, not the document itself
- Auto-extracted values must stay visible and easy to correct
- Manual correction must be faster than redoing the full flow
- Privacy reassurance should be visible in import and settings flows

## Current Build State

- Core UI and navigation are implemented
- Reminder persistence is now real and survives app restart via `sqflite`
- Imported document metadata is stored locally with reminder records
- Local notifications are scheduled through `flutter_local_notifications`
- Import/parsing still use mock implementations by default, with clean adapter boundaries prepared for future platform integrations
