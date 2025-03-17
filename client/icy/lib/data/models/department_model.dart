class Department {
  final String id;
  final String name;
  final String? description;

  const Department({required this.id, required this.name, this.description});

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
    };
  }
}
