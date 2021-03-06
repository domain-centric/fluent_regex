/*
 * Copyright (c) 2021 by Nils ten Hoeve. See LICENSE file in project.
 */

/// A [Fluent interface](http://en.wikipedia.org/wiki/Fluent_interface)
/// to create readable regular expressions.
class FluentRegex implements RegExp {
  /// ========================================================================
  ///                             FIELDS
  /// ========================================================================

  final String _expression;
  final bool _startOfLine;
  final bool _endOfLine;
  final bool _ignoreCase;
  final bool _multiLine;

  FluentRegex([String? expression])
      : _expression = expression ?? '',
        _startOfLine = false,
        _endOfLine = false,
        _ignoreCase = false,
        _multiLine = true;

  FluentRegex._copyWith(
    FluentRegex fluentRegex, {
    String? expression,
    bool? startOfLine,
    bool? endOfLine,
    bool? ignoreCase,
    bool? multiLine,
  })  : _expression = expression ?? fluentRegex._expression,
        _startOfLine = startOfLine ?? fluentRegex._startOfLine,
        _endOfLine = endOfLine ?? fluentRegex._endOfLine,
        _ignoreCase = ignoreCase ?? fluentRegex._ignoreCase,
        _multiLine = multiLine ?? fluentRegex._multiLine;

  /// ========================================================================
  ///                             CONSTRUCTORS
  /// ========================================================================

  /// ========================================================================
  ///                             FLAG MANIPULATING METHODS
  /// ========================================================================

  /// Enable or disable search in one line in prior
  /// to multi line search according to [enable] flag.
  ///
  /// Multi line search is enabled by default.
  ///
  /// Example:
  /// var regex = FluentRegex()
  ///   .startOfLine()
  ///   .literal('a')
  ///   .multiline(false);
  /// expect(regex.hasMatch('first line \na'), false);
  /// expect(regex.hasMatch('a'), true);

  FluentRegex multiline([bool enable = true]) =>
      FluentRegex._copyWith(this, multiLine: enable);

  /// Enable or disable search in one line in prior
  /// to multi line search according to [enable] flag.
  ///
  /// Multi line search is enabled by default.
  ///
  /// Example:
  /// var regex = FluentRegex()
  ///   .startOfLine()
  ///   .literal('a')
  ///   .searchFirstLineOnly();
  /// expect(regex.hasMatch('first line\na'), false);
  /// expect(regex.hasMatch('a'), true);
  FluentRegex searchFirstLineOnly([bool enable = true]) =>
      FluentRegex._copyWith(this, multiLine: !enable);

  /// Enable or disable matching with ignoring case according to [enable] flag.
  ///
  /// Case sensitive matching is enabled by default.
  ///
  /// Example:
  /// var regex = FluentRegex()
  ///   .literal('a')
  ///   .ignoreCase();
  /// expect(regex.hasMatch('A'), true);
  /// expect(regex.hasMatch('a'), true);
  FluentRegex ignoreCase([bool enable = true]) =>
      FluentRegex._copyWith(this, ignoreCase: enable);

  /// Mark the expression to start at the beginning of the line
  ///
  /// Enable or disable the expression to start at the beginning of the line using [enable] flag
  ///
  /// Example:
  /// var regex = FluentRegex()
  ///   .startOfLine()
  ///   .literal('abc');
  /// expect(regex.hasMatch('abc12'), true);
  /// expect(regex.hasMatch('12abc'), false);
  FluentRegex startOfLine([bool enable = true]) =>
      FluentRegex._copyWith(this, startOfLine: enable);

  /// Mark the expression to end at the last character of the line
  ///
  /// Enable or disable the expression to end at the last character of the line using [enable] flag
  ///
  /// Example:
  /// var regex = FluentRegex()
  ///   .literal('abc')
  ///   .endOfLine();
  /// expect(regex.hasMatch('abc12'), false);
  /// expect(regex.hasMatch('12abc'), true);
  FluentRegex endOfLine([bool enable = true]) =>
      FluentRegex._copyWith(this, endOfLine: enable);

  /// ========================================================================
  ///                             LITERALS
  /// ========================================================================
  /// Appends an expression to find the literal expression
  ///
  /// Example:
  /// var regex = FluentRegex().literal('abc');
  /// expect(regex.hasMatch('abc12'), true);
  /// expect(regex.hasMatch('12abc34'), true);
  /// expect(regex.hasMatch('12ab34'), false);
  FluentRegex literal(String literal,
      [Quantity quantity = const Quantity.oneTime()]) {
    if (literal.length == 1 || quantity == Quantity.oneTime()) {
      var newExpression = _expression + escape(literal) + quantity.toString();
      return FluentRegex._copyWith(this, expression: newExpression);
    } else {
      return group(FluentRegex(escape(literal)), quantity: quantity);
    }
  }

  /// Appends a [CharacterSet] to search for in the next character.
  ///
  /// Examples:
  /// var regex = FluentRegex()
  ///   .characterSet(CharacterSet()
  ///     .addDigits()
  ///     .addLetters(CaseType.lower)
  ///     .addRange('K', 'P')
  ///     .addLiterals('_-'));
  /// expect(regex.hasMatch('abc12KP_-'), true);
  /// expect(regex.findFirst('!abc12KP_-!'), 'a');
  /// expect(regex.findFirst('AB!2KP_-abc12KP_-!'), '2');
  FluentRegex characterSet(CharacterSet characterSet,
          [Quantity quantity = const Quantity.oneTime()]) =>
      FluentRegex._copyWith(this,
          expression: '$_expression$characterSet$quantity');

