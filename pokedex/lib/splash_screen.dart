import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:pokedex/presentation/pages/podex_page.dart';
import 'package:page_transition/page_transition.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash:
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
              "assets/gif/rotom.gif",
              width: 300,
              height: 300,
              fit: BoxFit.contain,
              gaplessPlayback: true,
            ),
          ),
          Text(
            'Pokedex',
            style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
              fontSize: 32,
            ),
          ),
        ],
      ),
      nextScreen: const PokedexPage(),
      splashIconSize: 400,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      duration: 3000,
      splashTransition: SplashTransition.scaleTransition,
      pageTransitionType: PageTransitionType.fade,
    );
  }
}
