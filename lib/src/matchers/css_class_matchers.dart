// @dart = 2.7

// Copyright 2021 Workiva Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:html';
import 'dart:svg' show AnimatedString;

import 'package:matcher/matcher.dart';

/// Allows you to check whether an [Element] has certain [classes] within its HTML `class` attribute.
///
/// [classes] can be a String of space-separated CSS classes, or an [Iterable] of String CSS classes.
///
/// Similar to [jest-dom's `toHaveClass` matcher](https://github.com/testing-library/jest-dom#tohaveclass).
/// However, instead of the JS `.not.toHaveClass()` pattern, you should use [excludesClasses], and instead of
/// using the `{exact: true}` option as you do in JS, you should use [hasExactClasses].
///
/// ### Examples
/// ```html
/// &lt;button data-test-id="delete-button" class="btn extra btn-danger">
///   Delete item
/// &lt;/button>
/// &lt;button data-test-id="no-classes">No Classes&lt;/button>
/// ```
///
/// ```dart
/// import 'package:react_testing_library/react_testing_library.dart' as rtl;
/// import 'package:test/test.dart';
///
/// main() {
///   test('', () {
///     final deleteButton = rtl.screen.getByTestId('delete-button');
///
///     expect(deleteButton, hasClasses('extra'));
///     expect(deleteButton, hasClasses('btn-danger btn'));
///     expect(deleteButton, hasClasses(['btn-danger', 'btn']));
///   });
/// }
/// ```
///
/// {@category Matchers}
Matcher hasClasses(classes) => _ElementClassNameMatcher(ClassNameMatcher.expected(classes));

/// Allows you to check whether an [Element] has certain [classes] within its HTML `class` attribute,
/// with no additional or duplicated classes like the [hasClasses] matcher allows.
///
/// [classes] can be a String of space-separated CSS classes, or an [Iterable] of String CSS classes.
///
/// Similar to [jest-dom's `toHaveClass` matcher](https://github.com/testing-library/jest-dom#tohaveclass)
/// when the `exact` option is set to `true`.
///
/// ### Examples
/// ```html
/// <button data-test-id="delete-button" class="btn extra btn-danger">
///   Delete item
/// </button>
/// <button data-test-id="no-classes">No Classes</button>
/// ```
///
/// ```dart
/// import 'package:react_testing_library/react_testing_library.dart' as rtl;
/// import 'package:test/test.dart';
///
/// main() {
///   test('', () {
///     final deleteButton = rtl.screen.getByTestId('delete-button');
///
///     expect(deleteButton, hasExactClasses('btn-danger extra btn'));
///     expect(deleteButton, hasExactClasses(['btn-danger', 'extra', 'btn']));
///   });
/// }
/// ```
///
/// {@category Matchers}
Matcher hasExactClasses(classes) =>
    _ElementClassNameMatcher(ClassNameMatcher.expected(classes, allowExtraneous: false));

/// Allows you to check whether an [Element] does not have certain [classes] within its HTML `class` attribute.
///
/// [classes] can be a String of space-separated CSS classes, or an [Iterable] of String CSS classes.
///
/// Similar to using `.not.hasClasses(classes)` in the jest-dom JS API.
///
/// ### Examples
/// ```html
/// <button data-test-id="delete-button" class="btn extra btn-danger">
///   Delete item
/// </button>
/// <button data-test-id="no-classes">No Classes</button>
/// ```
///
/// ```dart
/// import 'package:react_testing_library/react_testing_library.dart' as rtl;
/// import 'package:test/test.dart';
///
/// main() {
///   test('', () {
///     final deleteButton = rtl.screen.getByTestId('delete-button');
///
///     expect(deleteButton, excludesClasses('not-there'));
///     expect(deleteButton, hasClasses(['not-there', 'nope']));
///   });
/// }
/// ```
///
/// {@category Matchers}
Matcher excludesClasses(classes) => _ElementClassNameMatcher(ClassNameMatcher.unexpected(classes));

/// Match a list of class names on a component.
class ClassNameMatcher extends Matcher {
  ClassNameMatcher.expected(_expectedClasses, {this.allowExtraneous = true})
      : expectedClasses = getClassIterable(_expectedClasses).toSet(),
        unexpectedClasses = {};

  ClassNameMatcher.unexpected(_unexpectedClasses)
      : unexpectedClasses = getClassIterable(_unexpectedClasses).toSet(),
        allowExtraneous = true,
        expectedClasses = {};

  // Class names that are expected
  final Set expectedClasses;
  // Class names that we do not want
  final Set unexpectedClasses;