  /// ========================================================================
  ///                             SPECIAL CHARACTERS
  /// ========================================================================

  /// Appends letters or digits, same as [a-zA-Z_0-9]
  ///
  /// Example:
  /// var regex = FluentRegex().wordChar();
  /// expect(regex.hasMatch('l'), true);
  /// expect(regex.hasMatch('W'), true);
  /// expect(regex.hasMatch('5'), true);
  /// expect(regex.hasMatch('_'), true);
  /// expect(regex.hasMatch('%'), false);
  FluentRegex wordChar([Quantity quantity = const Quantity.oneTime()]) =>
      FluentRegex._copyWith(this, expression: '$_expression\\w$quantity');

  /// Appends non-letters or digits, same as [^\w]
  ///
  /// Example:
  /// var regex = FluentRegex().nonWordChar();
  /// expect(regex.hasMatch('l'), false);
  /// expect(regex.hasMatch('W'), false);
  /// expect(regex.hasMatch('5'), false);
  /// expect(regex.hasMatch('_'), false);
  /// expect(regex.hasMatch('%'), true);
  FluentRegex nonWordChar([Quantity quantity = const Quantity.oneTime()]) =>
      FluentRegex._copyWith(this, expression: '$_expression\\W$quantity');

  /// Appends digit, same as [0-9]
  ///
  /// Example:
  /// var regex = FluentRegex().digit();
  /// expect(regex.hasMatch('l'), false);
  /// expect(regex.hasMatch('W'), false);
  /// expect(regex.hasMatch('5'), true);
  /// expect(regex.hasMatch('_'), false);
  /// expect(regex.hasMatch('%'), false);
  FluentRegex digit([Quantity quantity = const Quantity.oneTime()]) =>
      FluentRegex._copyWith(this, expression: '$_expression\\d$quantity');

  /// Appends non-digit, same as [^0-9]
  ///
  /// Example:
  /// var regex = FluentRegex().nonDigit();
  /// expect(regex.hasMatch('l'), true);
  /// expect(regex.hasMatch('W'), true);
  /// expect(regex.hasMatch('5'), false);
  /// expect(regex.hasMatch('_'), true);
  /// expect(regex.hasMatch('%'), true);
  FluentRegex nonDigit([Quantity quantity = const Quantity.oneTime()]) =>
      FluentRegex._copyWith(this, expression: '$_expression\\D$quantity');

  /// Example:
  /// var regex = FluentRegex().letter();
  /// expect(regex.hasMatch('l'), true);
  /// expect(regex.hasMatch('W'), true);
  /// expect(regex.hasMatch('5'), false);
  /// expect(regex.hasMatch('_'), false);
  /// expect(regex.hasMatch('%'), false);
  FluentRegex letter(
      {CaseType caseType = CaseType.lowerAndUpper,
      Quantity quantity = const Quantity.oneTime()}) {
    switch (caseType) {
      case CaseType.lower:
        return FluentRegex._copyWith(this,
            expression: '$_expression[a-z]$quantity');
      case CaseType.upper:
        return FluentRegex._copyWith(this,
            expression: '$_expression[A-Z]$quantity');
      case CaseType.lowerAndUpper:
        return FluentRegex._copyWith(this,
            expression: '$_expression[a-zA-Z]$quantity');
    }
  }

  /// Example:
  /// var regex = FluentRegex().nonLetter();
  /// expect(regex.hasMatch('5'), true);
  /// expect(regex.hasMatch('_'), true);
  /// expect(regex.hasMatch('%'), true);
  /// expect(regex.hasMatch('l'), false);
  /// expect(regex.hasMatch('W'), false);
  FluentRegex nonLetter(
      {CaseType caseType = CaseType.lowerAndUpper,
      Quantity quantity = const Quantity.oneTime()}) {
    switch (caseType) {
      case CaseType.lower:
        return FluentRegex._copyWith(this,
            expression: '$_expression[^a-z]$quantity');
      case CaseType.upper:
        return FluentRegex._copyWith(this,
            expression: '$_expression[^A-Z]$quantity');
      case CaseType.lowerAndUpper:
        return FluentRegex._copyWith(this,
            expression: '$_expression[^a-zA-Z]$quantity');
    }
  }

  /// appends any character
  ///
  /// Example:
  /// var regex = FluentRegex().anyCharacter();
  /// expect(regex.findFirst('abc'), 'a');
  FluentRegex anyCharacter([Quantity quantity = const Quantity.oneTime()]) =>
      FluentRegex._copyWith(this, expression: '$_expression.$quantity');

  /// ========================================================================
  ///                             WHITE SPACE CHARACTERS
  /// ========================================================================

  /// Appends expression to match a tab character ('\u0009')
  ///
  /// Example:
  /// var regex = FluentRegex()
  ///   .tab();
  /// expect(regex.hasMatch('hello'), false);
  /// expect(regex.hasMatch('\u0009hello'), true);
  /// expect(regex.hasMatch('hello\tall'), true);
  FluentRegex tab([Quantity quantity = const Quantity.oneTime()]) =>
      FluentRegex._copyWith(this,
          expression: '$_expression${SpecialCharacter.tab}$quantity');

