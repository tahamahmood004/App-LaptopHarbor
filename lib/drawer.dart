import 'package:flutter/material.dart';
import 'package:bookstore/FAQPage.dart';
import 'package:bookstore/ProfileScreen.dart';
import 'package:bookstore/ServicesPage.dart';
import 'AboutUs.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.75,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          children: [
            // ✅ Drawer Header with Avatar & Close Button
            Container(
              color: Color.fromARGB(255, 24, 16, 133),
              padding:
                  EdgeInsets.only(top: 40, bottom: 20, left: 20, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                            'https://cdn-icons-png.flaticon.com/512/163/163850.png'),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Welcome, User!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),

            // ✅ List Items
            Expanded(
              child: ListView(
                children: [
                  drawerItem(Icons.home, "Home", () {
                    Navigator.pushReplacementNamed(context, '/home');
                  }),
                  drawerItem(Icons.person, "Profile", () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileScreen()));
                  }),
                  drawerItem(Icons.help_outline, "FAQ", () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => FAQPage()));
                  }),
                  drawerItem(Icons.build, "Services", () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ServicesPage()));
                  }),
                  drawerItem(Icons.person, "AboutUs", () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => AboutUsPage()));
                  }),
                  drawerItem(Icons.exit_to_app, "Logout", () {
                    // Logout logic
                  }),
                ],
              ),
            ),

            // ✅ Need Help Section
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  Text(
                    "Need Help?",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.phone, size: 18, color: Colors.black54),
                      SizedBox(width: 8),
                      Text("+1 (123) 456-7890",
                          style:
                              TextStyle(fontSize: 16, color: Colors.black54)),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.email, size: 18, color: Colors.black54),
                      SizedBox(width: 8),
                      Text("support@laptopharbor.com",
                          style:
                              TextStyle(fontSize: 16, color: Colors.black54)),
                    ],
                  ),
                  SizedBox(height: 15),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Drawer Item Widget (Reusable)
  Widget drawerItem(IconData icon, String text, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Color.fromARGB(255, 24, 16, 133)),
      title: Text(
        text,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
      tileColor: Colors.grey.shade100,
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    );
  }
}
