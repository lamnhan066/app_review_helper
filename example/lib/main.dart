import 'package:app_review_helper/app_review_helper.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: const MyApp(),
    theme: ThemeData(useMaterial3: false),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final instance = AppReviewHelper.instance;

  @override
  void initState() {
    init();
    super.initState();
  }

  Future<void> init() async {
    instance.initial(
      reviewDialog: AdaptiveReviewDialog(
        context: context,
        opinionFeedback: (opinion) {
          /// You can save this user's opinion to your database
          debugPrint(opinion);
        },
      ),
      minCalls: 0,
      minDays: 0,
      keepRemind: true,
      isDebug: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review Helper')),
      body: const Center(child: Text('Example')),
    );
  }
}
