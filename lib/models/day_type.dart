enum DayType { weekday, saturday, sundayHoliday }

extension DayTypeX on DayType {
  String get key {
    switch (this) {
      case DayType.weekday:
        return 'weekday';
      case DayType.saturday:
        return 'saturday';
      case DayType.sundayHoliday:
        return 'sundayHoliday';
    }
  }

  String get label {
    switch (this) {
      case DayType.weekday:
        return 'Powszednie';
      case DayType.saturday:
        return 'Sobota';
      case DayType.sundayHoliday:
        return 'Niedz/Święta';
    }
  }

  static DayType fromKey(String? key) {
    switch (key) {
      case 'saturday':
        return DayType.saturday;
      case 'sundayHoliday':
        return DayType.sundayHoliday;
      case 'weekday':
      default:
        return DayType.weekday;
    }
  }
}
