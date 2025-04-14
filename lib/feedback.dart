import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackDemo extends StatefulWidget {
  @override
  _FeedbackDemoState createState() => _FeedbackDemoState();
}

class _FeedbackDemoState extends State<FeedbackDemo> {
  final List<Map<String, dynamic>> _feedbackList = [];
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFeedbacks(); // Load feedback from Firebase on startup
  }

  void _loadFeedbacks() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('feedbacks').orderBy('timestamp', descending: true).get();

    final feedbacks = snapshot.docs.map((doc) => {
          'text': doc['text'],
          'email': doc['email'],
        }).toList();

    setState(() {
      _feedbackList.clear();
      _feedbackList.addAll(feedbacks);
    });
  }

  void _showFeedbackDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    _feedbackController.clear();
    _emailController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Feedback Form'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _feedbackController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Enter your feedback here...',
                    labelText: 'Feedback',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some feedback';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  String feedback = _feedbackController.text;
                  String email = _emailController.text;
                  await FirebaseFirestore.instance
                      .collection('feedbacks')
                      .add({
                        'text': feedback,
                        'email': email,
                        'timestamp': Timestamp.now(),
                      });
                  setState(() {
                    _feedbackList.insert(0, {'text': feedback, 'email': email});
                  });
                  Navigator.pop(context);
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
      appBar: AppBar(
        title: Text('Feedback Page', style: TextStyle(color: Colors.white)),
        toolbarHeight: 33.0,
        backgroundColor: Color.fromARGB(255, 24, 16, 133),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.feedback, color: Colors.white),
            onPressed: () => _showFeedbackDialog(context),
            tooltip: 'Give Feedback',
          ),
        ],
      ),
      body: _feedbackList.isEmpty
          ? Center(child: Text('No feedback yet.'))
          : ListView.builder(
              padding: EdgeInsets.all(8.0),
              itemCount: _feedbackList.length,
              itemBuilder: (context, index) {
                final feedback = _feedbackList[index];
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 6),
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feedback['text'],
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'From: ${feedback['email']}',
                          style: TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
