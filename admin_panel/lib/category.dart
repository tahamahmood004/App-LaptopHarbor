import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
// For clipboard support
class Categorydata extends StatefulWidget {
  const Categorydata({super.key});

  @override
  State<Categorydata> createState() => _CategorydataState();
}

class _CategorydataState extends State<Categorydata> {
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // Fetch Data from Firestore
  void fetchData() async {
    final userdata = await FirebaseFirestore.instance.collection('categories').get();
    final rawdata = userdata.docs.map((doc) {
      var data = doc.data();
      data["key"] = doc.id; // Add Firestore doc id as key
      return data;
    }).toList();

    setState(() {
      _users = rawdata;
    });
  }

  // Update data in Firestore
  void updateData(String docId, Map<String, dynamic> newData) async {
    final docRef = FirebaseFirestore.instance.collection('categories').doc(docId);
    await docRef.update(newData);
  }

  // Delete data from Firestore
  void deleteData(String docId) async {
    final docRef = FirebaseFirestore.instance.collection('categories').doc(docId);
    await docRef.delete();
  }

  // Copy ID to Clipboard
  void copyToClipboard(String id) {
    Clipboard.setData(ClipboardData(text: id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Category ID copied: $id"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Delete Confirmation Dialog
  void deleteDialog(String docId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Confirmation', style: TextStyle(color: Colors.black)),
          content: Text('Are you sure you want to delete this category?', style: TextStyle(color: Colors.black)),
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

  // Show Edit Dialog
  void showEditDialog(Map<String, dynamic> user) {
    final TextEditingController categoryController =
        TextEditingController(text: user["category"]);
    final TextEditingController catImageController =
        TextEditingController(text: user["cat_img"]);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Category', style: TextStyle(color: Colors.black)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: catImageController,
                decoration: InputDecoration(
                  labelText: 'Category Image URL',
                  labelStyle: TextStyle(color: Colors.black),
                ),
                style: TextStyle(color: Colors.black),
              ),
              TextField(
                controller: categoryController,
                decoration: InputDecoration(
                  labelText: 'Category',
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
                final updatedCategory = categoryController.text;
                final updatedCatImg = catImageController.text;

                if (updatedCategory.isEmpty || updatedCatImg.isEmpty) {
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

                final querySnapshot = await FirebaseFirestore.instance
                    .collection('categories')
                    .where('category', isEqualTo: updatedCategory)
                    .get();

                if (querySnapshot.docs.isNotEmpty && querySnapshot.docs.first.id != user["key"]) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('Category name already exists.', style: TextStyle(color: Colors.red)),
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

                final updatedData = {
                  "cat_img": updatedCatImg,
                  "category": updatedCategory,
                };

                updateData(user["key"], updatedData);
                Navigator.of(context).pop();
              },
              child: Text('Update', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  // Show Add Category Dialog with validation
  void showAddCategoryDialog() {
    final TextEditingController categoryController = TextEditingController();
    final TextEditingController catImageController = TextEditingController();

     showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Category', style: TextStyle(color: Colors.black)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: catImageController,
                decoration: InputDecoration(
                  labelText: 'Category Image URL',
                  labelStyle: TextStyle(color: Colors.black),
                ),
                style: TextStyle(color: Colors.black),
              ),
              TextField(
                controller: categoryController,
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: TextStyle(color: Colors.black),
                ),
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),

          // 
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              onPressed: () async {
                final category = categoryController.text;
                final catImg = catImageController.text;

                if (category.isEmpty || catImg.isEmpty) {
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

                // Check if the category name already exists
                final querySnapshot = await FirebaseFirestore.instance
                    .collection('categories')
                    .where('category', isEqualTo: category)
                    .get();

                if (querySnapshot.docs.isNotEmpty) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('Category name already exists. Please choose a different name.', style: TextStyle(color: Colors.red)),
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

                final newCategory = {
                  "cat_img": catImg,
                  "category": category,
                };

                FirebaseFirestore.instance.collection('categories').add(newCategory);
                Navigator.of(context).pop();
                fetchData();  // Refresh the list after adding the new category
              },
              child: Text('Add Category', style: TextStyle(color: Colors.black)),
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
        title: Text('Categories', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 24, 16, 133),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: showAddCategoryDialog, // Show the Add Category Dialog
          ),
        ],
      ),
      body: _users.isEmpty
          ? Center(child: CircularProgressIndicator())
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
                        Text(
                          "Category: ${user["category"]}",
                          style: TextStyle(color: Colors.black),
                        ),
                        user["cat_img"] != null
                            ? Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundImage: NetworkImage(user["cat_img"] ?? ""),
                                ),
                              )
                            : SizedBox.shrink(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.copy, color: Colors.blue), // Copy Icon
                              onPressed: () => copyToClipboard(user["key"]),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => showEditDialog(user),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => deleteDialog(user["key"]),
                            ),
                          ],
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
