import 'dart:io';

import 'package:app_review/app_review.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:satisfied_version/satisfied_version.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AppReviewHelper {
  AppReviewHelper._internal();

  /// Debug
  static bool _isDebug = false;

  /// Open the store if available, if not, it'll try opening the `fallbackUrl`.
  static Future<void> openStore({String? fallbackUrl}) async {
    if (kIsWeb) {
      if (fallbackUrl != null && await canLaunchUrlString(fallbackUrl)) {
        _print('Open the fallbackUrl on Web platform: $fallbackUrl');
        await launchUrlString(fallbackUrl);
      } else {
        _print('Web platform and fallbackUrl == null');
      }

      return;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        await AppReview.openGooglePlay(fallbackUrl: fallbackUrl);
        break;
      case TargetPlatform.iOS:
        await AppReview.openAppStore(fallbackUrl: fallbackUrl);
        break;
      default:
        _print('The current platform does not support `openStore`');
        if (fallbackUrl != null && await canLaunchUrlString(fallbackUrl)) {
          _print('Open the fallbackUrl: $fallbackUrl');
          await launchUrlString(fallbackUrl);
        }
    }
  }

  /// This function will request an in-app review every time a new version is published
  /// and it satisfy with the conditions.
  static Future<void> initial({
    /// Min days
    int minDays = 3,

    /// If you add this line in your main(), it's same as app opening count
    int minCallThisFunction = 3,

    /// If the current version is satisfied with this than not showing the request
    /// this value use plugin `satisfied_version` to compare.
    List<String> noRequestVersions = const [],

    /// If true, it'll keep asking for the review on each new version (and satisfy with all the above conditions).
    /// If false, it only requests for the first time the conditions are satisfied.
    bool keepRemind = true,

    /// Request with delayed duaration
    Duration? duration,

    /// Print debug log
    bool isDebug = !kReleaseMode,
  }) async {
    _isDebug = isDebug;

    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      _print('This platform is not supported');
      return;
    }

    if (!await AppReview.isRequestReviewAvailable) {
      _print('Cannot request an in app review at this time');
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    if (!keepRemind && (prefs.getBool('AppReviewHelper.Requested') ?? false)) {
      _print('The review has been requested and the `keepRemind` was disabled');
      return;
    }

    final info = await PackageInfo.fromPlatform();

    // Compare version
    var prefVersion = prefs.getString('AppReviewHelper.Version') ?? '0.0.0';
    if (prefVersion == info.version) {
      if (prefs.getBool('AppReviewHelper.Requested') ?? false) {
        _print('This version has been requested an in app review');
        return;
      }
    }

    // Compare with noRequestVersions
    if (info.version.satisfiedWith(noRequestVersions)) {
      _print(
        'This version is satisfied with `noRequestVersions` => Don\'t request',
      );
      return;
    }

    // Get data from prefs
    var callThisFunction =
        prefs.getInt('AppReviewHelper.CallThisFunction') ?? 0;
    var firstDateTimeString =
        prefs.getString('AppReviewHelper.FirstDateTime') ?? '';

    // Reset variables
    if (prefVersion != info.version) {
      callThisFunction = 0;
      firstDateTimeString = '';
      prefs.setBool('AppReviewHelper.Requested', false);
    }

    // Increase data
    callThisFunction += 1;
    final firstDateTime = DateTime.tryParse(firstDateTimeString);
    final now = DateTime.now();
    final days =
        firstDateTime == null ? 0 : firstDateTime.difference(now).inDays;

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
        final result = await AppReview.requestReview;

        _print('Review result: $result');
      } else {
        _print('AppReview.requestReview is called but in debug mode!');
      }
    } else {
      if (callThisFunction < minCallThisFunction) {
        _print('Don\'t satisfy with minCallThisFunction condition');
      }
      if (days < minDays) {
        _print('Don\'t satisfy with minDays condition');
      }
    }

    // Save data back to prefs
    prefs.setString('AppReviewHelper.Version', info.version);
    prefs.setInt('AppReviewHelper.CallThisFunction', callThisFunction);
    if (firstDateTime == null) {
      prefs.setString(
        'AppReviewHelper.FirstDateTime',
        now.toIso8601String(),
      );
    }
  }

  static void _print(Object? object) =>
      // ignore: avoid_print
      _isDebug ? debugPrint('[ApppReviewHelper] $object') : null;
}
