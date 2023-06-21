import 'package:app_review_helper/app_review_helper.dart';
import 'package:app_review_helper/src/models/review_mock.dart';
import 'package:app_review_helper/src/models/review_result.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Call initial', () {
    late AppReviewHelper instance;

    setUp(() {
      WidgetsFlutterBinding.ensureInitialized();
      AppReviewHelper.setMockInitialValues();
      SharedPreferences.setMockInitialValues({});
      PackageInfo.setMockInitialValues(
        appName: '',
        packageName: '',
        version: '',
        buildNumber: '',
        buildSignature: '',
      );
      instance = AppReviewHelper.instance;
      debugDefaultTargetPlatformOverride = null;
    });

    test('ReviewResult.notSupportedPlatform', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      final returned = await instance.initial();
      expect(returned, ReviewResult.unSupportedPlatform);
    });

    test('ReviewResult.unavailable', () async {
      AppReviewHelper.setMockInitialValues(
          ReviewMock(inAppReviewForceState: false));
      final returned = await instance.initial();
      expect(returned, ReviewResult.unavailable);
    });

    test('ReviewResult.keepRemindDisabled', () async {
      SharedPreferences.setMockInitialValues(
        {'AppReviewHelper.Requested': true},
      );
      AppReviewHelper.setMockInitialValues(ReviewMock(
        appVersion: '1.0.0',
        inAppReviewForceState: true,
      ));

      final returned1 = await instance.initial();
      expect(returned1, ReviewResult.keepRemindDisabled);
      final returned2 = await instance.initial(keepRemind: true);
      expect(returned2, isNot(ReviewResult.keepRemindDisabled));
      final returned3 = await instance.initial(remindedVersions: ['1.0.0']);
      expect(returned3, isNot(ReviewResult.keepRemindDisabled));
    });

    test('ReviewResult.noRequestVersion', () async {
      AppReviewHelper.setMockInitialValues(ReviewMock(appVersion: '1.0.0'));
      final returned = await instance.initial(noRequestVersions: ['1.0.0']);
      expect(returned, ReviewResult.noRequestVersion);
    });

    test('ReviewResult.dontSatisfyWithMinCallThisFunction', () async {
      AppReviewHelper.setMockInitialValues(
          ReviewMock(callThisFunction: 0, firstDateTime: DateTime(0)));
      final returned = await instance.initial(minCallThisFunction: 2);
      expect(returned, ReviewResult.dontSatisfyWithMinCallThisFunction);
    });

    test('ReviewResult.dontSatisfyWithMinDays', () async {
      AppReviewHelper.setMockInitialValues(
          ReviewMock(callThisFunction: 5, firstDateTime: DateTime.now()));
      final returned =
          await instance.initial(minDays: 2, minCallThisFunction: 3);
      expect(returned, ReviewResult.dontSatisfyWithMinDays);
    });

    test('ReviewResult.completed', () async {
      AppReviewHelper.setMockInitialValues(
        ReviewMock(
          callThisFunction: 5,
          firstDateTime: DateTime.now().subtract(const Duration(days: 5)),
        ),
      );
      final returned = await instance.initial(
        minCallThisFunction: 5,
        minDays: 5,
        isDebug: false,
      );
      expect(returned, ReviewResult.completed);
    });

    test('ReviewResult.compeletedInDebugMode', () async {
      AppReviewHelper.setMockInitialValues(
        ReviewMock(
          callThisFunction: 5,
          firstDateTime: DateTime.now().subtract(const Duration(days: 5)),
        ),
      );
      final returned = await instance.initial(
        minCallThisFunction: 5,
        minDays: 5,
        isDebug: true,
      );
      expect(returned, ReviewResult.compeletedInDebugMode);
    });
  });

  test('Test inDays', () {
    final past = DateTime.now().subtract(const Duration(days: 5));
    final now = DateTime.now();
    final difference = now.difference(past).inDays;

    expect(difference, equals(5));
  });
}
