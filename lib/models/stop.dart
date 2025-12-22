class Stop {
  final String id;
  final String name;

  const Stop({required this.id, required this.name});

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  factory Stop.fromJson(Map<String, dynamic> json) {
    return Stop(id: json['id'] as String, name: json['name'] as String);
  }
}
