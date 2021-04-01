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

import 'dart:html' show Node, ShadowRoot, document;

import 'package:react_testing_library/src/dom/scoped_queries.dart' show ScopedQueries;
import 'package:react_testing_library/src/util/is_or_contains.dart';
import 'package:test/test.dart' show addTearDown, expect, isNotNull, isTrue;

/// Queries scoped to the provided [container].
class WithinQueries extends ScopedQueries {
  WithinQueries(this.container) : super(() => container);

  final Node container;
}

/// Takes a DOM [node] and binds it to the raw query functions.
///
/// Can also be used to query within the [ShadowRoot] of an element by setting
/// [node] to the `Element.shadowRoot` value as shown below:
///
/// ```dart
/// // Or whatever query you want to use to find element(s) within the shadowRoot.
/// final fooNodeWithinShadowDom = within(someElement.shadowRoot).getByText('foo');
/// ```
///
/// > See: <https://testing-library.com/docs/dom-testing-library/api-within>
WithinQueries within(Node node) {
  expect(node, isNotNull, reason: 'You must provide a non-null element as the single argument to within().');
  if (node is! ShadowRoot) {
    expect(isOrContains(document.body, node), isTrue,
        reason:
            'The element you provide as the single argument to within() must exist in the DOM. Did you forget to append the element to the body?');
  }

  var withinQueriesInstance = WithinQueries(node);
  addTearDown(() {
    withinQueriesInstance = null;
  });

  return withinQueriesInstance;
}
