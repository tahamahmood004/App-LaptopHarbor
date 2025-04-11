import 'package:flutter/material.dart';

class FeedbackDemo extends StatelessWidget {
  void _showFeedbackDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String feedback = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Feedback Form'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Enter your feedback here...',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some feedback';
                }
                return null;
              },
              onSaved: (value) {
                feedback = value ?? '';
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  // Yahan tum feedback ko backend bhej sakte ho
                  print('User Feedback: $feedback');
                  Navigator.pop(context);
                  // Show snackbar or confirmation
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Thank you for your feedback!')),
                  );
                }
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Feedback Dialog Example')),
      body: Center(
        child: ElevatedButton(
          child: Text('Give Feedback'),
          onPressed: () => _showFeedbackDialog(context),
        ),
      ),
    );
  }
}