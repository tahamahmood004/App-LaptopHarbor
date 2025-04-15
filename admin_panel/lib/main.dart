import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/category.dart';
import 'package:myapp/feedback.dart';
import 'package:myapp/firebase_options.dart';
import 'package:myapp/orders.dart';
import 'package:myapp/product.dart';
import 'package:myapp/read_data.dart';
import 'package:myapp/subscribers.dart';
import 'package:myapp/wishlist.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white),
        ),
        appBarTheme: AppBarTheme(
          color: Color.fromARGB(255, 24, 16, 133),
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      home: AdminScreen(),
    );
  }
}

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int userCount = 0;
  int bookCount = 0;
  int categoryCount = 0;
  int orderCount = 0; // New variable for order count
  Map<String, int> categoryBookCount =
      {}; // To store the count of books per category
  List<String> categoryIds =
      []; // List to store category IDs for dynamic fetching
  Map<String, String> categoryNames = {}; // To store category name by id

  @override
  void initState() {
    super.initState();
    fetchCounts();
  }

  // Fetch the count of users, books, categories, orders, and books in each category
  void fetchCounts() async {
    final userSnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    setState(() {
      userCount = userSnapshot.docs.length;
    });

    final bookSnapshot =
        await FirebaseFirestore.instance.collection('products').get();
    setState(() {
      bookCount = bookSnapshot.docs.length;
    });

    final orderSnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .get(); // Fetch orders count
    setState(() {
      orderCount = orderSnapshot.docs.length;
    });

    final categorySnapshot =
        await FirebaseFirestore.instance.collection('categories').get();
    setState(() {
      categoryCount = categorySnapshot.docs.length;
      categoryIds = categorySnapshot.docs
          .map((doc) => doc.id)
          .toList(); // Fetch category IDs
    });

    fetchCategoryCounts();
    fetchCategoryNames();
  }

  void fetchCategoryCounts() async {
    final bookSnapshot =
        await FirebaseFirestore.instance.collection('products').get();
    Map<String, int> categoryCounts = {};

    for (var doc in bookSnapshot.docs) {
      final categoryId =
          doc['cat_id']; // Assuming 'cat_id' links to the category of the book

      if (categoryCounts.containsKey(categoryId)) {
        categoryCounts[categoryId] = categoryCounts[categoryId]! + 1;
      } else {
        categoryCounts[categoryId] = 1;
      }
    }

    setState(() {
      categoryBookCount = categoryCounts;
    });
  }

  void fetchCategoryNames() async {
    Map<String, String> names = {};
    for (String categoryId in categoryIds) {
      final categoryDoc = await FirebaseFirestore.instance
          .collection('categories')
          .doc(categoryId)
          .get();
      names[categoryId] = categoryDoc['category'];
    }

    setState(() {
      categoryNames = names;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        backgroundColor: Color.fromARGB(255, 24, 16, 133),
      ),
      drawer: DashboardDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Remove the banner section as requested
            SizedBox(height: 15),

//          Row(
//   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//   children: [
//     _buildRectangularCard(
//       imageUrl: 'https://res.cloudinary.com/dlgodph8a/image/upload/v1741325148/female_c88eyn.png', // Replace with your image URL
//       title: 'Users',
//       count: userCount,
//       color: Color.fromARGB(255, 4, 66, 85),
//     ),
//     _buildRectangularCard(
//       imageUrl: 'https://res.cloudinary.com/dlgodph8a/image/upload/v1741325577/istockphoto-1340317860-612x612_ceo5bl.jpg', // Replace with your image URL
//       title: 'Books',
//       count: bookCount,
//       color: Color.fromARGB(255, 4, 66, 85),
//     ),
//     _buildRectangularCard(
//       imageUrl: 'https://res.cloudinary.com/dlgodph8a/image/upload/v1741325815/istockphoto-1413549071-612x612_rltnaz.jpg', // Replace with your image URL
//       title: 'Categories',
//       count: categoryCount,
//       color: Color.fromARGB(255, 4, 66, 85),
//     ),
//     _buildRectangularCard(
//       imageUrl: 'https://res.cloudinary.com/dlgodph8a/image/upload/v1741326764/images_e4d0kz.png', // Replace with your image URL
//       title: 'Orders',
//       count: orderCount,
//       color: Color.fromARGB(255, 4, 66, 85),
//     ),
//   ],
// ),

            // Second Row - Category Count Cards
            Expanded(
              child: GridView.builder(
                itemCount: categoryIds.length, // Dynamically load categories
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 20,
                  childAspectRatio:
                      2.1, // Adjusting aspect ratio for rectangular cards
                ),
                itemBuilder: (context, index) {
                  String categoryId = categoryIds[index];
                  String categoryName =
                      categoryNames[categoryId] ?? 'Unknown Category';

                  return InkWell(
                    onTap: () {
                      // Navigate to the books screen for the selected category
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BooksByCategoryScreen(
                              categoryId: categoryId, catname: categoryName),
                        ),
                      );
                    },
                    child: _buildInfoCard(
                      icon: Icons.category,
                      title: 'Category: $categoryName',
                      count: categoryBookCount[categoryId] ?? 0,
                      gradientColors: [
                        Color.fromARGB(255, 255, 255, 255),
                        Color.fromARGB(255, 184, 230, 251)
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRectangularCard({
    required String imageUrl, // Accepting image URL
    required String title,
    required int count,
    required Color color,
  }) {
    return Card(
      color: color,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Circular image
            CircleAvatar(
              radius: 30, // Adjust the size of the circular image
              backgroundImage: NetworkImage(
                  imageUrl), // Use NetworkImage to load image from URL
            ),
            SizedBox(height: 7),
            Text(
              title,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Text(
              '$count',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to create regular cards (for category counts)
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required int count,
    required List<Color> gradientColors,
  }) {
    return Card(
      elevation:
          gradientColors.isEmpty ? 0 : 5, // Only add shadow to gradient cards
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradientColors.isEmpty
              ? null
              : LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(19),
          boxShadow: gradientColors.isEmpty
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 6,
                    spreadRadius: 2,
                    offset: Offset(4, 4),
                  ),
                ],
        ),
        child: Center(
          child: ListTile(
            leading: Icon(icon, color: Colors.black, size: 32),
            title: Text(title,
                style: TextStyle(color: Colors.black, fontSize: 12)),
            subtitle: Text(count.toString(),
                style: TextStyle(color: Colors.black, fontSize: 28)),
          ),
        ),
      ),
    );
  }
}

class BooksByCategoryScreen extends StatelessWidget {
  final String categoryId;
  final String catname;
  const BooksByCategoryScreen(
      {super.key, required this.categoryId, required this.catname});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Books in Category: $catname'),
        backgroundColor: Color.fromARGB(255, 24, 16, 133),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('products')
            .where('cat_id', isEqualTo: categoryId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No books available in this category.'));
          }
          final books = snapshot.data!.docs;

          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              var book = books[index];
              return ListTile(
                title: Text(book['b_name']),
                subtitle: Text(book['b_desc']),
              );
            },
          );
        },
      ),
    );
  }
}

