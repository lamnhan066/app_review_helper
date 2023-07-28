import 'package:conditional_trigger/conditional_trigger.dart';
import 'package:flutter/foundation.dart';

class ReviewMock extends ConditionalMock {
  /// Mock app version
  final String appVersion;

  /// Mock force state
  final bool inAppReviewForceState;

  final int callThisFunction;

  @visibleForTesting
  ReviewMock({
    /// Mock value for the first time the app opened.
    super.firstDateTime,

    /// Mock value for now DateTime.
    super.nowDateTime,

    /// Mock value from preferences.
    this.callThisFunction = 0,

    /// Mock app version
    this.appVersion = '0.0.0',

    /// Force in app review state to available or unavailable
    this.inAppReviewForceState = false,

    /// Force is requested
    super.isRequested,
  }) : super(calls: callThisFunction, version: appVersion);
}
