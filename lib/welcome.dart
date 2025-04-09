import 'package:bookstore/logpage.dart';
import 'package:flutter/material.dart';


class welcome extends StatefulWidget {
  final String username;
  const welcome({super.key,required this.username });

  @override
  State<welcome> createState() => _welcomeState();
}

class _welcomeState extends State<welcome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome')),
      body: Column(
        children: [
          Text(
          'Welcome, ${widget.username}!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        ElevatedButton(onPressed: (){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (builder) => Logpage()));
        }, child: Text('Logout'))
        ],
      ),
    );
  }
}