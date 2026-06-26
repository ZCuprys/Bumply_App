import 'package:flutter/material.dart';
import 'package:bumply_app/text_field.dart';
import 'package:bumply_app/gradient_container.dart';
import 'package:bumply_app/main_navigation_screen.dart';
import 'package:bumply_app/database/local_database.dart';
import 'package:bumply_app/helpers/password_helper.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

   @override
  State<LogInScreen> createState() {
    return _LogInScreenState();
  }
}

  class _LogInScreenState extends State<LogInScreen> {
  final loginController = TextEditingController();
  final passwordController = TextEditingController();

  static const Color buttonColor = Color.fromRGBO(158, 178, 255, 1);

  @override
  void dispose() {
    loginController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  Future<void> logInLocalUser() async {
    final login = loginController.text.trim();
    final password = passwordController.text;

    if (login.isEmpty || password.isEmpty) {
      showMessage('Fill in all fields');
      return;
    }

    final user = await LocalDatabase.instance.getUserByLogin(login);

    if (user == null) {
      showMessage('User does not exist');
      return;
    }

    final passwordSalt = user['password_salt'] as String;
    final passwordHash = user['password_hash'] as String;

    final isPasswordCorrect = PasswordHelper.verifyPassword(
      password: password,
      salt: passwordSalt,
      hash: passwordHash,
    );

    if (!isPasswordCorrect) {
      showMessage('Incorrect password');
      return;
    }

    if (!mounted) {
      return;
    }

    final userId = user['id'];
    
    if (userId == null) {
      showMessage('User ID not found');
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainNavigationScreen(userId: userId as int),
      ),
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const GradientContainer(
            Color.fromRGBO(137, 168, 248, 1),
            Color.fromRGBO(201, 216, 250, 1),
            Color.fromRGBO(241, 246, 255, 1),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.home_outlined,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),

                  const SizedBox(height: 110),

                  const Text(
                    'Log in',
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 35),

                  CustomInputField(
                    hintText: 'Login',
                    controller: loginController,
                  ),

                  const SizedBox(height: 18),

                  CustomInputField(
                    hintText: 'Password',
                    isPassword: true,
                    controller: passwordController,
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: 150,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: logInLocalUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Go',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
