# App Review Helper

This plugin will make it easier for you to use in-app review with minimal conditions.

## Introduction

<p>
    <img src="https://raw.githubusercontent.com/lamnhan066/app_review_helper/main/assets/intro/AppReviewHelperANDROID.webp" alt="Android" width="300"/>
    <img src="https://raw.githubusercontent.com/lamnhan066/app_review_helper/main/assets/intro/AppReviewHelperIOS.webp" alt="iOS" width="300"/>
</p>

## Usage

This method will do nothing if the current platform is other than Android and iOS.

``` dart
final appReviewHelper = AppReviewHelper.instance;
appReviewHelper.initial(
    /// [Optional] Show a dialog to ask the user about their feeling before the review. 
    /// If the user is not satisfied with the first dialog, the second dialog will be 
    /// shown (if `opinionFeedback` is set) to ask the user's opinion to make the app better. 
    ///
    /// Use `AdaptiveReviewDialog` to adapt with `ios` and `macos` specific UI.
    reviewDialog: DefaultReviewDialog(
        context: context,
        satisfactionText: 'How do you feel about this app?',
        satisfactionLikeText: 'Like',
        satisfactionLikeIcon: const Icon(Icons.thumb_up),
        satisfactionDislikeText: 'Dislike',
        satisfactionDislikeTextColor: Colors.grey,
        // Should be the same color with `satisfactionDislikeText`.
        satisfactionDislikeIcon: const Icon(Icons.thumb_down, color: Colors.grey),
        opinionText: 'Please let us know what we can do to improve this app',
        opinionSubmitButtonText: 'Submit',
        opinionCancelButtonText: 'Cancel',
        opinionAnonymousText: 'Completely anonymous',
        opinionFeedback: (opinion) {
          print(opinion);
      },
    ),

    /// Min days
    minDays: 3,

    /// If you add this line in your main(), it's same as app opening count
    minCallThisFunction: 3,

    /// If the current version is satisfied with this than not showing the request
    /// this value use plugin `satisfied_version` to compare.
    noRequestVersions: ['<=1.0.0', '3.0.0', '>4.0.0'],

    /// Control which versions allow reminding if `keepRemind` is false
    remindedVersions: ['2.0.0', '3.0.0'],

    /// If true, it'll keep asking for the review on each new version (and satisfy with all the above conditions).
    /// If false, it only requests for the first time the conditions are satisfied.
    keepRemind: true,

    /// Request with delayed duaration
    duration: const Duration(seconds: 1),
    
    /// Print debug log
    isDebug: false,
);
```

There are a few built-in dialogs:

- [DefaultReviewDialog] is a default one with `thumbUp` and `thumbDown` icon.
- [AdaptiveReviewDialog] use the adaptive dialog (show the dialog based on whether the target platform) with `thumbUp` and `thumbDown` icon.
- [FriendlyReviewDialog] is based on the `DefaultReviewDialog` with  `Good` and `Improve` text; `smile` and `frown` face icon.
- [FriendlyAdaptiveReviewDialog] is based on the `AdaptiveReviewDialog` with  `Good` and `Improve` text; `smile` and `frown` face icon.

You can create your own dialog by implementing `ReviewDialog`:

```dart
class CustomReviewDialog implements ReviewDialog {
  CustomReviewDialog();
  /// This dialog will be shown to ask for users' satisfaction with the app,
  /// when `true` is returned, the in-app request will be shown. When `false`
  /// is returned, the [opinion] dialog will be shown. The opinion dialog won't
  /// be shown when returning `null`.
  @override
  FutureOr<bool?> satisfaction() => throw UnimplementedError();

  /// This dialog will be shown when the user isn't satisfied with the app
  /// (which means the [satisfaction] dialog returns `false`). You can write
  /// your logic to send user's feedback to your server.
  @override
  FutureOr<void> opinion() => throw UnimplementedError();
}

```

Return values:

``` dart
/// This platform is not supported
ReviewState.unSupportedPlatform

/// Cannot request an in app review at this time
ReviewState.unavailable

///The review has been requested and the `keepRemind` was disabled
ReviewState.keepRemindDisabled

/// This version is satisfied with `noRequestVersions` => Don't request
ReviewState.noRequestVersion

/// Completed request review
ReviewState.completed

/// AppReview.requestReview is called but in debug mode!
ReviewState.compeletedInDebugMode

/// Don\'t satisfy with minCalls and minDays condition
ReviewState.dontSatisfyWithMinCallsAndDays

/// Don't satisfy with minCalls condition
ReviewState.dontSatisfyWithMinCalls

/// Don't satisfy with minDays condition
ReviewState.dontSatisfyWithMinDays
```

Use this function if you want to open the store. This function will try to open the `fallbackUrl` if the current platform is not Android or iOS.

``` dart
appReviewHelper.openStore();
```
