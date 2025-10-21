import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'Pokedex',
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'Pokemon',
                fontSize: 28,
                letterSpacing: 3.0
            ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFCC0000),
        elevation: 0
      ),
      body: const Center(
        child: Text(
            'Gotta catch \'em all!',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 24
          ),
        ),
      ),
      backgroundColor: Colors.white
    );
  }
}