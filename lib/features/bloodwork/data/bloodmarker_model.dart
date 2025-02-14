class BloodMarker {
  BloodMarker({
    required this.name,
    required this.value,
    required this.unit,
    required this.minRange,
    required this.maxRange,
    required this.category,
  });

  factory BloodMarker.fromJson(Map<String, dynamic> json) {
    return BloodMarker(
      name: json['name'] as String,
      value: json['value'] as double,
      unit: json['unit'] as String,
      minRange: json['minRange'] as double,
      maxRange: json['maxRange'] as double,
      category: json['category'] as BloodMarkerCategory,
    );
  }

  final String name;
  final double value;
  final String unit;
  final double minRange;
  final double maxRange;
  final BloodMarkerCategory category;

  bool get isNormal => value >= minRange && value <= maxRange;

  double get percentageFromRange {
    final range = maxRange - minRange;
    final position = value - minRange;
    return (position / range) * 100;
  }

  BloodMarker copyWith({
    String? name,
    double? value,
    String? unit,
    double? minRange,
    double? maxRange,
    BloodMarkerCategory? category,
  }) {
    return BloodMarker(
      name: name ?? this.name,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      minRange: minRange ?? this.minRange,
      maxRange: maxRange ?? this.maxRange,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      'unit': unit,
      'minRange': minRange,
      'maxRange': maxRange,
      'category': category,
    };
  }
}

enum BloodMarkerCategory {
  completeBloodCount('Complete Blood Count'),
  electrolyteMineral('Electrolytes & Minerals'),
  kidneyFunction('Kidney Function'),
  liverFunction('Liver Function'),
  lipidProfile('Lipid Profile'),
  bloodSugarDiabetes('Blood Sugar & Diabetes'),
  inflammatoryImmune('Inflammatory & Immune'),
  hormonal('Hormonal'),
  bloodClottingCoagulation('Blood Clotting'),
  vitaminNutritional('Vitamins & Nutrition'),
  cardiac('Cardiac Markers'),
  tumorCancer('Tumor Markers'),
  autoimmune('Autoimmune Markers');

  const BloodMarkerCategory(this.displayName);
  final String displayName;
}
