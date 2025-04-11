import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _filteredOrders = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  // Fetch orders from Firestore
  void fetchOrders() async {
    final userdata =
        await FirebaseFirestore.instance.collection('orders').get();
    List<Map<String, dynamic>> orders = [];

    for (var doc in userdata.docs) {
      var orderData = doc.data();
      orderData['id'] = doc.id;

      // Fetch user information using the userId
      var userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(orderData[
              'userId']) // Use 'userId' field in orders to query users
          .get();

      if (userSnapshot.exists) {
        orderData['customer_name'] = userSnapshot[
            'name']; // Assuming 'name' field exists in users collection
      } else {
        orderData['customer_name'] = 'Unknown Customer'; // Handle missing user
      }

      // Fetch product information from the items array (by product id)
      List<Map<String, dynamic>> items = [];
      for (var item in orderData['items']) {
        var productSnapshot = await FirebaseFirestore.instance
            .collection('products')
            .doc(item[
                'id']) // Use 'id' of the product in items array to query the products collection
            .get();

        if (productSnapshot.exists) {
          var productData = productSnapshot.data()!;
          var itemData = {
            'b_name': productData['b_name'], // Product Name
          };
          items.add(itemData);
        } else {
          items.add({
            'b_name': 'Unknown Product',
          });
        }
      }

      orderData['items'] = items; // Add the processed items list to the order

      // Add the processed order data to the list
      orders.add(orderData);
    }

    setState(() {
      _orders = orders;
      _filteredOrders = orders; // Initially display all orders
      isLoading = false;
    });
  }

  void showEditDialog(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) {
        String selectedStatus =
            order["status"] ?? "pending"; // Default to 'pending'

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit Order Status',
                  style: TextStyle(color: Colors.black)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: selectedStatus,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedStatus =
                            newValue!; // Update status within the dialog
                      });
                    },
                    items: ['pending', 'order confirmed', 'delivered']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
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
                    FirebaseFirestore.instance
                        .collection('orders')
                        .doc(order["id"])
                        .update({"status": selectedStatus}); // Update Firestore

                    Navigator.of(context).pop();
                    fetchOrders(); // Refresh list
                  },
                  child: Text('Update', style: TextStyle(color: Colors.black)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Search orders
  void searchOrders(String query) {
    final results = _orders.where((order) {
      final customerName = order['customer_name'].toLowerCase();
      return customerName.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredOrders = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
        backgroundColor: Color.fromARGB(255, 24, 16, 133),
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
                      labelText: 'Search Orders',
                      labelStyle: TextStyle(color: Colors.black),
                      prefixIcon: Icon(Icons.search, color: Colors.black),
                    ),
                    style: TextStyle(color: Colors.black),
                    onChanged: (value) {
                      setState(() {
                        if (value.isEmpty) {
                          _filteredOrders =
                              _orders; // Reset to all orders when search query is empty
                        } else {
                          searchOrders(
                              value); // Filter the list based on the search query
                        }
                      });
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = _filteredOrders[index];
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
                                "Customer Name: ${order["customer_name"]}",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text("Order Status: ${order["status"]}",
                                  style: TextStyle(color: Colors.black)),
                              Text("Total Price: \$${order["totalAmount"]}",
                                  style: TextStyle(color: Colors.black)),
                              Text("Payment Method: ${order["paymentMethod"]}",
                                  style: TextStyle(color: Colors.black)),
                              Text("Address: ${order["address"]}",
                                  style: TextStyle(color: Colors.black)),
                              Text("Contact Number: ${order["contactNumber"]}",
                                  style: TextStyle(color: Colors.black)),

                              // Loop through the items and display product information
                              ...order["items"].map<Widget>((item) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Product: ${item["b_name"]}",
                                        style: TextStyle(color: Colors.black)),
                                  ],
                                );
                              }).toList(),

                              // Order Timestamp
                              Text("Timestamp: ${order["timestamp"]?.toDate()}",
                                  style: TextStyle(color: Colors.black)),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () => showEditDialog(order),
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
