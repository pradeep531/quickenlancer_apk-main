import 'package:flutter/material.dart';
import 'package:quickenlancer_apk/Colors/colorfile.dart';

import '../home_page.dart';

class PostProjectFinal extends StatelessWidget {
  const PostProjectFinal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colorfile.body,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Post Project',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colorfile.textColor,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.withOpacity(0.1),
              Colors.pink.withOpacity(0.1),
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
                border: Border.all(
                  color: Color(0xFFE5ACCB), // Hex color #E5ACCB
                  width: 1.0, // 1px border width
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/tick.png',
                    width: 150,
                    height: 130,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Congratulations,\nYou Are Almost Done!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colorfile.textColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Thank you so much for posting your requirement, Quicklancer team is reviewing your requirement detail and will notify shortly.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colorfile.textColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MyHomePage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colorfile.textColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'GO BACK HOME',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
