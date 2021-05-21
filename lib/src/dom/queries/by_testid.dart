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

/// https://testing-library.com/docs/queries/bytestid/
///
/// {@template ByTestIdCaveatsCallout}
/// ### ByTestId Caveats
///
/// **Guiding Principles / Priority**
/// In the spirit of [the guiding principles](https://testing-library.com/docs/guiding-principles),
/// it is recommended to use this only [when a more accessible query is not an option](https://testing-library.com/docs/queries/about/#priority).
/// Using `data-test-id` attributes do not resemble how your software is used and should be avoided if possible.
/// That said, they are way better than querying based on DOM structure or styling css class names. Learn more
/// about `data-test-id`s from the blog post [_"Making your UI tests resilient to change"_](https://kentcdodds.com/blog/making-your-ui-tests-resilient-to-change).
///
/// **Enabling Test Mode**
/// When using a `*ByTestId` query on an OverReact component, you must call `enableTestMode()` within `main()` of your test(s).
/// {@endtemplate}
@JS()
library react_testing_library.src.dom.queries.by_testid;

import 'dart:html' show Element, Node;

import 'package:js/js.dart';

import 'package:react_testing_library/src/dom/async/types.dart';
import 'package:react_testing_library/src/dom/async/wait_for.dart';
import 'package:react_testing_library/src/dom/matches/types.dart';
import 'package:react_testing_library/src/dom/queries/interface.dart';
import 'package:react_testing_library/src/util/error_message_utils.dart' show withErrorInterop;