  /// Appends whitespace character, same as [ \t\n\x0B\f\r]
  ///
  /// Example:
  /// var regex = FluentRegex()
  ///   .whiteSpace();
  /// expect(regex.hasMatch(' '), true);
  /// expect(regex.hasMatch('\u0009'), true);
  /// expect(regex.hasMatch('\n'), true);
  /// expect(regex.hasMatch('\x0B'), true);
  /// expect(regex.hasMatch('\f'), true);
  /// expect(regex.hasMatch('\r'), true);
  /// expect(regex.hasMatch('h'), false);
  FluentRegex whiteSpace([Quantity quantity = const Quantity.oneTime()]) =>
      FluentRegex._copyWith(this,
          expression: '$_expression${SpecialCharacter.whiteSpace}$quantity');

  /// Appends non-whitespace character, same as [^\s]
  ///
  /// Example:
  /// var regex = FluentRegex()
  ///   .nonWhiteSpace();
  /// expect(regex.hasMatch(' '), false);
  /// expect(regex.hasMatch('\u0009'), false);
  /// expect(regex.hasMatch('\n'), false);
  /// expect(regex.hasMatch('\x0B'), false);
  /// expect(regex.hasMatch('\f'), false);
  /// expect(regex.hasMatch('\r'), false);
  /// expect(regex.hasMatch('h'), true);
  FluentRegex nonWhiteSpace([Quantity quantity = const Quantity.oneTime()]) =>
      FluentRegex._copyWith(this,
          expression:
              '$_expression${SpecialCharacter.noneWhiteSpace}$quantity');

  /// Appends universal (Unix + Windows CRLF + Macintosh) line break expression
  ///
  /// Example:
  /// var regex = FluentRegex()
  ///   .lineBreak();
  /// expect(regex.findFirst('hello\rworld'), '\r');
  /// expect(regex.findFirst('hello\nworld'), '\n');
  /// expect(regex.findFirst('hello\r\nworld'), '\r\n');
  /// expect(regex.findFirst('hello\r\rworld'), '\r\r');
  /// expect(regex.hasMatch('hello world'), false);
  FluentRegex lineBreak([Quantity quantity = const Quantity.oneTime()]) => or([
        FluentRegex(
            SpecialCharacter.carriageReturn + SpecialCharacter.carriageReturn),
        FluentRegex(
            SpecialCharacter.carriageReturn + SpecialCharacter.lineFeed),
        FluentRegex(SpecialCharacter.carriageReturn),
        FluentRegex(SpecialCharacter.lineFeed),
      ], quantity);

  /// ========================================================================
  ///                             GROUP
  /// ========================================================================

  /// Appends a fluentRegex as a group
  ///
  /// For capture parameter see [GroupType] class
  ///
  /// Example:
  /// var regex = FluentRegex()
  ///     .literal('a')
  ///     .group(FluentRegex().literal('bc'), quantity: Quantity.exactly(2));
  /// expect(regex.hasMatch('abc'), false);
  /// expect(regex.hasMatch('abcbc'), true);
  FluentRegex group(FluentRegex fluentRegex,
          {GroupType type = const GroupType.noneCapturing(),
          Quantity quantity = const Quantity.oneTime()}) =>
      FluentRegex._copyWith(this,
          expression: '$_expression($type$fluentRegex)$quantity');

  /// Appends multiple [FluentRegex]pressions as an or group
  ///
  /// Example:
  /// var regex = FluentRegex().or([
  ///   FluentRegex().literal('ab'),
  ///   FluentRegex().literal('cd'),
  /// ]);
  /// expect(regex.hasMatch('ab'), true);
  /// expect(regex.hasMatch('cd'), true);
  /// expect(regex.hasMatch('bc'), false);
  FluentRegex or(List<FluentRegex> fluentRegExpressions,
      [Quantity quantity = const Quantity.oneTime()]) {
    String orExpression = '';
    for (FluentRegex fluentRegex in fluentRegExpressions) {
      if (orExpression.isNotEmpty) {
        orExpression += '|';
      }
      orExpression += fluentRegex.toString();
    }
    return group(FluentRegex(orExpression), quantity: quantity);
  }

  /// ========================================================================
  ///                             CONVERSION METHODS
  /// ========================================================================

  /// Escapes (adds two slashes before) characters that have a special meaning in a RegExp:
  /// characters to escape are:   \^$.|?*+()[]{}
  ///
  /// Example:
  /// expect(FluentRegex.escape('a\\^\$.bc|?*d+-()[]{}1'),
  /// 'a\\\\\\^\\\$\\.bc\\|\\?\\*d\\+\\-\\(\\)\\[\\]\\{\\}1');

  static String escape(String value) {
    if (value.isEmpty) return value;
    const pattern =
        '(?:\\\\|\\^|\\\$|\\.|\\||\\?|\\*|\\+|\\-|\\(|\\)|\\[|\\]|\\{|\\})';
    return value.replaceAllMapped(RegExp(pattern), (Match match) {
      return '\\${match.group(0)}';
    });
  }

  /// Converts the pattern to a [RegExp]
  /// This is a private method because [FluentRegex] already implements [RegExp] (using this method)
  /// Returns resulting [RegExp] object
  RegExp _toRegExp() => RegExp(
        toString(),
        caseSensitive: !_ignoreCase,
        multiLine: _multiLine,
      );

