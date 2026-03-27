import '../../../../core/models/app_enums.dart';
import '../../domain/document.dart';
import '../../domain/extracted_field.dart';
import '../../domain/extraction_result.dart';
import 'recognized_document_text.dart';

class DocumentTextExtractionNormalizer {
  const DocumentTextExtractionNormalizer();

  ExtractionResult normalize({
    required Document document,
    required String rawText,
    required List<RecognizedLineCandidate> lines,
    String? suggestedTitle,
  }) {
    final cleanedRawText = _cleanText(rawText);
    final cleanedLines = [
      for (final line in lines)
        if (_cleanText(line.text).isNotEmpty)
          RecognizedLineCandidate(
            text: _cleanText(line.text),
            confidence: line.confidence,
          ),
    ];

    if (cleanedRawText.isEmpty || cleanedLines.isEmpty) {
      return buildFallback(
        document: document,
        primaryHint: '문자를 충분히 읽지 못했어요. 필요한 항목만 직접 확인해 주세요.',
      );
    }

    final categoryField = _extractCategory(
      title: suggestedTitle,
      rawText: '$cleanedRawText\n${document.title}',
    );
    final titleField = _extractTitle(
      document: document,
      lines: cleanedLines,
      category: categoryField.value,
      suggestedTitle: suggestedTitle,
    );
    final dueDateField = _extractDueDate(cleanedLines);
    final amountExtraction = _extractAmount(cleanedLines);
    final amountField = amountExtraction.amount;
    final currencyCodeField = amountExtraction.currencyCode;
    final noteField = _extractNote(cleanedLines, titleField.value);
    final repeatRule = _inferRepeatRule(cleanedRawText, categoryField.value);
    final reminderLeadTime = _inferLeadTime(categoryField.value, dueDateField);

    final hints = <String>[
      '자동으로 찾은 정보예요. 한 번만 확인해 주세요.',
      if (dueDateField.value == null) '날짜를 찾지 못했어요. 직접 선택해 주세요.',
      if (amountField.value == null) '금액 없이도 저장할 수 있어요.',
    ];

    return ExtractionResult(
      documentId: document.id,
      title: titleField,
      dueAt: dueDateField,
      amount: amountField,
      currencyCode: currencyCodeField,
      category: categoryField,
      note: noteField,
      sourceSubtitle: _buildSourceSubtitle(
        document: document,
        title: titleField.value,
        rawText: cleanedRawText,
      ),
      repeatRule: repeatRule,
      reminderLeadTime: reminderLeadTime,
      hints: hints.toSet().toList(),
    );
  }

  ExtractionResult buildFallback({
    required Document document,
    String? primaryHint,
  }) {
    final title = _cleanDisplayTitle(document.title);
    final categorySuggestion = _inferCategorySuggestion(title);
    final hints = <String>[
      primaryHint ?? '문서를 완전히 읽지 못했어요. 필요한 항목만 직접 확인해 주세요.',
      '금액 없이도 저장할 수 있어요.',
      '날짜를 찾지 못했어요. 직접 선택해 주세요.',
    ];

    return ExtractionResult(
      documentId: document.id,
      title: ExtractedField<String>(
        value: title.isEmpty ? null : title,
        state: title.isEmpty
            ? ExtractedFieldState.missing
            : ExtractedFieldState.needsConfirmation,
        rawText: title.isEmpty ? null : document.title,
        confidence: title.isEmpty ? null : 0.35,
      ),
      dueAt: const ExtractedField<DateTime>(
        value: null,
        state: ExtractedFieldState.missing,
      ),
      amount: const ExtractedField<double>(
        value: null,
        state: ExtractedFieldState.missing,
      ),
      currencyCode: const ExtractedField<String?>(
        value: null,
        state: ExtractedFieldState.missing,
      ),
      category: ExtractedField<ReminderCategory>(
        value: categorySuggestion?.category,
        state: categorySuggestion == null
            ? ExtractedFieldState.missing
            : ExtractedFieldState.needsConfirmation,
        confidence: categorySuggestion?.confidence,
      ),
      note: const ExtractedField<String>(
        value: null,
        state: ExtractedFieldState.missing,
      ),
      sourceSubtitle: _buildSourceSubtitle(
        document: document,
        title: title.isEmpty ? null : title,
        rawText: document.title,
      ),
      repeatRule: ReminderRepeatRule.none,
      reminderLeadTime: ReminderLeadTime.oneDayBefore,
      hints: hints,
    );
  }

