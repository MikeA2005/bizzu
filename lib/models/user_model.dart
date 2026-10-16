class UserModel {
  final String id;
  final String name;
  final List<String> deliverySchedules;

  UserModel({
    required this.id,
    required this.name,
    required this.deliverySchedules,
  });

  UserModel copyWith({
    String? id,
    String? name,
    List<String>? deliverySchedules,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      deliverySchedules: deliverySchedules ?? this.deliverySchedules,
    );
  }
}
