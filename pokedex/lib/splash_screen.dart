import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:pokedex/presentation/pages/home_page.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash:
      Column(
        children: [
          Center(
            child: LottieBuilder.asset(
                "assets/lottie/splash.json",
                width: 150,
                height: 150,
                fit: BoxFit.fill
            ),
          ),
        ],
      ),
      nextScreen: const HomePage(),
      splashIconSize: 400,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    );
  }
}
