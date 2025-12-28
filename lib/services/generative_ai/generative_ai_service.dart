import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../models/heart_healthy_meal.dart';

/// Generative AI Service using Google's Gemini API
/// Provides AI-powered meal suggestions for children with heart disease
class GenerativeAIService {
  GenerativeAIService._();
  static final GenerativeAIService instance = GenerativeAIService._();

  static const String _apiKey = 'AIzaSyAXDbfdrnQtZLscxNITRIr2PF1aWCraVnY';
  Model? _model;

  /// Initialize the service (call this before using)
  void initialize() {
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: _apiKey,
    );
  }

  Model get model {
    _model ??= GenerativeModel(
      model: 'gemini-pro',
      apiKey: _apiKey,
    );
    return _model!;
  }

  /// Get AI-powered meal suggestion based on user input
  Future<HeartHealthyMeal> getMealSuggestion(String userInput) async {
    try {
      final prompt = _buildPrompt(userInput);
      
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      
      final text = response.text ?? '';
      
      // Parse the AI response into a HeartHealthyMeal
      return _parseAIResponse(text, userInput);
    } catch (e) {
      throw Exception('Failed to get AI suggestion: $e');
    }
  }

  /// Build the prompt for the AI
  String _buildPrompt(String userInput) {
    return '''
You are a nutritionist specializing in heart-healthy meals for children with congenital heart disease (CHD).

User request: "$userInput"

Please provide a detailed, heart-healthy meal suggestion for a child with CHD. The meal should:
1. Be low in sodium (less than 200mg per serving)
2. Contain healthy fats (omega-3, monounsaturated)
3. Be rich in lean protein
4. Include whole grains and vegetables
5. Be appropriate for children (easy to chew, appealing)
6. Support cardiovascular health

Format your response as JSON with the following structure:
{
  "name": "Meal name",
  "mealType": ["breakfast" or "lunch" or "dinner"],
  "summary": "Brief description (2-3 sentences)",
  "ingredients": [
    {"name": "Ingredient name", "quantity": "Amount"}
  ],
  "steps": [
    "Step 1",
    "Step 2",
    ...
  ],
  "cookTime": 30,
  "servingSize": 2,
  "rating": 4.5
}

Only return the JSON, no additional text.
''';
  }

  /// Parse AI response into HeartHealthyMeal
  HeartHealthyMeal _parseAIResponse(String response, String userInput) {
    try {
      // Try to extract JSON from the response
      String jsonStr = response.trim();
      
      // Remove markdown code blocks if present
      if (jsonStr.startsWith('```')) {
        final lines = jsonStr.split('\n');
        lines.removeAt(0); // Remove first line (```json or ```)
        if (lines.isNotEmpty && lines.last.trim() == '```') {
          lines.removeLast(); // Remove last line (```)
        }
        jsonStr = lines.join('\n');
      }
      
      // Try to parse as JSON using dart:convert
      final jsonData = jsonDecode(jsonStr) as Map<String, dynamic>;
      
      return HeartHealthyMeal(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: jsonData['name']?.toString() ?? 'Heart-Healthy Meal',
        mealType: jsonData['mealType'] is List 
            ? (jsonData['mealType'] as List).map((e) => e.toString()).toList()
            : [jsonData['mealType']?.toString() ?? 'lunch'],
        rating: (jsonData['rating'] as num?)?.toDouble() ?? 4.5,
        cookTime: (jsonData['cookTime'] as num?)?.toInt() ?? 30,
        servingSize: (jsonData['servingSize'] as num?)?.toInt() ?? 2,
        summary: jsonData['summary']?.toString() ?? 'A heart-healthy meal for children with CHD.',
        ingredients: _parseIngredients(jsonData['ingredients']),
        mealSteps: _parseSteps(jsonData['steps']),
        createdAt: DateTime.now(),
      );
    } catch (e) {
      // Fallback to template-based meal if parsing fails
      return _createFallbackMeal(userInput);
    }
  }


  List<MealIngredient> _parseIngredients(dynamic ingredients) {
    if (ingredients == null) {
      return _getDefaultIngredients();
    }
    
    if (ingredients is List) {
      return ingredients.map((item) {
        if (item is Map) {
          return MealIngredient(
            name: item['name']?.toString() ?? 'Ingredient',
            quantity: item['quantity']?.toString() ?? '1',
          );
        }
        return MealIngredient(name: 'Ingredient', quantity: '1');
      }).toList();
    }
    
    return _getDefaultIngredients();
  }


  List<String> _parseSteps(dynamic steps) {
    if (steps == null) {
      return _getDefaultSteps();
    }
    
    if (steps is List) {
      return steps.map((step) => step.toString()).toList();
    }
    
    return _getDefaultSteps();
  }


  List<MealIngredient> _getDefaultIngredients() {
    return [
      MealIngredient(name: 'Lean Protein', quantity: '150g'),
      MealIngredient(name: 'Whole Grains', quantity: '1/2 cup'),
      MealIngredient(name: 'Fresh Vegetables', quantity: '1 cup'),
      MealIngredient(name: 'Olive Oil', quantity: '1 teaspoon'),
    ];
  }

  List<String> _getDefaultSteps() {
    return [
      'Prepare ingredients according to heart-healthy guidelines.',
      'Cook using low-sodium methods.',
      'Ensure all food is at safe temperature for children.',
      'Serve in child-friendly portions.',
    ];
  }

  HeartHealthyMeal _createFallbackMeal(String userInput) {
    final input = userInput.toLowerCase();
    String mealType = 'lunch';
    if (input.contains('breakfast') || input.contains('morning')) {
      mealType = 'breakfast';
    } else if (input.contains('dinner') || input.contains('evening')) {
      mealType = 'dinner';
    }

    return HeartHealthyMeal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'AI-Suggested Heart-Healthy Meal',
      mealType: [mealType],
      rating: 4.5,
      cookTime: 30,
      servingSize: 2,
      summary: 'A heart-healthy meal suggestion based on your request. This meal is designed for children with congenital heart disease, focusing on low sodium, healthy fats, and essential nutrients.',
      ingredients: _getDefaultIngredients(),
      mealSteps: _getDefaultSteps(),
      createdAt: DateTime.now(),
    );
  }
}

