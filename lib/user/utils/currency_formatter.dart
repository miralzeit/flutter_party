import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class Money {
  const Money({required this.amount, required this.currencyCode});

  final num amount;
  final String currencyCode;
}

String formatCurrency(
  num amount,
  String currencyCode,
  Locale locale, {
  String? fallbackCurrencyCode,
}) {
  final normalizedCurrency = currencyCode.trim().toUpperCase();
  final safeCurrency = normalizedCurrency.isEmpty
      ? (fallbackCurrencyCode ?? 'USD')
      : normalizedCurrency;
  final localeName = locale.toLanguageTag();

  return NumberFormat.currency(
    locale: localeName,
    name: safeCurrency,
  ).format(amount);
}

String formatMoney(
  Money money,
  BuildContext context, {
  String? fallbackCurrencyCode,
}) {
  return formatCurrency(
    money.amount,
    money.currencyCode,
    Localizations.localeOf(context),
    fallbackCurrencyCode: fallbackCurrencyCode,
  );
}
