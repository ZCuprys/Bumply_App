class ReportHelper {
  static String generateReportSummary({ //generuje podsumowanie raportu
    required String startDate,
    required String endDate,
    required List<Map<String, dynamic>> symptomEntries, //lista symptomów pobrana z bazy
  }) {
    final buffer = StringBuffer(); //budowanie dłuższego tekstu kawałek po kawałku.

    buffer.writeln('Pregnancy symptom report');
    buffer.writeln('');
    buffer.writeln('Period: $startDate - $endDate');
    buffer.writeln('');

    if (symptomEntries.isEmpty) { //czy lista symptomów jest pusta
      buffer.writeln('No symptoms were recorded in this period.');
      return buffer.toString();
    }

    final symptomCounts = <String, int>{}; //mapa liczy, ile razy wystąpił dany symptom
    final symptomsByDate = <String, List<String>>{}; //mapa grupuje symptomy według daty

    for (final entry in symptomEntries) {
      final date = entry['entry_date'] as String? ?? ''; //jako string ale może też byćnull
      final symptomName = entry['symptom_name'] as String? ?? 'Unknown symptom'; //?? - wpisz umknow symptom

      symptomCounts[symptomName] = (symptomCounts[symptomName] ?? 0) + 1; //jeśli symptom jeszcze nie istnieje w mapie → weź 0 i dodaj 1
                                                                          //jeśli symptom już istnieje → weź obecną liczbę i dodaj 1

      if (!symptomsByDate.containsKey(date)) { //grupuje symptomy według dnia
        symptomsByDate[date] = [];
      }

      symptomsByDate[date]!.add(symptomName); //! - dla tej daty lista już istnieje
    }

    buffer.writeln('Symptoms summary:');

    final sortedSymptomNames = symptomCounts.keys.toList()..sort();

    for (final symptomName in sortedSymptomNames) {
      final count = symptomCounts[symptomName] ?? 0;

      buffer.writeln('- $symptomName: $count');
    }

    buffer.writeln('');
    buffer.writeln('Daily details:');

    final sortedDates = symptomsByDate.keys.toList()..sort();

    for (final date in sortedDates) {
      final symptoms = symptomsByDate[date]!;
      symptoms.sort();

      buffer.writeln('- $date: ${symptoms.join(', ')}');
    }

    return buffer.toString();
  }
}