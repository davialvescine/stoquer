// utils/validators.dart
class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-mail é obrigatório';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'E-mail inválido';
    }
    return null;
  }

  static String? telefone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefone é obrigatório';
    }
    // Remove caracteres não numéricos
    final numeros = value.replaceAll(RegExp(r'[^\d]'), '');
    if (numeros.length < 10 || numeros.length > 11) {
      return 'Telefone inválido';
    }
    return null;
  }

  static String? naoVazio(String? value, String campo) {
    if (value == null || value.isEmpty) {
      return '$campo é obrigatório';
    }
    return null;
  }
}


