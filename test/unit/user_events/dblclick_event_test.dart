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

import 'package:react/react.dart' as react;
import 'package:react_testing_library/react_testing_library.dart' as rtl;
import 'package:test/test.dart';

main() {
  group('UserEvent.dblClick', () {
    List<Event> calls;
    int hoverEventCount;
    rtl.RenderResult renderedResult;

    setUp(() {
      calls = [];
      hoverEventCount = 0;

      final elementToRender = react.button({
        'id': 'root',
        'onClick': (react.SyntheticMouseEvent event) {
          calls.add(event.nativeEvent);
        },
        // Count mouseover events to find out how many hover events occur.
        'onMouseOver': (_) => hoverEventCount++,
      }, 'oh hai');

      renderedResult = rtl.render(elementToRender);
    });

    void _verifyDblClickEvent({
      bool hasEventInit = false
    }) {
      // Sanity check.
      expect(calls, hasLength(2));
      calls.forEach((event) {
        expect(event, isA<MouseEvent>());

        // Verify initial MouseEvent.
        expect((event as MouseEvent).shiftKey, hasEventInit ? isTrue : isFalse);
      });

      // Verify click count was incremented twice.
      expect((calls.first as MouseEvent).detail, equals(1));
      expect((calls[1] as MouseEvent).detail, equals(2));

      // Verify hover event only happens once.
      expect(hoverEventCount, equals(1));
    }

    test('', () {
      rtl.UserEvent.dblClick(renderedResult.getByRole('button'));
      _verifyDblClickEvent();
    });

    test('eventInit', () {
      rtl.UserEvent.dblClick(
        renderedResult.getByRole('button'),
        eventInit: {'shiftKey': true},
      );
      _verifyDblClickEvent(hasEventInit: true);
    });
  });
}