  /// Overrides toString
  /// Returns resulting [RegExp] pattern
  @override
  String toString() =>
      '${_startOfLine ? '^' : ''}$_expression${_endOfLine ? '\$' : ''}';

  /// ========================================================================
  ///                             REGEXP METHOD OVERRIDES
  /// ========================================================================

  @override
  bool hasMatch(String input) => _toRegExp().hasMatch(input);

  @override
  Iterable<RegExpMatch> allMatches(String input, [int start = 0]) =>
      _toRegExp().allMatches(input, start);

  @override
  RegExpMatch? firstMatch(String input) => _toRegExp().firstMatch(input);

  @override
  bool get isCaseSensitive => _toRegExp().isCaseSensitive;

  @override
  bool get isDotAll => _toRegExp().isDotAll;

  @override
  bool get isMultiLine => _toRegExp().isMultiLine;

  @override
  bool get isUnicode => _toRegExp().isUnicode;

  @override
  Match? matchAsPrefix(String string, [int start = 0]) =>
      _toRegExp().matchAsPrefix(string, start);

  @override
  String get pattern => _toRegExp().pattern;

  @override
  String? stringMatch(String input) => _toRegExp().stringMatch(input);

  /// ========================================================================
  ///                             CONVENIENCE METHODS
  /// ========================================================================

  /// Example:
  /// expect(FluentRegex().digit().hasNoMatch('a'), true);
  /// expect(FluentRegex().letter().hasNoMatch('a'), false);
  bool hasNoMatch(String input) => !hasMatch(input);

  /// Example:
  /// expect(FluentRegex().literal('a').replaceFirst('bababa', 'c'), 'bcbaba');
  String replaceFirst(String source, String replacement) =>
      source.replaceFirst(_toRegExp(), replacement);

  /// Example:
  /// expect(FluentRegex().literal('a').replaceAll('bababa', 'c'), 'bcbcbc');
  String replaceAll(String source, String replacement) =>
      source.replaceAll(_toRegExp(), replacement);

  /// Example:
  /// expect(FluentRegex().literal('a').removeFirst('bababa'), 'bbaba');
  String removeFirst(String source) => source.replaceFirst(_toRegExp(), '');

  /// Example:
  /// expect(FluentRegex().literal('a').removeAll('bababa'), 'bbb');
  String removeAll(String source) => source.replaceAll(_toRegExp(), '');

  /// Example:
  /// expect(FluentRegex().literal('a').findFirst('bababa'), 'a');
  /// expect(FluentRegex().literal('c').findFirst('bababa'), null);
  String? findFirst(String source) {
    var regExpMatch = _toRegExp().firstMatch(source);
    return (regExpMatch == null) ? null : regExpMatch.group(0);
  }

  /// Example:
  /// expect(FluentRegex().digit().findAll('a1bc2D3e&(f4'), ['1', '2', '3', '4']);
  /// expect(FluentRegex().letter().findAll('123&(4'), []);
  List<String> findAll(String source, [int start = 0]) => _toRegExp()
      .allMatches(source, start)
      .map((regExpMatch) => regExpMatch.group(0)!)
      .toList();

  /// Example:
  /// expect(
  /// FluentRegex()
  ///     .group(FluentRegex().literal('a').digit().literal('b'),
  /// type: GroupType.captureNamed('name'))
  ///     .findCapturedGroups('@abc2a7bD3e&(f4'),
  /// {
  /// 'name': 'a7b',
  /// });
  Map<String, String?> findCapturedGroups(String source, [int start = 0]) {
    Map<String, String?> results = {};
    var matches = _toRegExp().allMatches(source, start);
    for (var match in matches) {
      var groupNames = match.groupNames;
      if (groupNames.isEmpty) {
        _appendUnNamedCapturedGroupResults(match, results);
      } else {
        _appendNamedCapturedGroupResults(match, results);
      }
    }
    return results;
  }

  void _appendUnNamedCapturedGroupResults(
      RegExpMatch match, Map<String, String?> results) {
    int groupCount = match.groupCount;
    //group(0) is the full match, the following groups are captured groups
    if (groupCount > 0) {
      for (int i = 1; i <= groupCount; i++) {
        results[results.length.toString()] = match.group(i);
      }
    }
  }

  void _appendNamedCapturedGroupResults(
      RegExpMatch match, Map<String, String?> results) {
    for (String groupName in match.groupNames) {
      results[groupName] = match.namedGroup(groupName);
    }
  }

  /// ========================================================================
  ///                             DEFAULT EXPRESSIONS
  /// ========================================================================

// TODO standard expressions such as URI, URL, XML_ELEMENT, ETC

// Parsing email addresses based on the RFC 5322 standard:
//
// (?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*
// |  "(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]
// |  \\[\x01-\x09\x0b\x0c\x0e-\x7f])*")
// @ (?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?
// |  \[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}
// (?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:
// (?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]
// |  \\[\x01-\x09\x0b\x0c\x0e-\x7f])+)
// \])

