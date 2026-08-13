import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';


class AdLoadingPage extends StatelessWidget {
  const AdLoadingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2A), // Matches the dark app theme / splash color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/json/loading_ads.json',
              width: 150,
              height: 150,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const CircularProgressIndicator(
                  color: Colors.white,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
