import 'package:flutter/material.dart';

class FAQPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("FAQ", style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 24, 16, 133),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          faqItem("What types of books are available?", "We offer fiction, non-fiction, educational, and many more categories."),
          faqItem("How can I place an order?", "Simply add books to your cart and proceed to checkout."),
          faqItem("Do you offer cash on delivery?", "Yes, we provide COD in selected locations."),
          faqItem("Can I return or exchange a book?", "Yes, returns and exchanges are possible within 7 days."),
        ],
      ),
    );
  }

  Widget faqItem(String question, String answer) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(question, style: TextStyle(fontWeight: FontWeight.bold)),
        children: [Padding(padding: EdgeInsets.all(16), child: Text(answer))],
      ),
    );
  }
}