  ExtractedField<String> _extractTitle({
    required Document document,
    required List<RecognizedLineCandidate> lines,
    required ReminderCategory? category,
    String? suggestedTitle,
  }) {
    _ScoredMatch<String>? bestMatch;

    final normalizedSuggestedTitle = _cleanDisplayTitle(suggestedTitle ?? '');
    if (_isUsefulFallbackTitle(normalizedSuggestedTitle)) {
      bestMatch = _ScoredMatch<String>(
        value: normalizedSuggestedTitle,
        rawText: suggestedTitle,
        score: 1.02,
      );
    }

    for (var index = 0; index < lines.length; index++) {
      final line = lines[index];
      if (!_isMeaningfulTitleCandidate(line.text)) {
        continue;
      }

      var score = 0.28;
      if (_containsAny(line.text, _titleKeywords)) {
        score += 0.44;
      }
      if (_containsAny(line.text, _sourceKeywords)) {
        score += 0.18;
      }
      if (index < 2) {
        score += 0.18;
      } else if (index < 4) {
        score += 0.1;
      }
      score += (line.confidence ?? 0.45) * 0.22;

      final candidate = _ScoredMatch<String>(
        value: line.text,
        rawText: line.text,
        score: score,
      );
      if (bestMatch == null || candidate.score > bestMatch.score) {
        bestMatch = candidate;
      }
    }

    final fallbackTitle = _fallbackTitleForCategory(
      category: category,
      documentTitle: document.title,
    );
    if (bestMatch == null && fallbackTitle != null) {
      bestMatch = _ScoredMatch<String>(
        value: fallbackTitle,
        rawText: fallbackTitle,
        score: 0.48,
      );
    }

    final title = bestMatch?.value ?? _cleanDisplayTitle(document.title);
    if (title.isEmpty) {
      return const ExtractedField<String>(
        value: null,
        state: ExtractedFieldState.missing,
      );
    }

    final confidence = _normalizeScore(
      bestMatch?.score ?? 0.45,
      divisor: 1.2,
      min: 0.4,
      max: 0.94,
    );

    return ExtractedField<String>(
      value: title,
      state: _stateFromConfidence(confidence),
      rawText: bestMatch?.rawText ?? document.title,
      confidence: confidence,
    );
  }

  ExtractedField<DateTime> _extractDueDate(
    List<RecognizedLineCandidate> lines,
  ) {
    _ScoredMatch<DateTime>? bestMatch;

    for (final line in lines) {
      final dateMatch = _extractBestDateCandidate(line.text);
      if (dateMatch == null) {
        continue;
      }

      var score = dateMatch.keywordWeight;
      score += dateMatch.hasExplicitYear ? 0.22 : 0.08;
      score += (line.confidence ?? 0.45) * 0.22;
      if (_containsAny(line.text, _negativeDateKeywords)) {
        score -= 0.35;
      }

      final candidate = _ScoredMatch<DateTime>(
        value: dateMatch.date,
        rawText: line.text,
        score: score,
      );
      if (bestMatch == null || candidate.score > bestMatch.score) {
        bestMatch = candidate;
      }
    }

    if (bestMatch == null || bestMatch.score < 0.4) {
      return const ExtractedField<DateTime>(
        value: null,
        state: ExtractedFieldState.missing,
      );
    }

    final confidence = _normalizeScore(
      bestMatch.score,
      divisor: 1.45,
      min: 0.46,
      max: 0.95,
    );

    return ExtractedField<DateTime>(
      value: bestMatch.value,
      state: _stateFromConfidence(confidence),
      rawText: bestMatch.rawText,
      confidence: confidence,
    );
  }

