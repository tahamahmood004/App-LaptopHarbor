import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? currentUser;
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    currentUser = _auth.currentUser;

    _auth.authStateChanges().listen((user) {
      if (user == null) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        setState(() {
          currentUser = user;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 24, 16, 133),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              // 🔹 Profile Details Section
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser!.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return Center(child: Text("User not found"));
                      }

                      var userData = snapshot.data!.data() as Map<String, dynamic>;
                      nameController.text = userData['name'] ?? "No Name";
                      emailController.text = userData['email'] ?? "No Email";

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Profile Details", 
                            style: TextStyle(
                              fontSize: 22, 
                              fontWeight: FontWeight.bold, 
                              color: Color.fromARGB(255, 24, 16, 133),
                            ),
                          ),
                          SizedBox(height: 15),
                          _buildTextField(nameController, "Full Name"),
                          SizedBox(height: 15),
                          _buildTextField(emailController, "Email"),
                          SizedBox(height: 15),
                          _buildPasswordField(),
                          SizedBox(height: 25),

                          // 🔹 Save Button
                          _buildButton("Save Changes", Color.fromARGB(255, 24, 16, 133), () {
                            if (_formKey.currentState!.validate()) {
                              _updateUser(currentUser!.uid);
                            }
                          }),

                          SizedBox(height: 15),

                          // 🔹 Logout Button
                          _buildButton("Logout", Colors.red, () async {
                            await _auth.signOut();
                          }),
                        ],
                      );
                    },
                  ),
                ),
              ),

              SizedBox(height: 30),

              // 🔹 Order Details Section
              Text("Your Orders",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 24, 16, 133)),
              ),
              SizedBox(height: 10),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('orders')
                    .where('userId', isEqualTo: currentUser!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No orders found"));
                  }

                  var orders = snapshot.data!.docs;

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      var orderData = orders[index].data() as Map<String, dynamic>;
                      String userId = orderData['userId'];

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                            return Center(child: Text("User not found"));
                          }

                          var userData = userSnapshot.data!.data() as Map<String, dynamic>;
                          String userName = userData['b_name'] ?? "bookName";

                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: Icon(Icons.shopping_cart, color: Colors.blue),
                              title: Text(userName),
                              subtitle: Text("totalAmount: \$${orderData['totalAmount']}\nStatus: ${orderData['status']}"),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Function to Update User Data
  void _updateUser(String userId) {
    FirebaseFirestore.instance.collection('users').doc(userId).update({
      'name': nameController.text,
      'email': emailController.text,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully!")),
      );
    });
  }

  // 🔹 Reusable TextField
  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) => value!.isEmpty ? "Enter your $label" : null,
    );
  }

  // 🔹 Password Field with Show/Hide
  Widget _buildPasswordField() {
    return TextFormField(
      controller: passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: "Password",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
    );
  }

  // 🔹 Reusable Button
  Widget _buildButton(String text, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(text, style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 15),
          textStyle: TextStyle(fontSize: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
