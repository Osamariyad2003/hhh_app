import 'dart:math';
import '../models/heart_healthy_meal.dart';

/// Simple template-based meal suggestion service for children with heart disease
/// No external AI API required - uses keyword matching and templates
class HeartMealSuggestionService {
  HeartMealSuggestionService._();
  static final HeartMealSuggestionService instance = HeartMealSuggestionService._();

  final _random = Random();

  /// Generate a heart-healthy meal suggestion based on user input
  Future<HeartHealthyMeal> getMealSuggestion(String userInput) async {
    // Normalize input
    final input = userInput.toLowerCase().trim();
    
    // Determine meal type based on keywords or time of day
    final mealType = _determineMealType(input);
    
    // Match ingredients from input
    final matchedIngredients = _extractIngredients(input);
    
    // Generate meal based on matched ingredients
    final meal = _generateMealFromIngredients(matchedIngredients, mealType);
    
    // Simulate a small delay for better UX
    await Future.delayed(const Duration(milliseconds: 500));
    
    return meal;
  }

  List<String> _determineMealType(String input) {
    final now = DateTime.now();
    final hour = now.hour;
    
    // Check for explicit meal type mentions
    if (input.contains('breakfast') || input.contains('morning')) {
      return ['breakfast'];
    } else if (input.contains('lunch') || input.contains('noon') || input.contains('midday')) {
      return ['lunch'];
    } else if (input.contains('dinner') || input.contains('evening') || input.contains('night')) {
      return ['dinner'];
    }
    
    // Default based on time of day
    if (hour >= 6 && hour < 11) {
      return ['breakfast'];
    } else if (hour >= 11 && hour < 16) {
      return ['lunch'];
    } else {
      return ['dinner'];
    }
  }

  List<String> _extractIngredients(String input) {
    final commonIngredients = [
      'chicken', 'fish', 'salmon', 'tuna', 'turkey',
      'rice', 'quinoa', 'oats', 'pasta', 'bread',
      'vegetables', 'carrots', 'broccoli', 'spinach', 'tomatoes', 'potatoes',
      'eggs', 'milk', 'cheese', 'yogurt',
      'fruits', 'apples', 'bananas', 'berries', 'oranges',
      'beans', 'lentils', 'chickpeas',
      'avocado', 'olive oil', 'nuts', 'seeds',
    ];
    
    final matched = <String>[];
    for (final ingredient in commonIngredients) {
      if (input.contains(ingredient)) {
        matched.add(ingredient);
      }
    }
    
    // If no matches, use default heart-healthy ingredients
    if (matched.isEmpty) {
      return ['chicken', 'rice', 'vegetables'];
    }
    
    return matched.take(5).toList();
  }

