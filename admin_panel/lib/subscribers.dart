import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class Subscribers extends StatefulWidget {
  const Subscribers({super.key});

  @override
  State<Subscribers> createState() => _SubscribersState();
}

class _SubscribersState extends State<Subscribers> {
  List<Map<String, dynamic>> _subscribers = [];
  List<Map<String, dynamic>> _filteredSubscribers = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSubscribers();
  }

  void fetchSubscribers() async {
    final userdata = await FirebaseFirestore.instance.collection('subscribers').get();
    final rawdata = userdata.docs.map((doc) {
      var data = doc.data();
      data['id'] = doc.id;

      if (data['timestamp'] is Timestamp) {
        data['timestamp'] = (data['timestamp'] as Timestamp).toDate();
      }

      return data;
    }).toList();

    setState(() {
      _subscribers = rawdata;
      _filteredSubscribers = rawdata;
      isLoading = false;
    });
  }

  void deleteSubscriber(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('subscribers').doc(docId).delete();
      fetchSubscribers();
    } catch (e) {
      print("Error deleting subscriber: $e");
    }
  }

  void deleteDialog(String docId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Confirmation', style: TextStyle(color: Colors.black)),
          content: Text('Are you sure you want to delete this subscriber?', style: TextStyle(color: Colors.black)),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              onPressed: () {
                deleteSubscriber(docId);
                Navigator.of(context).pop();
              },
              child: Text('Delete', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  void searchSubscribers(String query) {
    final results = _subscribers.where((subscriber) {
      final email = subscriber['email']?.toLowerCase() ?? "";
      return email.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredSubscribers = results;
    });
  }

  void sendEmail(String recipientEmail) async {
    final Uri emailUri = Uri.parse(
        'https://mail.google.com/mail/?view=cm&fs=1&to=$recipientEmail&su=Exclusive%20Offer%20for%20You&body=Hello!%20Check%20out%20our%20new%20collection%20and%20discounts!');

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    } else {
      print("Could not launch Gmail");
    }
  }

  void sendEmailToAllSubscribers() async {
    final allEmails = _subscribers.map((sub) => sub['email']).join(",");
    final Uri emailUri = Uri.parse(
        'https://mail.google.com/mail/?view=cm&fs=1&to=$allEmails&su=Exciting%20News%20for%20Our%20Subscribers!&body=Hello%20Everyone!%20We%20have%20a%20special%20announcement%20for%20you!');

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    } else {
      print("Could not launch Gmail");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subscribers'),
         backgroundColor:Color.fromARGB(255, 24, 16, 133), // Dark blue background
        actions: [
          IconButton(
            icon: Icon(Icons.email),
            onPressed: sendEmailToAllSubscribers,
            tooltip: 'All Subscribers Mail',
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: 'Search Subscribers by Email',
                      labelStyle: TextStyle(color: Colors.black),
                      prefixIcon: Icon(Icons.search, color: Colors.black),
                    ),
                    style: TextStyle(color: Colors.black),
                    onChanged: (value) {
                      setState(() {
                        _filteredSubscribers = value.isEmpty
                            ? _subscribers
                            : _subscribers.where((subscriber) {
                                return subscriber['email']?.toLowerCase().contains(value.toLowerCase()) ?? false;
                              }).toList();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredSubscribers.length,
                    itemBuilder: (context, index) {
                      final subscriber = _filteredSubscribers[index];
                      final email = subscriber["email"] ?? 'No email';

                      return Card(
                        margin: EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Email: $email", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                              Text(
                                "Timestamp: ${subscriber["timestamp"] != null ? DateFormat('yyyy-MM-dd HH:mm').format(subscriber["timestamp"]) : 'No timestamp available'}",
                                style: TextStyle(color: Colors.black),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.email, color: Colors.blue),
                                    onPressed: () => sendEmail(email),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => deleteDialog(subscriber["id"]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
