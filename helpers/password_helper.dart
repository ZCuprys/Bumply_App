import 'dart:convert'; //kodowanie danych
import 'dart:math'; //bezpieczniejszy generator losowych wartości, potrzebny do wygenerowania soli

import 'package:crypto/crypto.dart'; //do algorytmów kryptograficznych (hash)

class PasswordHelper { //obsługuje hasła
  static String generateSalt() { //generuje losową sól, losowy ciąg znaków dodawany do hasła przed utworzeniem hasha
    final random = Random.secure();

    final values = List<int>.generate( //lista losowych wartości
      16,
      (_) => random.nextInt(256),
    );

    return base64Url.encode(values); //zmiana losowych bajtów soli na tekst
  }

  static String hashPassword(String password, String salt) { //zwraca hash hasła
    final bytes = utf8.encode('$password:$salt'); //łączenie hasła i soli

    return sha256.convert(bytes).toString(); //tworz. hasha
  }

  static bool verifyPassword({ //sprawdzenie czy hasło jest poprawne
    required String password,
    required String salt,
    required String hash,
  }) {
    final passwordHash = hashPassword(password, salt); //jesli takie same to ok

    return passwordHash == hash;
  }
}