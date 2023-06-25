# App Review Helper

This plugin will make it easier for you to use in-app review with minimal conditions.

## Introduction

The dialogs is shown before requesting a review
![Alt Text](https://raw.githubusercontent.com/vnniz/app_review_helper/main/assets/intro/ReviewHelperComment.webm)

## Usage

This method will do nothing if the current platform is other than Android and iOS.

``` dart
final appReviewHelper = AppReviewHelper.instance;
appReviewHelper.initial(
    /// Show a dialog to ask the user about their feeling before the review.
    /// If the user does not satisfy with the first dialog, the second dialog
    /// will be shown (if `whatCanWeDo` is set) to ask user's opinion to make
    /// the app better. 
    reviewDialogConfig: ReviewDialogConfig(
        context: context,
        whatCanWeDo: (opinion) {
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

Use this function if you want to open the store. This function will try to open the `fallbackUrl` if the current platform is not Android or iOS.

``` dart
appReviewHelper.openStore();
```
