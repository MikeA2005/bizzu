import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bizzu/models/user_model.dart';

class AuthService {
  // Singleton: reutiliza una única instancia y evita abrir conexiones duplicadas.
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _usersRef = FirebaseFirestore.instance.collection(
    'users',
  );

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  // UID que identifica al usuario también dentro de las colecciones remotas.
  User? get currentFirebaseUser => _auth.currentUser;
  String get currentUserId => _auth.currentUser?.uid ?? '';

  /// Iniciar sesión con correo y contraseña
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      // No se modifica la contraseña: los espacios pueden ser parte de ella.
      password: password,
    );
  }

  /// Registrar usuario en Firebase Auth y crear su documento en la colección 'users'
  Future<UserCredential> signUp({
    required String name,
    required String email,
    required String password,
    List<String>? deliverySchedules,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final uid = credential.user!.uid;
    await credential.user!.updateDisplayName(name.trim());

    final newUser = UserModel(
      id: uid,
      name: name.trim(),
      email: email.trim(),
      deliverySchedules:
          deliverySchedules ??
          ['Lunes a Viernes: 10:00 - 14:00 (Campus Universitario)'],
    );

    await _usersRef.doc(uid).set(newUser.toMap());
    return credential;
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
