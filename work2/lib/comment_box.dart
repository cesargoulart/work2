import 'package:flutter/material.dart';

class CommentBox extends StatefulWidget {
  final Function(String) onCommentSubmitted;

  const CommentBox({super.key, required this.onCommentSubmitted});

  @override
  State<CommentBox> createState() => _CommentBoxState();
}

class _CommentBoxState extends State<CommentBox> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _handleSubmitted(String comment) {
    if (comment.isNotEmpty) {
      widget.onCommentSubmitted(comment); // Pass the comment to the parent widget
      _commentController.clear(); // Clear the text field after submission
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 100, // Fixed height for the comment box
        child: TextField(
          controller: _commentController,
          decoration: const InputDecoration(
            labelText: 'Enter your comment',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 16), // Increased padding
          ),
          minLines: 3, // Minimum number of lines (makes the box taller)
          maxLines: 5, // Maximum number of lines (expands further if needed)
          keyboardType: TextInputType.multiline, // Allow multiline input
          onSubmitted: _handleSubmitted, // Handle submission when the user presses "Enter"
        ),
      ),
    );
  }
}