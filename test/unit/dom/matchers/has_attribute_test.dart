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

import 'dart:html' show DivElement;

import 'package:react_testing_library/matchers.dart' show hasAttribute;
import 'package:test/test.dart';

import '../../util/matchers.dart';

main() {
  group('hasAttribute matcher', () {
    DivElement testElement;

    setUp(() {
      testElement = DivElement();
    });

    test('should pass when the element has the attribute set to the correct value', () {
      testElement.setAttribute('index', '1');
      shouldPass(testElement, hasAttribute('index', '1'));
    });

    test('should pass when the element has the attribute set to a value that matches the matcher', () {
      testElement.setAttribute('index', 'foo bar baz');
      shouldPass(testElement, hasAttribute('index', contains('foo')));
    });

    test('should fail when the element has the attribute set to the wrong value', () {
      testElement.setAttribute('index', '-1');
      shouldFail(
          testElement,
          hasAttribute('index', '1'),
          'Expected: Element with "index" attribute that equals \'1\''
          ' Actual: DivElement:<div> Which: has attributes with value \'-1\' which is different.'
          ' Expected: 1'
          ' Actual: -1'
          ' ^ Differ at offset 0');
    });
  });
}