  _AmountExtractionResult _extractAmount(List<RecognizedLineCandidate> lines) {
    _ScoredMatch<_AmountCandidate>? bestMatch;

    for (final line in lines) {
      final amountMatch = _extractBestAmountCandidate(line.text);
      if (amountMatch == null) {
        continue;
      }
      if (_containsDate(line.text) &&
          !_containsAny(
            line.text,
            _amountKeywords.map((item) => item.term).toList(),
          ) &&
          amountMatch.currencyCode == null) {
        continue;
      }

      var score = amountMatch.keywordWeight;
      if (_containsAny(line.text, _amountSummaryKeywords)) {
        score += 0.16;
      }
      score += (line.confidence ?? 0.45) * 0.24;
      if (_containsAny(line.text, _negativeAmountKeywords)) {
        score -= 0.34;
      }

      final candidate = _ScoredMatch<_AmountCandidate>(
        value: amountMatch,
        rawText: line.text,
        score: score,
      );
      if (bestMatch == null || candidate.score > bestMatch.score) {
        bestMatch = candidate;
      }
    }

    if (bestMatch == null || bestMatch.score < 0.36) {
      return const _AmountExtractionResult(
        amount: ExtractedField<double>(
          value: null,
          state: ExtractedFieldState.missing,
        ),
        currencyCode: ExtractedField<String?>(
          value: null,
          state: ExtractedFieldState.missing,
        ),
      );
    }

    final confidence = _normalizeScore(
      bestMatch.score,
      divisor: 1.4,
      min: 0.45,
      max: 0.96,
    );

    final currencyCodeField = bestMatch.value.currencyCode == null
        ? ExtractedField<String?>(
            value: null,
            state: ExtractedFieldState.missing,
            rawText: bestMatch.rawText,
          )
        : ExtractedField<String?>(
            value: bestMatch.value.currencyCode,
            state: _stateFromConfidence(bestMatch.value.currencyConfidence),
            rawText: bestMatch.rawText,
            confidence: bestMatch.value.currencyConfidence,
          );

    return _AmountExtractionResult(
      amount: ExtractedField<double>(
        value: bestMatch.value.amount,
        state: _stateFromConfidence(confidence),
        rawText: bestMatch.rawText,
        confidence: confidence,
      ),
      currencyCode: currencyCodeField,
    );
  }

  ExtractedField<ReminderCategory> _extractCategory({
    required String? title,
    required String rawText,
  }) {
    final suggestion = _inferCategorySuggestion('$title\n$rawText');
    if (suggestion == null) {
      return const ExtractedField<ReminderCategory>(
        value: null,
        state: ExtractedFieldState.missing,
      );
    }

    return ExtractedField<ReminderCategory>(
      value: suggestion.category,
      state: _stateFromConfidence(suggestion.confidence),
      confidence: suggestion.confidence,
      rawText: rawText,
    );
  }

  ExtractedField<String> _extractNote(
    List<RecognizedLineCandidate> lines,
    String? title,
  ) {
    for (final line in lines) {
      if (line.text == title) {
        continue;
      }
      if (_containsAny(line.text, _noteKeywords) &&
          !_containsAny(
            line.text,
            _amountKeywords.map((item) => item.term).toList(),
          ) &&
          !_containsAny(
            line.text,
            _dateKeywords.map((item) => item.term).toList(),
          ) &&
          line.text.length <= 42) {
        return ExtractedField<String>(
          value: line.text,
          state: ExtractedFieldState.needsConfirmation,
          rawText: line.text,
          confidence: _normalizeScore(
            (line.confidence ?? 0.45) + 0.18,
            divisor: 1,
            min: 0.42,
            max: 0.74,
          ),
        );
      }
    }

    return const ExtractedField<String>(
      value: null,
      state: ExtractedFieldState.missing,
    );
  }

  ReminderRepeatRule _inferRepeatRule(
    String rawText,
    ReminderCategory? category,
  ) {
    final normalized = _cleanText(rawText);
    if (_containsAny(normalized, const ['매월', '매달', '정기결제', '자동결제', '월 정기'])) {
      return ReminderRepeatRule.monthly;
    }
    if (_containsAny(normalized, const ['매년', '연간', '갱신일', '계약기간', '보증기간'])) {
      return ReminderRepeatRule.yearly;
    }
    if (category == ReminderCategory.subscription ||
        category == ReminderCategory.utilities) {
      return ReminderRepeatRule.monthly;
    }
    if (category == ReminderCategory.insurance ||
        category == ReminderCategory.contractRenewal ||
        category == ReminderCategory.warranty) {
      return ReminderRepeatRule.yearly;
    }
    return ReminderRepeatRule.none;
  }

  ReminderLeadTime _inferLeadTime(
    ReminderCategory? category,
    ExtractedField<DateTime> dueDate,
  ) {
    if (dueDate.value == null) {
      return ReminderLeadTime.oneDayBefore;
    }
    return switch (category) {
      ReminderCategory.insurance ||
      ReminderCategory.contractRenewal => ReminderLeadTime.sevenDaysBefore,
      ReminderCategory.warranty => ReminderLeadTime.threeDaysBefore,
      _ => ReminderLeadTime.oneDayBefore,
    };
  }

