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

@JS()
library react_testing_library.src.dom.fire_event;

import 'dart:html';

import 'package:js/js.dart';
import 'package:react/react_client/js_backed_map.dart';
import 'package:react/react_client/js_interop_helpers.dart';

import '../user_event/user_event.dart';

/// Fires a DOM [event] on the provided [element].
///
/// > **NOTE:**
/// >
/// > Most projects have a few use cases for [fireEvent], but the majority of the time you should
///   probably use `@testing-library/user-event`.
/// >
/// > TODO: Link to the user event interop provided by this library once implemented (CPLAT-13506)
///
/// > Related: [fireEventByName]
///
/// > See: <https://testing-library.com/docs/dom-testing-library/api-events/#fireevent>
@JS('rtl.fireEvent')
external bool fireEvent(
  Element element,
  Event event,
);

@JS('rtl.fireEventObj')
external JsMap get _fireEventObj;

/// Since Dart doesn't support anonymous objects that can act as both a Map and a function
/// like the JS `fireEvent` can, this function acts as a proxy for:
///
/// ```js
/// // JS API
/// fireEvent.click(someElement, {'button': 2});
/// ```
///
/// Where the Dart API equivalent of the above call would be:
///
/// ```dart
/// // Dart API
/// fireEventByName('click', someElement, {'button': 2});
/// ```
///
/// The [eventName] must be one of the keys found in the
/// JS [`eventMap`](https://github.com/testing-library/dom-testing-library/blob/master/src/event-map.js)
///
/// > **NOTE:**
/// >
/// > Most projects have a few use cases for [fireEventByName], but the majority of the time you should
///   probably use [UserEvent] utilities instead.
///
/// > See: <https://testing-library.com/docs/dom-testing-library/api-events/#fireeventeventname>
bool fireEventByName(String eventName, Element element, [Map eventProperties]) {
  if (!JsBackedMap.fromJs(_jsEventMap).keys.contains(eventName)) {
    throw ArgumentError.value(eventName, 'eventName');
  }

  final bool Function(Element, [/*JsObject*/ dynamic]) jsFireEventByNameFn =
      JsBackedMap.fromJs(_fireEventObj)[eventName];

  if (eventProperties == null) {
    return jsFireEventByNameFn(element);
  }

  return jsFireEventByNameFn(element, jsifyAndAllowInterop(eventProperties));
}

@JS('rtl.eventMap')
external JsMap get _jsEventMap;
