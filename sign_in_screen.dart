import 'package:flutter/material.dart';
import 'package:bumply_app/text_field.dart';
import 'package:bumply_app/main_navigation_screen.dart';
import 'package:bumply_app/gradient_container.dart';
import 'package:bumply_app/database/local_database.dart';
import 'package:bumply_app/helpers/password_helper.dart';

class SignInScreen extends StatefulWidget { //na ten moment nie zapisuje jeszcze loginu ani hasła do zmiennych — tylko wyświetlasz pola.
  const SignInScreen({super.key});

   @override
  State<SignInScreen> createState() { //tworzy obiekt stanu
    return _SignInScreenState();
  }
}

class _SignInScreenState extends State<SignInScreen> {
  final loginController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  static const Color buttonColor = Color.fromRGBO(158, 178, 255, 1);

  @override
  void dispose() { //ekran usuniety z pamięci
    loginController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> createLocalUser() async {
    final login = loginController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (login.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      showMessage('Fill in all fields');
      return;
    }

    if (password != confirmPassword) {
      showMessage('Passwords are not the same');
      return;
    }

    final existingUser = await LocalDatabase.instance.getUserByLogin(login);

    if (existingUser != null) {
      showMessage('User already exists');
      return;
    }

    final salt = PasswordHelper.generateSalt();
    final passwordHash = PasswordHelper.hashPassword(password, salt);

    final userId = await LocalDatabase.instance.createUserProfile(
      login: login,
      displayName: login,
      passwordHash: passwordHash,
      passwordSalt: salt,
    );

    if (!mounted) { // sprawdza, czy ekran nadal istnieje
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainNavigationScreen(userId: userId),
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

                  const SizedBox(height: 80),

                  const Text(
                    'Sign in',
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 30),

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

                  const SizedBox(height: 18),

                  CustomInputField(
                    hintText: 'Confirm password',
                    isPassword: true,
                    controller: confirmPasswordController,
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: 150,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: createLocalUser,
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