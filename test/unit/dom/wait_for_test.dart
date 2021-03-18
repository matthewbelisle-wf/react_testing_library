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
import 'package:react_testing_library/src/util/error_message_utils.dart';
import 'package:test/test.dart';

import '../util/constants.dart';
import '../util/init.dart';
import '../util/matchers.dart';
import '../util/rendering.dart';

main() {
  group('', () {
    initConfigForInternalTesting();

    rtl.RenderResult renderResult;
    Element rootElement;

    group('waitFor()', () {
      setUp(() {
        renderResult = rtl.render(DelayedRenderOf({'childrenToRenderAfterDelay': elementsForQuerying('waitFor')}));
        rootElement = renderResult.getByTestId('delayed-render-of-root');
      });

      group('when the expectation argument returns', () {
        group('a test `expect` function', () {
          test('that succeeds', () async {
            expect(rootElement.children, isEmpty, reason: 'test setup sanity check');
            await rtl.waitFor(() => expect(rootElement.children, isNotEmpty), container: renderResult.container);
          }, timeout: asyncQueryTestTimeout);

          test('that fails', () async {
            expect(
                () async => await rtl.waitFor(() => expect(renderResult.container.contains(rootElement), isFalse),
                    container: renderResult.container),
                throwsA(isA<TestFailure>()));
          }, timeout: asyncQueryTestTimeout);
        });

        test('a function that throws an arbitrary error, rethrows the error thrown by the expectation', () async {
          expect(() async => await rtl.waitFor(() => throw AssertionError('foo'), container: renderResult.container),
              throwsA(isA<AssertionError>()));
        }, timeout: asyncQueryTestTimeout);

        group('a getBy* query', () {
          test('that succeeds', () async {
            expect(renderResult.queryByAltText('waitFor'), isNull, reason: 'test setup sanity check');
            await rtl.waitFor(() => renderResult.getByAltText('waitFor'), container: renderResult.container);
          }, timeout: asyncQueryTestTimeout);

          test('that fails, throws the error returned from the expectation', () async {
            expect(renderResult.queryByAltText('waitFor'), isNull, reason: 'test setup sanity check');
            expect(
                () async => await rtl.waitFor(() => renderResult.getByAltText('somethingThatDoesNotExist'),
                    container: renderResult.container),
                throwsA(allOf(
                  isA<TestingLibraryElementError>(),
                  /*TODO: Assert that the error matches a `getByAltText` error message*/
                )));
          }, timeout: asyncQueryTestTimeout);
        });

        group('an async findBy* query', () {
          test('that succeeds', () async {
            expect(renderResult.queryByAltText('waitFor'), isNull, reason: 'test setup sanity check');
            await rtl.waitFor(() => renderResult.findByAltText('waitFor'), container: renderResult.container);
          }, timeout: asyncQueryTestTimeout);

          group('that fails, throws the error returned from the expectation', () {
            test('', () async {
              expect(renderResult.queryByAltText('waitFor'), isNull, reason: 'test setup sanity check');
              expect(
                  () async => await rtl.waitFor(
                      () async => await renderResult.findByAltText('somethingThatDoesNotExist'),
                      container: renderResult.container),
                  throwsA(allOf(
                    isA<TestingLibraryElementError>(),
                    /*TODO: Assert that the error matches a `findByAltText` error message*/
                  )));
            }, timeout: asyncQueryTestTimeout);

            test('unless the timeout duration is less than the timeout duration of the query', () async {
              expect(renderResult.queryByAltText('waitFor'), isNull, reason: 'test setup sanity check');
              expect(
                  () async => await rtl.waitFor(
                      () async => await renderResult.findByAltText('somethingThatDoesNotExist'),
                      container: renderResult.container,
                      timeout: asyncQueryTimeout ~/ 2),
                  throwsA(allOf(
                    isA<TestingLibraryAsyncTimeout>(),
                    hasToStringValue(contains('Timed out in waitFor after')),
                  )));
            }, timeout: asyncQueryTestTimeout);
          });
        });
      });

      test('when onTimeout is customized', () async {
        expect(
            () async => await rtl.waitFor(() => expect(renderResult.container.contains(rootElement), isFalse),
                    container: renderResult.container, onTimeout: (error) {
                  return TestingLibraryAsyncTimeout('This is a custom message\n\noriginalError: \n$error');
                }),
            throwsA(allOf(
              isA<TestingLibraryAsyncTimeout>(),
              hasToStringValue(contains('This is a custom message')),
              hasToStringValue(contains('Expected')),
            )));
      });
    });

    group('waitForElementToBeRemoved()', () {
      Element elementThatWillBeRemovedAfterDelay;
      Element elementInDomButOutsideContainer;
      Duration delayAfterWhichTheElementWillBeRemoved = asyncQueryTimeout ~/ 2;
      Duration shortTimeout = asyncQueryTimeout ~/ 4;

      setUp(() {
        expect(shortTimeout, lessThan(delayAfterWhichTheElementWillBeRemoved), reason: 'test setup sanity check');

        renderResult = rtl.render(DelayedRenderOf(
          {
            'childrenToRenderAfterDelay': elementsForQuerying('waitForElementToBeRemoved'),
          },
          react.div(
            {},
            react.div({}, 'willBeRemoved'),
            elementsForQuerying('waitForElementToBeRemoved'),
          ),
        ));
        elementThatWillBeRemovedAfterDelay = renderResult.getByText('willBeRemoved');
        elementInDomButOutsideContainer = document.body.append(DivElement()
          ..id = 'notInScope'
          ..text = 'notInScope');
      });

      tearDown(() {
        elementInDomButOutsideContainer.remove();
      });

      group('when the callback argument returns', () {
        group('an element that is present initially', () {
          test('and eventually removed before timeout, completes successfully', () async {
            expect(
                () async => await rtl.waitForElementToBeRemoved(() => elementThatWillBeRemovedAfterDelay,
                    container: renderResult.container),
                returnsNormally);
          }, timeout: asyncQueryTestTimeout);

          test('and is not removed before timeout, throws ', () async {
            expect(
                () async => await rtl.waitForElementToBeRemoved(() => elementThatWillBeRemovedAfterDelay,
                    container: renderResult.container, timeout: shortTimeout),
                throwsA(allOf(
                  isA<TestingLibraryAsyncTimeout>(),
                  hasToStringValue(
                      contains('The element returned from the callback was still present in the container after')),
                  hasToStringValue(contains(rtl.prettyDOM(renderResult.container))),
                )));
          }, timeout: asyncQueryTestTimeout);
        });

        test('an element that is not present in the container initially, throws', () async {
          expect(querySelector('#notInScope'), isNotNull, reason: 'test setup sanity check');
          expect(renderResult.container, isNot(document.body), reason: 'test setup sanity check');
          expect(
              () async => await rtl.waitForElementToBeRemoved(() => elementInDomButOutsideContainer,
                  container: renderResult.container),
              throwsA(allOf(
                isA<TestingLibraryElementError>(),
                hasToStringValue(contains(
                    'The element returned from the callback was not present in the container at the time waitForElementToBeRemoved() was called')),
                hasToStringValue(contains(rtl.prettyDOM(renderResult.container))),
              )));
        }, timeout: asyncQueryTestTimeout);

        test('null, throws', () async {
          expect(
              () async => await rtl.waitForElementToBeRemoved(() => null, container: renderResult.container),
              throwsA(allOf(
                isA<TestingLibraryElementError>(),
                hasToStringValue(contains('The callback must return a non-null Element.')),
              )));
        }, timeout: asyncQueryTestTimeout);
      });
    });

    // TODO: Add tests where only a single element in a list of multiple elements is removed, etc.
    group('waitForElementsToBeRemoved()', () {
      Element elementThatWillBeRemovedAfterDelay;
      Element anotherElementThatWillBeRemovedAfterDelay;
      Element elementThatWillNotBeRemovedAfterDelay;
      Element elementInDomButOutsideContainer;
      Element anotherElementInDomButOutsideContainer;
      Duration delayAfterWhichTheElementWillBeRemoved = asyncQueryTimeout ~/ 2;
      Duration shortTimeout = asyncQueryTimeout ~/ 4;

      setUp(() {
        expect(shortTimeout, lessThan(delayAfterWhichTheElementWillBeRemoved), reason: 'test setup sanity check');

        renderResult = rtl.render(DelayedRenderOf(
          {
            'childrenToRenderAfterDelay': elementsForQuerying('waitForElementToBeRemoved'),
          },
          react.div(
            {},
            react.div({}, 'willBeRemoved'),
            react.div({}, 'willAlsoBeRemoved'),
            react.div({}, 'willNotBeRemoved'),
            elementsForQuerying('waitForElementToBeRemoved'),
          ),
        ));
        elementThatWillBeRemovedAfterDelay = renderResult.getByText('willBeRemoved');
        anotherElementThatWillBeRemovedAfterDelay = renderResult.getByText('willAlsoBeRemoved');
        elementThatWillNotBeRemovedAfterDelay = renderResult.getByText('willNotBeRemoved');
        elementInDomButOutsideContainer = document.body.append(DivElement()
          ..id = 'notInScope'
          ..text = 'notInScope');
        anotherElementInDomButOutsideContainer = document.body.append(DivElement()
          ..id = 'alsoNotInScope'
          ..text = 'alsoNotInScope');
      });

      tearDown(() {
        elementInDomButOutsideContainer.remove();
        anotherElementInDomButOutsideContainer.remove();
      });

      group('when the callback argument returns', () {
        group('an element that is present initially', () {
          test('and eventually removed before timeout, completes successfully', () async {
            await rtl.waitForElementsToBeRemoved(() => [elementThatWillBeRemovedAfterDelay],
                container: renderResult.container);
          }, timeout: asyncQueryTestTimeout);

          test('and not removed before timeout, throws ', () async {
            expect(
                () async => await rtl.waitForElementsToBeRemoved(() => [elementThatWillBeRemovedAfterDelay],
                    container: renderResult.container, timeout: shortTimeout),
                throwsA(allOf(
                  isA<TestingLibraryAsyncTimeout>(),
                  hasToStringValue(
                      contains('The element returned from the callback was still present in the container after')),
                  hasToStringValue(contains(rtl.prettyDOM(renderResult.container))),
                )));
          }, timeout: asyncQueryTestTimeout);
        });

        group('more than one element that is present initially', () {
          test('all of which are eventually removed before timeout, completes successfully', () async {
            expect(
                () async => await rtl.waitForElementsToBeRemoved(
                    () => [
                          elementThatWillBeRemovedAfterDelay,
                          anotherElementThatWillBeRemovedAfterDelay,
                        ],
                    container: renderResult.container),
                returnsNormally);
          }, timeout: asyncQueryTestTimeout);

          test('one of which is not removed before timeout, throws ', () async {
            expect(
                () async => await rtl.waitForElementsToBeRemoved(
                    () => [
                          elementThatWillBeRemovedAfterDelay,
                          anotherElementThatWillBeRemovedAfterDelay,
                          elementThatWillNotBeRemovedAfterDelay,
                        ],
                    container: renderResult.container,
                    timeout: shortTimeout),
                throwsA(allOf(
                  isA<TestingLibraryAsyncTimeout>(),
                  hasToStringValue(
                      contains('The element returned from the callback was still present in the container after')),
                  hasToStringValue(contains(rtl.prettyDOM(renderResult.container))),
                )));
          }, timeout: asyncQueryTestTimeout);
        });

        test('a single element that is not present in the container initially, throws', () async {
          expect(
              () async => await rtl.waitForElementsToBeRemoved(() => [elementInDomButOutsideContainer],
                  container: renderResult.container),
              throwsA(allOf(
                isA<TestingLibraryElementError>(),
                hasToStringValue(contains(
                    'One of the elements returned from the callback was not present in the container at the time waitForElementsToBeRemoved() was called')),
                hasToStringValue(contains(rtl.prettyDOM(renderResult.container))),
              )));
        }, timeout: asyncQueryTestTimeout);

        test('more than one element - one of which is not present in the container initially, throws', () async {
          expect(
              () async => await rtl.waitForElementsToBeRemoved(
                  () => [
                        elementThatWillBeRemovedAfterDelay,
                        elementInDomButOutsideContainer,
                      ],
                  container: renderResult.container),
              throwsA(allOf(
                isA<TestingLibraryElementError>(),
                hasToStringValue(contains(
                    'One of the elements returned from the callback was not present in the container at the time waitForElementsToBeRemoved() was called')),
                hasToStringValue(contains(rtl.prettyDOM(renderResult.container))),
              )));
        }, timeout: asyncQueryTestTimeout);

        test('more than one element - more than one of which are not present in the container initially, throws',
            () async {
          expect(
              () async => await rtl.waitForElementsToBeRemoved(
                  () => [
                        elementThatWillBeRemovedAfterDelay,
                        elementInDomButOutsideContainer,
                        anotherElementInDomButOutsideContainer,
                      ],
                  container: renderResult.container),
              throwsA(allOf(
                isA<TestingLibraryElementError>(),
                hasToStringValue(contains(
                    'One of the elements returned from the callback was not present in the container at the time waitForElementsToBeRemoved() was called')),
                hasToStringValue(contains(rtl.prettyDOM(renderResult.container))),
              )));
        }, timeout: asyncQueryTestTimeout);

        test('more than one element - all of which are not present in the container initially, throws', () async {
          expect(
              () async => await rtl.waitForElementsToBeRemoved(
                  () => [
                        elementInDomButOutsideContainer,
                        anotherElementInDomButOutsideContainer,
                      ],
                  container: renderResult.container),
              throwsA(allOf(
                isA<TestingLibraryElementError>(),
                hasToStringValue(contains(
                    'One of the elements returned from the callback was not present in the container at the time waitForElementsToBeRemoved() was called')),
                hasToStringValue(contains(rtl.prettyDOM(renderResult.container))),
              )));
        }, timeout: asyncQueryTestTimeout);

        test('null, throws', () async {
          expect(
              () async => await rtl.waitForElementsToBeRemoved(() => null, container: renderResult.container),
              throwsA(allOf(
                isA<TestingLibraryElementError>(),
                hasToStringValue(contains('The callback must return one or more non-null Elements.')),
              )));
        }, timeout: asyncQueryTestTimeout);

        test('an empty list, throws', () async {
          expect(
              () async => await rtl.waitForElementsToBeRemoved(() => [], container: renderResult.container),
              throwsA(allOf(
                isA<TestingLibraryElementError>(),
                hasToStringValue(contains('The callback must return one or more non-null Elements.')),
              )));
        }, timeout: asyncQueryTestTimeout);
      });
    });
  });
}
