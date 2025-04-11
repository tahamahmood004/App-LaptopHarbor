import 'package:flutter/material.dart';

class FeedbackStorage {
  static final List<String> feedbackList = [];
}

class HomePage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  String _feedback = '';

  void Feedback(BuildContext context) {
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
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter some feedback';
                }
                return null;
              },
              onSaved: (value) {
                _feedback = value ?? '';
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text('Submit'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  FeedbackStorage.feedbackList.add(_feedback);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Thanks for your feedback!')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _goToAdminDashboard(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FeedbackDashboardPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.admin_panel_settings),
            onPressed: () => _goToAdminDashboard(context),
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('Give Feedback'),
          onPressed: () => Feedback(context),
        ),
      ),
    );
  }
}

class FeedbackDashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final feedbacks = FeedbackStorage.feedbackList;

    return Scaffold(
      appBar: AppBar(title: Text('Admin Dashboard')),
      body: feedbacks.isEmpty
          ? Center(child: Text('No feedback yet!'))
          : ListView.builder(
              itemCount: feedbacks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.feedback),
                  title: Text('Feedback #${index + 1}'),
                  subtitle: Text(feedbacks[index]),
                );
              },
            ),
    );
  }
}