  String _buildSourceSubtitle({
    required Document document,
    required String? title,
    required String rawText,
  }) {
    final normalized = _cleanText('$title\n$rawText');
    if (_containsAny(normalized, const ['넷플릭스', '멤버십', '자동결제'])) {
      return '정기 결제 안내';
    }
    if (_containsAny(normalized, const ['관리비', '관리사무소', '공과금'])) {
      return '관리사무소';
    }
    if (_containsAny(normalized, const ['보험', '보험료'])) {
      return '보험 안내문';
    }
    if (_containsAny(normalized, const ['건강검진', '검진', '진료비', '병원'])) {
      return '의료 안내문';
    }
    if (_containsAny(normalized, const ['정수기', '필터', '보증기간', 'A/S', 'AS'])) {
      return '관리 안내문';
    }
    if (_containsAny(normalized, const ['계약기간', '계약만료', '갱신일'])) {
      return '계약 안내문';
    }

    final fallbackTitle = _cleanDisplayTitle(document.title);
    return fallbackTitle.isEmpty ? '가져온 문서' : fallbackTitle;
  }

  _CategorySuggestion? _inferCategorySuggestion(String text) {
    final normalized = _cleanText(text).toLowerCase();
    if (normalized.isEmpty) {
      return null;
    }

    final scores = <ReminderCategory, double>{
      for (final category in ReminderCategory.values)
        if (category != ReminderCategory.other) category: 0,
    };

    for (final keyword in _categoryKeywords) {
      if (normalized.contains(keyword.term.toLowerCase())) {
        scores.update(keyword.category, (value) => value + keyword.weight);
      }
    }

    final matches = scores.entries.where((entry) => entry.value > 0).toList()
      ..sort((left, right) => right.value.compareTo(left.value));
    if (matches.isEmpty) {
      return null;
    }

    final top = matches.first;
    final runnerUp = matches.length > 1 ? matches[1].value : 0.0;
    final adjustedScore = top.value - (runnerUp * 0.18);
    if (adjustedScore < 0.55) {
      return null;
    }

    return _CategorySuggestion(
      category: top.key,
      confidence: _normalizeScore(
        adjustedScore,
        divisor: 1.9,
        min: 0.48,
        max: 0.94,
      ),
    );
  }

  _DateCandidate? _extractBestDateCandidate(String text) {
    for (final keyword in _dateKeywords) {
      if (!text.contains(keyword.term)) {
        continue;
      }

      final tail = text.substring(
        text.indexOf(keyword.term) + keyword.term.length,
      );
      final afterKeyword = _extractFirstDateCandidate(tail);
      if (afterKeyword != null) {
        return _DateCandidate(
          date: afterKeyword.date,
          hasExplicitYear: afterKeyword.hasExplicitYear,
          keywordWeight: keyword.weight,
        );
      }
    }

    final general = _extractFirstDateCandidate(text);
    if (general == null) {
      return null;
    }

    return _DateCandidate(
      date: general.date,
      hasExplicitYear: general.hasExplicitYear,
      keywordWeight: 0.42,
    );
  }

  _DateCandidate? _extractFirstDateCandidate(String text) {
    final now = DateTime.now();

    for (final match in _fullYearKoreanPattern.allMatches(text)) {
      final date = _safeDate(
        int.parse(match.group(1)!),
        int.parse(match.group(2)!),
        int.parse(match.group(3)!),
      );
      if (date != null) {
        return _DateCandidate(
          date: date,
          hasExplicitYear: true,
          keywordWeight: 0,
        );
      }
    }

    for (final match in _fullYearNumericPattern.allMatches(text)) {
      final date = _safeDate(
        int.parse(match.group(1)!),
        int.parse(match.group(2)!),
        int.parse(match.group(3)!),
      );
      if (date != null) {
        return _DateCandidate(
          date: date,
          hasExplicitYear: true,
          keywordWeight: 0,
        );
      }
    }

    for (final match in _monthDayKoreanPattern.allMatches(text)) {
      return _DateCandidate(
        date: _resolveYearlessDate(
          month: int.parse(match.group(1)!),
          day: int.parse(match.group(2)!),
          now: now,
        ),
        hasExplicitYear: false,
        keywordWeight: 0,
      );
    }

    for (final match in _monthDayNumericPattern.allMatches(text)) {
      return _DateCandidate(
        date: _resolveYearlessDate(
          month: int.parse(match.group(1)!),
          day: int.parse(match.group(2)!),
          now: now,
        ),
        hasExplicitYear: false,
        keywordWeight: 0,
      );
    }

    return null;
  }

