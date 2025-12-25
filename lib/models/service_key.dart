import 'package:harmonogram/models/day_type.dart';

class ServiceKey {
  final String lineId;
  final DayType dayType;

  const ServiceKey(this.lineId, this.dayType);

  @override
  bool operator ==(Object other) =>
      other is ServiceKey && other.lineId == lineId && other.dayType == dayType;

  @override
  int get hashCode => Object.hash(lineId, dayType);
}
