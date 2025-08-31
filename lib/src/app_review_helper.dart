import 'dart:async';

import 'package:app_review_helper/src/models/review_dialog.dart';
import 'package:app_review_helper/src/models/review_state.dart';
import 'package:conditional_trigger/conditional_trigger.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';

import 'models/review_mock.dart';

class AppReviewHelper {
  /// Get AppReviewHelper instance.
  static AppReviewHelper instance = AppReviewHelper._internal();
  static ReviewMock? _mock;

  /// Set mock values.
  static void setMockInitialValues([ReviewMock? mock]) {
    _mock = mock;
  }

  AppReviewHelper._internal();

  /// Debug
  bool _isDebug = false;

  /// This function will request an in-app review every time a new version is published
  /// and it's satisfied with the conditions.
  Future<ReviewState> initial({
    /// There are 2 kinds of dialogs. The `satisfaction` dialog will be shown first
    /// to ask for the user's satisfaction. When the user is not satisfied with the app
    /// (which means the `satisfaction` dialog returns `false`), the second `opinion`
    /// dialog will be shown to ask for the user's opinion on how to improve the app.
    ///
    /// There is a built-in [DefaultReviewDialog].
    ReviewDialog? reviewDialog,

    /// Min days
    int minDays = 3,

    /// If you add this line in your main(), it's same as app opening count
    int minCalls = 3,

    /// If the current version is satisfied with this than not showing the request
    /// this value use plugin `satisfied_version` to compare.
    List<String> noRequestVersions = const [],

    /// List of version that allow the app to remind the in-app review.
    List<String> remindedVersions = const [],

    /// If true, it'll keep asking for the review on each new version (and satisfy with all the above conditions).
    /// If false, it only requests for the first time the conditions are satisfied.
    bool keepRemind = false,

    /// Request with delayed duaration
    Duration? duration,

    /// Print debug log
    bool isDebug = !kReleaseMode,
  }) async {
    _isDebug = isDebug;

    final supportedPlatform = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS);
    if (!supportedPlatform) {
      return _print(ReviewState.unSupportedPlatform)!;
    }

    final isAvailable = _mock != null
        ? _mock?.inAppReviewForceState == true
        : await InAppReview.instance.isAvailable();

    if (!isAvailable) {
      return _print(ReviewState.unavailable)!;
    }

    final condition = ConditionalTrigger(
      'AppReviewHelper',
      minDays: minDays,
      minCalls: minCalls,
      noRequestVersions: noRequestVersions,
      remindedVersions: remindedVersions,
      keepRemind: keepRemind,
      debugLog: isDebug,
    );

    condition.setMockInitialValues(_mock);

    switch (await condition.check()) {
      case ConditionalState.keepRemindDisabled:
        return _print(ReviewState.keepRemindDisabled)!;
      case ConditionalState.noRequestVersion:
        return _print(ReviewState.noRequestVersion)!;
      case ConditionalState.notSatisfiedWithMinCallsAndDays:
        return _print(ReviewState.notSatisfiedWithMinCallsAndDays)!;
      case ConditionalState.notSatisfiedWithMinCalls:
        return _print(ReviewState.notSatisfiedWithMinCalls)!;
      case ConditionalState.notSatisfiedWithMinDays:
        return _print(ReviewState.notSatisfiedWithMinDays)!;
      case ConditionalState.satisfied:
        if (!isDebug) {
          if (duration != null) await Future.delayed(duration);
          if (_mock == null) await _review(reviewDialog);
          return _print(ReviewState.completed)!;
        } else {
          return _print(ReviewState.compeletedInDebugMode)!;
        }
    }
  }

  /// If this [reviewDialog] is set, the pre-dialog will be shown before showing the
  /// request review dialog. Returns `true` if the review dialog is shown, `false`
  /// will be shown otherwise.
  Future<bool> _review(ReviewDialog? reviewDialog) async {
    if (reviewDialog == null) {
      await InAppReview.instance.requestReview();
      return true;
    }

    // Show the how do you feel dialog.
    final satisfactionCompleter = Completer<bool?>();
    satisfactionCompleter.complete(reviewDialog.satisfaction());
    final isSatisfied = await satisfactionCompleter.future;

    if (isSatisfied == true) {
      await InAppReview.instance.requestReview();
      return true;
    } else if (isSatisfied == false) {
      // Show the what can we do dialog.
      final opinionCompleter = Completer<void>();
      opinionCompleter.complete(reviewDialog.opinion());
      await opinionCompleter.future;
    }

    return false;
  }

  ReviewState? _print(Object log) {
    if (log is ReviewState) {
      if (_isDebug) {
        debugPrint('[App Review Helper] ${log.text}');
      }
      return log;
    }
    if (_isDebug) {
      debugPrint('[App Review Helper] $log');
    }
    return null;
  }
}
