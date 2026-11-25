import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bizzu/models/user_model.dart';

// Servicio que conecta los perfiles locales con la colección users remota.
class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final CollectionReference _usersRef = FirebaseFirestore.instance.collection(
    'users',
  );

  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';

  /// Obtiene el perfil del usuario autenticado desde Firestore
  Future<UserModel> getCurrentUser() async {
    final uid = currentUserId;
    if (uid.isEmpty) {
      return UserModel(
        id: '',
        name: 'Invitado',
        deliverySchedules: ['Horario a convenir'],
      );
    }
    return await getUserById(uid);
  }

  /// Stream en tiempo real del usuario autenticado
  Stream<UserModel> getCurrentUserStream() {
    final uid = currentUserId;
    if (uid.isEmpty) {
      return Stream.value(
        UserModel(
          id: '',
          name: 'Invitado',
          deliverySchedules: ['Horario a convenir'],
        ),
      );
    }
    return _usersRef.doc(uid).snapshots().map((doc) {
      if (!doc.exists) {
        return UserModel(
          id: uid,
          name: FirebaseAuth.instance.currentUser?.displayName ?? 'Usuario',
          email: FirebaseAuth.instance.currentUser?.email ?? '',
          deliverySchedules: ['Horario a convenir'],
        );
      }
      return UserModel.fromFirestore(doc);
    });
  }

  /// Obtiene cualquier vendedor por su UID desde Firestore
  Future<UserModel> getUserById(String id) async {
    if (id.isEmpty) {
      return UserModel(
        id: 'null',
        name: 'Vendedor Universitario',
        deliverySchedules: ['Horario a convenir'],
      );
    }
    final doc = await _usersRef.doc(id).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return UserModel(
      id: id,
      name: 'Vendedor Universitario',
      deliverySchedules: ['Horario a convenir'],
    );
  }
}
