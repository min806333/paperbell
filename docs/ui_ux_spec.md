# UI / UX Spec

## Tone

- Calm
- Trustworthy
- Organized
- Light
- Human
- Low cognitive load

## Design Tokens

- Primary: `#1F6B5C`
- Primary container: `#DDEFE9`
- Background: `#F6F7F4`
- Surface: `#FFFFFF`
- Surface variant: `#EEF2EF`
- Text primary: `#111827`
- Text secondary: `#6B7280`
- Border: `#E5E7EB`
- Warning: `#B45309`
- Error: `#B42318`
- Success: `#166534`

Spacing scale: `4, 8, 12, 16, 20, 24, 32`

Radius scale: `12, 16, 20, 28`

Typography:

- Korean-friendly, readable, non-condensed
- Strong section titles
- Comfortable body line height
- Large enough touch targets and form inputs for mobile

## Screen Inventory

### Home

- Greeting / control-oriented hero area
- Privacy reassurance copy
- Summary cards: 오늘 / 이번 주 / 이번 달 예상
- Filter chips
- Upcoming reminder cards
- Calm empty state

### Import Bottom Sheet

- 카메라로 촬영
- 사진에서 선택
- PDF 가져오기
- 최근 공유 문서
- Privacy reassurance note

### Document Review

- Document preview
- Multipage thumbnails
- Crop placeholder area
- Rotate / retake / continue actions
- Calm parsing loading overlay

### Extraction Confirm

- Expandable source preview
- Editable fields on one scrollable screen
- Suggested / 확인 필요 badges
- Inline missing-date and missing-amount states
- Primary CTA: 리마인더 저장
- Secondary CTA: 다시 인식

### Reminder Detail

- Summary card
- Source preview when available
- Saved field summary
- Note area
- Actions for complete / snooze / edit / delete

### Archive

- Search field
- Category / status filters
- Saved items list
- Empty state

### Settings

- Default reminder timing
- App lock placeholder
- Local storage / privacy info
- Export placeholder
- Delete-all-local-data action

## UX Notes

- Saving must remain possible even if amount is missing
- Saving stays blocked until a date is selected
- Notification permission failure must never block reminder saving
- Notification notices should stay calm and non-alarming
- The confirmation screen remains the product center of gravity
