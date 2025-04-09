import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Wishlist extends StatefulWidget {
  const Wishlist({super.key});

  @override
  State<Wishlist> createState() => _WishlistState();
}

class _WishlistState extends State<Wishlist> {
  List<Map<String, dynamic>> _wishlist = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWishlist();
  }

  // Fetch wishlist data from Firestore
  void fetchWishlist() async {
    final userdata = await FirebaseFirestore.instance.collection('wishlist').get();
    final rawdata = userdata.docs.map((doc) => doc.data()..['id'] = doc.id).toList(); // Add 'id' for each document
    setState(() {
      _wishlist = rawdata;
      isLoading = false;
    });
  }

  // Delete item from wishlist
  void deleteItem(String docId) async {
    try {
      final db = FirebaseFirestore.instance.collection('wishlist');
      await db.doc(docId).delete();  // Use document ID to delete
      print("Item deleted successfully!");
    } catch (e) {
      print("Error deleting item: $e");
    }
  }

  // Delete confirmation dialog
  void deleteDialog(String docId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Confirmation', style: TextStyle(color: Colors.black)),
          content: Text('Are you sure you want to delete this item?', style: TextStyle(color: Colors.black)),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              onPressed: () {
                deleteItem(docId);
                Navigator.of(context).pop();
              },
              child: Text('Delete', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  // Show edit wishlist item dialog
  void showEditDialog(Map<String, dynamic> item) {
    final TextEditingController itemNameController = TextEditingController(text: item["b_name"]);
    final TextEditingController itemPriceController = TextEditingController(text: item["price"]);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Wishlist Item', style: TextStyle(color: Colors.black)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: itemNameController,
                decoration: InputDecoration(
                  labelText: 'Item Name',
                  labelStyle: TextStyle(color: Colors.black),
                ),
                style: TextStyle(color: Colors.black),
              ),
            
              TextField(
                controller: itemPriceController,
                decoration: InputDecoration(
                  labelText: 'Price',
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
              onPressed: () {
                final updatedData = {
                  "b_name": itemNameController.text,
                  "price": itemPriceController.text,
                };
                FirebaseFirestore.instance.collection('wishlist').doc(item["id"]).update(updatedData);  // Use Firestore document ID
                Navigator.of(context).pop();
                fetchWishlist();  // Refresh the list after updating the item
              },
              child: Text('Update', style: TextStyle(color: Colors.black)),
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
        title: Text('Wishlist'),
          backgroundColor:Color.fromARGB(255, 24, 16, 133), // Dark blue background
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _wishlist.length,
                    itemBuilder: (context, index) {
                      final item = _wishlist[index];
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
                                "Name: ${item["b_name"]}",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text("Price: \$${item["price"]}", style: TextStyle(color: Colors.black)),
                              item["b_img"] != null
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      child: CircleAvatar(
                                        radius: 40,
                                        backgroundImage: NetworkImage(item["b_img"] ?? ""),
                                      ),
                                    )
                                  : SizedBox.shrink(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () => showEditDialog(item),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () => deleteDialog(item["id"]),
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
