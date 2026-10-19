import 'package:flutter/services.dart';

/// Formats typed digits as `dd-mm-yyyy`, inserting dashes automatically.
///
/// A dash is only added once the next digit is typed, so backspacing
/// through `12-3` → `12` works without getting stuck on the dash.
class DobInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 8) digits = digits.substring(0, 8);

    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 2 || i == 4) buffer.write('-');
      buffer.write(digits[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Parses a `dd-mm-yyyy` string, returning null if it isn't a real date.
DateTime? parseDob(String value) {
  final match = RegExp(r'^(\d{2})-(\d{2})-(\d{4})$').firstMatch(value.trim());
  if (match == null) return null;
  final day = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final year = int.parse(match.group(3)!);
  final date = DateTime(year, month, day);
  // DateTime rolls invalid dates over (31-02 → 03-03), so compare back.
  if (date.year != year || date.month != month || date.day != day) return null;
  return date;
}

/// Form validator for an optional date-of-birth field.
String? validateDob(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return null;
  final date = parseDob(text);
  if (date == null) return 'Enter a valid date as dd-mm-yyyy';
  if (date.isAfter(DateTime.now())) return 'Date of birth can’t be in the future';
  if (date.year < 1900) return 'Enter a year after 1900';
  return null;
}
