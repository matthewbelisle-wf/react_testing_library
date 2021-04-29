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

/// https://testing-library.com/docs/queries/bytitle/
@JS()
library react_testing_library.src.dom.queries.by_title;

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
mixin ByTitleQueries on IQueries {
  /// Returns a single element with the given [title] as the value of the `title` attribute,
  /// defaulting to an [exact] match.
  ///
  /// Throws if no element is found.
  /// Use [queryByTitle] if a RTE is not expected.
  ///
  /// > Related: [getAllByTitle]
  ///
  /// > See: <https://testing-library.com/docs/queries/bytitle/>
  ///
  /// ## Options
  ///
  /// ### [title]
  /// {@macro TextMatchArgDescription}
  /// {@macro MatcherOptionsExactArgDescription}
  /// {@macro MatcherOptionsNormalizerArgDescription}
  /// {@macro MatcherOptionsErrorMessage}
  E getByTitle<E extends Element>(
    /*TextMatch*/ dynamic title, {
    bool exact = true,
    NormalizerFn Function(NormalizerOptions) normalizer,
    String errorMessage,
  }) =>
      withErrorInterop(
          () => _jsGetByTitle(
                getContainerForScope(),
                TextMatch.toJs(title),
                buildMatcherOptions(exact: exact, normalizer: normalizer),
              ) as E,
          errorMessage: errorMessage);

  /// Returns a list of elements with the given [title] as the value of the `title` attribute,
  /// defaulting to an [exact] match.
  ///
  /// Throws if no elements are found.
  /// Use [queryAllByTitle] if a RTE is not expected.
  ///
  /// > Related: [getByTitle]
  ///
  /// > See: <https://testing-library.com/docs/queries/bytitle/>
  ///
  /// ## Options
  ///
  /// ### [title]
  /// {@macro TextMatchArgDescription}
  /// {@macro MatcherOptionsExactArgDescription}
  /// {@macro MatcherOptionsNormalizerArgDescription}
  /// {@macro MatcherOptionsErrorMessage}
  List<E> getAllByTitle<E extends Element>(
    /*TextMatch*/ dynamic title, {
    bool exact = true,
    NormalizerFn Function(NormalizerOptions) normalizer,
    String errorMessage,
  }) =>
      withErrorInterop(
          () => _jsGetAllByTitle(
                getContainerForScope(),
                TextMatch.toJs(title),
                buildMatcherOptions(exact: exact, normalizer: normalizer),
              ).cast<E>(), // <vomit/> https://github.com/dart-lang/sdk/issues/37676
          errorMessage: errorMessage);

  /// Returns a single element with the given [title] as the value of the `title` attribute,
  /// defaulting to an [exact] match.
  ///
  /// Returns `null` if no element is found.
  /// Use [getByTitle] if a RTE is expected.
  ///
  /// > Related: [queryAllByTitle]
  ///
  /// > See: <https://testing-library.com/docs/queries/bytitle/>
  ///
  /// ## Options
  ///
  /// ### [title]
  /// {@macro TextMatchArgDescription}
  /// {@macro MatcherOptionsExactArgDescription}
  /// {@macro MatcherOptionsNormalizerArgDescription}
  E queryByTitle<E extends Element>(
    /*TextMatch*/ dynamic title, {
    bool exact = true,
    NormalizerFn Function(NormalizerOptions) normalizer,
  }) =>
      _jsQueryByTitle(
        getContainerForScope(),
        TextMatch.toJs(title),
        buildMatcherOptions(exact: exact, normalizer: normalizer),
      ) as E;

  /// Returns a list of elements with the given [title] as the value of the `title` attribute,
  /// defaulting to an [exact] match.
  ///
  /// Returns an empty list if no element(s) are found.
  /// Use [getAllByTitle] if a RTE is expected.
  ///
  /// > Related: [queryByTitle]
  ///
  /// > See: <https://testing-library.com/docs/queries/bytitle/>
  ///
  /// ## Options
  ///
  /// ### [title]
  /// {@macro TextMatchArgDescription}
  /// {@macro MatcherOptionsExactArgDescription}
  /// {@macro MatcherOptionsNormalizerArgDescription}
  List<E> queryAllByTitle<E extends Element>(
    /*TextMatch*/ dynamic title, {
    bool exact = true,
    NormalizerFn Function(NormalizerOptions) normalizer,
  }) =>
      _jsQueryAllByTitle(
        getContainerForScope(),
        TextMatch.toJs(title),
        buildMatcherOptions(exact: exact, normalizer: normalizer),
      ).cast<E>(); // <vomit/> https://github.com/dart-lang/sdk/issues/37676

  /// Returns a future with a single element value with the given [title] as the value of the `title` attribute,
  /// defaulting to an [exact] match after waiting `1000ms` (or the specified [timeout] duration).
  ///
  /// If there is a specific condition you want to wait for other than the DOM node being on the page, wrap
  /// a non-async query like [getByTitle] or [queryByTitle] in a `waitFor` function.
  ///
  /// Throws if exactly one element is not found.
  ///
  /// > Related: [findAllByTitle]
  ///
  /// > See: <https://testing-library.com/docs/queries/bytitle/>
  ///
  /// ## Options
  ///
  /// ### [title]
  /// {@macro TextMatchArgDescription}
  /// {@macro MatcherOptionsExactArgDescription}
  /// {@macro MatcherOptionsNormalizerArgDescription}
  /// {@macro MatcherOptionsErrorMessage}
  ///
  /// ## Async Options
  ///
  /// {@macro sharedWaitForOptionsTimeoutDescription}
  /// {@macro sharedWaitForOptionsIntervalDescription}
  /// {@macro sharedWaitForOptionsOnTimeoutDescription}
  /// {@macro sharedWaitForOptionsMutationObserverDescription}
  Future<E> findByTitle<E extends Element>(
    /*TextMatch*/ dynamic title, {
    bool exact = true,
    NormalizerFn Function(NormalizerOptions) normalizer,
    String errorMessage,
    Duration timeout,
    Duration interval,
    QueryTimeoutFn onTimeout,
    MutationObserverOptions mutationObserverOptions,
  }) {
    // NOTE: Using our own Dart waitFor as a wrapper instead of calling _jsFindByTitle for consistency with our
    // need to use it on the analogous `findAllByTitle` query.
    return waitFor(
      () => getByTitle<E>(
        title,
        exact: exact,
        normalizer: normalizer,
        errorMessage: errorMessage,
      ),
      container: getContainerForScope(),
      timeout: timeout,
      interval: interval ?? defaultAsyncCallbackCheckInterval,
      onTimeout: onTimeout,
      mutationObserverOptions: mutationObserverOptions ?? defaultMutationObserverOptions,
    );
  }

  /// Returns a list of elements with the given [title] as the value of the `title` attribute,
  /// defaulting to an [exact] match after waiting `1000ms` (or the specified [timeout] duration).
  ///
  /// If there is a specific condition you want to wait for other than the DOM node being on the page, wrap
  /// a non-async query like [getByTitle] or [queryByTitle] in a `waitFor` function.
  ///
  /// Throws if no elements are found.
  ///
  /// > Related: [findByTitle]
  ///
  /// > See: <https://testing-library.com/docs/queries/bytitle/>
  ///
  /// ## Options
  ///
  /// ### [title]
  /// {@macro TextMatchArgDescription}
  /// {@macro MatcherOptionsExactArgDescription}
  /// {@macro MatcherOptionsNormalizerArgDescription}
  /// {@macro MatcherOptionsErrorMessage}
  ///
  /// ## Async Options
  ///
  /// {@macro sharedWaitForOptionsTimeoutDescription}
  /// {@macro sharedWaitForOptionsIntervalDescription}
  /// {@macro sharedWaitForOptionsOnTimeoutDescription}
  /// {@macro sharedWaitForOptionsMutationObserverDescription}
  Future<List<E>> findAllByTitle<E extends Element>(
    /*TextMatch*/ dynamic title, {
    bool exact = true,
    NormalizerFn Function(NormalizerOptions) normalizer,
    String errorMessage,
    Duration timeout,
    Duration interval,
    QueryTimeoutFn onTimeout,
    MutationObserverOptions mutationObserverOptions,
  }) {
    // NOTE: Using our own Dart waitFor as a wrapper instead of calling _jsFindAllByTitle because of the inability
    // to call `.cast<E>` on the list before returning to consumers (https://github.com/dart-lang/sdk/issues/37676)
    // like we can/must on the `getAllByTitle` return value.
    return waitFor(
      () => getAllByTitle<E>(
        title,
        exact: exact,
        normalizer: normalizer,
        errorMessage: errorMessage,
      ),
      container: getContainerForScope(),
      timeout: timeout,
      interval: interval ?? defaultAsyncCallbackCheckInterval,
      onTimeout: onTimeout,
      mutationObserverOptions: mutationObserverOptions ?? defaultMutationObserverOptions,
    );
  }
}

@JS('rtl.getByTitle')
external Element _jsGetByTitle(
  Node container,
  /*TextMatch*/
  title, [
  MatcherOptions options,
]);

@JS('rtl.getAllByTitle')
external List< /*Element*/ dynamic> _jsGetAllByTitle(
  Node container,
  /*TextMatch*/
  title, [
  MatcherOptions options,
]);

@JS('rtl.queryByTitle')
external Element _jsQueryByTitle(
  Node container,
  /*TextMatch*/
  title, [
  MatcherOptions options,
]);

@JS('rtl.queryAllByTitle')
external List< /*Element*/ dynamic> _jsQueryAllByTitle(
  Node container,
  /*TextMatch*/
  title, [
  MatcherOptions options,
]);
