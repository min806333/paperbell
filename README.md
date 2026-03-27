# 생활 행정 비서

문서 사진, 스크린샷, PDF를 받아 날짜와 금액 같은 핵심 정보를 추출하고, 한 화면에서 확인 후 리마인더로 저장하는 Flutter 모바일 MVP입니다.

## 현재 구현 범위

- Material 3 기반의 차분한 카드형 UI
- `go_router` + `flutter_riverpod` 기반 앱 셸과 하단 탭
- 홈, 보관함, 설정 화면
- 가져오기 바텀시트와 문서 검토 화면
- 추출 결과 확인/수정 화면
- 리마인더 상세 화면
- 목 import/parser 서비스와 현실적인 한국어 샘플 데이터
- 향후 로컬 DB/OCR 연동을 위한 모델, 저장소, 서비스 추상화

## 기술 스택

- Flutter stable / Dart 3
- Material 3
- go_router
- flutter_riverpod
- sqflite (현재는 스켈레톤만 준비)
- flutter_local_notifications (향후 알림 스케줄링 연결 예정)
- image_picker / file_picker / permission_handler

## 폴더 구조

```text
lib/
  app/
    app.dart
    navigation/
    theme/
  core/
    data/
    models/
    utils/
  features/
    import_flow/
    reminders/
    settings/
  shared/
    widgets/
docs/
  product_brief.md
  ui_ux_spec.md
  context_for_next_chat.md
  next_steps.md
```

## 실행

```bash
flutter pub get
flutter run
```

## 현재 제한 사항

- OCR은 실제 엔진 대신 목 파서로 동작합니다.
- 로컬 DB와 로컬 알림은 인터페이스/스켈레톤 위주이며, 아직 완전한 영속 저장은 연결하지 않았습니다.
- 공유 시트 처리와 실제 이미지/PDF 크롭은 다음 단계 작업입니다.

자세한 맥락은 [docs/context_for_next_chat.md](docs/context_for_next_chat.md)에서 바로 이어서 볼 수 있습니다.
