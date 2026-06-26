import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final String hintText; //tekst podpowiedzi wewnątrz pola
  final bool isPassword; //wpisywany tekst ukryty
  final TextEditingController? controller; //? - controller może być pusty, odczytywanie tekstu wpisanego

  const CustomInputField({
    super.key,
    required this.hintText, //pole obowiązkowe
    this.isPassword = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 265,
      height: 58,
      child: TextField(
        controller: controller,
        enabled: true,
        readOnly: false,
        canRequestFocus: true,
        keyboardType: TextInputType.visiblePassword,
        obscureText: isPassword,
        autocorrect: false,
        enableSuggestions: false,
        textInputAction: TextInputAction.next,
        
        cursorColor: Colors.white, 
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),

        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),

          filled: true,
          fillColor: const Color.fromRGBO(158, 178, 255, 1),
          contentPadding: const EdgeInsets.symmetric( //odstęp wewntrz pola
            horizontal: 26, //lewa i prawa
            vertical: 18, //góra i dół
          ),

          border: OutlineInputBorder( //kształt obramowania pola
            borderRadius: BorderRadius.circular(35),
            borderSide: BorderSide.none, //usuwa kreskę wokół pola
          ),

          enabledBorder: OutlineInputBorder( //kształt obramowania pola
            borderRadius: BorderRadius.circular(35),
            borderSide: BorderSide.none, //usuwa kreskę wokół pola
          ),

          focusedBorder: OutlineInputBorder( //kształt obramowania pola
            borderRadius: BorderRadius.circular(35),
            borderSide: BorderSide.none, //usuwa kreskę wokół pola
          ),
        ),
      ),
    );
  }
}