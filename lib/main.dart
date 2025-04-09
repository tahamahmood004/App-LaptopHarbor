import 'package:bookstore/firebase_options.dart';
import 'package:bookstore/home.dart';
import 'package:bookstore/loginscreen.dart';
import 'package:bookstore/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';



class myapp extends StatefulWidget {
  
  const myapp({super.key});

  @override
  State<myapp> createState() => _myappState();
}

class _myappState extends State<myapp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: TextTheme(
         bodyMedium: GoogleFonts.quicksand(),
         bodySmall: GoogleFonts.quicksand(),
         bodyLarge: GoogleFonts.quicksand()
        )
      ),
      debugShowCheckedModeBanner: false,
       initialRoute: '/splash',
      routes: {
        '/splash':(context)=>Splash(),
        '/home': (context) => homepage(username: ''),
        '/login': (context) => login(),
      },
    );
  }
}


  

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
 await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(myapp());
}