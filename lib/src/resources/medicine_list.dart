import 'dart:convert';

class MedicineModel {
  String? name;
  String? brandName;
  String? genericName;
  String? strength;

  MedicineModel({
    this.name,
    this.brandName,
    this.genericName,
    this.strength,
  });

  MedicineModel copyWith({
    String? name,
    String? brandName,
    String? genericName,
    String? strength,
  }) =>
      MedicineModel(
        name: name ?? this.name,
        brandName: brandName ?? this.brandName,
        genericName: genericName ?? this.genericName,
        strength: strength ?? this.strength,
      );

  factory MedicineModel.fromJson(String str) =>
      MedicineModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory MedicineModel.fromMap(Map<String, dynamic> json) => MedicineModel(
        name: json['name'],
        brandName: json['brandName'],
        genericName: json['genericName'],
        strength: json['strength'],
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'brandName': brandName,
        'genericName': genericName,
        'strength': strength,
      };
}

List<Map<String, dynamic>> medicineData = [
  {
    'name': 'Napa 500mg Tablet',
    'brandName': 'Napa',
    'genericName': 'Paracetamol',
    'strength': '500mg',
  },
  {
    'name': 'Ace 500mg Tablet',
    'brandName': 'Ace',
    'genericName': 'Paracetamol',
    'strength': '500mg',
  },
  {
    'name': 'Sergel 20mg Capsule',
    'brandName': 'Sergel',
    'genericName': 'Omeprazole',
    'strength': '20mg',
  },
  {
    'name': 'Monas 10mg Tablet',
    'brandName': 'Monas',
    'genericName': 'Montelukast',
    'strength': '10mg'
  },
  {
    'name': 'Napa Extra 500mg/65mg Tablet',
    'brandName': 'Napa Extra',
    'genericName': 'Paracetamol + Caffeine',
    'strength': '500mg+65mg',
  },
  {
    'name': 'Histac 150mg Tablet',
    'brandName': 'Histac',
    'genericName': 'Ranitidine',
    'strength': '150mg',
  },
  {
    'name': 'Amoxil 250mg Capsule',
    'brandName': 'Amoxil',
    'genericName': 'Amoxicillin',
    'strength': '250mg',
  },
  {
    'name': 'Norflox 400mg Tablet',
    'brandName': 'Norflox',
    'genericName': 'Norfloxacin',
    'strength': '400mg',
  },
  {
    'name': 'Calbo 500mg Tablet',
    'brandName': 'Calbo',
    'genericName': 'Calcium Carbonate',
    'strength': '500mg',
  },
  {
    'name': 'Fexo 120mg Tablet',
    'brandName': 'Fexo',
    'genericName': 'Fexofenadine',
    'strength': '120mg',
  },
  {
    'name': 'Azithral 500mg Tablet',
    'brandName': 'Azithral',
    'genericName': 'Azithromycin',
    'strength': '500mg',
  },
  {
    'name': 'Ciplox 500mg Tablet',
    'brandName': 'Ciplox',
    'genericName': 'Ciprofloxacin',
    'strength': '500mg',
  },
  {
    'name': 'Voltaren 50mg Tablet',
    'brandName': 'Voltaren',
    'genericName': 'Diclofenac',
    'strength': '50mg',
  },
  {
    'name': 'Neofen 400mg Tablet',
    'brandName': 'Neofen',
    'genericName': 'Ibuprofen',
    'strength': '400mg',
  },
  {
    'name': 'Pantop 40mg Tablet',
    'brandName': 'Pantop',
    'genericName': 'Pantoprazole',
    'strength': '40mg'
  },
  {
    'name': 'Finax 10mg Tablet',
    'brandName': 'Finax',
    'genericName': 'Finasteride',
    'strength': '10mg',
  },
  {
    'name': 'Glycomet 500mg Tablet',
    'brandName': 'Glycomet',
    'genericName': 'Metformin',
    'strength': '500mg',
  },
  {
    'name': 'Coveram 5mg/5mg Tablet',
    'brandName': 'Coveram',
    'genericName': 'Perindopril + Amlodipine',
    'strength': '5mg/5mg',
  },
  {
    'name': 'Losar 50mg Tablet',
    'brandName': 'Losar',
    'genericName': 'Losartan',
    'strength': '50mg',
  },
  {
    'name': 'Concor 5mg Tablet',
    'brandName': 'Concor',
    'genericName': 'Bisoprolol',
    'strength': '5mg'
  },
  {
    'name': 'Enalapril 5mg Tablet',
    'brandName': 'Enalapril',
    'genericName': 'Enalapril',
    'strength': '5mg',
  },
  {
    'name': 'Atorvastatin 10mg Tablet',
    'brandName': 'Atorvastatin',
    'genericName': 'Atorvastatin',
    'strength': '10mg',
  },
  {
    'name': 'Rosuvastatin 10mg Tablet',
    'brandName': 'Rosuvastatin',
    'genericName': 'Rosuvastatin',
    'strength': '10mg',
  },
  {
    'name': 'Fero 50mg Tablet',
    'brandName': 'Fero',
    'genericName': 'Ferrous sulfate',
    'strength': '50mg',
  },
  {
    'name': 'Folic Acid 5mg Tablet',
    'brandName': 'Folic Acid',
    'genericName': 'Folic acid',
    'strength': '5mg',
  },
  {
    'name': 'Vitamin D3 1000 IU Capsule',
    'brandName': 'Vitamin D3',
    'genericName': 'Cholecalciferol',
    'strength': '1000IU',
  },
  {
    'name': 'Cetirizine 10mg Tablet',
    'brandName': 'Cetirizine',
    'genericName': 'Cetirizine',
    'strength': '10mg',
  },
  {
    'name': 'Bromazepam 3mg Tablet',
    'brandName': 'Bromazepam',
    'genericName': 'Bromazepam',
    'strength': '3mg'
  },
  {
    'name': 'Lorazepam 1mg Tablet',
    'brandName': 'Lorazepam',
    'genericName': 'Lorazepam',
    'strength': '1mg',
  },
  {
    'name': 'Sertraline 50mg Tablet',
    'brandName': 'Sertraline',
    'genericName': 'Sertraline',
    'strength': '50mg'
  },
  {
    'name': 'Escitalopram 10mg Tablet',
    'brandName': 'Escitalopram',
    'genericName': 'Escitalopram',
    'strength': '10mg'
  },
  {
    'name': 'Insulin Actrapid 100IU Injection',
    'brandName': 'Actrapid',
    'genericName': 'Insulin',
    'strength': '100IU/mL',
  },
  {
    'name': 'Insulin Lantus 100IU Injection',
    'brandName': 'Lantus',
    'genericName': 'Insulin glargine',
    'strength': '100IU/mL',
  },
  {
    'name': 'Salbutamol 2mg Tablet',
    'brandName': 'Salbutamol',
    'genericName': 'Salbutamol',
    'strength': '2mg',
  },
  {
    'name': 'Prednisolone 5mg Tablet',
    'brandName': 'Prednisolone',
    'genericName': 'Prednisolone',
    'strength': '5mg'
  },
  {
    'name': 'Betamethasone 0.5mg Tablet',
    'brandName': 'Betamethasone',
    'genericName': 'Betamethasone',
    'strength': '0.5mg'
  },
  {
    'name': 'Oral Saline Solution',
    'brandName': 'Oral Saline',
    'genericName': 'Sodium Chloride/Potassium Chloride',
    'strength': '-',
  },
  {
    'name': 'Paracetamol Syrup',
    'brandName': 'Paracetamol Syrup',
    'genericName': 'Paracetamol',
    'strength': '120mg/5ml',
  },
  {
    'name': 'Cetirizine Syrup',
    'brandName': 'Cetirizine Syrup',
    'genericName': 'Cetirizine',
    'strength': '2.5mg/5ml',
  },
  {
    'name': 'Ambroxol Syrup',
    'brandName': 'Ambroxol Syrup',
    'genericName': 'Ambroxol',
    'strength': '15mg/5ml',
  },
  {
    'name': 'Diclofenac Gel',
    'brandName': 'Diclofenac Gel',
    'genericName': 'Diclofenac',
    'strength': '1% Gel',
  },
  {
    'name': 'Miconazole Cream',
    'brandName': 'Miconazole Cream',
    'genericName': 'Miconazole',
    'strength': '2% Cream'
  },
  {
    'name': 'Chlorhexidine Mouthwash',
    'brandName': 'Chlorhexidine Mouthwash',
    'genericName': 'Chlorhexidine',
    'strength': '0.2% mouthwash'
  },
  {
    'name': 'Metronidazole Infusion',
    'brandName': 'Metronidazole Infusion',
    'genericName': 'Metronidazole',
    'strength': '500mg/100ml',
  },
  {
    'name': 'Ceftriaxone Injection',
    'brandName': 'Ceftriaxone Injection',
    'genericName': 'Ceftriaxone',
    'strength': '1g/vial'
  },
  {
    'name': 'Amoxicillin + Clavulanate Injection',
    'brandName': 'Amoxicillin + Clavulanate Injection',
    'genericName': 'Amoxicillin+Clavulanate',
    'strength': '1.2g/vial'
  }
];
