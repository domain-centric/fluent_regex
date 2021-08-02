# fluent_regex

Package that helps to construct regular expressions in a readable fashion.

Regular expressions can be extremely useful in the right circumstances, but they can also be complicated to understand. Consider this regular expression for parsing email addresses based on the RFC 5322 standard:

```
(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*
  |  "(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]
      |  \\[\x01-\x09\x0b\x0c\x0e-\x7f])*")
@ (?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?
  |  \[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}
       (?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:
          (?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]
          |  \\[\x01-\x09\x0b\x0c\x0e-\x7f])+)
     \])
```
Few people can read and understand this...

With FluentRegex, we can express een e-mail address as:
```dart
var regex = FluentRegex()
                .startOfLine()
                .characterSet(
                    CharacterSet().addLetters().addDigits().addLiterals(".-_"),
                    Quantity.oneOrMoreTimes())
                .literal("@")
                .characterSet(
                    CharacterSet().addLetters().addDigits().addLiterals(".-"),
                    Quantity.oneOrMoreTimes())
                .literal(".")
                .characterSet(CharacterSet().addLetters(), Quantity.between(2, 4))
                .endOfLine();
```
See FluentRegex().emailAddress for a RFC 5322 compliant version, which is still complex but better to understand.

## Why this package while there are others?
This package was inspired by DartVerbalExpressions

Additional benefits of the fluent_regex package:
- FluentRegex implements RegExp
- All methods have a optional quantity parameter: no more confusion where the quantifier belongs to
- The CharacterSet class allows you to fluently define a bracket expression
