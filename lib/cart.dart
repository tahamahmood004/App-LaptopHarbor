import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> cartItems = [];
  int cartCount = 0;
String paymentMethod = "Cash on Delivery"; 
  
   TextEditingController addressController = TextEditingController();
  TextEditingController contactController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadCart();
  }


  void loadCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? cartList = prefs.getStringList('cart');
    if (cartList != null) {
       setState(() {
        cartItems = cartList.map<Map<String, dynamic>>((item) {
          try {
            final Map<dynamic, dynamic> decodedItem = jsonDecode(item);
            return decodedItem.map<String, dynamic>((key, value) => MapEntry(key.toString(), value));
          } catch (e) {
            print("Error decoding item: $item");
            return <String, dynamic>{};
          }
        }).where((item) => item.isNotEmpty).toList();
        cartCount = cartItems.length;
      });
    }
    }
  

  double getTotalPrice() {
  return cartItems.fold(0.0, (sum, item) => 
    sum + ((double.tryParse(item['price'].toString()) ?? 0) * (item['quantity'] ?? 1))
  );
}


void deleteitems(int index) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      cartItems.removeAt(index);
      prefs.setStringList('cart', cartItems.map((item) => jsonEncode(item)).toList());
      cartCount = cartItems.length;
    });
   
}
void removeFromCart(int index) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  
  setState(() {
    if (cartItems[index]['quantity'] > 1) {
      cartItems[index]['quantity'] -= 1;
    } else {
      cartItems.removeAt(index);
    }
    
    prefs.setStringList('cart', cartItems.map((item) => jsonEncode(item)).toList());
  });
}

 void showCheckoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Checkout"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: addressController,
                decoration: InputDecoration(labelText: "Enter Address"),
              ),
              TextField(
                controller: contactController,
                decoration: InputDecoration(labelText: "Enter Contact Number"),
                keyboardType: TextInputType.phone,
                
                
                
               


                
                
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text("Payment: "),
                  SizedBox(width: 10),
                  DropdownButton<String>(
                    value: paymentMethod,
                    items: [
                      DropdownMenuItem(
                          value: "Cash on Delivery",
                          child: Text("Cash on Delivery")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        paymentMethod = value!;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
    placeOrder(addressController.text, contactController.text);
    Navigator.pop(context); // Close dialog after placing order
  },
              child: Text("Complete Order"),
            ),
          ],
        );
      },
    );
  }
  void placeOrder(String address, String contactNumber) async {
  if (address.isEmpty || contactNumber.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Please enter address and contact number")),
    );
    return;
  }

  try {
    // Get current user ID from Firebase Auth
    String userId = FirebaseAuth.instance.currentUser!.uid;

    // Prepare order data
    Map<String, dynamic> orderData = {
      "userId": userId,
      "items": cartItems,
      "totalAmount": getTotalPrice(),
      "address": address,
      "contactNumber": contactNumber,
      "paymentMethod": "COD",
      "timestamp": FieldValue.serverTimestamp(),
    };

    // Save to Firestore in "orders" collection
    await FirebaseFirestore.instance.collection("orders").add(orderData);

    // Clear cart after order is placed
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      cartItems.clear();
      cartCount = 0;
      prefs.remove('cart');
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Order placed successfully!")),
    );

  } catch (e) {
    print("Error placing order: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to place order. Please try again.")),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cart"),
      leading: IconButton(onPressed: (){
 Navigator.pushReplacementNamed(context, '/home');

      }, icon: Icon(Icons.arrow_back)),
      ),
      body: Column(
        children: [
          Expanded(
            child: cartItems.isEmpty
                ? Center(child: Text("Cart is Empty"))
                : ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      var item = cartItems[index];
                      return Card(
  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15),
  ),
  elevation: 4, // Adds a subtle shadow effect
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Product Image
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            item['b_img'],
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.broken_image, size: 80, color: Colors.grey),
          ),
        ),
        SizedBox(width: 12),

        // Product Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['b_name'] ?? "Unknown",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 5),
              Text(
                "Price: \$${item['price'] ?? '0.00'}",
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 10),

              // Quantity Control
              Row(
                children: [
               IconButton(
  icon: Icon(Icons.remove_circle_outline, color: Colors.red),
 onPressed: () async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  setState(() {
    if (cartItems[index]['quantity'] > 1) {
      cartItems[index]['quantity'] -= 1;
    } else {
      cartItems.removeAt(index); // Remove item if quantity reaches 0
    }
    prefs.setStringList('cart', cartItems.map((item) => jsonEncode(item)).toList());
  });
},

),

                  Text(
                    item['quantity']?.toString() ?? '1',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
             IconButton(
  icon: Icon(Icons.add_circle_outline, color: Colors.green),
 onPressed: () async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  setState(() {
    cartItems[index]['quantity'] = (cartItems[index]['quantity'] ?? 1) + 1;
    prefs.setStringList('cart', cartItems.map((item) => jsonEncode(item)).toList());
  });
},

),

                ],
              ),
            ],
          ),
        ),

        // Remove Button
        IconButton(
          icon: Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => deleteitems(index),
        ),
      ],
    ),
  ),
);

                    },
                  ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5)]),
            child: Column(
              children: [
                Text("Total: \$${getTotalPrice().toStringAsFixed(2)}", 
    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: showCheckoutDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: Text("Checkout", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}