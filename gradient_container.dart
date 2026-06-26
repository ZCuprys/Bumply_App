import 'package:flutter/material.dart';

//kierunek gradientu
const startAlignment = Alignment.topCenter;
const endAlignment = Alignment.bottomCenter;

class GradientContainer extends StatelessWidget { //stworzony widget GradientContainer
 const GradientContainer(this.color1, this.color2, this.color3, {super.key}); //konstruktor 1

  const GradientContainer.blue({super.key}) //konstruktor 2
  : color1 = Colors.blue,
    color2 = Colors.lightBlue,
    color3 = Colors.white;

final Color color1; //final - po ustawieniu tego koloru nie można go już zmienić
final Color color2;
final Color color3;

@override
  Widget build(context) { //co wyświetlić na ekranie
    return Container(
      decoration: BoxDecoration( //dekoracje kontenera
        gradient: LinearGradient( 
          colors: [color1, color2, color3],
          begin: startAlignment,
          end: endAlignment,
        ),
      ),
    );
  }
}
