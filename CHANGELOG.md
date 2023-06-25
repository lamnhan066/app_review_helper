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