  /// Whether or not to allow extraneous classes (classes not specified in expectedClasses).
  final bool allowExtraneous;

  static Iterable getClassIterable(dynamic classNames) {
    Iterable classes;
    if (classNames is Iterable<String>) {
      classes = classNames.where((className) => className != null).expand(_splitSpaceDelimitedString);
    } else if (classNames is String) {
      classes = _splitSpaceDelimitedString(classNames);
    } else {
      throw ArgumentError.value(classNames, 'classNames', 'Must be a list of classNames or a className string');
    }

    return classes;
  }

  @override
  bool matches(className, Map matchState) {
    // There's a bug in DDC where, though the docs say `className` should
    // return `String`, it will return `AnimatedString` for `SvgElement`s. See
    // https://github.com/dart-lang/sdk/issues/36200.
    String castClassName;
    if (className is String) {
      castClassName = className;
    } else if (className is AnimatedString) {
      castClassName = className.baseVal;
    } else {
      throw ArgumentError.value(className, 'className', 'Must be a string type');
    }

    Iterable actualClasses = getClassIterable(castClassName);
    Set missingClasses = expectedClasses.difference(actualClasses.toSet());
    Set unwantedClasses = unexpectedClasses.intersection(actualClasses.toSet());

    // Calculate extraneous classes with Lists instead of Sets, to catch duplicates in actualClasses.
    List expectedClassList = expectedClasses.toList();
    List extraneousClasses = actualClasses.where((className) => !expectedClassList.remove(className)).toList();

    matchState.addAll(
        {'missingClasses': missingClasses, 'unwantedClasses': unwantedClasses, 'extraneousClasses': extraneousClasses});

    if (allowExtraneous) {
      return missingClasses.isEmpty && unwantedClasses.isEmpty;
    } else {
      return missingClasses.isEmpty && extraneousClasses.isEmpty;
    }
  }

  @override
  Description describe(Description description) {
    List<String> descriptionParts = [];
    if (allowExtraneous) {
      if (expectedClasses.isNotEmpty) {
        descriptionParts.add('has the classes: $expectedClasses');
      }
      if (unexpectedClasses.isNotEmpty) {
        descriptionParts.add('does not have the classes: $unexpectedClasses');
      }
    } else {
      descriptionParts.add('has ONLY the classes: $expectedClasses');
    }
    description.add(descriptionParts.join(' and '));

    return description;
  }

  @override
  Description describeMismatch(item, Description mismatchDescription, Map matchState, bool verbose) {
    final missingClasses = matchState['missingClasses'] as Set;
    final unwantedClasses = matchState['unwantedClasses'] as Set;
    final extraneousClasses = matchState['extraneousClasses'] as List;

    List<String> descriptionParts = [];
    if (allowExtraneous) {
      if (unwantedClasses.isNotEmpty) {
        descriptionParts.add('has unwanted classes: $unwantedClasses');
      }
    } else {
      if (extraneousClasses.isNotEmpty) {
        descriptionParts.add('has extraneous classes: $extraneousClasses');
      }
    }

    if (missingClasses.isNotEmpty) {
      descriptionParts.add('is missing classes: $missingClasses');
    }

    mismatchDescription.add(descriptionParts.join('; '));

    return mismatchDescription;
  }
}

class _ElementClassNameMatcher extends CustomMatcher {
  _ElementClassNameMatcher(matcher) : super('Element that', 'className', matcher);
  @override
  featureValueOf(covariant Element actual) => actual.className;
}

/// Returns a List of space-delimited tokens efficiently split from the specified [string].
///
/// Useful for splitting CSS className strings into class tokens, or `data-test-id` values into individual test IDs.
///
/// Handles leading and trailing spaces, as well as token separated by multiple spaces.
///
/// __Example:__
///
///     splitSpaceDelimitedString('   foo bar     baz') // ['foo', 'bar', 'baz']
List<String> _splitSpaceDelimitedString(String string) {
  const int SPACE = 32; // ' '.codeUnits.first;

  List<String> strings = [];
  int start = 0;

  while (start != string.length) {
    while (string.codeUnitAt(start) == SPACE) {
      start++;
      if (start == string.length) {
        return strings;
      }
    }

    int end = start;
    while (string.codeUnitAt(end) != SPACE) {
      end++;
      if (end == string.length) {
        strings.add(string.substring(start, end));
        return strings;
      }
    }

    strings.add(string.substring(start, end));

    start = end;
  }

  return strings;
}
