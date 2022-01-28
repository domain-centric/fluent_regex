/*
 * Copyright (c) 2021 by Nils ten Hoeve. See LICENSE file in project.
 */

import 'package:fluent_regex/fluent_regex.dart';
import 'package:test/test.dart';

void main() {
  group('class: FluentRegex', () {
    group('Flags', () {
      group('Multiline', () {
        test('multiline on by default', () {
          var regex = FluentRegex().startOfLine().literal('a');
          expect(regex.hasMatch('first line\na'), true);
          expect(regex.hasMatch('a'), true);
        });
        test('method: multiline(false)', () {
          var regex = FluentRegex().startOfLine().literal('a').multiline(false);
          expect(regex.hasMatch('first line \na'), false);
          expect(regex.hasMatch('a'), true);
        });
        test('method: searchFirstLineOnly()', () {
          var regex =
              FluentRegex().startOfLine().literal('a').searchFirstLineOnly();
          expect(regex.hasMatch('first line\na'), false);
          expect(regex.hasMatch('a'), true);
        });
      });
      group('IgnoreCase', () {
        test('Case sensitive by default', () {
          var regex = FluentRegex().literal('a');
          expect(regex.hasMatch('A'), false);
          expect(regex.hasMatch('a'), true);
        });
        test('method: ignoreCase()', () {
          var regex = FluentRegex().literal('a').ignoreCase();
          expect(regex.hasMatch('A'), true);
          expect(regex.hasMatch('a'), true);
        });
      });
      group('StartOfLine', () {
        test('method: startOfLine()', () {
          var regex = FluentRegex().startOfLine().literal('abc');
          expect(regex.hasMatch('abc12'), true);
          expect(regex.hasMatch('12abc'), false);
        });
      });
      group('EndOfLine', () {
        test('method: endOfLine()', () {
          var regex = FluentRegex().literal('abc').endOfLine();
          expect(regex.hasMatch('abc12'), false);
          expect(regex.hasMatch('12abc'), true);
        });
      });
    });
    group('Literals', () {
      test('method: literal()', () {
        var regex = FluentRegex().literal('abc');
        expect(regex.hasMatch('abc12'), true);
        expect(regex.hasMatch('12abc34'), true);
        expect(regex.hasMatch('12ab34'), false);
      });
      test('method: literal(Quantity)', () {
        var regex = FluentRegex().literal('abc', Quantity.exactly(2));
        expect(regex.hasMatch('abcabc12'), true);
        expect(regex.hasMatch('12abcabc34'), true);
        expect(regex.hasMatch('12ab34'), false);
      });

      test('method: characterSet()', () {
        var regex = FluentRegex().characterSet(CharacterSet()
            .addDigits()
            .addLetters(CaseType.lower)
            .addRange('K', 'P')
            .addLiterals('_-'));
        expect(regex.hasMatch('abc12KP_-'), true);
        expect(regex.findFirst('!abc12KP_-!'), 'a');
        expect(regex.findFirst('AB!2KP_-abc12KP_-!'), '2');
      });

      test('method: characterSet(Quantity)', () {
        var regex = FluentRegex().characterSet(
            CharacterSet()
                .addDigits()
                .addLetters(CaseType.lower)
                .addRange('K', 'P')
                .addLiterals('_-'),
            Quantity.exactly(10));
        expect(regex.hasMatch('abc12KP_-'), false);
        expect(regex.hasMatch('!abc12KP_-a'), true);
        expect(regex.findFirst('!!abc12KP_-abc12KP_-!'), 'abc12KP_-a');
      });
    });

    group('Special characters', () {
      test('method: wordChar()', () {
        var regex = FluentRegex().wordChar();
        expect(regex.hasMatch('l'), true);
        expect(regex.hasMatch('W'), true);
        expect(regex.hasMatch('5'), true);
        expect(regex.hasMatch('_'), true);
        expect(regex.hasMatch('%'), false);
      });
      test('method: nonWordChar()', () {
        var regex = FluentRegex().nonWordChar();
        expect(regex.hasMatch('l'), false);
        expect(regex.hasMatch('W'), false);
        expect(regex.hasMatch('5'), false);
        expect(regex.hasMatch('_'), false);
        expect(regex.hasMatch('%'), true);
      });
      test('method: digit()', () {
        var regex = FluentRegex().digit();
        expect(regex.hasMatch('l'), false);
        expect(regex.hasMatch('W'), false);
        expect(regex.hasMatch('5'), true);
        expect(regex.hasMatch('_'), false);
        expect(regex.hasMatch('%'), false);
      });
      test('method: nonDigit()', () {
        var regex = FluentRegex().nonDigit();
        expect(regex.hasMatch('l'), true);
        expect(regex.hasMatch('W'), true);
        expect(regex.hasMatch('5'), false);
        expect(regex.hasMatch('_'), true);
        expect(regex.hasMatch('%'), true);
      });
      test('method: letter()', () {
        var regex = FluentRegex().letter();
        expect(regex.hasMatch('l'), true);
        expect(regex.hasMatch('W'), true);
        expect(regex.hasMatch('5'), false);
        expect(regex.hasMatch('_'), false);
        expect(regex.hasMatch('%'), false);
      });
      test('method: nonLetter()', () {
        var regex = FluentRegex().nonLetter();
        expect(regex.hasMatch('5'), true);
        expect(regex.hasMatch('_'), true);
        expect(regex.hasMatch('%'), true);
        expect(regex.hasMatch('l'), false);
        expect(regex.hasMatch('W'), false);
      });

      test('method: anyCharacter()', () {
        var regex = FluentRegex().anyCharacter();
        expect(regex.findFirst('abc'), 'a');
      });
    });

    group('White space', () {
      test('method: wordChar()', () {
        var regex = FluentRegex().tab();
        expect(regex.hasMatch('hello'), false);
        expect(regex.hasMatch('\u0009hello'), true);
        expect(regex.hasMatch('hello\tall'), true);
      });

      test('method: tab()', () {
        var regex = FluentRegex().tab();
        expect(regex.hasMatch('hello'), false);
        expect(regex.hasMatch('\u0009hello'), true);
        expect(regex.hasMatch('hello\tall'), true);
      });

      test('method: whiteSpace()', () {
        var regex = FluentRegex().whiteSpace();
        expect(regex.hasMatch(' '), true);
        expect(regex.hasMatch('\u0009'), true);
        expect(regex.hasMatch('\n'), true);
        expect(regex.hasMatch('\x0B'), true);
        expect(regex.hasMatch('\f'), true);
        expect(regex.hasMatch('\r'), true);
        expect(regex.hasMatch('h'), false);
      });

      test('method: nonWhiteSpace()', () {
        var regex = FluentRegex().nonWhiteSpace();
        expect(regex.hasMatch(' '), false);
        expect(regex.hasMatch('\u0009'), false);
        expect(regex.hasMatch('\n'), false);
        expect(regex.hasMatch('\x0B'), false);
        expect(regex.hasMatch('\f'), false);
        expect(regex.hasMatch('\r'), false);
        expect(regex.hasMatch('h'), true);
      });

      test('method: lineBreak()', () {
        var regex = FluentRegex().lineBreak();
        expect(regex.findFirst('hello\rworld'), '\r');
        expect(regex.findFirst('hello\nworld'), '\n');
        expect(regex.findFirst('hello\r\nworld'), '\r\n');
        expect(regex.findFirst('hello\r\rworld'), '\r\r');
        expect(regex.hasMatch('hello world'), false);
      });
    });

    group('Groups', () {
      test('method: group()', () {
        var regex = FluentRegex()
            .literal('a')
            .group(FluentRegex().literal('bc'), quantity: Quantity.exactly(2));
        expect(regex.hasMatch('abc'), false);
        expect(regex.hasMatch('abcbc'), true);
      });
      test('method: or()', () {
        var regex = FluentRegex().or([
          FluentRegex().literal('ab'),
          FluentRegex().literal('cd'),
        ]);
        expect(regex.hasMatch('ab'), true);
        expect(regex.hasMatch('cd'), true);
        expect(regex.hasMatch('bc'), false);
      });
    });

    group('Default expressions', () {
      group('getter: e-mail', () {
        test('sometest@gmail.com', () {
          expect(
              FluentRegex().emailAddress.hasMatch('sometest@gmail.com'), true);
        });
        test('some+test@gmail.com', () {
          expect(
              FluentRegex().emailAddress.hasMatch('some+test@gmail.com'), true);
        });
        test('stuart.sillitoe@prodirectsport.net', () {
          expect(
              FluentRegex()
                  .emailAddress
                  .hasMatch('stuart.sillitoe@prodirectsport.net'),
              true);
        });
        test('_valid@mail.com', () {
          expect(FluentRegex().emailAddress.hasMatch('_valid@mail.com'), true);
        });
        test('also+valid@domain.com', () {
          expect(FluentRegex().emailAddress.hasMatch('also+valid@domain.com'),
              true);
        });
        test('sometest@[255.255.255.255]', () {
          expect(
              FluentRegex().emailAddress.hasMatch('sometest@[255.255.255.255]'),
              true);
        });
        test('invalid%\$£"@domain.com', () {
          expect(FluentRegex().emailAddress.hasMatch('invalid%\$£"@domain.com'),
              false);
        });
        test('invalid£@domain.com', () {
          expect(FluentRegex().emailAddress.hasMatch('invalid£@domain.com'),
              false);
        });
        test('valid%\$@domain.com', () {
          expect(
              FluentRegex().emailAddress.hasMatch('valid%\$@domain.com'), true);
        });
        test('sometest@gmail', () {
          expect(FluentRegex().emailAddress.hasMatch('sometest@gmail'), false);
        });
        test('sometest@[256.255.100.100]', () {
          expect(
              FluentRegex().emailAddress.hasMatch('sometest@[256.255.100.100]'),
              false);
        });
      });
    });

    group('Conversion', () {
      group('method: escape', () {
        test("method: escape('a\\^\$.bc|?*d+-()[]{}1')", () {
          expect(FluentRegex.escape('a\\^\$.bc|?*d+-()[]{}1'),
              'a\\\\\\^\\\$\\.bc\\|\\?\\*d\\+\\-\\(\\)\\[\\]\\{\\}1');
        });
        test("method: escape('\\')", () {
          expect(FluentRegex.escape('\\'), '\\\\');
        });
        test("method: escape('^')", () {
          expect(FluentRegex.escape('^'), '\\^');
        });
        test("method: escape('\$')", () {
          expect(FluentRegex.escape('\$'), '\\\$');
        });
        test("method: escape('.')", () {
          expect(FluentRegex.escape('.'), '\\.');
        });
        test("method: escape('|')", () {
          expect(FluentRegex.escape('|'), '\\|');
        });
        test("method: escape('?')", () {
          expect(FluentRegex.escape('?'), '\\?');
        });
        test("method: escape('|')", () {
          expect(FluentRegex.escape('|'), '\\|');
        });
        test("method: escape('*')", () {
          expect(FluentRegex.escape('*'), '\\*');
        });
        test("method: escape('+')", () {
          expect(FluentRegex.escape('+'), '\\+');
        });
        test("method: escape('-')", () {
          expect(FluentRegex.escape('-'), '\\-');
        });
        test("method: escape('(')", () {
          expect(FluentRegex.escape('('), '\\(');
        });
        test("method: escape(')')", () {
          expect(FluentRegex.escape(')'), '\\)');
        });
        test("method: escape('[')", () {
          expect(FluentRegex.escape('['), '\\[');
        });
        test("method: escape(']')", () {
          expect(FluentRegex.escape(']'), '\\]');
        });
        test("method: escape('{')", () {
          expect(FluentRegex.escape('{'), '\\{');
        });
        test("method: escape('}')", () {
          expect(FluentRegex.escape('}'), '\\}');
        });
        test("method: escape('}')", () {
          expect(FluentRegex.escape('}'), '\\}');
        });
        test("method: escape('a')", () {
          expect(FluentRegex.escape('a'), 'a');
        });
        test("method: escape()'", () {
          expect(FluentRegex.escape('a\\^\$.bc|?*d+()[]{}1'),
              'a\\\\\\^\\\$\\.bc\\|\\?\\*d\\+\\(\\)\\[\\]\\{\\}1');
        });
      });
    });

    group('Convenience methods', () {
      test('method: hasNoMatch', () {
        expect(FluentRegex().digit().hasNoMatch('a'), true);
        expect(FluentRegex().letter().hasNoMatch('a'), false);
      });
      test('method: replaceFirst', () {
        expect(
            FluentRegex().literal('a').replaceFirst('bababa', 'c'), 'bcbaba');
      });
      test('method: replaceAll', () {
        expect(FluentRegex().literal('a').replaceAll('bababa', 'c'), 'bcbcbc');
      });
      test('method: removeFirst', () {
        expect(FluentRegex().literal('a').removeFirst('bababa'), 'bbaba');
      });
      test('method: removeAll', () {
        expect(FluentRegex().literal('a').removeAll('bababa'), 'bbb');
      });
      test('method: findFirst', () {
        expect(FluentRegex().literal('a').findFirst('bababa'), 'a');
        expect(FluentRegex().literal('c').findFirst('bababa'), null);
      });
      test('method: findAll', () {
        expect(FluentRegex().digit().findAll('a1bc2D3e&(f4'),
            ['1', '2', '3', '4']);
        expect(FluentRegex().letter().findAll('123&(4'), []);
      });
      test('method: findCapturedGroups', () {
        expect(
            FluentRegex()
                .group(FluentRegex().literal('a').digit().literal('b'),
                    type: GroupType.captureNamed('name'))
                .findCapturedGroups('@abc2a7bD3e&(f4'),
            {
              'name': 'a7b',
            });
      });
    });
  });

  group('class: Quantity', () {
    test('constructor: zeroOrOneTime()', () {
      var regex = FluentRegex().literal('a', Quantity.zeroOrOneTime());
      expect(regex.hasMatch(''), true);
      expect(regex.hasMatch('a'), true);
    });
    test('constructor: zeroOrMoreTimes()', () {
      var regex = FluentRegex().literal('a', Quantity.zeroOrMoreTimes());
      expect(regex.hasMatch(''), true);
      expect(regex.hasMatch('a'), true);
      expect(regex.hasMatch('aa'), true);
    });
    test('constructor: oneTime()', () {
      var regex = FluentRegex().literal('a', Quantity.oneTime());
      expect(regex.hasMatch(''), false);
      expect(regex.hasMatch('a'), true);
    });
    test('constructor: oneOrMoreTimes()', () {
      var regex = FluentRegex().literal('a', Quantity.oneOrMoreTimes());
      expect(regex.hasMatch(''), false);
      expect(regex.hasMatch('a'), true);
      expect(regex.hasMatch('aa'), true);
    });
    test('constructor: exactly()', () {
      var regex = FluentRegex().literal('a', Quantity.exactly(2));
      expect(regex.hasMatch(''), false);
      expect(regex.hasMatch('a'), false);
      expect(regex.hasMatch('aa'), true);
      expect(regex.findFirst('aaa'), 'aa');
    });
    test('constructor: between()', () {
      var regex = FluentRegex().literal('a', Quantity.between(1, 2));
      expect(regex.hasMatch(''), false);
      expect(regex.hasMatch('a'), true);
      expect(regex.hasMatch('aa'), true);
      expect(regex.findFirst('aaa'), 'aa');
    });
    test('constructor: atLeast()', () {
      var regex = FluentRegex().literal('a', Quantity.atLeast(2));
      expect(regex.hasMatch(''), false);
      expect(regex.hasMatch('a'), false);
      expect(regex.hasMatch('aa'), true);
      expect(regex.findFirst('aaa'), 'aaa');
    });
    test('constructor: atMost()', () {
      var regex = FluentRegex().literal('a', Quantity.atMost(2));
      expect(regex.hasMatch(''), true);
      expect(regex.hasMatch('a'), true);
      expect(regex.hasMatch('aa'), true);
      expect(regex.findFirst('aaa'), 'aa');
    });
    test('getter: greedy', () {
      var regex = FluentRegex()
          .anyCharacter(Quantity.zeroOrMoreTimes().greedy)
          .literal('foo');
      expect(regex.findFirst('xfooxxxxxxfoo'), 'xfooxxxxxxfoo');
    });
    test('getter: reluctant', () {
      var regex = FluentRegex()
          .anyCharacter(Quantity.zeroOrMoreTimes().reluctant)
          .literal('foo');
      expect(regex.findFirst('xfooxxxxxxfoo'), 'xfoo');
    });
    test('getter: possessive', () {
      var regex = FluentRegex()
          .anyCharacter(Quantity.zeroOrMoreTimes().possessive)
          .literal('foo');
      expect(
          () => {regex.hasMatch('xfooxxxxxxfoo')},
          throwsA((e) =>
              e.toString() == 'FormatException: Nothing to repeat.*+foo'));
    });
  });

  group('class: CharacterSet', () {
    group('method: addDigits()', () {
      test('characterSet(CharacterSet().addDigits())', () {
        var regex = FluentRegex().characterSet(CharacterSet().addDigits());
        expect(regex.hasMatch('1'), true);
        expect(regex.hasMatch('a'), false);
      });
      test('characterSet(CharacterSet().addDigits(), Quantity.exactly(2))', () {
        var regex = FluentRegex()
            .characterSet(CharacterSet().addDigits(), Quantity.exactly(2));
        expect(regex.hasMatch('1'), false);
        expect(regex.hasMatch('23'), true);
        expect(regex.findFirst('456'), '45');
      });
      test('characterSet(CharacterSet.exclude().addDigits())', () {
        var regex =
            FluentRegex().characterSet(CharacterSet.exclude().addDigits());
        expect(regex.hasMatch('1'), false);
        expect(regex.hasMatch('a'), true);
      });
    });

    group('method: addNoneDigits()', () {
      test('characterSet(CharacterSet().addNoneDigits())', () {
        var regex = FluentRegex().characterSet(CharacterSet().addNoneDigits());
        expect(regex.hasMatch('1'), false);
        expect(regex.hasMatch('a'), true);
      });
      test('characterSet(CharacterSet().addDigits(), Quantity.exactly(2))', () {
        var regex = FluentRegex()
            .characterSet(CharacterSet().addNoneDigits(), Quantity.exactly(2));
        expect(regex.hasMatch('1'), false);
        expect(regex.hasMatch('23'), false);
        expect(regex.hasMatch('a!'), true);
        expect(regex.findFirst('bCd'), 'bC');
      });
      test('characterSet(CharacterSet.exclude().addDigits())', () {
        var regex =
            FluentRegex().characterSet(CharacterSet.exclude().addNoneDigits());
        expect(regex.hasMatch('1'), true);
        expect(regex.hasMatch('a'), false);
      });
    });

    group('method: addWordCharacters()', () {
      test('characterSet(CharacterSet().addWordCharacters())', () {
        var regex = FluentRegex().characterSet(CharacterSet().addWordChars());
        expect(regex.hasMatch('a'), true);
        expect(regex.hasMatch('Z'), true);
        expect(regex.hasMatch('1'), true);
        expect(regex.hasMatch('!'), false);
      });
      test(
          'characterSet(CharacterSet().addWordCharacters(), Quantity.exactly(2))',
          () {
        var regex = FluentRegex()
            .characterSet(CharacterSet().addWordChars(), Quantity.exactly(2));
        expect(regex.hasMatch('1'), false);
        expect(regex.hasMatch('a3'), true);
        expect(regex.hasMatch('a!'), false);
        expect(regex.findFirst('b9d'), 'b9');
      });
      test('characterSet(CharacterSet.exclude().addWordCharacters())', () {
        var regex =
            FluentRegex().characterSet(CharacterSet.exclude().addWordChars());
        expect(regex.hasMatch('1'), false);
        expect(regex.hasMatch('!'), true);
      });
    });

    group('method: addNoneWordCharacters()', () {
      test('characterSet(CharacterSet().addNoneWordCharacters())', () {
        var regex =
            FluentRegex().characterSet(CharacterSet().addNoneWordChars());
        expect(regex.hasMatch('a'), false);
        expect(regex.hasMatch('Z'), false);
        expect(regex.hasMatch('1'), false);
        expect(regex.hasMatch('!'), true);
      });
      test(
          'characterSet(CharacterSet().addNoneWordCharacters(), Quantity.exactly(2))',
          () {
        var regex = FluentRegex().characterSet(
            CharacterSet().addNoneWordChars(), Quantity.exactly(2));
        expect(regex.hasMatch('!'), false);
        expect(regex.hasMatch('!@'), true);
        expect(regex.hasMatch('a!'), false);
        expect(regex.findFirst('!@9d'), '!@');
      });
      test('characterSet(CharacterSet.exclude().addNoneWordCharacters())', () {
        var regex = FluentRegex()
            .characterSet(CharacterSet.exclude().addNoneWordChars());
        expect(regex.hasMatch('1'), true);
        expect(regex.hasMatch('!'), false);
      });
    });

    group('method: addWhiteSpaces()', () {
      test('WhiteSpaces', () {
        var regex = FluentRegex().characterSet(CharacterSet().addWhiteSpaces());
        expect(regex.hasMatch(' '), true);
        expect(regex.hasMatch('\u0009'), true);
        expect(regex.hasMatch('\n'), true);
        expect(regex.hasMatch('\x0B'), true);
        expect(regex.hasMatch('\f'), true);
        expect(regex.hasMatch('\r'), true);
        expect(regex.hasMatch('h'), false);
      });
    });
    group('method: addNoneWhiteSpaces()', () {
      test('NoneWhiteSpaces', () {
        var regex =
            FluentRegex().characterSet(CharacterSet().addNoneWhiteSpaces());
        expect(regex.hasMatch(' '), false);
        expect(regex.hasMatch('\u0009'), false);
        expect(regex.hasMatch('\n'), false);
        expect(regex.hasMatch('\x0B'), false);
        expect(regex.hasMatch('\f'), false);
        expect(regex.hasMatch('\r'), false);
        expect(regex.hasMatch('h'), true);
      });
    });

    group('method: addTabs()', () {
      test('Tabs', () {
        var regex = FluentRegex().characterSet(CharacterSet().addTabs());
        expect(regex.hasMatch('hello'), false);
        expect(regex.hasMatch('\u0009hello'), true);
        expect(regex.hasMatch('hello\tall'), true);
      });
    });

    group('method: addLineBreaks()', () {
      test('LineBreaks', () {
        var regex = FluentRegex().characterSet(CharacterSet().addLineBreaks());
        expect(regex.findFirst('hello\rworld'), '\r');
        expect(regex.findFirst('hello\nworld'), '\n');
        expect(regex.findAll('hello\r\nworld').length, 2);
        expect(regex.findAll('hello\r\rworld').length, 2);
        expect(regex.hasMatch('hello world'), false);
      });
    });

    group('method: addLetters()', () {
      test('characterSet(CharacterSet().addLetters())', () {
        var regex = FluentRegex().characterSet(CharacterSet().addLetters());
        expect(regex.hasMatch('a'), true);
        expect(regex.hasMatch('B'), true);
        expect(regex.hasMatch('3'), false);
      });
      test('characterSet(CharacterSet().addLetters(CaseType.lower))', () {
        var regex = FluentRegex()
            .characterSet(CharacterSet().addLetters(CaseType.lower));
        expect(regex.hasMatch('a'), true);
        expect(regex.hasMatch('B'), false);
        expect(regex.hasMatch('3'), false);
      });
      test('characterSet(CharacterSet().addLetters(CaseType.upper))', () {
        var regex = FluentRegex()
            .characterSet(CharacterSet().addLetters(CaseType.upper));
        expect(regex.hasMatch('a'), false);
        expect(regex.hasMatch('B'), true);
        expect(regex.hasMatch('3'), false);
      });
      test('characterSet(CharacterSet.exclude().addLetters())', () {
        var regex =
            FluentRegex().characterSet(CharacterSet.exclude().addLetters());
        expect(regex.hasMatch('3'), true);
        expect(regex.hasMatch('!'), true);
        expect(regex.hasMatch('a'), false);
        expect(regex.hasMatch('B'), false);
      });
    });
    group('method: addLiterals()', () {
      test("characterSet(CharacterSet().addLiterals('-'))", () {
        var regex =
            FluentRegex().characterSet(CharacterSet().addLiterals('-_'));
        expect(regex.hasMatch('-'), true);
        expect(regex.hasMatch('_'), true);
        expect(regex.hasMatch('a'), false);
      });
      test("characterSet(CharacterSet().addLiterals('!'), Quantity.exactly(2))",
          () {
        var regex = FluentRegex()
            .characterSet(CharacterSet().addLiterals('!'), Quantity.exactly(2));
        expect(regex.hasMatch('!'), false);
        expect(regex.hasMatch('!!'), true);
        expect(regex.findFirst('!!!'), '!!');
      });
      test("characterSet(CharacterSet.exclude().addLiterals('#'))", () {
        var regex =
            FluentRegex().characterSet(CharacterSet.exclude().addLiterals('#'));
        expect(regex.hasMatch('1'), true);
        expect(regex.hasMatch('a'), true);
        expect(regex.hasMatch('#'), false);
      });
    });

    group('method: addRange()', () {
      test("characterSet(CharacterSet().addRange('k', 'p').addRange('2', '6'))",
          () {
        var regex = FluentRegex()
            .characterSet(CharacterSet().addRange('k', 'p').addRange('2', '6'));
        expect(regex.hasMatch('l'), true);
        expect(regex.hasMatch('5'), true);
        expect(regex.hasMatch('a'), false);
      });
      test("characterSet(CharacterSet().addLiterals('!'), Quantity.exactly(2))",
          () {
        var regex = FluentRegex().characterSet(
            CharacterSet().addRange('k', 'p').addRange('2', '6'),
            Quantity.exactly(2));
        expect(regex.hasMatch('k'), false);
        expect(regex.hasMatch('k6'), true);
        expect(regex.findFirst('m56'), 'm5');
      });
      test("characterSet(CharacterSet.exclude().addLiterals('#'))", () {
        var regex = FluentRegex().characterSet(
            CharacterSet.exclude().addRange('k', 'p').addRange('2', '6'));
        expect(regex.hasMatch('1'), true);
        expect(regex.hasMatch('a'), true);
        expect(regex.hasMatch('m'), false);
        expect(regex.hasMatch('3'), false);
      });
    });
  });

  group('class: Capture', () {
    test('constructor: Capture.noneCapturing()', () {
      var regex = FluentRegex().literal('a').group(
            FluentRegex().literal('bc'),
            type: GroupType.noneCapturing(),
            quantity: Quantity.exactly(2),
          );
      expect(regex.hasMatch('abc'), false);
      expect(regex.hasMatch('abcbc'), true);
      expect(regex.findCapturedGroups('abcbc').length, 0);
    });

    test('constructor: Capture.captureUnNamed()', () {
      var regex = FluentRegex()
          .literal('a')
          .group(
            FluentRegex().literal('bc'),
            type: GroupType.captureUnNamed(),
          )
          .group(
            FluentRegex().literal('de'),
            type: GroupType.captureUnNamed(),
          );
      expect(regex.findCapturedGroups('abcdef').length, 2);
      expect(regex.findCapturedGroups('abcdef')['0'], 'bc');
      expect(regex.findCapturedGroups('abcdef')['1'], 'de');
    });

    test('constructor: GroupType.captureNamed()', () {
      var regex = FluentRegex()
          .literal('a')
          .group(
            FluentRegex().literal('bc'),
            type: GroupType.captureNamed('first'),
          )
          .group(
            FluentRegex().literal('de'),
            type: GroupType.captureNamed('second'),
          );
      expect(regex.findCapturedGroups('abcdef').length, 2);
      expect(regex.findCapturedGroups('abcdef')['first'], 'bc');
      expect(regex.findCapturedGroups('abcdef')['second'], 'de');
    });

    test("constructor: Capture.lookAhead()", () {
      // Looking for d only when it is followed by r
      // r will not be part of the result
      var regex = FluentRegex().literal('d').group(
            FluentRegex().literal('r'),
            type: GroupType.lookAhead(),
          );
      expect(regex.findFirst('drive'), 'd');
      expect(regex.hasMatch('beard'), false);
    });

    test("constructor: Capture.lookAheadAnythingBut()", () {
      // Looking for d only when it is NOT followed by r
      // r will not be part of the result
      var regex = FluentRegex().literal('d').group(
            FluentRegex().literal('r'),
            type: GroupType.lookAheadAnythingBut(),
          );
      expect(regex.hasMatch('drive'), false);
      expect(regex.findFirst('beard'), 'd');
    });

    test("constructor: Capture.lookPreceding()", () {
      // Looking for d only when it is preceded by r
      // r will not be part of the result
      var regex = FluentRegex()
          .group(
            FluentRegex().literal('r'),
            type: GroupType.lookPreceding(),
          )
          .literal('d');
      expect(regex.hasMatch('drive'), false);
      expect(regex.findFirst('beard'), 'd');
    });

    test("constructor: Capture.lookPrecedingAnythingBut()", () {
      // Looking for d only when it is NOT preceded by r
      // r will not be part of the result
      var regex = FluentRegex()
          .group(
            FluentRegex().literal('r'),
            type: GroupType.lookPrecedingAnythingBut(),
          )
          .literal('d');
      expect(regex.findFirst('drive'), 'd');
      expect(regex.hasMatch('beard'), false);
    });
  });
}
