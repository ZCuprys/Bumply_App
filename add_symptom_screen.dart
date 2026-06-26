import 'dart:async'; //Future - ta wartość pojawi się później

import 'package:flutter/material.dart';
import 'package:bumply_app/gradient_container.dart';
import 'package:bumply_app/database/local_database.dart';

class AddSymptomScreen extends StatefulWidget { //konfiguracja ekranu
  final int userId;

  const AddSymptomScreen({
    super.key,
    required this.userId,
  });

  @override
  State<AddSymptomScreen> createState() { //stan dla ekranu
    return _AddSymptomScreenState();
  }
}

class _AddSymptomScreenState extends State<AddSymptomScreen> { //zmienne i logika
  late Future<List<Map<String, dynamic>>> symptomsFuture; //będzie przechowywać listę symptomów, pojawi się dopiero później bo trzeba pobrać z bazy

  final Set<int> selectedSymptomIds = {}; //zbiór ID symptomów, które są aktualnie zaznaczone na ekranie (bez duplikatów)
  final Map<int, int> existingEntryIdsBySymptomId = {}; //zapamiętuje, które symptomy były wcześniej zapisane w bazie

  static const Color buttonColor = Color.fromRGBO(158, 178, 255, 1);
  static const Color itemColor = Color.fromRGBO(158, 178, 255, 0.65);

  @override
  void initState() {
    super.initState();

    symptomsFuture = LocalDatabase.instance.getSymptoms(); //lista, z której bud. checbox
    loadExistingSymptomsForToday(); //sprawdź które zapisane dzisiaj
  }

  String getTodayDate() {
    return DateTime.now().toIso8601String().split('T').first; //zostawia tylko datę
  }

  Future<void> loadExistingSymptomsForToday() async { //pobiera dane z bazy ale ich nie zwróci
    final today = getTodayDate();

    final entries = await LocalDatabase.instance.getSymptomEntriesByDate(
      userId: widget.userId,
      entryDate: today,
    );

    if (!mounted) { //czy ekran dalej istnieje
      return;
    }

    setState(() { //zmienily sie dane, przebuduj ekran
      for (final entry in entries) { //po każdym wpisie z bazy
        final symptomId = entry['symptom_id'] as int;
        final entryId = entry['id'] as int;

        selectedSymptomIds.add(symptomId); //dodaj symp do aktualnie zaznaczonych
        existingEntryIdsBySymptomId[symptomId] = entryId; //symptomId->entryId
      }
    });
  }

  Future<void> saveSelectedSymptoms() async { //zapisz wybór użytkownika
    final selectedIds = Set<int>.from(selectedSymptomIds); //kopia aktualnie zaznaczonych
    final existingIds = existingEntryIdsBySymptomId.keys.toSet(); //Id tych co były zapisane

    if (selectedIds.isEmpty && existingIds.isEmpty) {
      showMessage('Select at least one symptom');
      return;
    }

    final symptomsToAdd = selectedIds.difference(existingIds); //odejmij te co były w bazie
    final symptomsToDelete = existingIds.difference(selectedIds); //do usuniecia

    final today = getTodayDate();

    for (final symptomId in symptomsToAdd) { //symptomy które trzeba dodać
      await LocalDatabase.instance.insertSymptomEntry( //dodaj dla:
        userId: widget.userId,
        symptomId: symptomId,
        entryDate: today,
      );
    }

    for (final symptomId in symptomsToDelete) {
      final entryId = existingEntryIdsBySymptomId[symptomId]; //szukaj Id

      if (entryId != null) {
        await LocalDatabase.instance.deleteSymptomEntry(entryId); //usuwanie wpisu
      }
    }

    if (!mounted) {
      return;
    }

    Navigator.pop(context); //zamykanie ekranu
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void toggleSymptom(int symptomId, bool? isSelected) {
    setState(() {
      if (isSelected == true) { //dodaj id do zbioru zaznaczonych
        selectedSymptomIds.add(symptomId);
      } else {
        selectedSymptomIds.remove(symptomId);//usun ze zbioru zaznaczonych
      }
    });
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),

                      const Expanded(
                        child: Text(
                          'Add symptom',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(width: 48),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Text(
                    getTodayDate(),
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: symptomsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text(
                              'No symptoms available',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          );
                        }

                        final symptoms = snapshot.data!;

                        return ListView.builder(
                          itemCount: symptoms.length,
                          itemBuilder: (context, index) {
                            final symptom = symptoms[index];

                            final symptomId = symptom['id'] as int;
                            final symptomName = symptom['name'] as String;

                            final isSelected =
                                selectedSymptomIds.contains(symptomId);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: itemColor,
                                  borderRadius: BorderRadius.circular(35),
                                ),
                                child: CheckboxListTile(
                                  value: isSelected,
                                  onChanged: (value) {
                                    toggleSymptom(symptomId, value);
                                  },
                                  title: Text(
                                    symptomName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                  activeColor: Colors.white,
                                  checkColor:
                                      const Color.fromRGBO(137, 168, 248, 1),
                                  controlAffinity:
                                      ListTileControlAffinity.trailing,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: 180,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: saveSelectedSymptoms,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(35),
                        ),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}