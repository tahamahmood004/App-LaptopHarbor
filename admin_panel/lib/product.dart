import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Product extends StatefulWidget {
  const Product({super.key});

  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> {
  
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // Fetch data from Firestore
  void fetchData() async {
    final userdata = await FirebaseFirestore.instance.collection('products').get();
    final rawdata = userdata.docs.map((doc) => doc.data()..['id'] = doc.id).toList(); // Add 'id' for each document
    setState(() {
      _products = rawdata;
      _filteredProducts = rawdata; // Initially display all products
      isLoading = false;
    });
  }

  // Update data in Firestore
  void updateData(String docId, Map<String, dynamic> newData) async {
    try {
      final db = FirebaseFirestore.instance.collection('products');
      await db.doc(docId).update(newData);  // Use document ID to update
      print("Product updated successfully!");
    } catch (e) {
      print("Error updating data: $e");
    }
  }

  // Delete data from Firestore
  void deleteData(String docId) async {
    try {
      final db = FirebaseFirestore.instance.collection('products');
      await db.doc(docId).delete();  // Use document ID to delete
      print("Product deleted successfully!");
    } catch (e) {
      print("Error deleting data: $e");
    }
  }

  // Delete confirmation dialog
  void deleteDialog(String docId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Confirmation', style: TextStyle(color: Colors.black)),
          content: Text('Are you sure you want to delete this product?', style: TextStyle(color: Colors.black)),
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

  // Show edit dialog
  void showEditDialog(Map<String, dynamic> product) {
    final TextEditingController bDesc = TextEditingController(text: product["b_desc"]);
    final TextEditingController bImg = TextEditingController(text: product["b_img"]);
    final TextEditingController bName = TextEditingController(text: product["b_name"]);
    final TextEditingController catIdcontroller = TextEditingController(text: product["cat_id"]);
    final TextEditingController priceController = TextEditingController(text: product["price"]);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Product', style: TextStyle(color: Colors.black)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: bDesc,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: Colors.black),
                ),
                style: TextStyle(color: Colors.black),
              ),
              TextField(
                controller: bImg,
                decoration: InputDecoration(
                  labelText: 'Image URL',
                  labelStyle: TextStyle(color: Colors.black),
                ),
                style: TextStyle(color: Colors.black),
              ),
              TextField(
                controller: bName,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  labelStyle: TextStyle(color: Colors.black),
                ),
                style: TextStyle(color: Colors.black),
              ),
              TextField(
                controller: catIdcontroller,
                decoration: InputDecoration(
                  labelText: 'Category ID',
                  labelStyle: TextStyle(color: Colors.black),
                ),
                style: TextStyle(color: Colors.black),
              ),
              TextField(
                controller: priceController,
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
              onPressed: () async {
                // Validate if any field is empty
                if (bDesc.text.isEmpty ||
                    bImg.text.isEmpty ||
                    bName.text.isEmpty ||
                    catIdcontroller.text.isEmpty ||
                    priceController.text.isEmpty) {
                  // Show error message when fields are empty
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Error', style: TextStyle(color: Colors.black)),
                        content: Text(
                          'Please fill in all fields.',
                          style: TextStyle(color: Colors.black),
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK', style: TextStyle(color: Colors.black)),
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }

                // Check if price is a valid number
                if (double.tryParse(priceController.text) == null) {
                  // Show error message for invalid price
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Error', style: TextStyle(color: Colors.black)),
                        content: Text(
                          'Please enter a valid price.',
                          style: TextStyle(color: Colors.black),
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK', style: TextStyle(color: Colors.black)),
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }

             

                // Check if product name already exists
                final querySnapshot = await FirebaseFirestore.instance
                    .collection('products')
                    .where('b_name', isEqualTo: bName.text)
                    .get();

                if (querySnapshot.docs.isNotEmpty && querySnapshot.docs.first.id != product["id"]) {
                  // Show error if product name already exists
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Error', style: TextStyle(color: Colors.black)),
                        content: Text(
                          'Product name already exists. Please choose a different name.',
                          style: TextStyle(color: Colors.black),
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK', style: TextStyle(color: Colors.black)),
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }

                // Update product if validation passes
                final updatedData = {
                  "b_desc": bDesc.text,
                  "b_img": bImg.text,
                  "b_name": bName.text,
                  "cat_id": catIdcontroller.text,
                  "price": priceController.text,
                };
                updateData(product["id"], updatedData);  // Use Firestore document ID
                Navigator.of(context).pop();
              },
              child: Text('Update', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  // Show add product dialog with validation
  void showAddProductDialog() {
    final TextEditingController bDesccontroller = TextEditingController();
    final TextEditingController bImgcontroller = TextEditingController();
    final TextEditingController bNamecontroller = TextEditingController();
    final TextEditingController catIdcontroller = TextEditingController();
    final TextEditingController priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Product', style: TextStyle(color: Colors.black)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: bDesccontroller,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: Colors.black),
                ),
                style: TextStyle(color: Colors.black),
              ),
              TextField(
                controller: bImgcontroller,
                decoration: InputDecoration(
                  labelText: 'Image URL',
                  labelStyle: TextStyle(color: Colors.black),
                ),
                style: TextStyle(color: Colors.black),
              ),
              TextField(
                controller: bNamecontroller,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  labelStyle: TextStyle(color: Colors.black),
                ),
                style: TextStyle(color: Colors.black),
              ),
              TextField(
                controller: catIdcontroller,
                decoration: InputDecoration(
                  labelText: 'Category ID',
                  labelStyle: TextStyle(color: Colors.black),
                ),
                style: TextStyle(color: Colors.black),
              ),
              TextField(
                controller: priceController,
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
              onPressed: () async {
                // Validate if any field is empty
                if (bDesccontroller.text.isEmpty ||
                    bImgcontroller.text.isEmpty ||
                    bNamecontroller.text.isEmpty ||
                    catIdcontroller.text.isEmpty ||
                    priceController.text.isEmpty) {
                  // Show error message when fields are empty
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Error', style: TextStyle(color: Colors.black)),
                        content: Text(
                          'Please fill in all fields.',
                          style: TextStyle(color: Colors.black),
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK', style: TextStyle(color: Colors.black)),
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }

                // Check if price is a valid number
                if (double.tryParse(priceController.text) == null) {
                  // Show error message for invalid price
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Error', style: TextStyle(color: Colors.black)),
                        content: Text(
                          'Please enter a valid price.',
                          style: TextStyle(color: Colors.black),
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK', style: TextStyle(color: Colors.black)),
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }

            

                // Check if product name already exists
                final querySnapshot = await FirebaseFirestore.instance
                    .collection('products')
                    .where('b_name', isEqualTo: bNamecontroller.text)
                    .get();

                if (querySnapshot.docs.isNotEmpty) {
                  // Show error if product name already exists
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Error', style: TextStyle(color: Colors.black)),
                        content: Text(
                          'Product name already exists. Please choose a different name.',
                          style: TextStyle(color: Colors.black),
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK', style: TextStyle(color: Colors.black)),
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }

                // Add the new product if validation passes
                final newProduct = {
                  "b_desc": bDesccontroller.text,
                  "b_img": bImgcontroller.text,
                  "b_name": bNamecontroller.text,
                  "cat_id": catIdcontroller.text,
                  "price": priceController.text,
                };
                FirebaseFirestore.instance.collection('products').add(newProduct);
                Navigator.of(context).pop();
                fetchData();  // Refresh the list after adding the new product
              },
              child: Text('Add Product', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  // Search products
  void searchProducts(String query) {
    final results = _products.where((product) {
      final name = product['b_name'].toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredProducts = results;
    });
  }

  // Sort products by price or name
  void sortProducts(String criterion) {
    setState(() {
      if (criterion == 'Price') {
        _filteredProducts.sort((a, b) => double.parse(a['price']).compareTo(double.parse(b['price'])));
      } else if (criterion == 'Name') {
        _filteredProducts.sort((a, b) => a['b_name'].compareTo(b['b_name']));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Data'),
          backgroundColor:Color.fromARGB(255, 24, 16, 133), // Dark blue background
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: showAddProductDialog, // Show the Add Product Dialog
          ),
        ],
      ),body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: 'Search Products',
                      labelStyle: TextStyle(color: Colors.black),
                      prefixIcon: Icon(Icons.search, color: Colors.black),
                    ),
                    style: TextStyle(color: Colors.black),
                    onChanged: (value) {
                      setState(() {
                        if (value.isEmpty) {
                          _filteredProducts = _products;  // Reset to all products when search query is empty
                        } else {
                          searchProducts(value);  // Filter the list based on the search query
                        }
                      });
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => sortProducts('Price'),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                        foregroundColor: Colors.white, // Set text color to white
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Sort by Price'),
                    ),
                    SizedBox(width: 10), // Space between buttons
                    TextButton(
                      onPressed: () => sortProducts('Name'),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                        foregroundColor: Colors.white, // Set text color to white
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Sort by Name'),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
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
  "Name: ${product["b_name"]}",
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  ),
),
Text("Description: ${product["b_desc"]}", style: TextStyle(color: Colors.black)),
Text("Category ID: ${product["cat_id"]}", style: TextStyle(color: Colors.black)),
Text("Price: \$${product["price"]}", style: TextStyle(color: Colors.black)),
product["b_img"] != null
    ? Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: ClipOval(
          child: Image.network(
            product["b_img"],
            height: 80,
            width: 80, // Make it a square so the circle looks good
            fit: BoxFit.cover,
          ),
        ),
      )
    : SizedBox(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () => showEditDialog(product),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () => deleteDialog(product["id"]),
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