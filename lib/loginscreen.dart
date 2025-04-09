import 'dart:convert';
import 'package:bookstore/logpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  bool _obscureText = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController email = TextEditingController();
  final TextEditingController name = TextEditingController();
  final TextEditingController password = TextEditingController();

  void loginuser() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: email.text.trim(), password: password.text.trim());

        final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

        final service_id = 'service_5g86zmi';
        final temp_id = 'template_0smjgbd';
        final user_id = 'nU1lwMpua0KKX2hoV';

        final response = await http.post(url,
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'service_id': service_id,
              'template_id': temp_id,
              'user_id': user_id,
              'template_params': {
                'from_name': name.text,
                'to_email': email.text,
                'message': 'this is testing message',
              }
            }));

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'name': name.text,
          'email': email.text,
          'password': password.text
        });

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Register successful!')));
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Login failed! $e')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields correctly!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          height: 1000,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
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
              SizedBox(height: 20),

              // 👇 Image added here
              Image.asset(
                'assets/images/login.png', // Replace with your image path
                width: 210,
                height: 200,
                fit: BoxFit.cover,
              ),

              SizedBox(height: 20),
              Text('Sign Up', style: GoogleFonts.sigmar(fontSize: 35)),
              Text('Create your account', style: TextStyle(fontSize: 15)),
              Padding(padding: EdgeInsets.only(top: 18.0)),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(padding: EdgeInsets.only(top: 18.0)),
                    SizedBox(
                      width: 320,
                      child: TextFormField(
                        controller: name,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          } else if (!RegExp(r'^[a-zA-Z\s]+$')
                              .hasMatch(value)) {
                            return 'Name must contain only alphabets';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color.fromARGB(52, 4, 66, 85),
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(
                              left: 10,
                              top: 7,
                              right: 10,
                            ),
                            child: FaIcon(FontAwesomeIcons.user),
                          ),
                          label: Text('Name'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(55, 235, 230, 230)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 10),
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: 18.0)),
                    SizedBox(
                      width: 320,
                      child: TextFormField(
                        controller: email,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          } else if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color.fromARGB(52, 4, 66, 85),
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(
                              left: 10,
                              top: 7,
                              right: 10,
                            ),
                            child: FaIcon(FontAwesomeIcons.envelope),
                          ),
                          label: Text('Email'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(55, 235, 230, 230)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 10),
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: 18.0)),
                    SizedBox(
                      width: 320,
                      child: TextFormField(
                        controller: password,
                        obscureText: _obscureText,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          } else if (value.length < 6) {
                            return 'Password should be at least 6 characters';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color.fromARGB(52, 4, 66, 85),
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(
                              left: 10,
                              top: 7,
                              right: 10,
                            ),
                            child: FaIcon(FontAwesomeIcons.key),
                          ),
                          labelText: 'Password',
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
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 24, 16, 133)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 10),
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                    SizedBox(
                      width: 220,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: loginuser,
                        child: Text('REGISTER',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 24, 16, 133),
                        ),
                      ),
                    ),
                    // Padding(padding: EdgeInsets.only(top: 17.0)),
                    // Text('OR'),
                    // Padding(padding: EdgeInsets.only(top: 17.0)),
                    // SizedBox(
                    //   width: 280,
                    //   height: 50,
                    //   child: ElevatedButton(
                    //     onPressed: () {
                    //       // TODO: Add Google Sign-In Logic
                    //     },
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: Colors.white,
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(25),
                    //       ),
                    //       elevation: 3,
                    //     ),
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: [
                    //         FaIcon(
                    //           FontAwesomeIcons.google,
                    //           color: Colors.red,
                    //           size: 22,
                    //         ),
                    //         SizedBox(width: 12),
                    //         Text(
                    //           "Continue with Google",
                    //           style: TextStyle(
                    //             color: Colors.black,
                    //             fontSize: 16,
                    //             fontWeight: FontWeight.w600,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    Padding(padding: EdgeInsets.only(top: 17.0)),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontSize: 16),
                            children: [
                              TextSpan(
                                text: "Already have an account? ",
                              ),
                              TextSpan(
                                text: "Login",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 24, 16, 133)),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Logpage()));
                                  },
                              ),
                            ],
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
      ),
    );
  }
}
