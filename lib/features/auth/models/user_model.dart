class UserModel {
  final String id;
  final String email;
  final String fullName;
  final DateTime? createdAt;
  final DateTime? dateOfBirth;
  final String? gender;
  final double? weightKg;
  final double? heightCm;
  final String? fitnessLevel;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.createdAt,
    this.dateOfBirth,
    this.gender,
    this.weightKg,
    this.heightCm,
    this.fitnessLevel,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? json['fullName'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'].toString())
          : null,
      gender: json['gender'],
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      heightCm: (json['height_cm'] as num?)?.toDouble(),
      fitnessLevel: json['fitness_level'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      if (dateOfBirth != null)
        'date_of_birth': dateOfBirth!.toIso8601String().split('T')[0],
      if (gender != null) 'gender': gender,
      if (weightKg != null) 'weight_kg': weightKg,
      if (heightCm != null) 'height_cm': heightCm,
      if (fitnessLevel != null) 'fitness_level': fitnessLevel,
    };
  }
}
