import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WishlistPage extends StatefulWidget {
  @override
  _WishlistPageState createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> wishlistBooks = [];

  @override
  void initState() {
    super.initState();
    _fetchWishlist();
  }

  void _fetchWishlist() async {
    User? user = _auth.currentUser; // ✅ Logged-in user ka UID lena
    if (user != null) {
      String userId = user.uid;
      QuerySnapshot snapshot = await _firestore
          .collection('wishlist')
          .where('userId', isEqualTo: userId)
          .get();

      setState(() {
        wishlistBooks = snapshot.docs
            .map((doc) => {
                  "id": doc.id,
                  "title": doc["title"],
                  "author": doc["author"],
                  "b_img": doc["b_img"],
                })
            .toList();
      });
    }
  }

  void _removeFromWishlist(String bookId) async {
    await _firestore.collection('wishlist').doc(bookId).delete();
    _fetchWishlist(); // ✅ Delete hone ke baad list update
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Wishlist",
          style: TextStyle(color: Colors.white), // ✅ Text white
        ),
        backgroundColor: Color.fromARGB(255, 4, 66, 85),
        iconTheme: IconThemeData(color: Colors.white), // ✅ Back icon white
      ),
      body: wishlistBooks.isEmpty
          ? Center(
              child: Text(
                "Your wishlist is empty!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          : ListView.builder(
              itemCount: wishlistBooks.length,
              itemBuilder: (context, index) {
                var book = wishlistBooks[index];
                return Card(
                  color: Colors.grey[100],
                  margin: EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        book["b_img"]!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported),
                      ),
                    ),
                    title: Text(
                      book["title"]!,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("By ${book["author"]!}"),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _removeFromWishlist(book["id"]!); // ✅ Firestore se delete
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
