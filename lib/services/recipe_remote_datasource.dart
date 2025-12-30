import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/heart_healthy_meal.dart';
import 'generative_ai/generative_ai_service.dart';


class RecipeRemoteDatasource {
  RecipeRemoteDatasource._();
  static final RecipeRemoteDatasource instance = RecipeRemoteDatasource._();

  final _generativeAI = GenerativeAIService.instance;
  final _firestore = FirebaseFirestore.instance;

  void initialize() {
    _generativeAI.initialize();
  }

  Future<HeartHealthyMeal> getRecipeSuggestions(String userInput) async {
    try {
      return await _generativeAI.getMealSuggestion(userInput);
    } catch (e) {
      throw Exception('Error generating meal suggestion: $e');
    }
  }

  Future<void> saveSuggestedMealToFirestore(String userInput) async {
    try {
      final meal = await getRecipeSuggestions(userInput);

      await _firestore.collection('heart_healthy_meals').add(meal.toJson());
    } catch (e) {
      throw Exception('Failed to save suggested meal: $e');
    }
  }
}