  FluentRegex get emailAddress {
    var nameSet = CharacterSet()
        .addLetters()
        .addDigits()
        .addLiterals("\$!#%&'*+/=?^_`{|}~-");
    // (?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*
    var name = FluentRegex()
        .characterSet(nameSet, Quantity.oneOrMoreTimes())
        .group(
            FluentRegex()
                .literal('.')
                .characterSet(nameSet, Quantity.oneOrMoreTimes()),
            quantity: Quantity.zeroOrMoreTimes());
    var quotedNameSet1 = CharacterSet()
        .addRange('\x01', '\x08')
        .addLiterals('\x0b\x0c')
        .addRange('\x0e', '\x1f')
        .addLiterals('\x21')
        .addRange('\x23', '\x5b')
        .addRange('\x5d', '\x7f');
    var quotedNameSet2 = CharacterSet()
        .addRange('\x01', '\x09')
        .addLiterals('\x0b\x0c')
        .addRange('\x0e', '\x7f');
    // "(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f] | \\[\x01-\x09\x0b\x0c\x0e-\x7f])*")
    var quotedName = FluentRegex().literal('"').or([
      FluentRegex().characterSet(quotedNameSet1),
      FluentRegex().literal('\\').characterSet(quotedNameSet2),
    ], Quantity.zeroOrMoreTimes()).literal('"');
    //[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?
    var domainName = FluentRegex()
        .characterSet(CharacterSet().addLetters().addDigits())
        .group(
            FluentRegex()
                .characterSet(
                    CharacterSet().addLetters().addDigits().addLiterals('-'),
                    Quantity.zeroOrMoreTimes())
                .characterSet(CharacterSet().addLetters().addDigits(),
                    Quantity.zeroOrOneTime())
                .literal('.'),
            quantity: Quantity.oneOrMoreTimes())
        .characterSet(CharacterSet().addLetters().addDigits())
        .group(
            FluentRegex()
                .characterSet(
                    CharacterSet().addLetters().addDigits().addLiterals('-'),
                    Quantity.zeroOrMoreTimes())
                .characterSet(CharacterSet().addLetters().addDigits()),
            quantity: Quantity.zeroOrOneTime());

    //25[0-5]
    var ipAddressByte1 = FluentRegex()
        .literal('25')
        .characterSet(CharacterSet().addRange('0', '5'));
    //2[0-4][0-9]
    var ipAddressByte2 = FluentRegex()
        .literal('2')
        .characterSet(CharacterSet().addRange('0', '4'))
        .characterSet(CharacterSet().addDigits());
    //[01]?[0-9][0-9]?
    var ipAddressByte3 = FluentRegex()
        .characterSet(
            CharacterSet().addLiterals('01'), Quantity.zeroOrOneTime())
        .characterSet(CharacterSet().addDigits())
        .characterSet(CharacterSet().addDigits(), Quantity.zeroOrOneTime());
    // [a-z0-9-]*[a-z0-9]:
    // (?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]
    // |  \\[\x01-\x09\x0b\x0c\x0e-\x7f])+)
    var ipAddressSuffix = FluentRegex()
        .characterSet(CharacterSet().addLetters().addDigits().addLiterals('-'),
            Quantity.zeroOrMoreTimes())
        .characterSet(CharacterSet().addLetters().addDigits())
        .literal(':')
        .or([
      FluentRegex().characterSet(CharacterSet()
          .addRange('\x01', '\x08')
          .addLiterals('\x0b\x0c')
          .addRange('\x0e', '\x1f')
          .addRange('\x21', '\x5a')
          .addRange('\x53', '\x7f')),
      FluentRegex().literal('\\').characterSet(
          CharacterSet()
              .addRange('\x01', '\x09')
              .addLiterals('\x0b\x0c')
              .addRange('\x0e', '\x7f'),
          Quantity.oneOrMoreTimes()),
    ]);

    var domainAddress = FluentRegex()
        .literal('[')
        .group(
            FluentRegex().or([
              ipAddressByte1,
              ipAddressByte2,
              ipAddressByte3,
            ]).literal('.'),
            quantity: Quantity.exactly(3))
        .or([
      ipAddressByte1,
      ipAddressByte2,
      ipAddressByte3,
      ipAddressSuffix,
    ]).literal(']');

    return FluentRegex()
        .or([name, quotedName])
        .literal('@')
        .or([domainName, domainAddress]);
  }
}

class GroupType {
  final String _expression;

  /// Used when the found value does not need to be captured
  ///
  /// Example:
  /// var regex = FluentRegex().literal('a').group(
  ///   FluentRegex().literal('bc'),
  ///   type: GroupType.noneCapturing(),
  ///   quantity: Quantity.exactly(2),
  /// );
  /// expect(regex.hasMatch('abc'), false);
  /// expect(regex.hasMatch('abcbc'), true);
  /// expect(regex.findCapturedGroups('abcbc').length, 0);
  const GroupType.noneCapturing() : _expression = '?:';

  /// Used when the found value needs to be captured
  ///
  /// Example:
  /// var regex = FluentRegex()
  ///     .literal('a')
  ///     .group(
  ///   FluentRegex().literal('bc'),
  ///   type: GroupType.captureUnNamed(),
  /// )
  ///     .group(
  ///   FluentRegex().literal('de'),
  ///   type: GroupType.captureUnNamed(),
  /// );
  /// expect(regex.findCapturedGroups('abcdef').length, 2);
  /// expect(regex.findCapturedGroups('abcdef')['0'], 'bc');
  /// expect(regex.findCapturedGroups('abcdef')['1'], 'de');
  const GroupType.captureUnNamed() : _expression = '';

