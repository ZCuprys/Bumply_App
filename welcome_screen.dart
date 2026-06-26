import 'package:flutter/material.dart';

import 'package:bumply_app/gradient_container.dart';
import 'package:bumply_app/sign_in_screen.dart';
import 'package:bumply_app/log_in_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold( //podstawowy szkielet ekranu
      body: Stack( //body - główna zawartość ekranu, Stack - układa elementy jeden na drugim
        children: [
          const GradientContainer(
            Color.fromRGBO(137, 168, 248, 1),
            Color.fromRGBO(201, 216, 250, 1),
            Color.fromRGBO(241, 246, 255, 1),
          ),

          SafeArea( //zawartość nie wchodzi pod górny pasek telefonu, aparat itp
            child: Column( //układa elementy pionowo
              children: [
                const SizedBox(height: 150), //robi pustą przestrzeń

                Row( //układa elementy poziomo
                  mainAxisAlignment: MainAxisAlignment.center, //cały rząd ma być wyśrodkowany
                  children: [
                    Image.asset( //logo
                      'assets/images/bumply_logo.png',
                      height: 240,
                    ),

                    const SizedBox(width: 10), //odstęp logo a tekst (width bo jesteśmy w row, nie height)

                    const Column( //kolumna tylko dla tekstu
                      crossAxisAlignment: CrossAxisAlignment.start, //tekst wyrównany do lewej strony
                      children: [
                        Text(
                          'Welcome',
                          style: TextStyle(
                            fontSize: 46,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Aboard',
                          style: TextStyle(
                            fontSize: 46,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                            height: 0.95,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 45),

              //PRZYCISKI

                SizedBox(
                  width: 200,
                  height: 65,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignInScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(158, 178, 255, 1),
                      foregroundColor: Colors.white, //kolor tekstu i ikon na przycisku
                      elevation: 6, //cień
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(35),
                      ),
                    ),
                    child: const Text(
                      'Start',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: 170,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LogInScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(158, 178, 255, 1),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Log in',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}