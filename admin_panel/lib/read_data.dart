import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FetchData extends StatefulWidget {
  const FetchData({super.key});

  @override
  State<FetchData> createState() => _FetchDataState();
}

class _FetchDataState extends State<FetchData> {
  List<Map<String, dynamic>> _users = [];
  TextEditingController searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // Fetching data from Firestore
  void fetchData() async {
    setState(() {
      _isLoading = true;
    });

    final userdata = await FirebaseFirestore.instance.collection('users').get();
    final rawdata = userdata.docs.map((doc) {
      var data = doc.data();
      data['id'] = doc.id;  // Save the Firestore document ID as 'id'
      return data;
    }).toList();

    setState(() {
      _users = rawdata;
      _isLoading = false;
    });
  }

  // Update data in Firestore
  void updateData(String docId, Map<String, dynamic> newData) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(docId)  // Use the document ID to get the correct document
          .update(newData);  // Update specific fields
      print("Data updated successfully!");
    } catch (e) {
      print("Error updating data: $e");
    }
  }

  // Delete data from Firestore
  void deleteData(String docId) async {
    await FirebaseFirestore.instance.collection('users').doc(docId).delete();
  }

  // Show confirmation dialog for deleting data
  void deleteDialog(String docId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Confirmation', style: TextStyle(color: Colors.black)),
          content: Text('Are you sure you want to delete this user?', style: TextStyle(color: Colors.black)),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              onPressed: () {
                deleteData(docId);
                Navigator.of(context).pop();
              },
              child: Text('Delete', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  // Email validation function
  bool isValidEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
    return regex.hasMatch(email);
  }

  // Show dialog for editing user details with Gmail validation
  void showEditDialog(Map<String, dynamic> user) {
    final TextEditingController nameController = TextEditingController(text: user["name"]);
    final TextEditingController emailController = TextEditingController(text: user["email"]);
    final TextEditingController passwordController = TextEditingController(text: user["password"]);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit User', style: TextStyle(color: Colors.black)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Colors.black),
                ),
                style: TextStyle(color: Colors.black),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.black),
                ),
                style: TextStyle(color: Colors.black),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.black),
                ),
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = nameController.text;
                final newEmail = emailController.text;
                final newPassword = passwordController.text;

                // Name validation - check if the name contains numbers
                if (RegExp(r'\d').hasMatch(newName)) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('Name should not contain numbers.', style: TextStyle(color: Colors.red)),
                        actions: [
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('OK', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }

                // Password validation - check if the password has at least 7 characters
                if (newPassword.length < 7) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('Password should be at least 7 characters long.', style: TextStyle(color: Colors.red)),
                        actions: [
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('OK', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }

                // Email validation - check if the email is valid
                if (!isValidEmail(newEmail)) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('Please enter a valid email address.', style: TextStyle(color: Colors.red)),
                        actions: [
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('OK', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }

                // Check if the email already exists in Firestore (excluding the current user's email)
                final querySnapshot = await FirebaseFirestore.instance
                    .collection('users')
                    .where('email', isEqualTo: newEmail)
                    .get();

                if (querySnapshot.docs.isNotEmpty && querySnapshot.docs[0].id != user["id"]) {
                  // If email exists and it's not the same as the current user's email, show error
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('This email is already registered. Please use a different email.',
                            style: TextStyle(color: Colors.red)),
                        actions: [
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('OK', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }

                // If validations pass, proceed with the update
                final updatedData = {
                  "name": newName,
                  "email": newEmail,
                  "password": newPassword,
                };

                updateData(user["id"], updatedData);  // Use Firestore document ID to update
                Navigator.of(context).pop();
              },
              child: Text('Update', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  // Add user dialog implementation with Gmail validation
  void showAddUserDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New User', style: TextStyle(color: Colors.black)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Colors.black),
                ),
                style: TextStyle(color: Colors.black),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.black),
                ),
                style: TextStyle(color: Colors.black),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.black),
                ),
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text;
                final email = emailController.text;
                final password = passwordController.text;

                // Validate if all fields are filled
                if (name.isEmpty || email.isEmpty || password.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('Please fill in all fields.', style: TextStyle(color: Colors.red)),
                        actions: [
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('OK', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }

                // Name validation - check if the name contains numbers
                if (RegExp(r'\d').hasMatch(name)) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('Name should not contain numbers.', style: TextStyle(color: Colors.red)),
                        actions: [
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('OK', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }

                // Password validation - check if the password has at least 7 characters
                if (password.length < 7) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('Password should be at least 7 characters long.', style: TextStyle(color: Colors.red)),
                        actions: [
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('OK', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }

                // Email validation - check if the email is valid
                if (!isValidEmail(email)) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('Please enter a valid email address.', style: TextStyle(color: Colors.red)),
                        actions: [
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('OK', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }

                // Check for duplicate email
                final querySnapshot = await FirebaseFirestore.instance
                    .collection('users')
                    .where('email', isEqualTo: email)
                    .get();

                if (querySnapshot.docs.isNotEmpty) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('This email is already registered. Please use a different email.', style: TextStyle(color: Colors.red)),
                        actions: [
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('OK', style: TextStyle(color: Colors.black)),
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }

                // Add the new user if validation passes
                final newUser = {
                  "name": name,
                  "email": email,
                  "password": password,
                  "images": "", // You can add logic for default images here
                };

                try {
                  await FirebaseFirestore.instance.collection('users').add(newUser);
                  print("User added successfully!");
                  Navigator.of(context).pop();
                  fetchData(); // Refresh user list after adding
                } catch (e) {
                  print("Error adding user: $e");
                }
              },
              child: Text('Add User', style: TextStyle(color: Colors.black)),
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
        title: Text('Users Data', style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255))),
        
        backgroundColor: Color.fromARGB(255, 24, 16, 133),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: showAddUserDialog, // Show Add User Dialog
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search Users',
                labelStyle: TextStyle(color: Colors.black),
                prefixIcon: Icon(Icons.search, color: Colors.black),
              ),
              style: TextStyle(color: Colors.black),
              onChanged: (value) {
                setState(() {
                  if (value.isEmpty) {
                    fetchData(); // Reset the list to all users when search query is empty
                  } else {
                    _users = _users
                        .where((user) => user["name"]
                            .toLowerCase()
                            .contains(value.toLowerCase()) || user["email"]
                            .toLowerCase()
                            .contains(value.toLowerCase()))
                        .toList();
                  }
                });
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _users.isEmpty
                    ? Center(child: Text("No users found."))
                    : ListView.builder(
                        itemCount: _users.length,
                        itemBuilder: (context, index) {
                          final user = _users[index];
                          return Card(
                            margin: EdgeInsets.all(10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Name: ${user["name"]}",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black)),
                                  Text("Email: ${user["email"]}",
                                      style: TextStyle(color: Colors.black)),
                                  Text("Password: ${user["password"]}",
                                      style: TextStyle(color: Colors.black)),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () => showEditDialog(user),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () => deleteDialog(user["id"]),
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
