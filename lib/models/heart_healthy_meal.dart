/// Heart-healthy meal suggestion model for children with heart disease
class HeartHealthyMeal {
  final String id;
  final String name;
  final List<String> mealType; // ["breakfast", "lunch", "dinner"]
  final double rating;
  final int cookTime; // minutes
  final int servingSize;
  final String summary;
  final List<MealIngredient> ingredients;
  final List<String> mealSteps;
  final String? imageUrl;
  final DateTime createdAt;

  const HeartHealthyMeal({
    required this.id,
    required this.name,
    required this.mealType,
    required this.rating,
    required this.cookTime,
    required this.servingSize,
    required this.summary,
    required this.ingredients,
    required this.mealSteps,
    this.imageUrl,
    required this.createdAt,
  });

  factory HeartHealthyMeal.fromJson(Map<String, dynamic> json) {
    return HeartHealthyMeal(
      id: json['id'] as String? ?? '',
      name: json['name'] as String,
      mealType: (json['mealType'] as List<dynamic>? ?? json['meal_type'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      cookTime: (json['cookTime'] as int?) ?? json['cook_time'] as int? ?? 30,
      servingSize: (json['servingSize'] as int?) ?? json['serving_size'] as int? ?? 4,
      summary: json['summary'] as String,
      ingredients: (json['ingredients'] as List<dynamic>?)
          ?.map((e) => MealIngredient.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      mealSteps: (json['mealSteps'] as List<dynamic>? ?? json['meal_steps'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      imageUrl: json['imageUrl'] as String? ?? json['image_url'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mealType': mealType,
      'rating': rating,
      'cookTime': cookTime,
      'servingSize': servingSize,
      'summary': summary,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
      'mealSteps': mealSteps,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  HeartHealthyMeal copyWith({
    String? id,
    String? name,
    List<String>? mealType,
    double? rating,
    int? cookTime,
    int? servingSize,
    String? summary,
    List<MealIngredient>? ingredients,
    List<String>? mealSteps,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return HeartHealthyMeal(
      id: id ?? this.id,
      name: name ?? this.name,
      mealType: mealType ?? this.mealType,
      rating: rating ?? this.rating,
      cookTime: cookTime ?? this.cookTime,
      servingSize: servingSize ?? this.servingSize,
      summary: summary ?? this.summary,
      ingredients: ingredients ?? this.ingredients,
      mealSteps: mealSteps ?? this.mealSteps,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class MealIngredient {
  final String name;
  final String quantity;
  final String? imageUrl;

  const MealIngredient({
    required this.name,
    required this.quantity,
    this.imageUrl,
  });

  factory MealIngredient.fromJson(Map<String, dynamic> json) {
    return MealIngredient(
      name: json['name'] as String,
      quantity: json['quantity'] as String? ?? json['amount'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }
}