  /// Used when the found value needs to be captured using a name
  ///
  /// Example:
  /// var regex = FluentRegex()
  ///     .literal('a')
  ///     .group(
  ///   FluentRegex().literal('bc'),
  ///   type: GroupType.captureNamed('first'),
  /// )
  ///     .group(
  ///   FluentRegex().literal('de'),
  ///   type: GroupType.captureNamed('second'),
  /// );
  /// expect(regex.findCapturedGroups('abcdef').length, 2);
  /// expect(regex.findCapturedGroups('abcdef')['first'], 'bc');
  /// expect(regex.findCapturedGroups('abcdef')['second'], 'de');
  const GroupType.captureNamed(String name) : _expression = '?<$name>';

  /// When looking for a value that is followed by another value
  /// and the following value may not be captured
  ///
  /// Example:
  /// // Looking for d only when it is followed by r
  /// // r will not be part of the result
  /// var regex = FluentRegex().literal('d').group(
  ///   FluentRegex().literal('r'),
  ///   type: GroupType.lookAhead(),
  /// );
  /// expect(regex.findFirst('drive'), 'd');
  /// expect(regex.hasMatch('beard'), false);
  const GroupType.lookAhead() : _expression = '?=';

  /// When looking for a value that is NOT followed by another value
  /// and the following value may not be captured
  ///
  /// Example:
  /// // Looking for d only when it is NOT followed by r
  /// // r will not be part of the result
  /// var regex = FluentRegex().literal('d').group(
  ///   FluentRegex().literal('r'),
  ///   type: GroupType.lookAheadAnythingBut(),
  /// );
  /// expect(regex.hasMatch('drive'), false);
  /// expect(regex.findFirst('beard'), 'd');
  const GroupType.lookAheadAnythingBut() : _expression = '?!';

  /// When looking for a value that is preceded by another value
  /// and the preceded value may not be captured
  ///
  /// Example:
  /// // Looking for d only when it is preceded by r
  /// // r will not be part of the result
  /// var regex = FluentRegex()
  ///     .group(
  ///       FluentRegex().literal('r'),
  ///       type: GroupType.lookPreceding(),
  ///     )
  ///     .literal('d');
  /// expect(regex.hasMatch('drive'), false);
  /// expect(regex.findFirst('beard'), 'd');
  const GroupType.lookPreceding() : _expression = '?<=';

  /// When looking for a value that is NOT preceded by another value
  /// and the preceded value may not be captured
  ///
  /// Example:
  /// // Looking for d only when it is NOT preceded by r
  /// // r will not be part of the result
  /// var regex = FluentRegex()
  ///     .group(
  ///       FluentRegex().literal('r'),
  ///       type: GroupType.lookPrecedingAnythingBut(),
  ///     )
  ///     .literal('d');
  /// expect(regex.findFirst('drive'), 'd');
  /// expect(regex.hasMatch('beard'), false);
  const GroupType.lookPrecedingAnythingBut() : _expression = '?<!';

  @override
  String toString() => _expression;
}

enum Scope { include, exclude }

extension ScopeExtenstion on Scope {
  String get expression {
    switch (this) {
      case Scope.include:
        return '';
      case Scope.exclude:
        return '^';
    }
  }
}

enum CaseType { lower, upper, lowerAndUpper }

extension CaseTypeExtension on CaseType {
  bool get hasLower {
    switch (this) {
      case CaseType.lower:
      case CaseType.lowerAndUpper:
        return true;
      default:
        return false;
    }
  }

  bool get hasUpper {
    switch (this) {
      case CaseType.upper:
      case CaseType.lowerAndUpper:
        return true;
      default:
        return false;
    }
  }
}

class SpecialCharacter {
  /// Same as: [0-9]
  static final String digit = '\\d';

  /// Same as: ^[0-9]
  static final String noneDigit = '\\D';

  /// Same as: [a-zA-Z0-9_]
  static final String wordChar = '\\w';

  /// Same as: ^[a-zA-Z0-9_]
  static final String noneWordChar = '\\W';
  static final String wordBoundary = '\\b';
  static final String noneWordBoundary = '\\B';

  /// Same as: [ \t\n\x0B\f\r]
  static final String whiteSpace = '\\s';

  /// Same as: [^ \t\n\x0B\f\r]
  static final String noneWhiteSpace = '\\S';

  /// Same as: [\u0009]
  static final String tab = '\\t';

  /// Same as: [\u000D]
  static final String carriageReturn = '\\r';

  /// Same as: [\u000A]
  static final String lineFeed = '\\n';
}

/// a [CharacterSet] is a collection of characters that is being searched for.
/// e.g. it may contain letters and/or digits and/or other literals.
/// You can also add a range e.g.:
/// - 'k-p' (letters k trough p)
/// - '2-6' (digits 2 trough 6)
class CharacterSet {
  final Scope _mode;
  final Set<String> _sets = {};

  CharacterSet() : _mode = Scope.include;

  CharacterSet.exclude() : _mode = Scope.exclude;

  /// See [SpecialCharacter.digit]
  /// Example:
  /// var regex=FluentRegex().characterSet(CharacterSet().addDigits());
  /// expect(regex.hasMatch('1'),true);
  /// expect(regex.hasMatch('a'),false);
  CharacterSet addDigits() {
    _sets.add(SpecialCharacter.digit);
    return this;
  }

