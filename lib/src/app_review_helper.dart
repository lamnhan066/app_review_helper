import 'package:app_review_helper/src/models/review_dialog_config.dart';
import 'package:app_review_helper/src/models/review_mock.dart';
import 'package:app_review_helper/src/models/review_result.dart';
import 'package:app_review_helper/src/review.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:satisfied_version/satisfied_version.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:update_helper/update_helper.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AppReviewHelper {
  static AppReviewHelper instance = AppReviewHelper._internal();
  static ReviewMock? _mock;

  /// Set mock values.
  static void setMockInitialValues([ReviewMock? mock]) => _mock = mock;

  AppReviewHelper._internal();

  /// Debug
  bool _isDebug = false;

  /// Open the store if available, if not, it'll try opening the `fallbackUrl`.
  Future<void> openStore({String? fallbackUrl, bool debugLog = false}) async {
    if (kIsWeb) {
      if (fallbackUrl != null && await canLaunchUrlString(fallbackUrl)) {
        _print('Open the fallbackUrl on Web platform: $fallbackUrl');
        await launchUrlString(fallbackUrl);
      } else {
        _print('Web platform and fallbackUrl == null');
      }

      return;
    }

    await UpdateHelper.openStore(fallbackUrl: fallbackUrl, debugLog: debugLog);
  }

  /// This function will request an in-app review every time a new version is published
  /// and it satisfy with the conditions.
  Future<ReviewResult> initial({
    /// Show the dialog with thump up - down to let the user to choose before
    /// requesting a review. Only request a review if the thump up is chosen.
    /// If not, the dialog with text field will be shown to get the review
    /// from user.
    ReviewDialogConfig? reviewDialogConfig,

    /// Min days
    int minDays = 3,

    /// If you add this line in your main(), it's same as app opening count
    int minCallThisFunction = 3,

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
                defaultTargetPlatform == TargetPlatform.iOS) &&
            !kIsWeb;
    if (!supportedPlatform) {
      return _print(ReviewResult.unSupportedPlatform)!;
    }

    final isAvailable = _mock != null
        ? _mock?.inAppReviewForceState == true
        : await InAppReview.instance.isAvailable();

    if (!isAvailable) {
      return _print(ReviewResult.unavailable)!;
    }

    final prefs = await SharedPreferences.getInstance();
    final info = await PackageInfo.fromPlatform();

    // Compare version
    if (prefs.getBool('AppReviewHelper.Requested') ?? false) {
      keepRemind = keepRemind || info.version.satisfiedWith(remindedVersions);
      if (!keepRemind) {
        return _print(ReviewResult.keepRemindDisabled)!;
      }
    }

    // Compare with noRequestVersions
    if (info.version.satisfiedWith(noRequestVersions)) {
      return _print(ReviewResult.noRequestVersion)!;
    }

    // Get data from prefs
    var callThisFunction =
        prefs.getInt('AppReviewHelper.CallThisFunction') ?? 0;
    var firstDateTimeString =
        prefs.getString('AppReviewHelper.FirstDateTime') ?? '';

    // Reset variables
    var prefVersion = prefs.getString('AppReviewHelper.Version') ?? '0.0.0';
    if (prefVersion != info.version) {
      callThisFunction = 0;
      firstDateTimeString = '';
      prefs.setBool('AppReviewHelper.Requested', false);
    }

    // Increase data
    callThisFunction += 1;
    DateTime? firstDateTime = DateTime.tryParse(firstDateTimeString);
    DateTime now = DateTime.now();
    int days = firstDateTime == null ? 0 : now.difference(firstDateTime).inDays;

    // Save data back to prefs
    prefs.setString('AppReviewHelper.Version', info.version);
    prefs.setInt('AppReviewHelper.CallThisFunction', callThisFunction);
    if (firstDateTime == null) {
      prefs.setString(
        'AppReviewHelper.FirstDateTime',
        now.toIso8601String(),
      );
    }

    // Mock values
    if (_mock != null) {
      callThisFunction = _mock!.callThisFunction;
      firstDateTime = _mock!.firstDateTime;
      now = _mock!.nowDateTime;
      days = now.difference(firstDateTime).inDays;
    }

    // Print debug
    _print('prefs version: $prefVersion, currentVersion: ${info.version}');
    _print('Call this function $callThisFunction times');
    _print('First time open this app was $days days before');

    // Compare
    if (callThisFunction >= minCallThisFunction && days >= minDays) {
      prefs.setBool('AppReviewHelper.Requested', true);
      _print('Satisfy with all conditions');

      if (!isDebug) {
        if (duration != null) await Future.delayed(duration);

        // Only call review when not mocking.
        if (_mock == null) await review(reviewDialogConfig);

        return _print(ReviewResult.completed)!;
      } else {
        return _print(ReviewResult.compeletedInDebugMode)!;
      }
    } else {
      if (callThisFunction < minCallThisFunction) {
        return _print(ReviewResult.dontSatisfyWithMinCallThisFunction)!;
      }

      return _print(ReviewResult.dontSatisfyWithMinDays)!;
    }
  }

  ReviewResult? _print(Object log) {
    if (log is ReviewResult) {
      if (_isDebug) {
        debugPrint('[ApppReviewHelper] ${log.text}');
      }
      return log;
    }
    if (_isDebug) {
      debugPrint('[ApppReviewHelper] $log');
    }
    return null;
  }
}
