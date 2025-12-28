import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/heart_healthy_meal.dart';
import 'heart_meal_suggestion_service.dart';

/// Recipe/Meal suggestion service for children with heart disease
/// Uses template-based suggestions (no external AI API required)
class RecipeRemoteDatasource {
  RecipeRemoteDatasource._();
  static final RecipeRemoteDatasource instance = RecipeRemoteDatasource._();

  final _suggestionService = HeartMealSuggestionService.instance;
  final _firestore = FirebaseFirestore.instance;

  /// Get heart-healthy meal suggestions based on user input
  Future<HeartHealthyMeal> getRecipeSuggestions(String userInput) async {
    try {
      return await _suggestionService.getMealSuggestion(userInput);
    } catch (e) {
      throw Exception('Error generating meal suggestion: $e');
    }
  }

  /// Save suggested heart-healthy meal to Firestore
  Future<void> saveSuggestedMealToFirestore(String userInput) async {
    try {
      // Get the suggested meal
      final meal = await _suggestionService.getMealSuggestion(userInput);
      
      // Save to Firestore
      await _firestore.collection('heart_healthy_meals').add(meal.toJson());
    } catch (e) {
      throw Exception('Failed to save suggested meal: $e');
    }
  }
}
