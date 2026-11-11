import 'package:flutter_test/flutter_test.dart';
import 'package:lipsync_test/numbers.dart';
import 'package:lipsync_test/viseme.dart';

void main() {
  test('spells small numbers', () {
    expect(spellOutNumbers('0'), 'zero');
    expect(spellOutNumbers('7'), 'seven');
    expect(spellOutNumbers('13'), 'thirteen');
    expect(spellOutNumbers('40'), 'forty');
    expect(spellOutNumbers('42'), 'forty two');
  });

  test('spells hundreds and thousands', () {
    expect(spellOutNumbers('100'), 'one hundred');
    expect(spellOutNumbers('305'), 'three hundred five');
    expect(spellOutNumbers('1000'), 'one thousand');
    expect(spellOutNumbers('2024'), 'two thousand twenty four');
    expect(
      spellOutNumbers('12345'),
      'twelve thousand three hundred forty five',
    );
    expect(
      spellOutNumbers('99999'),
      'ninety nine thousand nine hundred ninety nine',
    );
  });

  test('handles separators, leading zeros and large numbers', () {
    expect(
      spellOutNumbers('12,345'),
      'twelve thousand three hundred forty five',
    );
    expect(spellOutNumbers('3.25'), 'three point two five');
    expect(spellOutNumbers('007'), 'zero zero seven');
    expect(spellOutNumbers('100000'), 'one zero zero zero zero zero');
  });

  test('leaves the surrounding text alone', () {
    expect(
      spellOutNumbers('I have 3 apples, 2 pears.'),
      'I have three apples, two pears.',
    );
  });

  test('numbers turn into mouth shapes', () {
    expect(textToVisemes('2'), textToVisemes('two'));
    expect(textToVisemes('21'), textToVisemes('twenty one'));
  });
}