  _AmountCandidate? _extractBestAmountCandidate(String text) {
    final normalized = _cleanText(text);
    _AmountCandidate? bestMatch;

    for (final match in _currencyAwareAmountPattern.allMatches(normalized)) {
      final amount = _parseAmount(match.group(1));
      final rawNumber = match.group(1) ?? '';
      final currencyDetection = _detectCurrencyCode(
        normalized,
        match.start,
        match.end,
      );
      final hasDecimalAmount = rawNumber.contains('.');

      if (amount == null) {
        continue;
      }

      if (amount < 1000 &&
          currencyDetection.code != 'USD' &&
          !hasDecimalAmount) {
        continue;
      }

      var keywordWeight = 0.34;
      for (final keyword in _amountKeywords) {
        if (normalized.contains(keyword.term)) {
          keywordWeight = keyword.weight > keywordWeight
              ? keyword.weight
              : keywordWeight;
        }
      }

      final candidate = _AmountCandidate(
        amount: amount,
        keywordWeight: keywordWeight,
        currencyCode: currencyDetection.code,
        currencyConfidence: currencyDetection.confidence,
      );
      if (bestMatch == null ||
          candidate.keywordWeight > bestMatch.keywordWeight ||
          (candidate.keywordWeight == bestMatch.keywordWeight &&
              candidate.currencyConfidence > bestMatch.currencyConfidence)) {
        bestMatch = candidate;
      }
    }

    return bestMatch;
  }

  _CurrencyDetection _detectCurrencyCode(
    String text,
    int matchStart,
    int matchEnd,
  ) {
    final prefixStart = matchStart - 6 < 0 ? 0 : matchStart - 6;
    final suffixEnd = matchEnd + 6 > text.length ? text.length : matchEnd + 6;
    final window = text.substring(prefixStart, suffixEnd);

    final hasKrwNear = _krwCurrencyPattern.hasMatch(window);
    final hasUsdNear = _usdCurrencyPattern.hasMatch(window);
    if (hasKrwNear && !hasUsdNear) {
      return const _CurrencyDetection(code: 'KRW', confidence: 0.95);
    }
    if (hasUsdNear && !hasKrwNear) {
      return const _CurrencyDetection(code: 'USD', confidence: 0.95);
    }

    final hasKrwAnywhere = _krwCurrencyPattern.hasMatch(text);
    final hasUsdAnywhere = _usdCurrencyPattern.hasMatch(text);
    if (hasKrwAnywhere && !hasUsdAnywhere) {
      return const _CurrencyDetection(code: 'KRW', confidence: 0.82);
    }
    if (hasUsdAnywhere && !hasKrwAnywhere) {
      return const _CurrencyDetection(code: 'USD', confidence: 0.82);
    }

    if (!hasKrwAnywhere && !hasUsdAnywhere && _amountPattern.hasMatch(text)) {
      return const _CurrencyDetection(code: null, confidence: 0);
    }

    return const _CurrencyDetection(code: null, confidence: 0);
  }

  double? _parseAmount(String? rawNumber) {
    if (rawNumber == null) {
      return null;
    }
    final cleaned = rawNumber.replaceAll(',', '');
    return double.tryParse(cleaned);
  }

  DateTime? _safeDate(int year, int month, int day) {
    if (month < 1 || month > 12 || day < 1 || day > 31) {
      return null;
    }
    return DateTime(year, month, day);
  }

  DateTime _resolveYearlessDate({
    required int month,
    required int day,
    required DateTime now,
  }) {
    var candidate = DateTime(now.year, month, day);
    if (candidate.isBefore(now.subtract(const Duration(days: 30)))) {
      candidate = DateTime(now.year + 1, month, day);
    }
    return candidate;
  }

  ExtractedFieldState _stateFromConfidence(double confidence) {
    if (confidence >= 0.72) {
      return ExtractedFieldState.suggested;
    }
    return ExtractedFieldState.needsConfirmation;
  }

  double _normalizeScore(
    double rawScore, {
    required double divisor,
    required double min,
    required double max,
  }) {
    final normalized = (rawScore / divisor).clamp(0.0, 1.0);
    return (min + (max - min) * normalized).clamp(min, max).toDouble();
  }

