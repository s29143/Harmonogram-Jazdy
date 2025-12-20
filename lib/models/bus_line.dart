class BusLine {
  final String id;
  final String z;
  final String number;

  const BusLine({required this.id, required this.z, required this.number});

  BusLine copyWith({String? id, String? z, String? number}) {
    return BusLine(
      id: id ?? this.id,
      z: z ?? this.z,
      number: number ?? this.number,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'z': z, 'number': number};

  factory BusLine.fromJson(Map<String, dynamic> json) {
    return BusLine(
      id: json['id'] as String,
      z: json['z'] as String,
      number: json['number'] as String,
    );
  }
}
