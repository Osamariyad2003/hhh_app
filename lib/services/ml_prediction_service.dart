import '../core/dio_helper.dart';
import '../models/heart_disease_prediction.dart';

class MLPredictionService {
  MLPredictionService._();
  static final MLPredictionService instance = MLPredictionService._();

  /// Predict heart disease based on patient data
  /// 
  /// This calls the ML prediction API endpoint which should be running
  /// a model trained on the UCI Heart Disease dataset
  /// 
  /// API endpoint: POST /api/ml/predict-heart-disease
  Future<HeartDiseasePredictionResponse> predictHeartDisease(
    HeartDiseasePredictionRequest request,
  ) async {
    try {
      final response = await DioHelper.postData(
        url: 'ml/predict-heart-disease',
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return HeartDiseasePredictionResponse.fromJson(response.data);
      } else {
        throw Exception('Prediction failed: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback: Return a mock response for development/testing
      // In production, this should throw the error
      throw Exception('Failed to get prediction: $e');
    }
  }

  /// Get available ML models
  Future<List<String>> getAvailableModels() async {
    try {
      final response = await DioHelper.getData(url: 'ml/models');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.cast<String>();
        } else if (data is Map && data.containsKey('models')) {
          return (data['models'] as List).cast<String>();
        }
      }
      return ['Random Forest', 'Logistic Regression', 'SVM', 'KNN', 'Decision Tree', 'XGBoost'];
    } catch (e) {
      // Return default models if API is not available
      return ['Random Forest', 'Logistic Regression', 'SVM', 'KNN', 'Decision Tree', 'XGBoost'];
    }
  }

  /// Validate prediction request data
  bool validateRequest(HeartDiseasePredictionRequest request) {
    if (request.age < 0 || request.age > 120) return false;
    if (request.sex != 0 && request.sex != 1) return false;
    if (request.cp < 0 || request.cp > 3) return false;
    if (request.trestbps < 0 || request.trestbps > 300) return false;
    if (request.chol < 0 || request.chol > 600) return false;
    if (request.fbs != 0 && request.fbs != 1) return false;
    if (request.restecg < 0 || request.restecg > 2) return false;
    if (request.thalach < 0 || request.thalach > 250) return false;
    if (request.exang != 0 && request.exang != 1) return false;
    if (request.oldpeak < 0 || request.oldpeak > 10) return false;
    if (request.slope < 0 || request.slope > 2) return false;
    if (request.ca < 0 || request.ca > 3) return false;
    if (request.thal != 3 && request.thal != 6 && request.thal != 7) return false;
    return true;
  }
}

