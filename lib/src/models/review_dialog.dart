import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// The dialogs will be shown before showing the in-app request.
///
/// There are a few built-in dialogs:
/// - [DefaultReviewDialog] is a default one with `thumbUp` and `thumbDown` icon.
/// - [AdaptiveReviewDialog] use the adaptive dialog (show the dialog based on whether the target platform)
///   with `thumbUp` and `thumbDown` icon.
/// - [FriendlyReviewDialog] is based on the `DefaultReviewDialog` with `smile` and `frown` face icon.
/// - [FriendlyAdaptiveReviewDialog] is based on the `AdaptiveReviewDialog` with `smile` and `frown` face icon.
abstract class ReviewDialog {
  /// This dialog will be shown to ask for users' satisfaction with the app,
  /// when `true` is returned, the in-app request will be shown, otherwise
  /// the [opinion] dialog will be shown.
  FutureOr<bool> satisfaction() => throw UnimplementedError();

  /// This dialog will be shown when the user isn't satisfied with the app
  /// (which means the [satisfaction] dialog returns `false`). You can write
  /// your logic to send user's feedback to your server.
  FutureOr<void> opinion() => throw UnimplementedError();
}

class DefaultReviewDialog implements ReviewDialog {
  /// Current Buildcontext.
  final BuildContext context;

  /// Shows text to ask for user satisfaction.
  ///
  /// Default is `How do you feel about this app?`.
  final String satisfactionText;

  /// Icon for the like button.
  ///
  /// Default is [Icons.thumb_up].
  final Widget satisfactionLikeIcon;

  /// Text for the like button.
  ///
  /// Default is `Like`.
  final String satisfactionLikeText;

  /// Icon for the dislike button. This icon should have the same color with
  /// [satisfactionDislikeTextColor].
  ///
  /// Default is [Icons.thumb_down].
  final Widget satisfactionDislikeIcon;

  /// Text for the dislike button.
  ///
  /// Default is `Dislike`.
  final String satisfactionDislikeText;

  /// Color of the `satisfactionDislikeText` text.
  ///
  /// Default is `Colors.grey`.
  final Color? satisfactionDislikeTextColor;

  /// Text for the opinion dialog.
  ///
  /// Default is `Please let us know what we can do to improve this app`.
  final String opinionText;

  /// Text for the submit button.
  ///
  /// Default is `Submit`.
  final String opinionSubmitText;

  /// Text for the cancel button.
  ///
  /// Default is `Cancel`.
  final String opinionCancelText;

  /// Color of the `opinionCancelButtonText` text.
  ///
  /// Default is `Colors.grey`.
  final Color? opinionCancelTextColor;

  /// This is a small text that shows under the [TextField] on the left side
  /// to tell the user that the opinion dialog does not collect any data that
  /// is linked to them.
  ///
  /// Default is `Completely anonymous`.
  final String opinionAnonymousText;

  /// The user's opinion feedback that returning when the user presses `submit`.
  ///
  /// The `opinion` dialog won't be shown when this value is not set.
  final void Function(String opinion)? opinionFeedback;

  /// Default review dialog.
  ///
  /// Note that the `opinion` dialog won't be shown when `opinionFeedback` value is not set.
  const DefaultReviewDialog({
    required this.context,
    this.satisfactionText = 'How do you feel about this app?',
    this.satisfactionLikeIcon = const Icon(Icons.thumb_up),
    this.satisfactionLikeText = 'Like',
    this.satisfactionDislikeIcon =
        const Icon(Icons.thumb_down, color: Colors.grey),
    this.satisfactionDislikeText = 'Dislike',
    this.satisfactionDislikeTextColor = Colors.grey,
    this.opinionText = 'Please let us know what we can do to improve this app',
    this.opinionSubmitText = 'Submit',
    this.opinionCancelText = 'Cancel',
    this.opinionCancelTextColor = Colors.grey,
    this.opinionAnonymousText = 'Completely anonymous',
    this.opinionFeedback,
  });

