import 'dart:async';
import 'dart:convert';

import 'package:app_review_helper/src/models/review_dialog.dart';
import 'package:app_review_helper/src/models/review_dialog_config.dart';
import 'package:app_review_helper/src/models/review_state.dart';
import 'package:conditional_trigger/conditional_trigger.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

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

  /// Open the store if available, if not, it'll try opening the `fallbackUrl`.
  Future<void> openStore({String? fallbackUrl}) async {
    if (kIsWeb) {
      if (fallbackUrl != null && await canLaunchUrlString(fallbackUrl)) {
        _print('Open the fallbackUrl on Web platform: $fallbackUrl');
        await launchUrlString(fallbackUrl);
      } else {
        _print('Web platform and fallbackUrl == null');
      }

      return;
    }

    final packageName = (await PackageInfo.fromPlatform()).packageName;

    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        try {
          _print('Android try to launch: market://details?id=$packageName');
          await launchUrlString(
            'market://details?id=$packageName',
            mode: LaunchMode.externalApplication,
          );
        } catch (_) {
          try {
            _print(
                'Android try to launch: https://play.google.com/store/apps/details?id=$packageName');
            await launchUrlString(
              'https://play.google.com/store/apps/details?id=$packageName',
              mode: LaunchMode.externalApplication,
            );
          } catch (e) {
            _print(
                'Cannot get the Store URL on iOS or MacOS, try to launch: $fallbackUrl');
            if (fallbackUrl != null && await canLaunchUrlString(fallbackUrl)) {
              await launchUrlString(
                fallbackUrl,
                mode: LaunchMode.externalApplication,
              );
            } else {
              rethrow;
            }
          }
        }

        return;
      }

      if (defaultTargetPlatform
          case TargetPlatform.iOS || TargetPlatform.macOS) {
        try {
          final response = await http.get((Uri.parse(
              'http://itunes.apple.com/lookup?bundleId=$packageName')));
          final json = jsonDecode(response.body);

          _print('iOS or MacOS get json from bundleId: $json');
          _print('iOS or MacOS get trackId: ${json['results'][0]['trackId']}');

          await launchUrlString(
            'https://apps.apple.com/app/id${json['results'][0]['trackId']}',
            mode: LaunchMode.externalApplication,
          );
        } catch (e) {
          _print(
              'Cannot get the Store URL on iOS or MacOS, try to launch: $fallbackUrl');
          if (fallbackUrl != null && await canLaunchUrlString(fallbackUrl)) {
            await launchUrlString(
              fallbackUrl,
              mode: LaunchMode.externalApplication,
            );
          } else {
            rethrow;
          }
        }

        return;
      }

      if (fallbackUrl != null && await canLaunchUrlString(fallbackUrl)) {
        _print('Other platforms, try to launch: $fallbackUrl');
        await launchUrlString(
          fallbackUrl,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      _print('Cannot open the Store automatically!');

      rethrow;
    }
  }

  /// This function will request an in-app review every time a new version is published
  /// and it's satisfied with the conditions.
  Future<ReviewState> initial({
    /// Show the dialog with thump up - down to let the user to choose before
    /// requesting a review. Only request a review if the thump up is chosen.
    /// If not, the dialog with text field will be shown to get the review
    /// from user.
    @Deprecated('Use `reviewDialog` for more customizable.')
    ReviewDialogConfig? reviewDialogConfig,

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

    final supportedPlatform =
        (defaultTargetPlatform == TargetPlatform.android ||
                defaultTargetPlatform == TargetPlatform.iOS ||
                defaultTargetPlatform == TargetPlatform.macOS) &&
            !kIsWeb;
    if (!supportedPlatform) {
      return _print(ReviewState.unSupportedPlatform)!;
    }

    // TODO(lamnhan066): Avoid breaking change, so we will remove this temporary solution when `reviewDialogConfig` is removed.
    if (reviewDialogConfig != null && reviewDialog == null) {
      reviewDialog = DefaultReviewDialog(
        context: reviewDialogConfig.context,
        satisfactionLikeText: reviewDialogConfig.likeText,
        satisfactionDislikeText: reviewDialogConfig.dislikeText,
        satisfactionText: reviewDialogConfig.isUsefulText,
        opinionText: reviewDialogConfig.whatCanWeDoText,
        opinionSubmitText: reviewDialogConfig.submitButtonText,
        opinionCancelText: reviewDialogConfig.cancelButtonText,
        opinionAnonymousText: reviewDialogConfig.anonymousText,
        opinionFeedback: (opinion) {
          if (reviewDialogConfig.whatCanWeDo != null) {
            reviewDialogConfig.whatCanWeDo!(opinion);
          }
        },
      );
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
