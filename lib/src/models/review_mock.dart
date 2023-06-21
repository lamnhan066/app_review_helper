import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ReviewMock {
  /// Mock value for the first time the app opened.
  DateTime firstDateTime = DateTime.now();

  /// Mock value for now DateTime.
  DateTime nowDateTime = DateTime.now();

  /// Mock value from preferences.
  int callThisFunction = 0;

  /// Mock app version
  String appVersion = '1.0.0';

  /// Force in app review state to available or unavailable
  bool inAppReviewForceState = true;

  @visibleForTesting
  ReviewMock({
    /// Mock value for the first time the app opened.
    DateTime? firstDateTime,

    /// Mock value for now DateTime.
    DateTime? nowDateTime,

    /// Mock value from preferences.
    int? callThisFunction,

    /// Mock app version
    String? appVersion,

    /// Force in app review state to available or unavailable
    bool? inAppReviewForceState,
  }) {
    this.firstDateTime = firstDateTime ?? this.firstDateTime;
    this.nowDateTime = nowDateTime ?? this.nowDateTime;
    this.callThisFunction = callThisFunction ?? this.callThisFunction;
    this.inAppReviewForceState =
        inAppReviewForceState ?? this.inAppReviewForceState;
    if (appVersion != null) {
      this.appVersion = appVersion;
      // ignore: invalid_use_of_visible_for_testing_member
      PackageInfo.setMockInitialValues(
        appName: '',
        packageName: '',
        version: appVersion,
        buildNumber: '',
        buildSignature: '',
      );
    }
  }
}
