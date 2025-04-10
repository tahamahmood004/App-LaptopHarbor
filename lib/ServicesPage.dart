import 'package:flutter/material.dart';

class ServicesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Our Services", style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 24, 16, 133),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          serviceItem(Icons.shopping_cart, "Online Laptop Selling",
              "Buy laptop from our huge collection with easy checkout."),
          serviceItem(Icons.delivery_dining, "Fast Delivery",
              "Get your laptop delivered within 3-5 business days."),
          serviceItem(Icons.book_online, "Gaming Laptops also Available",
              "We also offer gaming laptops and accessories."),
          serviceItem(Icons.star, "Customer Reviews",
              "Check honest reviews before making a purchase."),
        ],
      ),
    );
  }

  Widget serviceItem(IconData icon, String title, String description) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Color.fromARGB(255, 24, 16, 133)),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
      ),
    );
  }
}
