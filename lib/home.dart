import 'dart:convert';
import 'dart:math';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:bookstore/ProductDetailPage.dart';
import 'package:bookstore/allcategories_page.dart';
import 'package:bookstore/allproducts_page.dart';
import 'package:bookstore/cart.dart';
import 'package:bookstore/categories.dart';
import 'package:bookstore/drawer.dart';
import 'package:bookstore/loginscreen.dart';
import 'package:bookstore/logpage.dart';
import 'package:bookstore/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class homepage extends StatefulWidget {
  final String username;

  const homepage({super.key, required this.username});

  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> with WidgetsBindingObserver {
  String? userid;
  Set<String> wishlist = {};

  void didChangeDependencies() {
    super.didChangeDependencies();
    getCartCount(); // Update cart count whenever page rebuilds
  }

  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> filtered = [];
  int cartCount = 0;
  bool isLoggedIn = false;
  String username = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getusername();
    fetchdata();
    getCartCount();
    checkAndShowNewsletterPopup();
    fetchWishlist();
  }

  void fetchWishlist() async {
    String userId = "User123"; // Replace with actual user ID

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('wishlist')
        .where('userId', isEqualTo: userId)
        .get();

    setState(() {
      wishlist = snapshot.docs.map((doc) => doc['b_id'].toString()).toSet();
    });
  }

  void toggleWishlist(String bookId, Map<String, dynamic> product) async {
    String? userId = userid; // Replace with actual user ID

    if (wishlist.contains(bookId)) {
      // 🔴 Remove from wishlist
      await FirebaseFirestore.instance
          .collection('wishlist')
          .where('userId', isEqualTo: userId)
          .where('b_id', isEqualTo: bookId)
          .get()
          .then((snapshot) {
        for (var doc in snapshot.docs) {
          doc.reference.delete();
        }
      });

      setState(() {
        wishlist.remove(bookId);
      });
    } else {
      // ✅ Add to wishlist
      await FirebaseFirestore.instance.collection('wishlist').add({
        'userId': userId,
        'b_id': bookId,
        'b_name': product['b_name'],
        'b_img': product['b_img'],
        'price': product['price'],
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        wishlist.add(bookId);
      });
    }
  }

  void checkAndShowNewsletterPopup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasSubscribed = prefs.getBool('hasSubscribed') ?? false;

    if (!hasSubscribed) {
      Future.delayed(Duration(seconds: 2), () {
        showNewsletterPopup();
      });
    }
  }

  void showNewsletterPopup() {
    TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Subscribe to our Newsletter"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Get updates on new arrivals and offers!"),
              SizedBox(height: 10),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "Enter your email",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close popup
              },
              child: Text("Close"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 24, 16, 133),
              ),
              onPressed: () {
                if (emailController.text.isNotEmpty) {
                  saveSubscription(emailController.text);
                  Navigator.pop(context); // Close popup
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please enter a valid email")));
                }
              },
              child: Text(
                "Subscribe",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void saveSubscription(String email) async {
    await FirebaseFirestore.instance.collection('subscribers').add({
      'email': email,
      'timestamp': FieldValue.serverTimestamp(),
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('hasSubscribed', true); // Mark as subscribed

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Subscribed successfully!")));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove observer
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App is in focus again, refresh the cart count
      getCartCount();
    }
  }

  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn'); // Remove login status
    await prefs.remove('username'); // Remove stored username

    /// ✅ Navigate back to Login Page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => myapp()),
    );
  }

  void getusername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String storedUsername = prefs.getString('username') ?? '';
    String storedUserid = prefs.getString('userId') ?? '';

    setState(() {
      username = storedUsername;
      userid = storedUserid;
    });
  }

  void getCartCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartList = prefs.getStringList('cart') ?? [];

    setState(() {
      cartCount = cartList.length; // Update badge count
    });
  }

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

  void fetchdata() async {
    final data = await FirebaseFirestore.instance.collection('products').get();
    final raw = data.docs
        .map((doc) => {
              'id': doc.id,
              ...doc.data(),
            })
        .toList();

    final cat = await FirebaseFirestore.instance.collection('categories').get();
    final categ = cat.docs
        .map((doc) => {
              'id': doc.id,
              ...doc.data(),
            })
        .toList();

    setState(() {
      products = raw;
      categories = categ;
      filtered = products;
    });
  }

  void filterSearch(String query) {
    setState(() {
      filtered = products.where((item) {
        String productName = item['b_name']?.toString().toLowerCase() ??
            ''; // Change 'name' to your field
        return productName.contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool loginStatus = prefs.getBool('isLoggedIn') ?? false;
    String storedUsername = prefs.getString('username') ?? '';

    setState(() {
      isLoggedIn = loginStatus;
      username = storedUsername;
    });

    Future.delayed(Duration.zero, () {
      if (!loginStatus && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Logpage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        getCartCount();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: 33.0,
          backgroundColor: Color.fromARGB(255, 24, 16, 133),
          iconTheme: IconThemeData(color: Colors.white),
          actions: [
            Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.shopping_cart, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CartPage()),
                    ).then((value) {
                      if (value == true) {
                        getCartCount(); // Refresh count after returning
                      }
                    });
                  },
                ),
                if (cartCount > 0) // Show badge only if cart has items
                  Positioned(
                    right: 3,
                    top: 3,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2), // Reduce padding
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 104, 193, 235),
                        borderRadius:
                            BorderRadius.circular(12), // Reduce border radius
                      ),
                      constraints: BoxConstraints(
                        minWidth: 15, // Set minimum width
                        minHeight: 15, // Reduce height
                      ),
                      child: Text(
                        cartCount.toString(), // Display cart count
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11, // Decrease font size
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            if (username.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Center(
                  child: Row(
                    children: [
                      Text(
                        username,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          logout();
                        },
                        icon: Icon(Icons.logout),
                      ),
                    ],
                  ),
                ),
              )
            else
              IconButton(
                icon: Icon(
                  FontAwesomeIcons.user,
                  color: Colors.white,
                  size: 15,
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
          ],
          flexibleSpace: Center(
            child: Text(
              'Laptopharbor',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        drawer: AppDrawer(),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: EdgeInsets.all(0.0),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          /// 📌 Background Image or Color Container
                          Container(
                            width: double.infinity,
                            height: 120,
                            // decoration: BoxDecoration(
                            //   image: DecorationImage(
                            //     image: NetworkImage('https://source.unsplash.com/featured/?books'),
                            //     fit: BoxFit.cover,
                            //   ),
                            //   borderRadius: BorderRadius.circular(10),
                            // ),
                          ),

                          Container(
                            width: double.infinity,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(30),
                                bottomRight: Radius.circular(30),
                              ),
                              color: Color.fromARGB(255, 127, 122, 185),
                            ),
                            child: Center(
                              child: AnimatedTextKit(
                                repeatForever: true, // Loops the animation
                                animatedTexts: [
                                  TypewriterAnimatedText(
                                    'Welcome to Laptopharbor',
                                    textStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: GoogleFonts.dancingScript()
                                          .fontFamily,
                                    ),
                                    speed: Duration(
                                        milliseconds: 100), // Speed of typing
                                    cursor: '|', // Blinking cursor
                                  ),
                                  TypewriterAnimatedText(
                                    'Find Your laptop!',
                                    textStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: GoogleFonts.dancingScript()
                                          .fontFamily,
                                    ),
                                    speed: Duration(milliseconds: 100),
                                    cursor: '|',
                                  ),
                                ],
                              ),
                            ),
                          ),

                          /// 📌 Search Bar with Proper Constraints
                          Positioned(
                            bottom: 10,
                            left: 40,
                            right: 40, // Ensures full width
                            child: Container(
                              width: 250,
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Color.fromARGB(87, 99, 94, 94)),
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black12, blurRadius: 5),
                                ],
                              ),
                              child: TextField(
                                onChanged: filterSearch,
                                decoration: InputDecoration(
                                  hintText: "Search your laptop...",
                                  hintStyle: TextStyle(fontSize: 13),
                                  border: InputBorder.none,
                                  suffixIcon:
                                      Icon(Icons.search, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      //banner/// Center(
                      Center(
                        child: Stack(
                          children: [
                            // Background Image
                            Container(
                              height: 200,
                              width: MediaQuery.of(context).size.width * 0.9,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                image: DecorationImage(
                                  image: AssetImage(
                                      'assets/images/banner.png'), // 👈 Apni image yahan set karein
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            // Overlay Content
                            Positioned(
                              left: 20,
                              top: 40,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Text(
                                  //   "40% OFF ON ALL ITEMS",
                                  //   style: TextStyle(
                                  //     color: Colors.white,
                                  //     fontSize: 20,
                                  //     fontWeight: FontWeight.bold,
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // SizedBox(height: 15),
                      // Container(
                      //   padding: EdgeInsets.symmetric(horizontal: 18.0),
                      //   decoration: BoxDecoration(
                      //     border: Border.all(color: Color.fromARGB(87, 99, 94, 94)),
                      //     color: Colors.white,
                      //     borderRadius: BorderRadius.circular(30),
                      //     boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
                      //   ),
                      //   child: TextField(
                      //     onChanged: filterSearch,
                      //     decoration: InputDecoration(
                      //       hintText: "Search your books...",
                      //       hintStyle: TextStyle(fontSize: 13),
                      //       border: InputBorder.none,
                      //       suffixIcon: Icon(Icons.search, color: Colors.grey),
                      //     ),
                      //   ),
                      // ),

                      Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Text('CATEGORIES',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w700)),
                          )),
                      Align(
                        alignment: Alignment.topRight,
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      CategoriesPage()), // Category Page Open Hoga
                            );
                          },
                          icon: Icon(Icons.arrow_forward,
                              color: Color.fromARGB(255, 128, 78, 105),
                              size: 18),
                          // Stylish forward arrow icon
                          label: Text(
                            "See More",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 24, 16, 133),
                              letterSpacing: 0.5, // Adds a premium touch
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6), // Proper spacing
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    8)), // Soft rounded corners
                            foregroundColor: Color.fromARGB(
                                255, 24, 16, 133), // Button press color effect
                          ),
                        ),
                      ),
                      categories.isEmpty
                          ? Center(child: CircularProgressIndicator())
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      childAspectRatio: 0.9),
                              itemCount: min(4, categories.length),
                              itemBuilder: (context, index) {
                                final category = categories[index];
                                return GestureDetector(
                                  onTap: () {
                                    String catid = category['id'];
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (builder) =>
                                                categoriespage(catid: catid)));
                                  },
                                  child: Column(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: NetworkImage(category[
                                                'cat_img'] ??
                                            'https://via.placeholder.com/150'),
                                        radius: 35,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        category['category'] ?? 'No Category',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                      // Background Image
                      Container(
                        height: 200,
                        width: MediaQuery.of(context).size.width * 0.9,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: DecorationImage(
                            image: AssetImage(
                                'assets/images/banner1.png'), // 👈 Apni image yahan set karein
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      //2nd banner
                      // Center(child: Stack(
                      //       children: [
                      //         // Background Image
                      //         Container(
                      //           height: 200,
                      //           width: MediaQuery.of(context).size.width * 0.9,
                      //           decoration: BoxDecoration(
                      //             borderRadius: BorderRadius.circular(15),
                      //             image: DecorationImage(
                      //               image: AssetImage('assets/images/banner1.png'), // 👈 Apni image yahan set karein
                      //               fit: BoxFit.cover,
                      //             ),
                      //           ),
                      //         ),

//2nd banner

                      Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                              padding: EdgeInsets.only(left: 12.0),
                              child: Text('POPULAR PRODUCTS',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700)))),
                      Align(
                        alignment: Alignment.topRight,
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ProductsPage()), // Saare products ka page open hoga
                            );
                          },
                          icon: Icon(Icons.arrow_forward,
                              color: Color.fromARGB(255, 128, 78, 105),
                              size: 18), // Stylish forward arrow icon
                          label: Text(
                            "See More",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 24, 16, 133),
                              letterSpacing: 0.5, // Adds a premium touch
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6), // Proper spacing
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    8)), // Soft rounded corners
                            foregroundColor: Color.fromARGB(
                                255, 24, 16, 133), // Button press color effect
                          ),
                        ),
                      ),

                      filtered.isEmpty
                          ? Center(child: CircularProgressIndicator())
                          : Container(
                              child: GridView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          crossAxisSpacing: 1,
                                          childAspectRatio: 0.58),
                                  itemCount: min(6, filtered.length),
                                  itemBuilder: (context, index) {
                                    final product = filtered[index];

                                    return GestureDetector(
                                        onTap: () {},
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          elevation: 8,
                                          shadowColor: Colors.black26,
                                          color: Colors.white,
                                          margin: EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 10),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                /// 📌 Product Image with Error Handling
                                                Stack(
                                                  children: [
                                                    FadeInImage(
                                                      placeholder: AssetImage(
                                                          'assets/images/placeholder.jpg'),
                                                      image: NetworkImage(
                                                          product['b_img'] ??
                                                              ''),
                                                      height: 130,
                                                      width: double.infinity,
                                                      fit: BoxFit.cover,
                                                      imageErrorBuilder:
                                                          (context, error,
                                                              stackTrace) {
                                                        return Image.asset(
                                                          'assets/images/placeholder.jpg',
                                                          height: 130,
                                                          width:
                                                              double.infinity,
                                                          fit: BoxFit.cover,
                                                        );
                                                      },
                                                    ),

                                                    Positioned(
                                                      top: 10,
                                                      left: 10,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          toggleWishlist(
                                                              product['id'],
                                                              product);
                                                        },
                                                        child: Icon(
                                                          wishlist.contains(
                                                                  product['id'])
                                                              ? Icons.favorite
                                                              : Icons
                                                                  .favorite_border,
                                                          color: wishlist
                                                                  .contains(
                                                                      product[
                                                                          'id'])
                                                              ? Colors.red
                                                              : Colors.white,
                                                          size: 24,
                                                        ),
                                                      ),
                                                    ),

                                                    /// 🌟 Special Offer Badge
                                                    Positioned(
                                                      top: 10,
                                                      right: 10,
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 10,
                                                                vertical: 5),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Color.fromARGB(
                                                              255, 24, 16, 133),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                        ),
                                                        child: Text(
                                                          "New Arrival",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 9,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                /// 📌 Product Details
                                                Padding(
                                                  padding: EdgeInsets.all(9),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      /// 🏷 Product Name
                                                      Text(
                                                        product['b_name'] ??
                                                            'No Name',
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black87,
                                                        ),
                                                      ),

                                                      SizedBox(height: 5),

                                                      /// 💲 Price
                                                      Text(
                                                        "\$${product['price'] ?? '0.00'}",
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors.black87,
                                                        ),
                                                      ),

                                                      SizedBox(height: 10),

                                                      /// 🛒 Add to Cart Button with Gradient Effect
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween, // Buttons ko ek line mein rakhnay ke liye
                                                        children: [
                                                          Expanded(
                                                            child:
                                                                ElevatedButton(
                                                              onPressed: () {
                                                                addtocart(
                                                                    products[
                                                                        index]);
                                                              },
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        vertical:
                                                                            10), // Thoda chhota size
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                ),
                                                                backgroundColor:
                                                                    Color.fromARGB(
                                                                        255,
                                                                        24,
                                                                        16,
                                                                        133),
                                                              ),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Icon(
                                                                      Icons
                                                                          .shopping_cart,
                                                                      color: Colors
                                                                          .white,
                                                                      size:
                                                                          18), // Icon ka size chhota
                                                                  SizedBox(
                                                                      width: 5),
                                                                  Text(
                                                                    "",
                                                                    style: TextStyle(
                                                                        fontSize: 11, // Text ka size chhota
                                                                        fontWeight: FontWeight.bold,
                                                                        color: Color.fromARGB(255, 24, 16, 133),
                                                                        backgroundColor: Colors.white),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                              width:
                                                                  10), // Space between button & arrow
                                                          Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      255,
                                                                      255,
                                                                      255),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                            child: IconButton(
                                                                onPressed: () {
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder: (context) =>
                                                                          ProductDetailPage(
                                                                              product: product),
                                                                    ),
                                                                  );
                                                                },
                                                                icon: Icon(
                                                                  Icons
                                                                      .arrow_forward,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          24,
                                                                          16,
                                                                          133),
                                                                ) // Chhota arrow icon
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ));
                                  }),
                            ),
                      // SizedBox(height: 20),
                      // Text("© 2025 laptopharbor - All Rights Reserved", style: TextStyle(fontSize: 14, color: const Color.fromARGB(255, 103, 114, 128))),
                      // SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
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
                          icon: Icon(
                            FontAwesomeIcons.facebook,
                            color: Color.fromARGB(255, 24, 16, 133),
                          ),
                          onPressed: () {}, // Add social links
                        ),
                        IconButton(
                          icon: Icon(FontAwesomeIcons.twitter,
                              color: Color.fromARGB(255, 24, 16, 133)),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(
                            FontAwesomeIcons.instagram,
                            color: Color.fromARGB(255, 24, 16, 133),
                          ),
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
                          child: Text("About Us",
                              style: TextStyle(color: Colors.black)),
                        ),
                        Text("|", style: TextStyle(color: Colors.grey)),
                        TextButton(
                          onPressed: () {},
                          child: Text("Contact",
                              style: TextStyle(color: Colors.black)),
                        ),
                      ],
                    ),

                    SizedBox(height: 5),

                    /// 📌 Copyright Text
                    Text(
                      "© 2025 LaptopHarbor. All Rights Reserved.",
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
