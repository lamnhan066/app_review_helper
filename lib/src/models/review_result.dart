/// Result of the review request.
enum ReviewResult {
  unSupportedPlatform('This platform is not supported'),
  unavailable('Cannot request an in app review at this time'),
  keepRemindDisabled(
      'The review has been requested and the `keepRemind` was disabled'),
  noRequestVersion(
      'This version is satisfied with `noRequestVersions` => Don\'t request'),
  completed('Completed request review'),
  compeletedInDebugMode('AppReview.requestReview is called but in debug mode!'),
  dontSatisfyWithMinCallsAndDays(
      'Don\'t satisfy with minCalls and minDays condition'),
  dontSatisfyWithMinCalls('Don\'t satisfy with minCalls condition'),
  dontSatisfyWithMinDays('Don\'t satisfy with minDays condition');

  final String text;
  const ReviewResult(this.text);
}
