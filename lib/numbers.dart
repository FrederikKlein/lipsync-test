/// Spells out numbers as English words so they can be lip-synced.
///
/// Whole numbers up to [maxSpelledNumber] are read as words
/// ("12345" → "twelve thousand three hundred forty five"). Larger numbers and
/// numbers with leading zeros ("007") are read digit by digit. Thousands
/// commas are ignored ("12,345") and a decimal point is read as "point"
/// ("3.25" → "three point two five").
///
/// Words are separated by spaces, not hyphens, because a hyphen would make
/// the mouth pause.
String spellOutNumbers(String text) => text.replaceAllMapped(
  RegExp(r'\d+(?:[.,]\d+)*'),
  (m) => _spellToken(m[0]!),
);

const int maxSpelledNumber = 99999;

const List<String> _ones = [
  'zero',
  'one',
  'two',
  'three',
  'four',
  'five',
  'six',
  'seven',
  'eight',
  'nine',
  'ten',
  'eleven',
  'twelve',
  'thirteen',
  'fourteen',
  'fifteen',
  'sixteen',
  'seventeen',
  'eighteen',
  'nineteen',
];

const List<String> _tens = [
  '',
  '',
  'twenty',
  'thirty',
  'forty',
  'fifty',
  'sixty',
  'seventy',
  'eighty',
  'ninety',
];

String _spellToken(String token) {
  var number = token;
  if (RegExp(r'^\d{1,3}(,\d{3})+(\.\d+)?$').hasMatch(number)) {
    number = number.replaceAll(',', '');
  }

  final parts = number.split(RegExp(r'[.,]'));
  if (parts.length == 2 && number.contains('.')) {
    return '${_spellInteger(parts[0])} point ${_spellDigits(parts[1])}';
  }
  // Anything else, like "1,2" or "1.2.2024": read each group on its own.
  return parts.map(_spellInteger).join(' ');
}

String _spellInteger(String digits) {
  if (digits.length > 1 && digits.startsWith('0')) return _spellDigits(digits);
  final value = int.parse(digits);
  if (value > maxSpelledNumber) return _spellDigits(digits);
  return _belowHundredThousand(value);
}

String _spellDigits(String digits) =>
    digits.split('').map((d) => _ones[int.parse(d)]).join(' ');

String _belowHundredThousand(int n) {
  final thousands = n ~/ 1000;
  final rest = n % 1000;
  if (thousands == 0) return _belowThousand(n);
  final words = '${_belowThousand(thousands)} thousand';
  return rest == 0 ? words : '$words ${_belowThousand(rest)}';
}

String _belowThousand(int n) {
  final hundreds = n ~/ 100;
  final rest = n % 100;
  if (hundreds == 0) return _belowHundred(n);
  final words = '${_ones[hundreds]} hundred';
  return rest == 0 ? words : '$words ${_belowHundred(rest)}';
}

String _belowHundred(int n) {
  if (n < 20) return _ones[n];
  final unit = n % 10;
  final tens = _tens[n ~/ 10];
  return unit == 0 ? tens : '$tens ${_ones[unit]}';
}