class DashboardDrawer extends StatelessWidget {
  const DashboardDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.7),
              spreadRadius: 5,
              blurRadius: 15,
              offset: Offset(4, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 24, 16, 133),
              ),
              accountName: Text('Admin', style: TextStyle(color: Colors.white)),
              accountEmail: Text('Admin@gmail.com',
                  style: TextStyle(color: Colors.white)),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(
                    'https://png.pngtree.com/png-vector/20230822/ourmid/pngtree-flat-icon-vector-illustration-of-a-man-in-yellow-png-image_6835640.png'),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.person, color: Colors.white),
                    title: Text('User Management',
                        style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => FetchData()));
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.book, color: Colors.white),
                    title: Text('Product Management',
                        style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Product()));
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.category, color: Colors.white),
                    title: Text('Categories',
                        style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Categorydata()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.category, color: Colors.white),
                    title:
                        Text('orders', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Orders()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.feedback, color: Colors.white),
                    title:
                        Text('feedback', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FeedbackDemo()),
                      );
                    },
                  ),
                  ListTile(
                    leading:
                        Icon(Icons.heart_broken_rounded, color: Colors.white),
                    title:
                        Text('wishlist', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Wishlist()),
                      );
                    },
                  ),
                  ListTile(
                    leading:
                        Icon(Icons.verified_user_outlined, color: Colors.white),
                    title: Text('suscribers',
                        style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Subscribers()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.logout, color: Colors.white),
                    title:
                        Text('Logout', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      // Logout functionality can go here
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