  HeartHealthyMeal _generateMealFromIngredients(List<String> ingredients, List<String> mealType) {
    final mealName = _generateMealName(ingredients, mealType.first);
    final mealTemplate = _getMealTemplate(ingredients, mealType.first);
    
    return HeartHealthyMeal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: mealName,
      mealType: mealType,
      rating: 4.0 + (_random.nextDouble() * 0.8), // 4.0 to 4.8
      cookTime: 20 + _random.nextInt(40), // 20-60 minutes
      servingSize: 2 + _random.nextInt(4), // 2-5 servings
      summary: mealTemplate['summary'] as String,
      ingredients: mealTemplate['ingredients'] as List<MealIngredient>,
      mealSteps: mealTemplate['steps'] as List<String>,
      createdAt: DateTime.now(),
    );
  }

  String _generateMealName(List<String> ingredients, String mealType) {
    final primaryIngredient = ingredients.isNotEmpty ? ingredients.first : 'Healthy';
    final mealNames = {
      'breakfast': [
        'Heart-Healthy $primaryIngredient Oatmeal',
        'Nutritious $primaryIngredient Breakfast Bowl',
        'Child-Friendly $primaryIngredient Morning Meal',
        'Low-Sodium $primaryIngredient Breakfast',
      ],
      'lunch': [
        'Heart-Smart $primaryIngredient Lunch',
        'Balanced $primaryIngredient Meal for Kids',
        'Healthy $primaryIngredient Lunch Plate',
        'Child-Friendly $primaryIngredient Dish',
      ],
      'dinner': [
        'Heart-Healthy $primaryIngredient Dinner',
        'Nutritious $primaryIngredient Evening Meal',
        'Low-Sodium $primaryIngredient Dinner',
        'Balanced $primaryIngredient Family Meal',
      ],
    };
    
    final names = mealNames[mealType] ?? mealNames['lunch']!;
    return names[_random.nextInt(names.length)];
  }

  Map<String, dynamic> _getMealTemplate(List<String> ingredients, String mealType) {
    final primaryIngredient = ingredients.isNotEmpty ? ingredients.first : 'chicken';
    
    if (mealType == 'breakfast') {
      return {
        'summary': 'A heart-healthy breakfast designed for children with heart conditions. This meal is low in sodium, contains healthy fats, and provides essential nutrients. Perfect for starting the day with energy while supporting cardiovascular health. Contains approximately 250-300 calories per serving.',
        'ingredients': [
          MealIngredient(name: 'Rolled Oats', quantity: '1 cup'),
          MealIngredient(name: 'Low-Fat Milk', quantity: '1 cup'),
          MealIngredient(name: 'Fresh Berries', quantity: '1/2 cup'),
          MealIngredient(name: 'Banana', quantity: '1 small, sliced'),
          MealIngredient(name: 'Honey', quantity: '1 teaspoon'),
          MealIngredient(name: 'Chia Seeds', quantity: '1 tablespoon'),
        ],
        'steps': [
          'Heat the milk in a small saucepan over medium heat until warm (do not boil).',
          'Add the rolled oats and stir gently. Cook for 5-7 minutes until creamy.',
          'Remove from heat and let cool slightly (important for children).',
          'Transfer to a bowl and top with fresh berries and banana slices.',
          'Drizzle with honey and sprinkle chia seeds on top.',
          'Serve warm and ensure it\'s at a safe temperature for your child.',
        ],
      };
    } else if (mealType == 'lunch') {
      return {
        'summary': 'A balanced, heart-healthy lunch perfect for children with heart disease. This meal is low in sodium, rich in lean protein and vegetables, and uses heart-friendly cooking methods. Provides essential vitamins and minerals while maintaining cardiovascular health. Contains approximately 350-400 calories per serving.',
        'ingredients': [
          MealIngredient(name: 'Lean Chicken Breast', quantity: '150g, diced'),
          MealIngredient(name: 'Brown Rice', quantity: '1/2 cup, cooked'),
          MealIngredient(name: 'Steamed Broccoli', quantity: '1 cup'),
          MealIngredient(name: 'Carrots', quantity: '1/2 cup, sliced'),
          MealIngredient(name: 'Olive Oil', quantity: '1 teaspoon'),
          MealIngredient(name: 'Lemon Juice', quantity: '1 tablespoon'),
        ],
        'steps': [
          'Cook brown rice according to package instructions (use low-sodium method).',
          'Cut chicken breast into small, child-friendly pieces.',
          'Heat olive oil in a non-stick pan over medium heat.',
          'Cook chicken pieces for 6-8 minutes until fully cooked and tender.',
          'Steam broccoli and carrots until soft (important for easy chewing).',
          'Arrange rice, chicken, and vegetables on a plate.',
          'Drizzle with fresh lemon juice for flavor (no added salt).',
          'Let cool to safe temperature before serving to your child.',
        ],
      };
    } else {
      // dinner
      return {
        'summary': 'A nutritious, heart-healthy dinner designed specifically for children with heart conditions. This meal emphasizes lean protein, whole grains, and vegetables while being low in sodium and saturated fats. Supports healthy growth and cardiovascular function. Contains approximately 400-450 calories per serving.',
        'ingredients': [
          MealIngredient(name: 'Baked Salmon', quantity: '100g fillet'),
          MealIngredient(name: 'Quinoa', quantity: '1/2 cup, cooked'),
          MealIngredient(name: 'Steamed Vegetables', quantity: '1 cup mixed'),
          MealIngredient(name: 'Sweet Potato', quantity: '1/2 medium, baked'),
          MealIngredient(name: 'Olive Oil', quantity: '1 teaspoon'),
          MealIngredient(name: 'Fresh Herbs', quantity: '1 tablespoon, chopped'),
        ],
        'steps': [
          'Preheat oven to 180°C (356°F).',
          'Place salmon fillet on a baking sheet lined with parchment paper.',
          'Drizzle with olive oil and sprinkle with fresh herbs (no salt).',
          'Bake for 12-15 minutes until fish flakes easily.',
          'Cook quinoa according to package instructions (low-sodium method).',
          'Bake sweet potato until soft (about 30-40 minutes).',
          'Steam mixed vegetables until tender but still colorful.',
          'Arrange all components on a plate and let cool to safe temperature.',
          'Ensure all pieces are small and easy for your child to eat.',
        ],
      };
    }
  }
}