  String _cleanText(String value) {
    return value.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String _cleanDisplayTitle(String value) {
    return _cleanText(
      value
          .replaceAll(RegExp(r'[_\-]+'), ' ')
          .replaceAll(
            RegExp(r'\.(jpg|jpeg|png|pdf)$', caseSensitive: false),
            '',
          ),
    );
  }

  bool _isMeaningfulTitleCandidate(String text) {
    if (!_isMeaningfulShortLine(text)) {
      return false;
    }
    if (_containsAny(text, _dateKeywords.map((item) => item.term).toList()) &&
        _containsDate(text)) {
      return false;
    }
    if (_containsAny(text, _amountKeywords.map((item) => item.term).toList()) &&
        _currencyAwareAmountPattern.hasMatch(text)) {
      return false;
    }
    if (_containsAny(text, _negativeTitleKeywords)) {
      return false;
    }
    return true;
  }

  bool _isMeaningfulShortLine(String text) {
    if (text.length < 3 || text.length > 36) {
      return false;
    }
    final digitRatio =
        text.replaceAll(RegExp(r'[^0-9]'), '').length / text.length;
    return digitRatio < 0.45;
  }

  bool _isUsefulFallbackTitle(String title) {
    if (title.isEmpty) {
      return false;
    }
    return !_genericDocumentTitles.contains(title);
  }

  String? _fallbackTitleForCategory({
    required ReminderCategory? category,
    required String documentTitle,
  }) {
    final cleanedDocumentTitle = _cleanDisplayTitle(documentTitle);
    if (_isUsefulFallbackTitle(cleanedDocumentTitle)) {
      return cleanedDocumentTitle;
    }

    return switch (category) {
      ReminderCategory.utilities => '관리비 납부',
      ReminderCategory.subscription => '구독 결제',
      ReminderCategory.insurance => '보험 안내',
      ReminderCategory.tax => '세금 안내',
      ReminderCategory.medical => '의료 일정',
      ReminderCategory.contractRenewal => '계약 갱신',
      ReminderCategory.warranty => '보증 확인',
      _ => null,
    };
  }

  bool _containsDate(String text) {
    return _fullYearKoreanPattern.hasMatch(text) ||
        _fullYearNumericPattern.hasMatch(text) ||
        _monthDayKoreanPattern.hasMatch(text) ||
        _monthDayNumericPattern.hasMatch(text);
  }

  bool _containsAny(String text, List<String> keywords) {
    final normalized = text.toLowerCase();
    for (final keyword in keywords) {
      if (normalized.contains(keyword.toLowerCase())) {
        return true;
      }
    }
    return false;
  }
}

class _ScoredMatch<T> {
  const _ScoredMatch({
    required this.value,
    required this.rawText,
    required this.score,
  });

  final T value;
  final String? rawText;
  final double score;
}

class _DateCandidate {
  const _DateCandidate({
    required this.date,
    required this.hasExplicitYear,
    required this.keywordWeight,
  });

  final DateTime date;
  final bool hasExplicitYear;
  final double keywordWeight;
}

class _AmountCandidate {
  const _AmountCandidate({
    required this.amount,
    required this.keywordWeight,
    required this.currencyCode,
    required this.currencyConfidence,
  });

  final double amount;
  final double keywordWeight;
  final String? currencyCode;
  final double currencyConfidence;
}

class _AmountExtractionResult {
  const _AmountExtractionResult({
    required this.amount,
    required this.currencyCode,
  });

  final ExtractedField<double> amount;
  final ExtractedField<String?> currencyCode;
}

class _CurrencyDetection {
  const _CurrencyDetection({required this.code, required this.confidence});

  final String? code;
  final double confidence;
}

final _currencyAwareAmountPattern = RegExp(
  r'(?:₩|￦|\$|\b(?:krw|usd)\b)?\s*([0-9]{1,3}(?:,[0-9]{3})+(?:\.\d{1,2})?|[0-9]+(?:\.\d{1,2})?)(?:\s*(?:원|\bkrw\b|\busd\b))?',
  caseSensitive: false,
);
final _krwCurrencyPattern = RegExp(r'(₩|￦|\bkrw\b|원)', caseSensitive: false);
final _usdCurrencyPattern = RegExp(r'(\$|\busd\b)', caseSensitive: false);

class _CategorySuggestion {
  const _CategorySuggestion({required this.category, required this.confidence});

  final ReminderCategory category;
  final double confidence;
}

class _WeightedKeyword {
  const _WeightedKeyword(this.term, this.weight);

  final String term;
  final double weight;
}

class _CategoryKeyword {
  const _CategoryKeyword({
    required this.category,
    required this.term,
    required this.weight,
  });

