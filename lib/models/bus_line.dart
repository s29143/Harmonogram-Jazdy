class BusLine {
  final String id;
  final String z;
  final String number;
  final int stopsCount;

  const BusLine({
    required this.id,
    required this.z,
    required this.number,
    required this.stopsCount,
  });

  BusLine copyWith({String? id, String? z, String? number, int? stopsCount}) {
    return BusLine(
      id: id ?? this.id,
      z: z ?? this.z,
      number: number ?? this.number,
      stopsCount: stopsCount ?? this.stopsCount,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'z': z,
    'number': number,
    'stopsCount': stopsCount,
  };

  factory BusLine.fromJson(Map<String, dynamic> json) {
    return BusLine(
      id: json['id'] as String,
      z: json['z'] as String,
      number: json['number'] as String,
      stopsCount: (json['stopsCount'] as num).toInt(),
    );
  }
}
