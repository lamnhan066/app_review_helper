import 'package:app_review_helper/app_review_helper.dart';
import 'package:app_review_helper/src/models/review_mock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Call initial', () {
    late AppReviewHelper instance;

    setUp(() {
      WidgetsFlutterBinding.ensureInitialized();
      AppReviewHelper.setMockInitialValues();
      SharedPreferences.setMockInitialValues({});
      instance = AppReviewHelper.instance;
      debugDefaultTargetPlatformOverride = null;
    });

    test('ReviewState.notSupportedPlatform', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      final returned = await instance.initial();
      expect(returned, ReviewState.unSupportedPlatform);
    });

    test('ReviewState.unavailable', () async {
      AppReviewHelper.setMockInitialValues(
          ReviewMock(inAppReviewForceState: false));
      final returned = await instance.initial();
      expect(returned, ReviewState.unavailable);
    });

    test('ReviewState.keepRemindDisabled', () async {
      AppReviewHelper.setMockInitialValues(ReviewMock(
        appVersion: '1.0.0',
        inAppReviewForceState: true,
        isRequested: true,
      ));

      final returned1 = await instance.initial();
      expect(returned1, ReviewState.keepRemindDisabled);
      final returned2 = await instance.initial(keepRemind: true);
      expect(returned2, isNot(ReviewState.keepRemindDisabled));
      final returned3 = await instance.initial(remindedVersions: ['1.0.0']);
      expect(returned3, isNot(ReviewState.keepRemindDisabled));
    });

    test('ReviewState.noRequestVersion', () async {
      AppReviewHelper.setMockInitialValues(ReviewMock(
        appVersion: '1.0.0',
        inAppReviewForceState: true,
      ));
      final returned = await instance.initial(noRequestVersions: ['1.0.0']);
      expect(returned, ReviewState.noRequestVersion);
    });

    test('ReviewState.notSatisfiedWithMinCallThisFunctionAndDays', () async {
      AppReviewHelper.setMockInitialValues(ReviewMock(
        callThisFunction: 0,
        firstDateTime: DateTime.now(),
        inAppReviewForceState: true,
      ));
      final returned = await instance.initial(minCalls: 2, minDays: 2);
      expect(returned, ReviewState.notSatisfiedWithMinCallsAndDays);
    });

    test('ReviewState.notSatisfiedWithMinCallThisFunction', () async {
      AppReviewHelper.setMockInitialValues(ReviewMock(
        callThisFunction: 0,
        firstDateTime: DateTime(0),
        inAppReviewForceState: true,
      ));
      final returned = await instance.initial(minCalls: 2);
      expect(returned, ReviewState.notSatisfiedWithMinCalls);
    });

    test('ReviewState.notSatisfiedWithMinDays', () async {
      AppReviewHelper.setMockInitialValues(ReviewMock(
        callThisFunction: 5,
        firstDateTime: DateTime.now(),
        nowDateTime: DateTime.now(),
        inAppReviewForceState: true,
      ));
      final returned = await instance.initial(minDays: 2, minCalls: 3);
      expect(returned, ReviewState.notSatisfiedWithMinDays);
    });

    test('ReviewState.completed', () async {
      AppReviewHelper.setMockInitialValues(
        ReviewMock(
          callThisFunction: 5,
          firstDateTime: DateTime.now().subtract(const Duration(days: 5)),
          inAppReviewForceState: true,
        ),
      );
      final returned = await instance.initial(
        minCalls: 5,
        minDays: 5,
        isDebug: false,
      );
      expect(returned, ReviewState.completed);
    });

    test('ReviewState.compeletedInDebugMode', () async {
      AppReviewHelper.setMockInitialValues(
        ReviewMock(
          callThisFunction: 5,
          firstDateTime: DateTime.now().subtract(const Duration(days: 5)),
          inAppReviewForceState: true,
        ),
      );
      final returned = await instance.initial(
        minCalls: 5,
        minDays: 5,
        isDebug: true,
      );
      expect(returned, ReviewState.compeletedInDebugMode);
    });
  });

  test('Test inDays', () {
    final past = DateTime.now().subtract(const Duration(days: 5));
    final now = DateTime.now();
    final difference = now.difference(past).inDays;

    expect(difference, equals(5));
  });
}
