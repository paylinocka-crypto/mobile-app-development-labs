import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

class PasswordHasher {
  PasswordHasher()
    : _algorithm = Pbkdf2.hmacSha256(iterations: 150000, bits: 256);

  final Pbkdf2 _algorithm;
  final Random _random = Random.secure();

  String _randomString(int length) {
    final bytes = List<int>.generate(length, (_) => _random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  String generateSalt() => _randomString(16);

  String generateId() => _randomString(16);

  Future<String> hash(String password, String salt) async {
    final key = await _algorithm.deriveKeyFromPassword(
      password: password,
      nonce: base64Url.decode(salt),
    );

    return base64UrlEncode(await key.extractBytes());
  }

  Future<bool> verify(String password, String salt, String expectedHash) async {
    final actual = base64Url.decode(await hash(password, salt));
    final expected = base64Url.decode(expectedHash);

    if (actual.length != expected.length) {
      return false;
    }

    var difference = 0;
    for (var i = 0; i < actual.length; i++) {
      difference |= actual[i] ^ expected[i];
    }

    return difference == 0;
  }
}
