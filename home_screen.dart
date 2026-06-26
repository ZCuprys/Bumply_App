import 'package:flutter/material.dart';

import 'package:bumply_app/database/local_database.dart';
import 'package:bumply_app/add_symptom_screen.dart';
import 'package:bumply_app/welcome_screen.dart';

class HomeScreen extends StatefulWidget {
  final int userId;

  const HomeScreen({
    super.key,
    required this.userId,
  });

  @override
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color buttonColor = Color.fromRGBO(158, 178, 255, 1);

  late Future<List<Map<String, dynamic>>> todaySymptomsFuture;

  @override
  void initState() {
    super.initState();

    todaySymptomsFuture = loadTodaySymptoms();
  }

  String getTodayDate() {
    return DateTime.now().toIso8601String().split('T').first;
  }

  String getMonthName() {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final now = DateTime.now();

    return months[now.month - 1];
  }

  Future<List<Map<String, dynamic>>> loadTodaySymptoms() {
    final today = getTodayDate();

    return LocalDatabase.instance.getSymptomEntriesByDate(
      userId: widget.userId,
      entryDate: today,
    );
  }

  Future<void> openAddSymptomScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddSymptomScreen(userId: widget.userId),
      ),
    );

    setState(() {
      todaySymptomsFuture = loadTodaySymptoms();
    });
  }

  void logOut() {          //usuwa całą historię ekranów i wraca do WelcomeScreen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const WelcomeScreen(),
      ),
      (route) => false,
    );
  }

  void showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Log out'),
          content: const Text(
            'Are you sure you want to log out?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                logOut();
              },
              child: const Text('Log out'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FutureBuilder<Map<String, dynamic>?>(
                  future: LocalDatabase.instance.getUserProfileById(widget.userId),
                  builder: (context, snapshot) {
                    final user = snapshot.data;

                    final displayName =
                        user?['display_name'] as String? ?? 'User';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hello,',
                          style: TextStyle(
                            fontSize: 46,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                          ),
                        ),

                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 40,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                            height: 0.9,
                          ),
                        ),
                      ],
                    );
                  },
                ),

                IconButton(
                  onPressed: showLogoutDialog,
                  icon: const Icon(
                    Icons.logout_outlined,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 80),

            Center(
              child: Container(
                width: 190,
                height: 190,
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(158, 178, 255, 0.65),
                  shape: BoxShape.circle,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      now.day.toString(),
                      style: const TextStyle(
                        fontSize: 70,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                        height: 0.9,
                      ),
                    ),

                    Text(
                      getMonthName(),
                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                        height: 0.9,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            Center(
              child: SizedBox(
                width: 200,
                height: 60,
                child: ElevatedButton(
                  onPressed: openAddSymptomScreen,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(35),
                    ),
                  ),
                  child: const Text(
                    'Add symptom',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 45),

            const Text(
              'Today\'s symptoms',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w400,
                color: Color.fromRGBO(96, 111, 160, 1),
              ),
            ),

            const SizedBox(height: 12),

            FutureBuilder<List<Map<String, dynamic>>>(
              future: todaySymptomsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text(
                    'No symptoms added today',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color.fromRGBO(96, 111, 160, 0.75),
                    ),
                  );
                }

                final symptoms = snapshot.data!;

                final visibleSymptoms = symptoms.take(4).toList();
                final hiddenSymptomsCount = symptoms.length - visibleSymptoms.length;

                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ...visibleSymptoms.map((symptom) {
                      final symptomName =
                          symptom['symptom_name'] as String? ?? 'Symptom';

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(158, 178, 255, 0.35),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          symptomName,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color.fromRGBO(96, 111, 160, 1),
                          ),
                        ),
                      );
                    }),

                    if (hiddenSymptomsCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(158, 178, 255, 0.25),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          '+$hiddenSymptomsCount more',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color.fromRGBO(96, 111, 160, 1),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}


