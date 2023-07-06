import 'package:flutter/material.dart';

class ReviewDialogConfig {
  /// Context for this dialog.
  final BuildContext context;

  /// "Please let us know how you feel about this app?"
  final String isUsefulText;

  /// "Like"
  final String likeText;

  /// "Dislike"
  final String dislikeText;

  /// If this value is set, a second dialog will be shown to ask user's comment
  /// to make this app better. User's comment will be returned to this function.
  final void Function(String whatCanWeDo)? whatCanWeDo;

  /// "What can we do to improve this app?"
  final String whatCanWeDoText;

  /// "Submit"
  final String submitButtonText;

  /// "Cancel"
  final String cancelButtonText;

  /// "Completely anonymous"
  final String anonymousText;

  ReviewDialogConfig({
    required this.context,
    this.isUsefulText = 'How do you feel about this app?',
    this.likeText = 'Like',
    this.dislikeText = 'Dislike',
    this.whatCanWeDo,
    this.whatCanWeDoText =
        'Please let us know what we can do to improve this app:',
    this.submitButtonText = 'Submit',
    this.cancelButtonText = 'Cancel',
    this.anonymousText = 'Completely anonymous',
  });
}
