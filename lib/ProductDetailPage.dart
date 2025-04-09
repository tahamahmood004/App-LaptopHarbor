import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;

  ProductDetailPage({required dynamic product})
      : product = (product is QueryDocumentSnapshot) ? product.data() as Map<String, dynamic> : product;

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();


}


class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1;

int cartCount = 0;

  void addtocart(Map<String, dynamic> product) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  if (isLoggedIn) {
    List<String> cartList = prefs.getStringList('cart') ?? [];
    cartList.add(jsonEncode(product));
    
    await prefs.setStringList('cart', cartList);

    setState(() {
      cartCount = cartList.length; // Update badge count
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${product['b_name']} added to cart!"),
        duration: Duration(seconds: 2),
      ),
    );
  } else {
    Navigator.pushReplacementNamed(context, '/login');
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 4, 66, 85),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: const Color.fromARGB(255, 255, 255, 255)),
          onPressed: () => Navigator.pop(context),
        ),
        title: AnimatedTextKit(
          animatedTexts: [
            TyperAnimatedText(
              "🚚 Free Delivery on Orders Above Rs.1,999/-",
              textStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 255, 255, 255),
              ),
              speed: Duration(milliseconds: 100),
            ),
          ],
          totalRepeatCount: 1,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
//               // HD Banner Image
//               Container(
//   width: double.infinity,
//   height: 200,
//   decoration: BoxDecoration(
//     borderRadius: BorderRadius.circular(15), // ✅ Rounded corners
//     boxShadow: [
//       BoxShadow(
//         color: Colors.black.withOpacity(0.3),
//         blurRadius: 8,
//         spreadRadius: 2,
//         offset: Offset(0, 4), // ✅ Soft shadow effect
//       ),
//     ],
//     image: DecorationImage(
//       image: NetworkImage("https://images.unsplash.com/photo-1512820790803-83ca734da794"),
//       fit: BoxFit.cover,
//     ),
//   ),
//   child: Stack(
//     children: [
//       // ✅ Gradient Overlay
//       Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(15),
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Colors.black.withOpacity(0.3), // Dark fade effect
//               Colors.black.withOpacity(0.6),
//             ],
//           ),
//         ),
//       ),
//       // ✅ Centered Text with Elegant Style
//       Align(
//   alignment: Alignment.center,
//   child: Text(
//     "Discover Your Next Read!",
//     textAlign: TextAlign.center,
//     style: TextStyle(
//       fontSize: 20,
//       color: Colors.white,
//       fontFamily: 'Georgia', // ✅ Classy & elegant font
//       shadows: [
//         Shadow(
//           color: Colors.black.withOpacity(0.5),
//           blurRadius: 6,
//           offset: Offset(2, 2),
//         ),
//       ],
//     ),
//   ),
// )

//     ],
//   ),
// ),



              SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Book Image
                  Container(
                    width: 170,
                    height: 260,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(widget.product['b_img']),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(2, 2))
                      ],
                    ),
                  ),
                  SizedBox(width: 50), // 🔹 Space Between Image and Details
                  // Product Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Book Name",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54),
                        ),
                        Text(
                          widget.product['b_name'],
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Price",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54),
                        ),
                        Text(
                          "Rs. ${(double.tryParse(widget.product['price'].toString()) ?? 0.0).toStringAsFixed(0)}",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            _quantityButton(Icons.remove, () {
                              if (quantity > 1) {
                                setState(() {
                                  quantity--;
                                });
                              }
                            }),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                quantity.toString(),
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                            _quantityButton(Icons.add, () {
                              setState(() {
                                quantity++;
                              });
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10), // 🔹 Space Between Details and Description
              // Description
              Text(
                "Book Description",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              SizedBox(height: 5),
              Text(
                widget.product['b_desc'] ?? "No description available",
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              SizedBox(height: 20),
              // Delivery Info
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.local_shipping, color: Colors.black54),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Estimated delivery in 3-5 working days",
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: 160,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:  Color.fromARGB(255, 24, 16, 133),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: () {
                      addtocart(widget.product);
                      
                    },
                    child: Text(
                      "ADD TO CART",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold ,color: Colors.white),
                      
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
               Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              color: Colors.grey[200], // Light gray background
              child: Column(
          children: [
            /// 📌 Social Media Icons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(FontAwesomeIcons.facebook, color:Color.fromARGB(255, 24, 16, 133),),
                  onPressed: () {}, // Add social links
                ),
                IconButton(
                  icon: Icon(FontAwesomeIcons.twitter, color: Color.fromARGB(255, 24, 16, 133),),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(FontAwesomeIcons.instagram, color:Color.fromARGB(255, 24, 16, 133),  ),
                  onPressed: () {},
                ),
              ],
            ),
           
            SizedBox(height: 10),
           
            /// 📌 Divider Line
            Divider(color: Colors.grey, thickness: 1),
          
            SizedBox(height: 10),
          
            /// 📌 About & Contact Links
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {},
                  child: Text("About Us", style: TextStyle(color: Colors.black)),
                ),
                Text("|", style: TextStyle(color: Colors.grey)),
                TextButton(
                  onPressed: () {},
                  child: Text("Contact", style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          
            SizedBox(height: 5),
          
            /// 📌 Copyright Text
            Text(
              "© 2025 Book Store. All Rights Reserved.",
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quantityButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
        ),
        padding: EdgeInsets.all(8),
        child: Icon(icon, size: 24, color: Colors.black),
      ),
      
    );
   
  }
  
}
