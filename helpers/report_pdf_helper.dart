import 'dart:typed_data'; //dostęp do danych binarnych (bajty)

import 'package:pdf/pdf.dart'; //dostęp do ustawień pdf
import 'package:pdf/widgets.dart' as pw; //dostęp do widgetów pdf pw dla odróżnienia od widgetów Flutter

class ReportPdfHelper { //Przygotowanie dokumetu pdf
  static Future<Uint8List> generateReportPdf({//generuje pdf
    required String startDate,
    required String endDate,
    required String summary,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            pw.Text(
              'Bumply',
              style: pw.TextStyle(
                fontSize: 28,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 8),

            pw.Text(
              'Pregnancy symptom report',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 16),

            pw.Text(
              'Period: $startDate - $endDate',
              style: const pw.TextStyle(
                fontSize: 13,
              ),
            ),

            pw.SizedBox(height: 8),

            pw.Text(
              'Generated on: ${DateTime.now().toIso8601String().split("T").first}', //odcina godzinę
              style: const pw.TextStyle(
                fontSize: 13,
              ),
            ),

            pw.SizedBox(height: 24),

            pw.Container( //kontener z treścią raportu
              width: double.infinity, //całą dostępną szerokość strony
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                  color: PdfColors.blueGrey200,
                ),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Text(
                summary,
                style: const pw.TextStyle(
                  fontSize: 12,
                  lineSpacing: 4,
                ),
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }
}