import 'package:bizzu/models/user_model.dart';
import 'package:flutter/material.dart';

class UserService extends ChangeNotifier {
  // Singleton pattern, so we can access the same instance of UserService throughout the app
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  // User data
  final Map<String, UserModel> _users = {
    '1': UserModel(
      id: '1',
      name: 'Miguel',
      deliverySchedules: [
        'Lunes y Miércoles: 10:00 - 12:00',
        'Viernes: 14:00 - 16:00',
      ],
    ),
    '2': UserModel(
      id: '2',
      name: 'Ana',
      deliverySchedules: [
        'Martes y Jueves: 09:00 - 11:00',
        'Sábado: 15:00 - 17:00',
      ],
    ),
    '3': UserModel(
      id: '3',
      name: 'Carlos',
      deliverySchedules: [
        'Lunes a Viernes: 08:00 - 10:00',
        'Sábado: 12:00 - 14:00',
      ],
    ),
  };

  final String _currentUserId = '1'; // Simulating a logged-in user

  // Get the current user
  UserModel get currentUser => _users[_currentUserId]!;

  // Get a user by ID
  UserModel getUserById(String id) {
    return _users[id] ??
        UserModel(
          id: 'null',
          name: 'Vendedor Universitario',
          deliverySchedules: ['Horario a convenir'],
        );
  }
}