  /// See [SpecialCharacter.noneDigit]
  /// Example:
  /// var regex=FluentRegex().characterSet(CharacterSet().addDigits());
  /// expect(regex.hasMatch('1'),false);
  /// expect(regex.hasMatch('a'),true);
  CharacterSet addNoneDigits() {
    _sets.add(SpecialCharacter.noneDigit);
    return this;
  }

  /// See [SpecialCharacter.wordChar]
  /// Example:
  /// var regex=FluentRegex().characterSet(CharacterSet().addWordCharacters());
  /// expect(regex.hasMatch('a'),true);
  /// expect(regex.hasMatch('Z'),true);
  /// expect(regex.hasMatch('1'),true);
  /// expect(regex.hasMatch('!'),false);
  CharacterSet addWordChars() {
    _sets.add(SpecialCharacter.wordChar);
    return this;
  }

  /// See [SpecialCharacter.noneWordChar]
  /// Example:
  /// var regex=FluentRegex().characterSet(CharacterSet().addNoneWordCharacters());
  /// expect(regex.hasMatch('a'),false);
  /// expect(regex.hasMatch('Z'),false);
  /// expect(regex.hasMatch('1'),false);
  /// expect(regex.hasMatch('!'),true);
  CharacterSet addNoneWordChars() {
    _sets.add(SpecialCharacter.noneWordChar);
    return this;
  }

  /// See [SpecialCharacter.whiteSpace]
  /// Example:
  /// var regex = FluentRegex().characterSet(CharacterSet().addWhiteSpaces());
  /// expect(regex.hasMatch(' '), true);
  /// expect(regex.hasMatch('\u0009'), true);
  /// expect(regex.hasMatch('\n'), true);
  /// expect(regex.hasMatch('\x0B'), true);
  /// expect(regex.hasMatch('\f'), true);
  /// expect(regex.hasMatch('\r'), true);
  /// expect(regex.hasMatch('h'), false);
  CharacterSet addWhiteSpaces() {
    _sets.add(SpecialCharacter.whiteSpace);
    return this;
  }

  /// See [SpecialCharacter.noneWhiteSpace]
  /// Example:
  /// var regex = FluentRegex().characterSet(CharacterSet().addNoneWhiteSpaces());
  /// expect(regex.hasMatch(' '), false);
  /// expect(regex.hasMatch('\u0009'), false);
  /// expect(regex.hasMatch('\n'), false);
  /// expect(regex.hasMatch('\x0B'), false);
  /// expect(regex.hasMatch('\f'), false);
  /// expect(regex.hasMatch('\r'), false);
  /// expect(regex.hasMatch('h'), true);
  CharacterSet addNoneWhiteSpaces() {
    _sets.add(SpecialCharacter.noneWhiteSpace);
    return this;
  }

  /// See [SpecialCharacter.tab]
  /// Example:
  /// var regex = FluentRegex().characterSet(CharacterSet().tab());
  /// expect(regex.hasMatch('hello'), false);
  /// expect(regex.hasMatch('\u0009hello'), true);
  /// expect(regex.hasMatch('hello\tall'), true);
  CharacterSet addTabs() {
    _sets.add(SpecialCharacter.tab);
    return this;
  }

  /// See [SpecialCharacter.carriageReturn] and [SpecialCharacter.lineFeed]
  /// Example:
  /// expect(regex.findFirst('hello\rworld'), '\r');
  /// expect(regex.findFirst('hello\nworld'), '\n');
  /// expect(regex.findFirst('hello\r\nworld'), '\r\n');
  /// expect(regex.findFirst('hello\r\rworld'), '\r\r');
  /// expect(regex.hasMatch('hello world'), false);
  CharacterSet addLineBreaks() {
    _sets.add(SpecialCharacter.carriageReturn);
    _sets.add(SpecialCharacter.lineFeed);
    return this;
  }

  /// Example:
  /// var regex = FluentRegex().characterSet(CharacterSet().addLetters());
  /// expect(regex.hasMatch('a'), true);
  /// expect(regex.hasMatch('B'), true);
  /// expect(regex.hasMatch('3'), false);
  CharacterSet addLetters([CaseType caseType = CaseType.lowerAndUpper]) {
    if (caseType.hasLower) addRange('a', 'z');
    if (caseType.hasUpper) addRange('A', 'Z');
    return this;
  }

  /// Example:
  /// var regex =
  ///    FluentRegex().characterSet(CharacterSet().addLiterals('-_'));
  /// expect(regex.hasMatch('-'), true);
  /// expect(regex.hasMatch('_'), true);
  /// expect(regex.hasMatch('a'), false);
  CharacterSet addLiterals(String literalsToAdd) {
    _sets.add(FluentRegex.escape(literalsToAdd));
    return this;
  }

  /// Example:
  /// var regex = FluentRegex()
  ///     .characterSet(CharacterSet().addRange('k', 'p').addRange('2', '6'));
  /// expect(regex.hasMatch('l'), true);
  /// expect(regex.hasMatch('5'), true);
  /// expect(regex.hasMatch('a'), false);
  CharacterSet addRange(String from, String to) {
    String range = '$from-$to';
    _sets.add(range);
    return this;
  }

