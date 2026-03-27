import 'dart:ui';

import 'package:intl/intl.dart';

import '../../app/localization/app_strings.dart';

class AppFormatters {
  static String currency(
    num? amount, {
    String? currencyCode,
    Locale? locale,
    String? emptyAmountLabel,
    String? unknownCurrencyLabel,
  }) {
    final strings = AppStrings.current;
    if (amount == null) {
      return emptyAmountLabel ?? strings.noAmountLabel;
    }

    final resolvedLocale = _resolvedLocale(locale);
    final normalizedCurrency = currencyCode?.toUpperCase();

    if (normalizedCurrency == 'USD') {
      final formatter = NumberFormat.currency(
        locale: 'en_US',
        symbol: resolvedLocale.languageCode == 'ko' ? 'US\$' : '\$',
        decimalDigits: 2,
      );
      return formatter.format(amount);
    }

    if (normalizedCurrency == 'KRW' || normalizedCurrency == null) {
      if (normalizedCurrency == null) {
        final formatter = NumberFormat.decimalPatternDigits(
          locale: _localeName(resolvedLocale),
          decimalDigits: amount % 1 == 0 ? 0 : 2,
        );
        return '${formatter.format(amount)} (${unknownCurrencyLabel ?? strings.unknownCurrencyLabel})';
      }

      final formatter = NumberFormat.currency(
        locale: _localeName(resolvedLocale),
        symbol: resolvedLocale.languageCode == 'en' ? 'KRW ' : '₩',
        decimalDigits: 0,
      );
      return formatter.format(amount);
    }

    final fallbackFormatter = NumberFormat.decimalPatternDigits(
      locale: _localeName(resolvedLocale),
      decimalDigits: amount % 1 == 0 ? 0 : 2,
    );
    return '${fallbackFormatter.format(amount)} ($normalizedCurrency)';
  }

  static String dueDate(DateTime date, {Locale? locale}) {
    final resolvedLocale = _resolvedLocale(locale);
    final formatter = DateFormat(
      resolvedLocale.languageCode == 'en' ? 'MMM d (EEE)' : 'M월 d일 (E)',
      _localeName(resolvedLocale),
    );
    return formatter.format(date);
  }

  static String shortDate(DateTime date, {Locale? locale}) {
    final resolvedLocale = _resolvedLocale(locale);
    final formatter = DateFormat(
      resolvedLocale.languageCode == 'en' ? 'MMM d' : 'M월 d일',
      _localeName(resolvedLocale),
    );
    return formatter.format(date);
  }

  static String calendarDate(DateTime date, {Locale? locale}) {
    final resolvedLocale = _resolvedLocale(locale);
    final formatter = DateFormat(
      resolvedLocale.languageCode == 'en' ? 'y MMM d' : 'yyyy년 M월 d일',
      _localeName(resolvedLocale),
    );
    return formatter.format(date);
  }

  static bool isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  static bool isThisWeek(DateTime date, DateTime now) {
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 7));
    return !date.isBefore(start) && date.isBefore(end);
  }

  static bool isThisMonth(DateTime date, DateTime now) {
    return date.year == now.year && date.month == now.month;
  }

  static String relativeLabel(
    DateTime date,
    DateTime now, {
    Locale? locale,
    String? todayLabel,
    String? tomorrowLabel,
  }) {
    final strings = AppStrings.current;
    if (isSameDay(date, now)) {
      return todayLabel ?? strings.todayRelativeLabel;
    }

    if (isSameDay(date, now.add(const Duration(days: 1)))) {
      return tomorrowLabel ?? strings.tomorrowRelativeLabel;
    }

    return shortDate(date, locale: locale);
  }

  static Locale _resolvedLocale(Locale? locale) =>
      locale ?? const Locale('ko', 'KR');

  static String _localeName(Locale locale) => switch (locale.languageCode) {
    'en' => 'en_US',
    _ => 'ko_KR',
  };
}
