import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _logger = Logger();

  Future<String?> registerUser({required String email, required String password}) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return 'success';
    } on FirebaseAuthException catch (e) {
      _logger.w('Erro de autenticação no registo: ${e.code}');
      return e.message;
    } catch (e) {
      _logger.e('Erro desconhecido no registo', error: e);
      return e.toString();
    }
  }

  Future<String?> loginUser({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return 'success';
    } on FirebaseAuthException catch (e) {
      _logger.w('Erro de autenticação no login: ${e.code}');
      return e.message;
    } catch (e) {
      _logger.e('Erro desconhecido no login', error: e);
      return e.toString();
    }
  }

  Future<String?> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return 'success';
    } on FirebaseAuthException catch (e) {
      _logger.w('Erro ao redefinir senha: ${e.code}');
      return e.message;
    } catch (e) {
      _logger.e('Erro desconhecido ao redefinir senha', error: e);
      return e.toString();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}