/// Result of the review request.
enum ReviewState {
  /// This platform is not supported.
  unSupportedPlatform('This platform is not supported'),

  /// Cannot request an in app review at this time.
  unavailable('Cannot request an in app review at this time'),

  /// The review has been requested and the `keepRemind` was disabled.
  keepRemindDisabled(
      'The review has been requested and the `keepRemind` was disabled'),

  /// This version is satisfied with `noRequestVersions` => Not request.
  noRequestVersion(
      'This version is satisfied with `noRequestVersions` => Don\'t request'),

  /// Completed request review.
  completed('Completed request review'),

  /// AppReview.requestReview is called but in debug mode!.
  compeletedInDebugMode('AppReview.requestReview is called but in debug mode!'),

  /// Not satisfied with minCalls and minDays condition.
  notSatisfiedWithMinCallsAndDays(
      'Don\'t satisfy with minCalls and minDays condition'),

  /// Not satisfied with minCalls condition.
  notSatisfiedWithMinCalls('Don\'t satisfy with minCalls condition'),

  /// Not satisfied with minDays condition.
  notSatisfiedWithMinDays('Don\'t satisfy with minDays condition');

  /// Natural message for this ReviewState.
  final String text;
  const ReviewState(this.text);
}