/// PRIVATE. Do not export from this library.
///
/// The public API is either the top level function by the same name as the methods in here,
/// or the methods by the same name exposed by `screen` / `within()`.
mixin ByTestIdQueries on IQueries {
  /// Returns a single element with the given [testId] value for the `data-test-id` attribute,
  /// defaulting to an [exact] match.
  ///
  /// {@macro ByTestIdCaveatsCallout}
  ///
  /// Throws if no element is found.
  /// Use [queryByTestId] if a RTE is not expected.
  ///
  /// > Related: [getAllByTestId]
  ///
  /// > See: <https://testing-library.com/docs/queries/bytestid/>
  ///
  /// {@template ByTestIdExample}
  /// ## Example
  ///
  /// > The example below demonstrates the usage of the `getByTestId` query. However, the example
  /// is also relevant for `getAllByTestId`, `queryByTestId`, `queryAllByTestId`, `findByTestId`
  /// and `findAllByTestId`.
  /// >
  /// > Read more about the different [types of queries](https://testing-library.com/docs/queries/about#types-of-queries) to gain more clarity on which one suits your use-cases best.
  ///
  /// ```html
  /// <div data-test-id="custom-element" />
  /// ```
  ///
  /// ```dart
  /// import 'package:react/react.dart' as react;
  /// import 'package:react_testing_library/react_testing_library.dart' as rtl;
  /// import 'package:test/test.dart';
  ///
  /// main() {
  ///   test('', () {
  ///     // Render the DOM shown in the example snippet above
  ///     final result = rtl.render(
  ///       react.div({'data-test-id': 'custom-element'}),
  ///     );
  ///
  ///     final el = result.getByTestId('custom-element');
  ///   });
  /// }
  /// ```
  /// {@endtemplate}
  /// {@macro RenderSupportsReactAndOverReactCallout}
  ///
  /// ## Options
  ///
  /// ### [testId]
  /// {@macro TextMatchArgDescription}
  /// {@macro MatcherOptionsExactArgDescription}
  /// {@macro MatcherOptionsNormalizerArgDescription}
  E getByTestId<E extends Element>(
    /*TextMatch*/ dynamic testId, {
    bool exact = true,
    NormalizerFn Function([NormalizerOptions]) normalizer,
  }) =>
      withErrorInterop(
        () => _jsGetByTestId(
          getContainerForScope(),
          TextMatch.toJs(testId),
          buildMatcherOptions(exact: exact, normalizer: normalizer),
        ) as E,
      );

  /// Returns a list of elements with the given [testId] value for the `data-test-id` attribute,
  /// defaulting to an [exact] match.
  ///
  /// {@macro ByTestIdCaveatsCallout}
  ///
  /// Throws if no elements are found.
  /// Use [queryAllByTestId] if a RTE is not expected.
  ///
  /// > Related: [getByTestId]
  ///
  /// > See: <https://testing-library.com/docs/queries/bytestid/>
  ///
  /// {@macro ByTestIdExample}
  /// {@macro RenderSupportsReactAndOverReactCallout}
  ///
  /// ## Options
  ///
  /// ### [testId]
  /// {@macro TextMatchArgDescription}
  /// {@macro MatcherOptionsExactArgDescription}
  /// {@macro MatcherOptionsNormalizerArgDescription}
  List<E> getAllByTestId<E extends Element>(
    /*TextMatch*/ dynamic testId, {
    bool exact = true,
    NormalizerFn Function([NormalizerOptions]) normalizer,
  }) =>
      withErrorInterop(
        () => _jsGetAllByTestId(
          getContainerForScope(),
          TextMatch.toJs(testId),
          buildMatcherOptions(exact: exact, normalizer: normalizer),
        ).cast<E>(), // <vomit/> https://github.com/dart-lang/sdk/issues/37676
      );

  /// Returns a single element with the given [testId] value for the `data-test-id` attribute,
  /// defaulting to an [exact] match.
  ///
  /// {@macro ByTestIdCaveatsCallout}
  ///
  /// Returns `null` if no element is found.
  /// Use [getByTestId] if a RTE is expected.
  ///
  /// > Related: [queryAllByTestId]
  ///
  /// > See: <https://testing-library.com/docs/queries/bytestid/>
  ///
  /// {@macro ByTestIdExample}
  /// {@macro RenderSupportsReactAndOverReactCallout}
  ///
  /// ## Options
  ///
  /// ### [testId]
  /// {@macro TextMatchArgDescription}
  /// {@macro MatcherOptionsExactArgDescription}
  /// {@macro MatcherOptionsNormalizerArgDescription}
  E queryByTestId<E extends Element>(
    /*TextMatch*/ dynamic testId, {
    bool exact = true,
    NormalizerFn Function([NormalizerOptions]) normalizer,
  }) =>
      _jsQueryByTestId(
        getContainerForScope(),
        TextMatch.toJs(testId),
        buildMatcherOptions(exact: exact, normalizer: normalizer),
      ) as E;

  /// Returns a list of elements with the given [testId] value for the `data-test-id` attribute,
  /// defaulting to an [exact] match.
  ///
  /// {@macro ByTestIdCaveatsCallout}
  ///
  /// Returns an empty list if no element(s) are found.
  /// Use [getAllByTestId] if a RTE is expected.
  ///
  /// > Related: [queryByTestId]
  ///
  /// > See: <https://testing-library.com/docs/queries/bytestid/>
  ///
  /// {@macro ByTestIdExample}
  /// {@macro RenderSupportsReactAndOverReactCallout}
  ///
  /// ## Options
  ///
  /// ### [testId]
  /// {@macro TextMatchArgDescription}
  /// {@macro MatcherOptionsExactArgDescription}
  /// {@macro MatcherOptionsNormalizerArgDescription}
  List<E> queryAllByTestId<E extends Element>(
    /*TextMatch*/ dynamic testId, {
    bool exact = true,
    NormalizerFn Function([NormalizerOptions]) normalizer,
  }) =>
      _jsQueryAllByTestId(
        getContainerForScope(),
        TextMatch.toJs(testId),
        buildMatcherOptions(exact: exact, normalizer: normalizer),
      ).cast<E>(); // <vomit/> https://github.com/dart-lang/sdk/issues/37676

  /// Returns a future with a single element value with the given [testId] value for the `data-test-id` attribute,
  /// defaulting to an [exact] match after waiting 1000ms (or the provided [timeout] duration).
  ///
  /// If there is a specific condition you want to wait for other than the DOM node being on the page, wrap
  /// a non-async query like [getByTestId] or [queryByTestId] in a `waitFor` function.
  ///
  /// {@macro ByTestIdCaveatsCallout}
  ///
  /// Throws if exactly one element is not found.
  ///
  /// > Related: [findAllByTestId]
  ///
  /// > See: <https://testing-library.com/docs/queries/bytestid/>
  ///
  /// {@macro ByTestIdExample}
  /// {@macro RenderSupportsReactAndOverReactCallout}
  ///
  /// ## Options
  ///
  /// ### [testId]
  /// {@macro TextMatchArgDescription}
  /// {@macro MatcherOptionsExactArgDescription}
  /// {@macro MatcherOptionsNormalizerArgDescription}
  ///
  /// ## Async Options
  ///
  /// {@macro sharedWaitForOptionsTimeoutDescription}
  /// {@macro sharedWaitForOptionsIntervalDescription}
  /// {@macro sharedWaitForOptionsOnTimeoutDescription}
  /// {@macro sharedWaitForOptionsMutationObserverDescription}
  Future<E> findByTestId<E extends Element>(
    /*TextMatch*/ dynamic testId, {
    bool exact = true,
    NormalizerFn Function([NormalizerOptions]) normalizer,
    Duration timeout,
    Duration interval,
    QueryTimeoutFn onTimeout,
    MutationObserverOptions mutationObserverOptions,
  }) {
    // NOTE: Using our own Dart `waitFor` as a wrapper around `getByTestId` instead of an
    // interop like `_jsFindByTestId` to give consumers better async stack traces.
    return waitFor(
      () => getByTestId<E>(
        testId,
        exact: exact,
        normalizer: normalizer,
      ),
      container: getContainerForScope(),
      timeout: timeout,
      interval: interval ?? defaultAsyncCallbackCheckInterval,
      onTimeout: onTimeout,
      mutationObserverOptions: mutationObserverOptions ?? defaultMutationObserverOptions,
    );
  }

  /// Returns a list of elements with the given [testId] value for the `data-test-id` attribute,
  /// defaulting to an [exact] match after waiting 1000ms (or the provided [timeout] duration).
  ///
  /// If there is a specific condition you want to wait for other than the DOM node being on the page, wrap
  /// a non-async query like [getByTestId] or [queryByTestId] in a `waitFor` function.
  ///
  /// {@macro ByTestIdCaveatsCallout}
  ///
  /// Throws if no elements are found.
  ///
  /// > Related: [findByTestId]
  ///
  /// > See: <https://testing-library.com/docs/queries/bytestid/>
  ///
  /// {@macro ByTestIdExample}
  /// {@macro RenderSupportsReactAndOverReactCallout}
  ///
  /// ## Options
  ///
  /// ### [testId]
  /// {@macro TextMatchArgDescription}
  /// {@macro MatcherOptionsExactArgDescription}
  /// {@macro MatcherOptionsNormalizerArgDescription}
  ///
  /// ## Async Options
  ///
  /// {@macro sharedWaitForOptionsTimeoutDescription}
  /// {@macro sharedWaitForOptionsIntervalDescription}
  /// {@macro sharedWaitForOptionsOnTimeoutDescription}
  /// {@macro sharedWaitForOptionsMutationObserverDescription}
  Future<List<E>> findAllByTestId<E extends Element>(
    /*TextMatch*/ dynamic testId, {
    bool exact = true,
    NormalizerFn Function([NormalizerOptions]) normalizer,
    Duration timeout,
    Duration interval,
    QueryTimeoutFn onTimeout,
    MutationObserverOptions mutationObserverOptions,
  }) {
    // NOTE: Using our own Dart `waitFor` as a wrapper around `getAllByTestId` instead of an
    // interop like `_jsFindAllByTestId` to give consumers better async stack traces.
    return waitFor(
      () => getAllByTestId<E>(
        testId,
        exact: exact,
        normalizer: normalizer,
      ),
      container: getContainerForScope(),
      timeout: timeout,
      interval: interval ?? defaultAsyncCallbackCheckInterval,
      onTimeout: onTimeout,
      mutationObserverOptions: mutationObserverOptions ?? defaultMutationObserverOptions,
    );
  }
}

@JS('rtl.getByTestId')
external Element _jsGetByTestId(
  Node container,
  /*TextMatch*/ dynamic testId, [
  MatcherOptions options,
]);

@JS('rtl.getAllByTestId')
external List< /*Element*/ dynamic> _jsGetAllByTestId(
  Node container,
  /*TextMatch*/ dynamic testId, [
  MatcherOptions options,
]);

@JS('rtl.queryByTestId')
external Element _jsQueryByTestId(
  Node container,
  /*TextMatch*/ dynamic testId, [
  MatcherOptions options,
]);

@JS('rtl.queryAllByTestId')
external List< /*Element*/ dynamic> _jsQueryAllByTestId(
  Node container,
  /*TextMatch*/ dynamic testId, [
  MatcherOptions options,
]);