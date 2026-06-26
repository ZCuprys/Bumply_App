import 'package:flutter/material.dart';

import 'package:bumply_app/database/local_database.dart';

class CalendarScreen extends StatefulWidget {
  final int userId;

  const CalendarScreen({
    super.key,
    required this.userId,
  });

  @override
  State<CalendarScreen> createState() {
    return _CalendarScreenState();
  }
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime currentMonth;
  late DateTime selectedDate;

  late Future<List<Map<String, dynamic>>> selectedDateSymptomsFuture;

  Set<String> datesWithSymptoms = {};

  static const Color textColor = Color.fromRGBO(96, 111, 160, 1);
  static const Color lightBoxColor = Color.fromRGBO(158, 178, 255, 0.35);
  static const Color selectedDayColor = Color.fromRGBO(158, 178, 255, 1);

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    currentMonth = DateTime(now.year, now.month, 1);
    selectedDate = DateTime(now.year, now.month, now.day);

    selectedDateSymptomsFuture = loadSelectedDateSymptoms();

    loadDatesWithSymptomsForMonth();
  }

  String formatDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  String getMonthName(int month) {
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

    return months[month - 1];
  }

  Future<List<Map<String, dynamic>>> loadSelectedDateSymptoms() {
    return LocalDatabase.instance.getSymptomEntriesByDate(
      userId: widget.userId,
      entryDate: formatDate(selectedDate),
    );
  }

  Future<void> loadDatesWithSymptomsForMonth() async {
    final firstDayOfMonth = DateTime(
      currentMonth.year,
      currentMonth.month,
      1,
    );

    final lastDayOfMonth = DateTime(
      currentMonth.year,
      currentMonth.month + 1,
      0,
    );

    final entries = await LocalDatabase.instance.getSymptomEntriesBetweenDates(
      userId: widget.userId,
      startDate: formatDate(firstDayOfMonth),
      endDate: formatDate(lastDayOfMonth),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      datesWithSymptoms = entries
          .map((entry) => entry['entry_date'] as String)
          .toSet();
    });
  }

  void selectDate(DateTime date) {
    setState(() {
      selectedDate = date;
      selectedDateSymptomsFuture = loadSelectedDateSymptoms();
    });
  }

  void goToPreviousMonth() {
    final newMonth = DateTime(
      currentMonth.year,
      currentMonth.month - 1,
      1,
    );

    setState(() {
      currentMonth = newMonth;
      selectedDate = newMonth;
      selectedDateSymptomsFuture = loadSelectedDateSymptoms();
    });

    loadDatesWithSymptomsForMonth();
  }

  void goToNextMonth() {
    final newMonth = DateTime(
      currentMonth.year,
      currentMonth.month + 1,
      1,
    );

    setState(() {
      currentMonth = newMonth;
      selectedDate = newMonth;
      selectedDateSymptomsFuture = loadSelectedDateSymptoms();
    });

    loadDatesWithSymptomsForMonth();
  }

  Widget buildWeekdayLabels() {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Row(
      children: weekdays.map((weekday) {
        return Expanded(
          child: Center(
            child: Text(
              weekday,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget buildCalendarGrid() {
    final firstDayOfMonth = DateTime(
      currentMonth.year,
      currentMonth.month,
      1,
    );

    final daysInMonth = DateTime(
      currentMonth.year,
      currentMonth.month + 1,
      0,
    ).day;

    final emptyCellsBeforeMonth = firstDayOfMonth.weekday - 1;

    final totalCells = emptyCellsBeforeMonth + daysInMonth;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalCells,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        if (index < emptyCellsBeforeMonth) {
          return const SizedBox();
        }

        final dayNumber = index - emptyCellsBeforeMonth + 1;

        final date = DateTime(
          currentMonth.year,
          currentMonth.month,
          dayNumber,
        );

        return buildDayCell(date);
      },
    );
  }

  Widget buildDayCell(DateTime date) {
    final isSelected =
        formatDate(date) == formatDate(selectedDate);

    final hasSymptoms = datesWithSymptoms.contains(formatDate(date));

    return GestureDetector(
      onTap: () {
        selectDate(date);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? selectedDayColor : lightBoxColor,
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              date.day.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? Colors.white : textColor,
              ),
            ),

            if (hasSymptoms)
              Positioned(
                bottom: 7,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : textColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildSelectedDateSymptoms() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: selectedDateSymptomsFuture,
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
            'No symptoms for this day',
            style: TextStyle(
              fontSize: 16,
              color: Color.fromRGBO(96, 111, 160, 0.75),
            ),
          );
        }

        final symptoms = snapshot.data!;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: symptoms.map((symptom) {
            final symptomName =
                symptom['symptom_name'] as String? ?? 'Symptom';

            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: lightBoxColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                symptomName,
                style: const TextStyle(
                  fontSize: 15,
                  color: textColor,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final monthTitle =
        '${getMonthName(currentMonth.month)} ${currentMonth.year}';

    final selectedDateText = formatDate(selectedDate);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),

            const Text(
              'Calendar',
              style: TextStyle(
                fontSize: 46,
                fontWeight: FontWeight.w300,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 25),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(255, 255, 255, 0.18),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: goToPreviousMonth,
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: textColor,
                          size: 20,
                        ),
                      ),

                      Expanded(
                        child: Text(
                          monthTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                      ),

                      IconButton(
                        onPressed: goToNextMonth,
                        icon: const Icon(
                          Icons.arrow_forward_ios,
                          color: textColor,
                          size: 20,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  buildWeekdayLabels(),

                  const SizedBox(height: 12),

                  buildCalendarGrid(),
                ],
              ),
            ),

            const SizedBox(height: 28),

            Text(
              'Symptoms on $selectedDateText',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),

            const SizedBox(height: 14),

            Expanded(
              child: SingleChildScrollView(
                child: buildSelectedDateSymptoms(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}