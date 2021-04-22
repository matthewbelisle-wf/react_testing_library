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

import 'package:matcher/matcher.dart';
import 'package:react_testing_library/src/matchers/jest_dom/util/constants.dart';

/// Allows you to check whether the given element is `checked`.
///
/// It accepts an `input` of type `checkbox` or `radio` and elements with a `role` of `checkbox`, `radio` or `switch`
/// with a valid `aria-checked` attribute of "true" or "false".
///
/// Similar to [jest-dom's `toBeChecked` matcher](https://github.com/testing-library/jest-dom#tobechecked).
///
/// ### Examples
///
/// ```html
/// &lt;div>
///   &lt;input type="checkbox" name="pepperoni" checked />
///   &lt;input type="checkbox" name="pineapple" />
///   &lt;div role="checkbox" aria-checked="true">Red Sauce&lt;/div>
///   &lt;div role="checkbox" aria-checked="false">White Sauce&lt;/div>
///   &lt;div role="switch" aria-checked="true">Mozzarella&lt;/div>
///   &lt;div role="switch" aria-checked="false">Cheddar&lt;/div>
/// &lt;/div>
/// ```
///
/// ```dart
/// import 'package:react/react.dart' as react;
/// import 'package:react_testing_library/matchers.dart' show isChecked;
/// import 'package:react_testing_library/react_testing_library.dart' as rtl;
/// import 'package:test/test.dart';
///
/// main() {
///   test('', () {
///     // Render the DOM shown in the example snippet above
///     final result = rtl.render(react.div({},
///       react.input({'type': 'checkbox', 'name': 'pepperoni', 'checked': true}),
///       react.input({'type': 'checkbox', 'name': 'pineapple'}),
///       react.div({'role': 'checkbox', 'aria-checked': 'true'}, 'Red Sauce'),
///       react.div({'role': 'checkbox', 'aria-checked': 'false'}, 'White Sauce'),
///       react.div({'role': 'switch', 'aria-checked': 'true'}, 'Mozzarella'),
///       react.div({'role': 'switch', 'aria-checked': 'false'}, 'Cheddar'),
///     ));
///
///     // Use react_testing_library queries to store references to the node(s)
///     const inputCheckboxChecked = result.getByRole('checkbox', name: 'pepperoni');
///     const inputCheckboxUnchecked = result.getByRole('checkbox', name: 'pineapple');
///     const ariaCheckboxChecked = result.getByRole('checkbox', name: 'Red Sauce');
///     const ariaCheckboxUnchecked = result.getByRole('checkbox', name: 'White Sauce');
///     const ariaSwitchChecked = result.getByRole('switch', name: 'Mozzarella');
///     const ariaSwitchUnchecked = result.getByRole('switch', name: 'Cheddar');
///
///     // Use the `isChecked` matcher as the second argument of `expect()`
///     expect(inputCheckboxChecked, isChecked);
///     expect(inputCheckboxUnchecked, isNot(isChecked));
///     expect(ariaCheckboxChecked, isChecked);
///     expect(ariaCheckboxUnchecked, isNot(isChecked));
///     expect(ariaSwitchChecked, isChecked);
///     expect(ariaSwitchUnchecked, isNot(isChecked));
///   });
/// }
/// ```
///
/// {@macro RenderSupportsReactAndOverReactCallout}
///
/// {@category Matchers}
const Matcher isChecked = _IsChecked();

class _IsChecked extends Matcher {
  static const _validTypes = ['checkbox', 'radio'];
  static const _validRoles = [..._validTypes, 'switch'];

  const _IsChecked();

  @override
  Description describe(Description description) {
    return description..add('An element that is checked');
  }

  bool isElementThatCanBeChecked(item, Map matchState) =>
      item != null && matchState['isElement'] && matchState['canBeChecked'];

  bool isElementChecked(Element item, Map matchState) {
    if (item is InputElement) {
      final type = item.getAttribute('type');
      if (_validTypes.contains(type)) {
        return item.checked;
      }
    }

    final role = item.getAttribute('role');
    if (_validRoles.contains(role)) {
      final ariaCheckedValue = item.getAttribute('aria-checked');
      return ariaCheckedValue == 'true';
    }

    return false;
  }

  void setMatchState(item, Map matchState) {
    matchState['isElement'] = item is Element;
    matchState['canBeChecked'] = (item is InputElement && _validTypes.contains(item.getAttribute('type'))) ||
        (item is Element && _validRoles.contains(item.getAttribute('role')));
  }

  String get defaultMismatchDescription => 'is not checked.';

  @override
  bool matches(item, Map matchState) {
    setMatchState(item, matchState);

    if (!isElementThatCanBeChecked(item, matchState)) return false;

    return isElementChecked(item, matchState);
  }

  @override
  Description describeMismatch(item, Description mismatchDescription, Map matchState, bool verbose) {
    if (matchState['isElement'] != true) {
      return mismatchDescription..add(notAnElementMismatchDescription);
    } else if (matchState['canBeChecked'] != true) {
      return mismatchDescription..add('is not a type of HTML Element that can be checked.');
    }

    return mismatchDescription..add(defaultMismatchDescription);
  }
}