  @override
  Future<bool> satisfaction() async {
    final isSatisfied = await showDialog<bool>(
      context: context,
      builder: (ctx) => Material(
        color: Colors.transparent,
        child: AlertDialog(
          content: Text(
            satisfactionText,
            style: const TextStyle(fontSize: 13),
            textAlign: TextAlign.center,
          ),
          alignment: Alignment.center,
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actionsPadding: const EdgeInsets.all(8),
          actions: [
            TextButton.icon(
              onPressed: () {
                Navigator.pop(ctx, true);
              },
              icon: satisfactionLikeIcon,
              label: Text(
                satisfactionLikeText,
                style: const TextStyle(fontSize: 12),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.pop(ctx, false);
              },
              icon: satisfactionDislikeIcon,
              label: Text(
                satisfactionDislikeText,
                style: TextStyle(
                  fontSize: 12,
                  color: satisfactionDislikeTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return isSatisfied == true;
  }

  @override
  Future<void> opinion() async {
    // We don't need to show this dialog if `opinionFeedback` is null.
    if (opinionFeedback == null) return;

    String text = '';
    final isSubmit = await showDialog<bool>(
      context: context,
      builder: (ctx) => Material(
        color: Colors.transparent,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                opinionText,
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 8),
              TextField(
                onChanged: (newText) => text = newText,
                minLines: 3,
                maxLines: 6,
                autocorrect: false,
                style: const TextStyle(fontSize: 12),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(8.0),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 2),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  opinionAnonymousText,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.all(12),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx, false);
              },
              child: Text(
                opinionCancelText,
                style: TextStyle(
                  fontSize: 12,
                  color: opinionCancelTextColor,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx, true);
              },
              child: Text(
                opinionSubmitText,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );

    if (isSubmit == true) opinionFeedback!(text);
  }
}

class AdaptiveReviewDialog extends DefaultReviewDialog {
  /// This dialog is based on `DefaultReviewDialog` but uses `AlertDialog.adaptive` to show.
  ///
  /// Note that the `opinion` dialog won't be shown when `opinionFeedback` value is not set.
  const AdaptiveReviewDialog({
    required super.context,
    super.satisfactionText,
    super.satisfactionLikeIcon,
    super.satisfactionLikeText,
    super.satisfactionDislikeIcon,
    super.satisfactionDislikeText,
    super.satisfactionDislikeTextColor,
    super.opinionText,
    super.opinionSubmitText,
    super.opinionCancelText,
    super.opinionCancelTextColor,
    super.opinionAnonymousText,
    super.opinionFeedback,
  });

  @override
  Future<bool> satisfaction() async {
    final isSatisfied = await showDialog<bool>(
      context: context,
      builder: (ctx) => Material(
        color: Colors.transparent,
        child: AlertDialog.adaptive(
          content: Text(
            satisfactionText,
            style: const TextStyle(fontSize: 13),
            textAlign: TextAlign.center,
          ),
          alignment: Alignment.center,
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actionsPadding: const EdgeInsets.all(8),
          actions: [
            TextButton.icon(
              onPressed: () {
                Navigator.pop(ctx, true);
              },
              icon: const Icon(Icons.thumb_up),
              label: Text(
                satisfactionLikeText,
                style: const TextStyle(fontSize: 12),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.pop(ctx, false);
              },
              icon: satisfactionDislikeIcon,
              label: Text(
                satisfactionDislikeText,
                style: TextStyle(
                  fontSize: 12,
                  color: satisfactionDislikeTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return isSatisfied == true;
  }

  @override
  Future<void> opinion() async {
    // We don't need to show this dialog if `opinionFeedback` is null.
    if (opinionFeedback == null) return;

    String text = '';
    final isSubmit = await showDialog<bool>(
      context: context,
      builder: (ctx) => Material(
        color: Colors.transparent,
        child: AlertDialog.adaptive(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                opinionText,
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 8),
              TextField(
                onChanged: (newText) => text = newText,
                minLines: 3,
                maxLines: 6,
                autocorrect: false,
                style: const TextStyle(fontSize: 12),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(8.0),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 2),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  opinionAnonymousText,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.all(12),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx, false);
              },
              child: Text(
                opinionCancelText,
                style: TextStyle(
                  fontSize: 12,
                  color: opinionCancelTextColor,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx, true);
              },
              child: Text(
                opinionSubmitText,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );

    if (isSubmit == true) opinionFeedback!(text);
  }
}

class FriendlyReviewDialog extends DefaultReviewDialog {
  /// The same as the [DefaultReviewDialog] but with friendly Icons.
  ///
  ///   `satisfactionLikeIcon` = const Icon(FontAwesomeIcons.faceSmile)
  ///   `satisfactionDislikeIcon` = const Icon(FontAwesomeIcons.faceFrownOpen, color: Colors.grey)
  FriendlyReviewDialog({
    required super.context,
    super.satisfactionText,
    super.satisfactionLikeText,
    super.satisfactionLikeIcon = const Icon(FontAwesomeIcons.faceSmile),
    super.satisfactionDislikeIcon = const Icon(
      FontAwesomeIcons.faceFrownOpen,
      color: Colors.grey,
    ),
    super.satisfactionDislikeText,
    super.satisfactionDislikeTextColor,
    super.opinionText,
    super.opinionSubmitText,
    super.opinionCancelText,
    super.opinionCancelTextColor,
    super.opinionAnonymousText,
    super.opinionFeedback,
  });
}

class FriendlyAdaptiveReviewDialog extends AdaptiveReviewDialog {
  /// The same as the [AdaptiveReviewDialog] but with friendly Icons.
  ///
  ///   `satisfactionLikeIcon` = const Icon(FontAwesomeIcons.faceSmile)
  ///   `satisfactionDislikeIcon` = const Icon(FontAwesomeIcons.faceFrownOpen, color: Colors.grey)
  FriendlyAdaptiveReviewDialog({
    required super.context,
    super.satisfactionText,
    super.satisfactionLikeText,
    super.satisfactionLikeIcon = const Icon(FontAwesomeIcons.faceSmile),
    super.satisfactionDislikeIcon = const Icon(
      FontAwesomeIcons.faceFrownOpen,
      color: Colors.grey,
    ),
    super.satisfactionDislikeText,
    super.satisfactionDislikeTextColor,
    super.opinionText,
    super.opinionSubmitText,
    super.opinionCancelText,
    super.opinionCancelTextColor,
    super.opinionAnonymousText,
    super.opinionFeedback,
  });
}
