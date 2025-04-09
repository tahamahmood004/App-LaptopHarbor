import 'package:bookstore/drawer.dart';
import 'package:bookstore/home.dart';
import 'package:bookstore/loginscreen.dart';
import 'package:bookstore/welcome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class Logpage extends StatefulWidget {
  const Logpage({super.key});

  @override
  State<Logpage> createState() => _LogpageState();
}

class _LogpageState extends State<Logpage> {
  bool _obscureText = true;

  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  void loginuser() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: email.text.trim(), password: password.text.trim());

        final data = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (data.exists) {
          String username = data['name'];

          final String userId = userCredential.user!.uid;

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('username', username);
          await prefs.setBool('isLoggedIn', true);
          if (userId != null) {
            await prefs.setString('userId', userId);
            print("User ID: $userId");
          } else {
            print("User ID field does not exist in Firestore.");
          }
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (builder) => homepage(username: username)));
        }
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Login failed! $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        child: Container(
          height: 1000,
          decoration: BoxDecoration(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              Image.asset(
                'assets/images/login2.png',
                height: 210,
                fit: BoxFit.contain,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    child: Icon(
                      Icons.arrow_back,
                      size: 30,
                      color: Colors.black,
                    ),
                  )
                ],
              ),
              Padding(padding: EdgeInsets.only(top: 18.0)),
              Text('Login', style: GoogleFonts.sigmar(fontSize: 35)),
              Text('login yourself!', style: TextStyle(fontSize: 15)),
              Padding(padding: EdgeInsets.only(top: 18.0)),
              Padding(padding: EdgeInsets.only(top: 18.0)),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(padding: EdgeInsets.only(top: 18.0)),
                    SizedBox(
                      width: 320,
                      child: TextFormField(
                        controller: email,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color.fromARGB(52, 4, 66, 85),
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(left: 10, top: 7, right: 10),
                            child: FaIcon(FontAwesomeIcons.envelope),
                          ),
                          label: Text('Email'),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: const Color.fromARGB(55, 235, 230, 230)),
                              borderRadius: BorderRadius.circular(10)),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                        ),
                        validator: (value) {
                          String emailValue = value?.trim() ?? '';  // Trim any leading/trailing spaces
                          if (emailValue.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(emailValue)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: 18.0)),
                    SizedBox(
                      width: 320,
                      child: TextFormField(
                        controller: password,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color.fromARGB(52, 4, 66, 85),
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(left: 10, top: 7, right: 10),
                            child: FaIcon(FontAwesomeIcons.key),
                          ),
                          prefixIconConstraints: BoxConstraints(minWidth: 50),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Color.fromARGB(255, 24, 16, 133)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 40),
                    SizedBox(
                      width: 220,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: loginuser,
                        child: Text('LOGIN', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 24, 16, 133),
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: 17.0)),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (builder) => login()));
                      },
                      child: Text('click here to create account'),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}