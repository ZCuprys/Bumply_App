import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import 'package:bumply_app/database/local_database.dart';
import 'package:bumply_app/helpers/report_helper.dart';
import 'package:bumply_app/helpers/report_pdf_helper.dart';

class ReportsPage extends StatefulWidget {
  final int userId;

  const ReportsPage({
    super.key,
    required this.userId,
  });

  @override
  State<ReportsPage> createState() {
    return _ReportsPageState();
  }
}

class _ReportsPageState extends State<ReportsPage> {
  DateTime startDate = DateTime.now().subtract(const Duration(days: 7)); //domyślnie zakres 7 dni
  DateTime endDate = DateTime.now();

  late Future<List<Map<String, dynamic>>> reportsFuture; //przechowuje przyszłą liste

  static const Color buttonColor = Color.fromRGBO(158, 178, 255, 1);
  static const Color textColor = Color.fromRGBO(96, 111, 160, 1);

  @override
  void initState() {
    super.initState();

    reportsFuture = LocalDatabase.instance.getReports( //przy wejściu pobiera historię
      userId: widget.userId,
    );
  }

  String formatDate(DateTime date) {
    return date.toIso8601String().split('T').first;
  }

  String formatCreatedAt(String createdAt) {
    final dateTime = DateTime.tryParse(createdAt);

    if (dateTime == null) {
      return createdAt;
    }

    final year = dateTime.year.toString();
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$year-$month-$day $hour:$minute';
  }

  Future<void> pickStartDate() async { //systemowy wybór daty
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      startDate = pickedDate;
    });
  }

  Future<void> pickEndDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      endDate = pickedDate;
    });
  }

  Future<void> generateReport() async {
    if (startDate.isAfter(endDate)) {
      showMessage('Start date cannot be after end date');
      return;
    }

    final startDateText = formatDate(startDate);
    final endDateText = formatDate(endDate);

    final symptomEntries =
        await LocalDatabase.instance.getSymptomEntriesBetweenDates(
      userId: widget.userId,
      startDate: startDateText,
      endDate: endDateText,
    );

    final summary = ReportHelper.generateReportSummary(
      startDate: startDateText,
      endDate: endDateText,
      symptomEntries: symptomEntries,
    );

    await LocalDatabase.instance.insertReport(
      userId: widget.userId,
      startDate: startDateText,
      endDate: endDateText,
      summary: summary,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      reportsFuture = LocalDatabase.instance.getReports(
        userId: widget.userId,
      );
    });

    showReportDialog(summary);
  }

  void showReportDialog(String summary) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Report generated'),
          content: SingleChildScrollView(
            child: Text(summary),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void showExistingReportDialog(String summary) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Report preview'),
          content: SingleChildScrollView(
            child: Text(summary),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> shareReportAsPdf({
    required String startDate,
    required String endDate,
    required String summary,
  }) async {
    final pdfBytes = await ReportPdfHelper.generateReportPdf(
      startDate: startDate,
      endDate: endDate,
      summary: summary,
    );

    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'bumply_report_${startDate}_$endDate.pdf',
    );
  }

  Future<void> deleteSelectedReport(int reportId) async {
  await LocalDatabase.instance.deleteReport(reportId);

  if (!mounted) {
    return;
  }

  setState(() {
    reportsFuture = LocalDatabase.instance.getReports(
      userId: widget.userId,
    );
  });

  showMessage('Report deleted');
  }

  void showDeleteReportDialog(int reportId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete report'),
          content: const Text(
            'Are you sure you want to delete this report?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context);
                deleteSelectedReport(reportId);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Widget buildDateBox({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(158, 178, 255, 0.55),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),

            const Text(
              'Reports',
              style: TextStyle(
                fontSize: 46,
                fontWeight: FontWeight.w300,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: buildDateBox(
                    title: 'Start date',
                    value: formatDate(startDate),
                    onTap: pickStartDate,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: buildDateBox(
                    title: 'End date',
                    value: formatDate(endDate),
                    onTap: pickEndDate,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            Center(
              child: SizedBox(
                width: 220,
                height: 60,
                child: ElevatedButton(
                  onPressed: generateReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(35),
                    ),
                  ),
                  child: const Text(
                    'Generate report',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 35),

            const Text(
              'History',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),

            const SizedBox(height: 14),

            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: reportsFuture,
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
                      'No reports generated yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color.fromRGBO(96, 111, 160, 0.75),
                      ),
                    );
                  }

                  final reports = snapshot.data!;

                  return ListView.builder(
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final report = reports[index];

                      final reportId = report['id'] as int;
                      final startDate = report['start_date'] as String;
                      final endDate = report['end_date'] as String;
                      final summary = report['summary'] as String;
                      final createdAt = report['created_at'] as String;
                      final createdAtText = formatCreatedAt(createdAt);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () {
                            showExistingReportDialog(summary);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(158, 178, 255, 0.35),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.description_outlined,
                                  color: textColor,
                                  size: 26,
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$startDate - $endDate',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: textColor,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        'Created: $createdAtText',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color.fromRGBO(96, 111, 160, 0.7),
                                        ),
                                      ),

                                      const SizedBox(height: 3),

                                      const Text(
                                        'Tap to preview',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color.fromRGBO(96, 111, 160, 0.65),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                IconButton(
                                  onPressed: () {
                                    shareReportAsPdf(
                                      startDate: startDate,
                                      endDate: endDate,
                                      summary: summary,
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.picture_as_pdf_outlined,
                                    color: textColor,
                                    size: 25,
                                  ),
                                ),
                                
                                IconButton(
                                  onPressed: () {
                                    showDeleteReportDialog(reportId);
                                  },
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: textColor,
                                    size: 26,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}