import 'numbers.dart';

/// The mouth shapes the Rive animation can show.
///
/// [riveValue] is the exact string written to the `Laut` view model property.
/// It MUST match the values used in the state machine's transition conditions
/// in the .riv file. Change them here if the file uses different names.
enum Viseme {
  closed(' '),
  mbp('m'),
  sz('s'),
  fv('f'),
  ahI('ah'),
  oh('oh'),
  eeUhEn('ee'),
  ooUWR('oo'),
  lTh('l');

  const Viseme(this.riveValue);

  final String riveValue;
}

/// How many beats a long vowel is held, compared to 1 for a normal sound.
const int longSoundBeats = 3;

/// Multi-letter sounds. Checked before single letters, longest first.
const Map<String, Viseme> _digraphs = {
  'sch': Viseme.sz,
  'sh': Viseme.sz,
  'ch': Viseme.sz,
  'th': Viseme.lTh,
  'ph': Viseme.fv,
  'qu': Viseme.ooUWR,
};

/// Letter groups that make one long vowel (read = riiid).
const Map<String, Viseme> _longVowels = {
  'aa': Viseme.ahI,
  'ee': Viseme.eeUhEn,
  'ea': Viseme.eeUhEn,
  'ie': Viseme.eeUhEn,
  'oo': Viseme.ooUWR,
  'oa': Viseme.oh,
};

/// How many beats the mouth stays closed for a pause. Spaces and other
/// unknown characters take one beat.
const Map<String, int> _pauseBeats = {
  ',': 3,
  ';': 3,
  ':': 3,
  '-': 3,
  '–': 3,
  '—': 3,
  '.': 6,
  '!': 6,
  '?': 6,
  '…': 6,
};

const Set<String> _vowels = {'a', 'e', 'i', 'o', 'u', 'ä', 'ö', 'ü'};

const Map<String, Viseme> _letters = {
  // Shown in the chart
  'm': Viseme.mbp,
  'b': Viseme.mbp,
  'p': Viseme.mbp,
  's': Viseme.sz,
  'c': Viseme.sz,
  'z': Viseme.sz,
  'f': Viseme.fv,
  'v': Viseme.fv,
  'a': Viseme.ahI,
  'i': Viseme.ahI,
  'o': Viseme.oh,
  'e': Viseme.eeUhEn,
  'u': Viseme.ooUWR,
  'w': Viseme.ooUWR,
  'r': Viseme.ooUWR,
  'l': Viseme.lTh,
  // Not in the chart: closest shape
  'x': Viseme.sz,
  'j': Viseme.sz,
  'y': Viseme.eeUhEn,
  'd': Viseme.eeUhEn,
  't': Viseme.eeUhEn,
  'n': Viseme.eeUhEn,
  'k': Viseme.eeUhEn,
  'g': Viseme.eeUhEn,
  'q': Viseme.ooUWR,
  // German
  'ä': Viseme.ahI,
  'ö': Viseme.oh,
  'ü': Viseme.ooUWR,
  'ß': Viseme.sz,
};

/// Letters that don't get their own mouth shape (the mouth keeps its shape).
const Set<String> _silent = {'h'};

final int _maxDigraphLength =
    _digraphs.keys.map((k) => k.length).reduce((a, b) => a > b ? a : b);

/// Turns [text] into the sequence of mouth shapes to play, one entry per beat.
///
/// Long vowels (aa, ee, ea, ie, oo, oa, and a vowel followed by a silent h
/// like in "Bahn") are repeated [longSoundBeats] times so they are held longer.
/// Numbers are spelled out as English words first (see [spellOutNumbers]).
/// Silent letters (h) are skipped. Spaces, punctuation and other unknown
/// characters close the mouth. Punctuation keeps it closed longer (see
/// [_pauseBeats]). When several of them follow each other, the longest pause
/// wins: "end. Next" pauses as long as ".", not "." plus the space.
List<Viseme> textToVisemes(String text) {
  final input = spellOutNumbers(text).toLowerCase();
  final result = <Viseme>[];
  var i = 0;

  while (i < input.length) {
    Viseme? match;
    var length = 1;
    var beats = 1;

    if (i + 2 <= input.length) {
      final long = _longVowels[input.substring(i, i + 2)];
      if (long != null) {
        match = long;
        length = 2;
        beats = longSoundBeats;
      }
    }

    for (var len = _maxDigraphLength; len >= 2 && match == null; len--) {
      if (i + len > input.length) continue;
      final candidate = _digraphs[input.substring(i, i + len)];
      if (candidate != null) {
        match = candidate;
        length = len;
      }
    }

    if (match == null && _silent.contains(input[i])) {
      i++;
      continue;
    }

    if (match == null && _isVowelBeforeSilentH(input, i)) {
      beats = longSoundBeats;
    }

    match ??= _letters[input[i]];

    if (match == null) {
      final pause = _pauseBeats[input[i]] ?? 1;
      final alreadyClosed = _trailingClosedBeats(result);
      if (pause > alreadyClosed) {
        result.addAll(List.filled(pause - alreadyClosed, Viseme.closed));
      }
    } else {
      result.addAll(List.filled(beats, match));
    }

    i += length;
  }

  return result;
}

/// A vowel followed by an h that isn't followed by another vowel, like
/// "Bahn", "Uhr" or "oh". In "aha" the h is spoken, so the a stays short.
bool _isVowelBeforeSilentH(String input, int i) {
  if (!_vowels.contains(input[i])) return false;
  if (i + 1 >= input.length || input[i + 1] != 'h') return false;
  return i + 2 >= input.length || !_vowels.contains(input[i + 2]);
}

int _trailingClosedBeats(List<Viseme> result) {
  var count = 0;
  for (var i = result.length - 1; i >= 0 && result[i] == Viseme.closed; i--) {
    count++;
  }
  return count;
}