  @override
  String toString() {
    return '[${_mode.expression}${_sets.join()}]';
  }
}

enum MultiplicityMode { greedy, reluctant, possessive }

extension MultiplicityModeExtenstion on MultiplicityMode {
  String get expression {
    switch (this) {
      case MultiplicityMode.greedy:
        return '';
      case MultiplicityMode.reluctant:
        return '?';
      case MultiplicityMode.possessive:
        return '+';
    }
  }
}

/// Expresses how often something is repeated

class Quantity {
  final String _expression;
  final MultiplicityMode _mode;

  const Quantity._(this._expression, [this._mode = MultiplicityMode.greedy]);

  /// Example:
  /// var regex = FluentRegex().literal('a', Quantity.zeroOrOneTime());
  /// expect(regex.hasMatch(''), true);
  /// expect(regex.hasMatch('a'), true);
  const Quantity.zeroOrOneTime() : this._('?');

  /// Example:
  /// var regex = FluentRegex().literal('a', Quantity.zeroOrMoreTimes());
  /// expect(regex.hasMatch(''), true);
  /// expect(regex.hasMatch('a'), true);
  /// expect(regex.hasMatch('aa'), true);
  const Quantity.zeroOrMoreTimes() : this._('*');

  /// Example:
  /// var regex = FluentRegex().literal('a', Quantity.oneTime());
  /// expect(regex.hasMatch(''), false);
  /// expect(regex.hasMatch('a'), true);
  const Quantity.oneTime() : this._('');

  /// Example:
  /// var regex = FluentRegex().literal('a', Quantity.oneOrMoreTimes());
  /// expect(regex.hasMatch(''), false);
  /// expect(regex.hasMatch('a'), true);
  /// expect(regex.hasMatch('aa'), true);
  const Quantity.oneOrMoreTimes() : this._('+');

  /// Example:
  /// var regex = FluentRegex().literal('a', Quantity.exactly(2));
  /// expect(regex.hasMatch(''), false);
  /// expect(regex.hasMatch('a'), false);
  /// expect(regex.hasMatch('aa'), true);
  /// expect(regex.findFirst('aaa'), 'aa');
  const Quantity.exactly(int times) : this._('{$times}');

  /// Example:
  /// var regex = FluentRegex().literal('a', Quantity.between(1,2));
  /// expect(regex.hasMatch(''), false);
  /// expect(regex.hasMatch('a'), true);
  /// expect(regex.hasMatch('aa'), true);
  /// expect(regex.findFirst('aaa'), 'aa');
  const Quantity.between(int min, int max) : this._('{$min,$max}');

  /// Example:
  /// var regex = FluentRegex().literal('a', Quantity.atLeast(2));
  /// expect(regex.hasMatch(''), false);
  /// expect(regex.hasMatch('a'), false);
  /// expect(regex.hasMatch('aa'), true);
  /// expect(regex.findFirst('aaa'), 'aaa');
  const Quantity.atLeast(int min) : this._('{$min,}');

  /// Example:
  /// var regex = FluentRegex().literal('a', Quantity.atMost(2));
  /// expect(regex.hasMatch(''), true);
  /// expect(regex.hasMatch('a'), true);
  /// expect(regex.hasMatch('aa'), true);
  /// expect(regex.findFirst('aaa'), 'aa');
  const Quantity.atMost(int max) : this._('{0,$max}');

  /// A greedy quantifier indicates the engine to start with the whole string.
  /// If no match is found it will if will reduce a character to check until it matches (or not)
  ///
  /// Example:
  /// var regex = FluentRegex()
  ///   .anyCharacter(Quantity.zeroOrMoreTimes().greedy)
  ///   .literal('foo');
  /// expect(regex.findFirst('xfooxxxxxxfoo'), 'xfooxxxxxxfoo');

  Quantity get greedy => Quantity._(_expression, MultiplicityMode.greedy);

  /// A reluctant quantifier indicates the engine to start with the shortest possible piece of string.
  /// If no match is found it will if will add a character to check until it matches (or not)
  ///
  /// Example:
  /// var regex = FluentRegex()
  ///   .anyCharacter(Quantity.zeroOrMoreTimes().reluctant)
  ///   .literal('foo');
  /// expect(regex.findFirst('xfooxxxxxxfoo'), 'xfoo');
  Quantity get reluctant => Quantity._(_expression, MultiplicityMode.reluctant);

  /// A possessive quantifier is similar to a greedy quantifier.
  /// It indicates the engine to start by checking the entire string.
  /// It is different in the sense if it doesn't work: if there is no initial match, there is no looking back.
  /// E.g. this can be used to increase performance.
  ///
  /// Example:
  /// var regex = FluentRegex()
  ///   .anyCharacter(Quantity.zeroOrMoreTimes().possessive)
  ///   .literal('foo');
  /// expect(
  /// () => {regex.hasMatch('xfooxxxxxxfoo')},
  /// throwsA((e) =>
  /// e.toString()== 'FormatException: Nothing to repeat.*+foo'));
  Quantity get possessive =>
      Quantity._(_expression, MultiplicityMode.possessive);

  @override
  String toString() {
    return '$_expression${_mode.expression}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Quantity &&
          runtimeType == other.runtimeType &&
          _expression == other._expression &&
          _mode == other._mode;

  @override
  int get hashCode => _expression.hashCode ^ _mode.hashCode;
}
