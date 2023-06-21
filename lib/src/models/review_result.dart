/// Result of the review request.
enum ReviewResult {
  unSupportedPlatform('This platform is not supported'),
  unavailable('Cannot request an in app review at this time'),
  keepRemindDisabled(
      'The review has been requested and the `keepRemind` was disabled'),
  // alreadyRequested('This version has been requested an in app review'),
  noRequestVersion(
      'This version is satisfied with `noRequestVersions` => Don\'t request'),
  completed('Completed request review'),
  compeletedInDebugMode('AppReview.requestReview is called but in debug mode!'),
  dontSatisfyWithMinCallThisFunction(
      'Don\'t satisfy with minCallThisFunction condition'),
  dontSatisfyWithMinDays('Don\'t satisfy with minDays condition');

  final String text;
  const ReviewResult(this.text);
}