  final ReminderCategory category;
  final String term;
  final double weight;
}

const _titleKeywords = <String>[
  '관리비',
  '납부',
  '결제',
  '보험',
  '갱신',
  '검진',
  '예약',
  '세금',
  '필터',
  '교체',
  '보증',
  '계약',
  '멤버십',
];

const _sourceKeywords = <String>['관리사무소', '넷플릭스', '보험', '병원', '정수기', '멤버십'];

const _negativeTitleKeywords = <String>[
  '청구금액',
  '납부기한',
  '결제일',
  '합계',
  '총액',
  '페이지',
];

const _negativeDateKeywords = <String>[
  '발행일',
  '작성일',
  '승인일',
  '거래일',
  '이용기간',
  '청구기간',
];

const _negativeAmountKeywords = <String>[
  '할인',
  '적립',
  '포인트',
  '잔액',
  '부가세',
  '공급가액',
  '단가',
];

const _amountSummaryKeywords = <String>['총 납부금액', '총납부금액', '합계', '총액'];

const _noteKeywords = <String>[
  '자동이체',
  '자동결제',
  '준비물',
  '보장',
  '유의',
  '문의',
  '필수',
  '확인',
  '안내',
];

const _dateKeywords = <_WeightedKeyword>[
  _WeightedKeyword('납부기한', 1.0),
  _WeightedKeyword('결제일', 0.96),
  _WeightedKeyword('갱신일', 0.98),
  _WeightedKeyword('만료일', 0.9),
  _WeightedKeyword('사용기한', 0.92),
  _WeightedKeyword('예약일', 0.9),
  _WeightedKeyword('검진일', 0.88),
  _WeightedKeyword('청구 마감', 0.82),
  _WeightedKeyword('기한', 0.74),
  _WeightedKeyword('마감', 0.7),
  _WeightedKeyword('까지', 0.66),
];

const _amountKeywords = <_WeightedKeyword>[
  _WeightedKeyword('총 납부금액', 1.0),
  _WeightedKeyword('총납부금액', 1.0),
  _WeightedKeyword('청구금액', 0.96),
  _WeightedKeyword('결제금액', 0.94),
  _WeightedKeyword('납부금액', 0.92),
  _WeightedKeyword('합계', 0.9),
  _WeightedKeyword('총액', 0.9),
  _WeightedKeyword('보험료', 0.88),
  _WeightedKeyword('진료비', 0.88),
  _WeightedKeyword('관리비', 0.84),
  _WeightedKeyword('이용료', 0.8),
  _WeightedKeyword('요금', 0.76),
  _WeightedKeyword('자동결제', 0.7),
];

const _categoryKeywords = <_CategoryKeyword>[
  _CategoryKeyword(
    category: ReminderCategory.utilities,
    term: '관리비',
    weight: 1.0,
  ),
  _CategoryKeyword(
    category: ReminderCategory.utilities,
    term: '공과금',
    weight: 0.95,
  ),
  _CategoryKeyword(
    category: ReminderCategory.utilities,
    term: '전기요금',
    weight: 1.0,
  ),
  _CategoryKeyword(
    category: ReminderCategory.utilities,
    term: '수도요금',
    weight: 1.0,
  ),
  _CategoryKeyword(
    category: ReminderCategory.utilities,
    term: '가스요금',
    weight: 1.0,
  ),
  _CategoryKeyword(
    category: ReminderCategory.utilities,
    term: '도시가스',
    weight: 0.92,
  ),
  _CategoryKeyword(
    category: ReminderCategory.subscription,
    term: '구독',
    weight: 0.95,
  ),
  _CategoryKeyword(
    category: ReminderCategory.subscription,
    term: '멤버십',
    weight: 0.96,
  ),
  _CategoryKeyword(
    category: ReminderCategory.subscription,
    term: '자동결제',
    weight: 0.86,
  ),
  _CategoryKeyword(
    category: ReminderCategory.subscription,
    term: '정기결제',
    weight: 0.92,
  ),
  _CategoryKeyword(
    category: ReminderCategory.subscription,
    term: '넷플릭스',
    weight: 1.0,
  ),
  _CategoryKeyword(
    category: ReminderCategory.subscription,
    term: '유튜브',
    weight: 0.95,
  ),
  _CategoryKeyword(
    category: ReminderCategory.subscription,
    term: '쿠팡와우',
    weight: 0.92,
  ),
  _CategoryKeyword(
    category: ReminderCategory.insurance,
    term: '보험',
    weight: 1.0,
  ),
  _CategoryKeyword(
    category: ReminderCategory.insurance,
    term: '보험료',
    weight: 1.0,
  ),
  _CategoryKeyword(
    category: ReminderCategory.insurance,
    term: '보장내용',
    weight: 0.82,
  ),
  _CategoryKeyword(
    category: ReminderCategory.insurance,
    term: '보장',
    weight: 0.66,
  ),
  _CategoryKeyword(category: ReminderCategory.tax, term: '세금', weight: 0.96),
  _CategoryKeyword(category: ReminderCategory.tax, term: '주민세', weight: 1.0),
  _CategoryKeyword(category: ReminderCategory.tax, term: '자동차세', weight: 1.0),
  _CategoryKeyword(category: ReminderCategory.tax, term: '국세', weight: 1.0),
  _CategoryKeyword(category: ReminderCategory.tax, term: '지방세', weight: 1.0),
  _CategoryKeyword(category: ReminderCategory.tax, term: '재산세', weight: 1.0),
  _CategoryKeyword(
    category: ReminderCategory.medical,
    term: '진료비',
    weight: 1.0,
  ),
  _CategoryKeyword(
    category: ReminderCategory.medical,
    term: '병원',
    weight: 0.84,
  ),
  _CategoryKeyword(
    category: ReminderCategory.medical,
    term: '건강검진',
    weight: 1.0,
  ),
  _CategoryKeyword(
    category: ReminderCategory.medical,
    term: '검진',
    weight: 0.92,
  ),
  _CategoryKeyword(
    category: ReminderCategory.medical,
    term: '의료비',
    weight: 0.96,
  ),
  _CategoryKeyword(
    category: ReminderCategory.medical,
    term: '진료',
    weight: 0.76,
  ),
  _CategoryKeyword(
    category: ReminderCategory.contractRenewal,
    term: '계약기간',
    weight: 1.0,
  ),
  _CategoryKeyword(
    category: ReminderCategory.contractRenewal,
    term: '계약만료',
    weight: 1.0,
  ),
  _CategoryKeyword(
    category: ReminderCategory.contractRenewal,
    term: '재계약',
    weight: 1.0,
  ),
  _CategoryKeyword(
    category: ReminderCategory.contractRenewal,
    term: '갱신일',
    weight: 0.96,
  ),
  _CategoryKeyword(
    category: ReminderCategory.contractRenewal,
    term: '만료일',
    weight: 0.96,
  ),
  _CategoryKeyword(
    category: ReminderCategory.contractRenewal,
    term: '계약 갱신',
    weight: 1.0,
  ),
  _CategoryKeyword(
    category: ReminderCategory.contractRenewal,
    term: '사용기한',
    weight: 0.74,
  ),
  _CategoryKeyword(
    category: ReminderCategory.warranty,
    term: '보증기간',
    weight: 1.0,
  ),
  _CategoryKeyword(
    category: ReminderCategory.warranty,
    term: '무상보증',
    weight: 1.0,
  ),
  _CategoryKeyword(
    category: ReminderCategory.warranty,
    term: '보증',
    weight: 0.92,
  ),
  _CategoryKeyword(
    category: ReminderCategory.warranty,
    term: 'A/S',
    weight: 0.84,
  ),
  _CategoryKeyword(
    category: ReminderCategory.warranty,
    term: 'AS',
    weight: 0.82,
  ),
  _CategoryKeyword(
    category: ReminderCategory.warranty,
    term: '필터 교체',
    weight: 1.0,
  ),
  _CategoryKeyword(
    category: ReminderCategory.warranty,
    term: '필터',
    weight: 0.76,
  ),
];

const _genericDocumentTitles = <String>{
  '촬영한 문서',
  '가져온 사진 문서',
  '가져온 PDF 문서',
  '공유한 문서',
  'PDF 문서',
};

final _fullYearKoreanPattern = RegExp(
  r'((?:20\d{2}|19\d{2}))\s*년\s*(1[0-2]|0?[1-9])\s*월\s*(3[01]|[12]\d|0?[1-9])\s*일',
);
final _fullYearNumericPattern = RegExp(
  r'((?:20\d{2}|19\d{2}))(?:[./-])\s*(1[0-2]|0?[1-9])(?:[./-])\s*(3[01]|[12]\d|0?[1-9])',
);
final _monthDayKoreanPattern = RegExp(
  r'(1[0-2]|0?[1-9])\s*월\s*(3[01]|[12]\d|0?[1-9])\s*일',
);
final _monthDayNumericPattern = RegExp(
  r'(?<!\d)(1[0-2]|0?[1-9])[./-](3[01]|[12]\d|0?[1-9])(?!\d)',
);
final _amountPattern = RegExp(
  r'(?:₩|￦|krw)?\s*([0-9]{1,3}(?:,[0-9]{3})+|[0-9]{4,})(?:\s*원)?',
  caseSensitive: false,
);
