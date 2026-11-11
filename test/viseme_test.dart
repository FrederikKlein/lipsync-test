import 'package:flutter_test/flutter_test.dart';
import 'package:lipsync_test/viseme.dart';

List<Viseme> long(Viseme v) => List.filled(longSoundBeats, v);

void main() {
  test('maps letters from the chart', () {
    expect(textToVisemes('mbp'), [Viseme.mbp, Viseme.mbp, Viseme.mbp]);
    expect(textToVisemes('fv'), [Viseme.fv, Viseme.fv]);
    expect(textToVisemes('ai'), [Viseme.ahI, Viseme.ahI]);
    expect(textToVisemes('o'), [Viseme.oh]);
    expect(textToVisemes('uwr'), [Viseme.ooUWR, Viseme.ooUWR, Viseme.ooUWR]);
    expect(textToVisemes('L'), [Viseme.lTh]);
  });

  test('matches digraphs before single letters', () {
    expect(textToVisemes('sh'), [Viseme.sz]);
    expect(textToVisemes('th'), [Viseme.lTh]);
    expect(textToVisemes('schoo'), [Viseme.sz, ...long(Viseme.ooUWR)]);
  });

  test('skips h, closes on spaces and punctuation', () {
    expect(textToVisemes('Ohm'), [...long(Viseme.oh), Viseme.mbp]);
    expect(textToVisemes('a  b'), [Viseme.ahI, Viseme.closed, Viseme.mbp]);
  });

  test('handles a German word', () {
    expect(textToVisemes('Bär'), [Viseme.mbp, Viseme.ahI, Viseme.ooUWR]);
  });

  test('holds long vowels longer', () {
    expect(textToVisemes('read'),
        [Viseme.ooUWR, ...long(Viseme.eeUhEn), Viseme.eeUhEn]);
    expect(textToVisemes('Bahn'),
        [Viseme.mbp, ...long(Viseme.ahI), Viseme.eeUhEn]);
    expect(textToVisemes('Liebe'),
        [Viseme.lTh, ...long(Viseme.eeUhEn), Viseme.mbp, Viseme.eeUhEn]);
    expect(textToVisemes('boat'),
        [Viseme.mbp, ...long(Viseme.oh), Viseme.eeUhEn]);
  });

  test('keeps short vowels short', () {
    expect(textToVisemes('red'),
        [Viseme.ooUWR, Viseme.eeUhEn, Viseme.eeUhEn]);
    expect(textToVisemes('aha'), [Viseme.ahI, Viseme.ahI]);
  });

  test('punctuation pauses longer, the longest pause in a row wins', () {
    List<Viseme> closed(int n) => List.filled(n, Viseme.closed);
    expect(textToVisemes('a b'), [Viseme.ahI, ...closed(1), Viseme.mbp]);
    expect(textToVisemes('a, b'), [Viseme.ahI, ...closed(3), Viseme.mbp]);
    expect(textToVisemes('a. b'), [Viseme.ahI, ...closed(6), Viseme.mbp]);
    expect(textToVisemes('a?! b'), [Viseme.ahI, ...closed(6), Viseme.mbp]);
  });
}
