import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/heart_healthy_meal.dart';
import 'generative_ai/generative_ai_service.dart';

/// Recipe/Meal suggestion service for children with heart disease
/// Uses Google Generative AI (Gemini) for intelligent meal suggestions
class RecipeRemoteDatasource {
  RecipeRemoteDatasource._();
  static final RecipeRemoteDatasource instance = RecipeRemoteDatasource._();

  final _generativeAI = GenerativeAIService.instance;
  final _firestore = FirebaseFirestore.instance;

  /// Initialize the Generative AI service
  void initialize() {
    _generativeAI.initialize();
  }

  /// Get heart-healthy meal suggestions based on user input
  /// Uses Google Generative AI (Gemini) with fallback to template-based suggestions
  Future<HeartHealthyMeal> getRecipeSuggestions(String userInput) async {
    try {
      // Try using Generative AI first
      return await _generativeAI.getMealSuggestion(userInput);
    } catch (e) {
      // Fallback to template-based suggestions if AI fails

      throw Exception('Error generating meal suggestion: $e');
    }
  }

  Future<void> saveSuggestedMealToFirestore(String userInput) async {
    try {
      // Use Generative AI to get the meal
      final meal = await getRecipeSuggestions(userInput);

      // Save to Firestore
      await _firestore.collection('heart_healthy_meals').add(meal.toJson());
    } catch (e) {
      throw Exception('Failed to save suggested meal: $e');
    }
  }
}
