# App Review Helper

This plugin will make it easier for you to use in-app review with minimal conditions. It will also try requesting an in-app review every time a new version is published and it satisfy with the conditions.

## Usage

``` dart
AppReviewHelper.initial(
    /// Min days
    minDays: 3,

    /// If you add this line in your main(), it's same as app opening count
    minCallThisFunction: 3,

    /// If the current version is satisfied with this than not showing the request
    /// this value use plugin `satisfied_version` to compare.
    noRequestVersions: ['<=1.0.0', '3.0.0', '>4.0.0'],

    /// Request with delayed duaration
    duration: const Duration(seconds: 1),
    
    /// Print debug log
    isDebug: false,
);
```
