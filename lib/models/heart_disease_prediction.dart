class HeartDiseasePredictionRequest {
  final int age;
  final int sex; // 1 = male, 0 = female
  final int cp; // chest pain type (0-3)
  final int trestbps; // resting blood pressure
  final int chol; // serum cholesterol
  final int fbs; // fasting blood sugar > 120 mg/dl (1 = true, 0 = false)
  final int restecg; // resting electrocardiographic results
  final int thalach; // maximum heart rate achieved
  final int exang; // exercise induced angina (1 = yes, 0 = no)
  final double oldpeak; // ST depression induced by exercise
  final int slope; // slope of the peak exercise ST segment
  final int ca; // number of major vessels (0-3)
  final int thal; // thalassemia (3 = normal, 6 = fixed defect, 7 = reversable defect)

  HeartDiseasePredictionRequest({
    required this.age,
    required this.sex,
    required this.cp,
    required this.trestbps,
    required this.chol,
    required this.fbs,
    required this.restecg,
    required this.thalach,
    required this.exang,
    required this.oldpeak,
    required this.slope,
    required this.ca,
    required this.thal,
  });

  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'sex': sex,
      'cp': cp,
      'trestbps': trestbps,
      'chol': chol,
      'fbs': fbs,
      'restecg': restecg,
      'thalach': thalach,
      'exang': exang,
      'oldpeak': oldpeak,
      'slope': slope,
      'ca': ca,
      'thal': thal,
    };
  }

  factory HeartDiseasePredictionRequest.fromJson(Map<String, dynamic> json) {
    return HeartDiseasePredictionRequest(
      age: json['age'] as int,
      sex: json['sex'] as int,
      cp: json['cp'] as int,
      trestbps: json['trestbps'] as int,
      chol: json['chol'] as int,
      fbs: json['fbs'] as int,
      restecg: json['restecg'] as int,
      thalach: json['thalach'] as int,
      exang: json['exang'] as int,
      oldpeak: (json['oldpeak'] as num).toDouble(),
      slope: json['slope'] as int,
      ca: json['ca'] as int,
      thal: json['thal'] as int,
    );
  }
}

class HeartDiseasePredictionResponse {
  final bool hasDisease;
  final double probability;
  final String model;
  final Map<String, dynamic>? details;

  HeartDiseasePredictionResponse({
    required this.hasDisease,
    required this.probability,
    required this.model,
    this.details,
  });

  factory HeartDiseasePredictionResponse.fromJson(Map<String, dynamic> json) {
    return HeartDiseasePredictionResponse(
      hasDisease: json['has_disease'] as bool? ?? json['prediction'] == 1,
      probability: (json['probability'] as num?)?.toDouble() ?? 
                   (json['confidence'] as num?)?.toDouble() ?? 0.0,
      model: json['model'] as String? ?? 'Random Forest',
      details: json['details'] as Map<String, dynamic>?,
    );
  }

  String get riskLevel {
    if (probability >= 0.8) return 'High Risk';
    if (probability >= 0.5) return 'Moderate Risk';
    return 'Low Risk';
  }

  String get recommendation {
    if (hasDisease) {
      return 'Please consult with a healthcare professional immediately for further evaluation and treatment.';
    } else if (probability >= 0.5) {
      return 'Consider consulting with a healthcare professional for preventive care and monitoring.';
    } else {
      return 'Continue maintaining a healthy lifestyle with regular check-ups.';
    }
  }
}

