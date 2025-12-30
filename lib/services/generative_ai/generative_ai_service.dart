import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../models/heart_healthy_meal.dart';

class GenerativeAIService {
  GenerativeAIService._();
  static final GenerativeAIService instance = GenerativeAIService._();

  static const String _apiKey = 'AIzaSyDhugogohGxLtF7W6o8mebhwRwCARfT73c';
  GenerativeModel? _model;

  void initialize() {
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: _apiKey,
    );
  }

  GenerativeModel get model {
    _model ??= GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: _apiKey,
    );
    return _model!;
  }

  Future<HeartHealthyMeal> getMealSuggestion(String userInput) async {
    try {
      final prompt = _buildPrompt(userInput);

      final content = [Content.text(prompt)];
      final response = await model.generateContent(
        content,
        generationConfig: GenerationConfig(
          temperature: 0.8,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 3000,
        ),
      );

      final text = response.text ?? '';

      if (text.isEmpty) {
        throw Exception('AI returned empty response');
      }

      return _parseAIResponse(text, userInput);
    } catch (e) {
      debugPrint('GenerativeAI Error: $e');
      rethrow;
    }
  }

  String _buildPrompt(String userInput) {
    return '''You are a certified pediatric nutritionist and registered dietitian specializing in congenital heart disease (CHD) nutrition for children. You have extensive experience creating medically appropriate, heart-healthy meal plans for children with various types of CHD.

USER REQUEST: "$userInput"

TASK: Create a comprehensive, medically sound, heart-healthy meal suggestion specifically designed for a child with congenital heart disease. This meal must be safe, nutritious, and appropriate for pediatric cardiac patients.

CRITICAL NUTRITIONAL REQUIREMENTS FOR CHD CHILDREN:
1. SODIUM RESTRICTION: Maximum 150-200mg sodium per serving. Use NO added salt, avoid processed foods, canned goods, and high-sodium ingredients. Use herbs, spices, lemon, and natural flavorings instead.

2. HEART-HEALTHY FATS: Include omega-3 fatty acids (salmon, tuna, walnuts, flaxseeds) and monounsaturated fats (olive oil, avocado). Avoid trans fats and limit saturated fats.

3. LEAN PROTEIN: Provide 15-20% of calories from high-quality lean protein sources: skinless poultry, fish (especially fatty fish), legumes, eggs, low-fat dairy. Avoid processed meats.

4. COMPLEX CARBOHYDRATES: Use whole grains (brown rice, quinoa, oats, whole wheat), sweet potatoes, and starchy vegetables. Avoid refined sugars and white flour.

5. FRUITS & VEGETABLES: Include 3-5 servings of colorful, nutrient-dense fruits and vegetables rich in antioxidants, vitamins, and fiber. Fresh or frozen (no added salt) preferred.

6. CHILD-FRIENDLY: Soft texture, easy to chew, colorful and appealing, age-appropriate portions, safe serving temperature.

7. COOKING METHODS: Use heart-healthy methods: baking, steaming, grilling, poaching, or sautéing with minimal oil. Avoid deep-frying.

RESPONSE FORMAT - Return ONLY valid JSON (no markdown, no code blocks, no explanations):
{
  "name": "Creative, descriptive meal name that sounds appealing to children",
  "mealType": ["breakfast" OR "lunch" OR "dinner" - choose ONE based on user request or time of day],
  "summary": "A detailed 3-4 sentence description explaining: (1) why this meal is beneficial for children with CHD, (2) key nutritional benefits, (3) how it supports heart health and growth, (4) approximate calorie range per serving",
  "ingredients": [
    {"name": "Specific ingredient name", "quantity": "Precise amount with units (e.g., '150g', '1/2 cup', '2 tablespoons')"},
    ... (include 5-8 ingredients)
  ],
  "steps": [
    "Detailed step 1 with specific instructions and safety notes",
    "Detailed step 2 with cooking times and temperatures",
    ... (include 6-10 detailed steps)
  ],
  "cookTime": [number in minutes, typically 20-60],
  "servingSize": [number of servings, typically 1-4],
  "rating": [number between 4.0 and 5.0, representing nutritional quality]
}

CRITICAL: 
- Return ONLY the JSON object, nothing else
- Ensure all JSON is valid and properly formatted
- Use double quotes for all strings
- Include all required fields
- Make the meal creative, nutritious, and appealing to children
- Base meal type on user input or infer from context (breakfast for morning, lunch for midday, dinner for evening)

Generate the meal suggestion now:''';
  }

  HeartHealthyMeal _parseAIResponse(String response, String userInput) {
    try {
      String jsonStr = response.trim();

      if (jsonStr.startsWith('```')) {
        final lines = jsonStr.split('\n');
        lines.removeAt(0); 
        if (lines.isNotEmpty && lines.last.trim() == '```') {
          lines.removeLast(); 
        }
        jsonStr = lines.join('\n');
      }

      final jsonStart = jsonStr.indexOf('{');
      final jsonEnd = jsonStr.lastIndexOf('}');
      if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
        jsonStr = jsonStr.substring(jsonStart, jsonEnd + 1);
      }

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
        summary:
            jsonData['summary']?.toString() ??
            'A heart-healthy meal for children with CHD.',
        ingredients: _parseIngredients(jsonData['ingredients']),
        mealSteps: _parseSteps(jsonData['steps']),
        createdAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error parsing AI response: $e');
      debugPrint('Response was: $response');
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
      summary:
          'A heart-healthy meal suggestion based on your request. This meal is designed for children with congenital heart disease, focusing on low sodium, healthy fats, and essential nutrients.',
      ingredients: _getDefaultIngredients(),
      mealSteps: _getDefaultSteps(),
      createdAt: DateTime.now(),
    );
  }
}
