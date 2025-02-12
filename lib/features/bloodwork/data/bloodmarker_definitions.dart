import 'package:bloodinsight/features/bloodwork/data/bloodmarker_model.dart';

enum BloodUnit {
  gPerDL('g/dL'),
  gPerL('g/L'),
  mgPerDL('mg/dL'),
  mmolPerL('mmol/L'),
  pgPerCell('pg/cell'),
  fL('fL'),
  cellsPerCMM('cells/cmm'),
  // IU = International Unit
  // ignore: constant_identifier_names
  IUPerL('IU/L'),
  mEqPerL('mEq/L'),
  ngPerML('ng/mL'),
  percentageRatio('%'),
  ngPerDL('ng/dL'),
  mcgPerDL('µg/dL'),
  pgPerML('pg/mL');

  const BloodUnit(this.display);
  final String display;

  @override
  String toString() => display;
}

class MarkerDefinition {
  const MarkerDefinition({
    required this.name,
    required this.unit,
    required this.minRange,
    required this.maxRange,
    required this.category,
  });

  final String name;
  final BloodUnit unit;
  final double minRange;
  final double maxRange;
  final BloodMarkerCategory category;
}

final markerDefinitions = [
  // Complete Blood Count (CBC)
  const MarkerDefinition(
    name: 'Hemoglobin',
    unit: BloodUnit.gPerDL,
    minRange: 12,
    maxRange: 16,
    category: BloodMarkerCategory.completeBloodCount,
  ),
  const MarkerDefinition(
    name: 'White Blood Cells',
    unit: BloodUnit.cellsPerCMM,
    minRange: 4000,
    maxRange: 11000,
    category: BloodMarkerCategory.completeBloodCount,
  ),
  const MarkerDefinition(
    name: 'Red Blood Cells',
    unit: BloodUnit.cellsPerCMM,
    minRange: 4.5,
    maxRange: 5.5,
    category: BloodMarkerCategory.completeBloodCount,
  ),
  const MarkerDefinition(
    name: 'Platelets',
    unit: BloodUnit.cellsPerCMM,
    minRange: 150000,
    maxRange: 450000,
    category: BloodMarkerCategory.completeBloodCount,
  ),
  const MarkerDefinition(
    name: 'Hematocrit',
    unit: BloodUnit.percentageRatio,
    minRange: 36,
    maxRange: 46,
    category: BloodMarkerCategory.completeBloodCount,
  ),
  const MarkerDefinition(
    name: 'MCV',
    unit: BloodUnit.fL,
    minRange: 80,
    maxRange: 96,
    category: BloodMarkerCategory.completeBloodCount,
  ),

  // Electrolyte & Mineral
  const MarkerDefinition(
    name: 'Sodium',
    unit: BloodUnit.mEqPerL,
    minRange: 135,
    maxRange: 145,
    category: BloodMarkerCategory.electrolyteMineral,
  ),
  const MarkerDefinition(
    name: 'Potassium',
    unit: BloodUnit.mEqPerL,
    minRange: 3.5,
    maxRange: 5,
    category: BloodMarkerCategory.electrolyteMineral,
  ),
  const MarkerDefinition(
    name: 'Calcium',
    unit: BloodUnit.mgPerDL,
    minRange: 8.5,
    maxRange: 10.5,
    category: BloodMarkerCategory.electrolyteMineral,
  ),
  const MarkerDefinition(
    name: 'Magnesium',
    unit: BloodUnit.mgPerDL,
    minRange: 1.7,
    maxRange: 2.2,
    category: BloodMarkerCategory.electrolyteMineral,
  ),

  // Kidney Function
  const MarkerDefinition(
    name: 'Creatinine',
    unit: BloodUnit.mgPerDL,
    minRange: 0.7,
    maxRange: 1.3,
    category: BloodMarkerCategory.kidneyFunction,
  ),
  const MarkerDefinition(
    name: 'BUN',
    unit: BloodUnit.mgPerDL,
    minRange: 7,
    maxRange: 20,
    category: BloodMarkerCategory.kidneyFunction,
  ),
  const MarkerDefinition(
    name: 'eGFR',
    unit: BloodUnit.mEqPerL,
    minRange: 90,
    maxRange: 120,
    category: BloodMarkerCategory.kidneyFunction,
  ),

  // Liver Function
  const MarkerDefinition(
    name: 'ALT',
    unit: BloodUnit.IUPerL,
    minRange: 7,
    maxRange: 56,
    category: BloodMarkerCategory.liverFunction,
  ),
  const MarkerDefinition(
    name: 'AST',
    unit: BloodUnit.IUPerL,
    minRange: 10,
    maxRange: 40,
    category: BloodMarkerCategory.liverFunction,
  ),
  const MarkerDefinition(
    name: 'Albumin',
    unit: BloodUnit.gPerDL,
    minRange: 3.4,
    maxRange: 5.4,
    category: BloodMarkerCategory.liverFunction,
  ),
  const MarkerDefinition(
    name: 'Bilirubin',
    unit: BloodUnit.mgPerDL,
    minRange: 0.3,
    maxRange: 1.2,
    category: BloodMarkerCategory.liverFunction,
  ),

  // Lipid Profile
  const MarkerDefinition(
    name: 'Total Cholesterol',
    unit: BloodUnit.mgPerDL,
    minRange: 125,
    maxRange: 200,
    category: BloodMarkerCategory.lipidProfile,
  ),
  const MarkerDefinition(
    name: 'HDL Cholesterol',
    unit: BloodUnit.mgPerDL,
    minRange: 40,
    maxRange: 60,
    category: BloodMarkerCategory.lipidProfile,
  ),
  const MarkerDefinition(
    name: 'LDL Cholesterol',
    unit: BloodUnit.mgPerDL,
    minRange: 0,
    maxRange: 100,
    category: BloodMarkerCategory.lipidProfile,
  ),
  const MarkerDefinition(
    name: 'Triglycerides',
    unit: BloodUnit.mgPerDL,
    minRange: 0,
    maxRange: 150,
    category: BloodMarkerCategory.lipidProfile,
  ),

  // Blood Sugar & Diabetes
  const MarkerDefinition(
    name: 'Fasting Glucose',
    unit: BloodUnit.mgPerDL,
    minRange: 70,
    maxRange: 100,
    category: BloodMarkerCategory.bloodSugarDiabetes,
  ),
  const MarkerDefinition(
    name: 'HbA1c',
    unit: BloodUnit.percentageRatio,
    minRange: 4,
    maxRange: 5.7,
    category: BloodMarkerCategory.bloodSugarDiabetes,
  ),

  // Inflammatory & Immune
  const MarkerDefinition(
    name: 'CRP',
    unit: BloodUnit.mgPerDL,
    minRange: 0,
    maxRange: 3,
    category: BloodMarkerCategory.inflammatoryImmune,
  ),
  const MarkerDefinition(
    name: 'ESR',
    unit: BloodUnit.mmolPerL,
    minRange: 0,
    maxRange: 20,
    category: BloodMarkerCategory.inflammatoryImmune,
  ),

  // Hormonal
  const MarkerDefinition(
    name: 'TSH',
    unit: BloodUnit.IUPerL,
    minRange: 0.4,
    maxRange: 4,
    category: BloodMarkerCategory.hormonal,
  ),
  const MarkerDefinition(
    name: 'Free T4',
    unit: BloodUnit.ngPerDL,
    minRange: 0.7,
    maxRange: 1.8,
    category: BloodMarkerCategory.hormonal,
  ),
  const MarkerDefinition(
    name: 'Free T3',
    unit: BloodUnit.pgPerML,
    minRange: 2.3,
    maxRange: 4.2,
    category: BloodMarkerCategory.hormonal,
  ),

  // Blood Clotting & Coagulation
  const MarkerDefinition(
    name: 'PT',
    unit: BloodUnit.IUPerL,
    minRange: 11,
    maxRange: 13.5,
    category: BloodMarkerCategory.bloodClottingCoagulation,
  ),
  const MarkerDefinition(
    name: 'INR',
    unit: BloodUnit.percentageRatio,
    minRange: 0.8,
    maxRange: 1.1,
    category: BloodMarkerCategory.bloodClottingCoagulation,
  ),

  // Vitamin & Nutritional
  const MarkerDefinition(
    name: 'Vitamin D',
    unit: BloodUnit.ngPerML,
    minRange: 30,
    maxRange: 100,
    category: BloodMarkerCategory.vitaminNutritional,
  ),
  const MarkerDefinition(
    name: 'Vitamin B12',
    unit: BloodUnit.pgPerML,
    minRange: 200,
    maxRange: 900,
    category: BloodMarkerCategory.vitaminNutritional,
  ),
  const MarkerDefinition(
    name: 'Ferritin',
    unit: BloodUnit.ngPerML,
    minRange: 30,
    maxRange: 400,
    category: BloodMarkerCategory.vitaminNutritional,
  ),

  // Cardiac
  const MarkerDefinition(
    name: 'Troponin I',
    unit: BloodUnit.ngPerML,
    minRange: 0,
    maxRange: 0.04,
    category: BloodMarkerCategory.cardiac,
  ),
  const MarkerDefinition(
    name: 'BNP',
    unit: BloodUnit.pgPerML,
    minRange: 0,
    maxRange: 100,
    category: BloodMarkerCategory.cardiac,
  ),

  // Tumor & Cancer
  const MarkerDefinition(
    name: 'PSA',
    unit: BloodUnit.ngPerML,
    minRange: 0,
    maxRange: 4,
    category: BloodMarkerCategory.tumorCancer,
  ),
  const MarkerDefinition(
    name: 'CEA',
    unit: BloodUnit.ngPerML,
    minRange: 0,
    maxRange: 2.5,
    category: BloodMarkerCategory.tumorCancer,
  ),

  // Autoimmune
  const MarkerDefinition(
    name: 'ANA',
    unit: BloodUnit.IUPerL,
    minRange: 0,
    maxRange: 1,
    category: BloodMarkerCategory.autoimmune,
  ),
  const MarkerDefinition(
    name: 'RF',
    unit: BloodUnit.IUPerL,
    minRange: 0,
    maxRange: 14,
    category: BloodMarkerCategory.autoimmune,
  ),
];
