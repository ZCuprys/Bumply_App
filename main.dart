import 'package:flutter/material.dart'; //dostęp do podstawowych elementów MaterialDesign(BuildContext, Scaffold, Colors, IconButton itp.)
import 'package:bumply_app/welcome_screen.dart';

void main() {
  runApp(const BumplyApp()); //Nic nie zwraca, uruchamia aplikację
                            //BumplyApp zostaje "korzeniem" drzewa Widgetów, jest stały (const)
}

class BumplyApp extends StatelessWidget { //własny widget - sam z siebie się nie zmienia
  const BumplyApp({super.key}); //konstruktor klasy

  @override
  Widget build(BuildContext context) { //metoda build - co ma być wyświetlone na ekranie
    return const MaterialApp( //główny widget kofiguracyjny, właściwość home ustawia pierwszy ekran aplikacji
      debugShowCheckedModeBanner: false, //usuwa czerwoną wstążkę DEBUG z rogu ekranu
      home: WelcomeScreen(), //pierwszy ekran aplikacji
    );
  }
}


