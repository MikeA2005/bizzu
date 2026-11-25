import 'package:cloud_firestore/cloud_firestore.dart';

// Modelo del perfil remoto asociado al UID creado por Firebase Authentication.
class UserModel {
  final String id;
  final String name;
  final String email;
  final List<String> deliverySchedules;

  UserModel({
    required this.id,
    required this.name,
    this.email = '',
    required this.deliverySchedules,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      id: doc.id,
      name: data['name'] ?? 'Vendedor Universitario',
      email: data['email'] ?? '',
      deliverySchedules: List<String>.from(
        data['deliverySchedules'] ?? ['Horario a convenir'],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'deliverySchedules': deliverySchedules,
    };
  }
}
