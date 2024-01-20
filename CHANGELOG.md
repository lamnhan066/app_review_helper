## 0.9.5

* Add `satisfactionBarrierDismissible` and `barrierColor` to the `ReviewDialog`.
* The opinion dialog won't be shown if the satisfaction dialog is closed by tapping on the barrier.
* Fix issue that the `AdaptiveReviewDialog` shows the `satisfactionLikeIcon` incorrectly.
* Use `Good` and `Improve` for the satisfaction dialog of the `FriendlyReviewDialog` and `FriendlyAdaptiveReviewDialog`.

## 0.9.4

* Add `FriendlyReviewDialog` and `FriendlyAdaptiveReviewDialog` that use `FontAwesomeIcons.faceSmile` and `FontAwesomeIcons.faceFrownOpen` for the satisfaction dialog button icon.
* Update README.

## 0.9.3

* Fixed: shows the `satisfactionLikeIcon` incorrectly.

## 0.9.2

* Add `macos` to the supported platform list.
* Add `ReviewDialog` abstract so we can easily implement custom dialogs.
* Add `DefaultReviewDialog` which implements `ReviewDialog` to show the default dialog.
* Add `AdaptiveReviewDialog` which is the same as `DefaultReviewDialog` but can adapt with the specific platform UI design using `AlertDialog.adaptive`.
* Mark `ReviewDialogConfig` as deprecated (but not a Breaking Change). Migration guide:

  * Old:

  ```dart
  instance.initial(
    reviewDialogConfig: ReviewDialogConfig(
      context: context,
      isUsefulText: 'How do you feel about this app?',
      likeText: 'Like',
      dislikeText: 'Dislike',
      whatCanWeDoText: 'Please let us know what we can do to improve this app',
      submitButtonText: 'Submit',
      cancelButtonText: 'Cancel',
      anonymousText: 'Completely anonymous',
      whatCanWeDo: (opinion) {
        /// You can save this user's opinion to your database
        debugPrint(opinion);
      },
    ),
  );
  ```

  * Now:

  ```dart
  instance.initial(
    reviewDialog: DefaultReviewDialog(
      context: context,
      satisfactionText: 'How do you feel about this app?',
      satisfactionLikeText: 'Like',
      satisfactionLikeIcon: const Icon(Icons.thumb_up),
      satisfactionDislikeText: 'Dislike',
      satisfactionDislikeIcon: const Icon(Icons.thumb_down, color: Colors.grey),
      opinionText: 'Please let us know what we can do to improve this app',
      opinionSubmitButtonText: 'Submit',
      opinionCancelButtonText: 'Cancel',
      opinionAnonymousText: 'Completely anonymous',
      opinionFeedback: (opinion) {
        /// You can save this user's opinion to your database
        debugPrint(opinion);
      },
    ),
  );
  ```

## 0.9.1

* Correctly show the review.
* Reduced the package size.

## 0.9.0

* Bump `conditional_trigger` to `v0.4.0` (With BREAKCHANGE).
* Change from `ReviewState.dontSatisfyWithMinCalls`, `ReviewState.dontSatisfyWithMinDays` and `ReviewState.dontSatisfyWithMinCallsAndDays` to `ReviewState.notSatisfiedWithMinCalls`, `ReviewState.notSatisfiedWithMinDays` and `ReviewState.notSatisfiedWithMinCallsAndDays`.

## 0.8.0

* Bump dependencies.

## 0.7.1

* Change `package_info_plus version` to `^4.2.0`.

## 0.7.0

* Upgrade dependencies.

## 0.6.1

* Update comments.
* Update homepage URL.

## 0.6.0

* Bump dependencies.

## 0.5.0

* Rename from `ReviewResult` to `ReviewState` and:
  * Rename from `minCallThisFunction` to `minCalls`.
  * Rename `dontSatisfyWithMinCallThisFunction` to `dontSatisfyWithMinCalls`.
  * Add `dontSatisfyWithMinCallsAndDays`.
* Bump dependencies.

## 0.4.3

* Add anonymous text under text field of the opinion dialog.

## 0.4.2

* Improves pub scores.

## 0.4.1

* Update dependencies.
* Update screenshots.

## 0.4.0-rc.2

* Update dependencies.

## 0.4.0-rc.1

* Add dialogs to ask users about their opinions before requesting the review.
* Improve code logic.
* Add tests.
* Add example.

## 0.3.0

* Update dependencies.
* Update dart sdk to ">=2.18.0 <4.0.0`, flutter min sdk to "3.3.0".

## 0.2.1

* [BUG] Fixed the way calculating `minDays`.

## 0.2.0

* **[BREAKING CHANGE]** Change `keepRemind` default value to `false`.
* Add `remindedVersions` parameter to control the version to allow reminding.

## 0.1.1

* Use `in_app_review` instead of `app_review` package.

## 0.1.0

* **[BREAKING CHANGE]** Move from static method to instance:
  * Before: `AppReviewHelper.initial()`
  * Now: `AppReviewHelper.instance.initial()`

## 0.0.3+1

* Do nothing for the platforms that are not Android and iOS, only `openStore` will launch if the `fallbackUrl` is available.

## 0.0.3

* Added `keepRemind` parameter to disable the default behavior (default behavior is auto requests for the review on each new version), and it's `true` by default.
* `openStore` method will open the `fallbackUrl` if available on not supported platforms.

## 0.0.2

* Add `openStore` to open the current app on the store.

## 0.0.1

* Initial release.
