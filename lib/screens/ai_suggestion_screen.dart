import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/ai_suggestion_cubit.dart';
import '../cubits/ai_suggestion_states.dart';
import '../models/heart_healthy_meal.dart';
import '../widgets/lang_toggle_button.dart';

class AISuggestionScreen extends StatefulWidget {
  const AISuggestionScreen({super.key});

  @override
  State<AISuggestionScreen> createState() => _AISuggestionScreenState();
}

class _AISuggestionScreenState extends State<AISuggestionScreen> {
  final _ingredientsController = TextEditingController();

  @override
  void dispose() {
    _ingredientsController.dispose();
    super.dispose();
  }

  void _getSuggestions() {
    final ingredients = _ingredientsController.text.trim();
    context.read<AISuggestionCubit>().getSuggestions(ingredients);
  }

  void _saveToFirestore() {
    final ingredients = _ingredientsController.text.trim();
    context.read<AISuggestionCubit>().saveSuggestionToFirestore(ingredients);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AISuggestionCubit, AISuggestionState>(
      listener: (context, state) {
        if (state is AISuggestionSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Suggestion saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('AI Health Suggestions'),
          actions: const [LangToggleButton()],
        ),
        body: BlocBuilder<AISuggestionCubit, AISuggestionState>(
          builder: (context, state) {
            final isLoading = state is AISuggestionLoading;
            final isSaving = state is AISuggestionSaving;
            final hasError = state is AISuggestionError;
            final hasSuggestion = state is AISuggestionSuccess ||
                state is AISuggestionSaving ||
                state is AISuggestionSaved ||
                (state is AISuggestionError && state.previousSuggestion != null);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                color: Theme.of(context).colorScheme.primary,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Heart-Healthy Meal Suggestions',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Get personalized, heart-healthy meal suggestions for children with heart disease. All suggestions are low in sodium and designed for cardiovascular health.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  TextField(
                    controller: _ingredientsController,
                    decoration: InputDecoration(
                      labelText: 'Ingredients or Meal Description',
                      hintText: 'e.g., chicken, rice, vegetables or "I want a healthy breakfast for my child"',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.edit_note),
                      filled: true,
                      fillColor: Colors.grey[50],
                      helperText: 'Designed for children with heart disease - low sodium, heart-healthy',
                    ),
                    maxLines: 4,
                    minLines: 3,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _getSuggestions(),
                    enabled: !isLoading && !isSaving,
                  ),
                  const SizedBox(height: 16),

                  ElevatedButton.icon(
                    onPressed: (isLoading || isSaving) ? null : _getSuggestions,
                    icon: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                    label: Text(isLoading ? 'Getting Suggestions...' : 'Get Suggestions'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  if (hasError) ...[
                    const SizedBox(height: 16),
                    Card(
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Theme.of(context).colorScheme.onErrorContainer,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                (state).message,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onErrorContainer,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                color: Theme.of(context).colorScheme.onErrorContainer,
                                size: 20,
                              ),
                              onPressed: () => context.read<AISuggestionCubit>().clearError(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  if (hasSuggestion) ...[
                    const SizedBox(height: 24),
                    _buildSuggestionCard(_getSuggestionFromState(state)),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  HeartHealthyMeal? _getSuggestionFromState(AISuggestionState state) {
    if (state is AISuggestionSuccess) {
      return state.suggestion;
    } else if (state is AISuggestionSaving) {
      return state.suggestion;
    } else if (state is AISuggestionSaved) {
      return state.suggestion;
    } else if (state is AISuggestionError) {
      return state.previousSuggestion;
    }
    return null;
  }

  Widget _buildSuggestionCard(HeartHealthyMeal? result) {
    if (result == null) return const SizedBox.shrink();
    
    final cubitState = context.read<AISuggestionCubit>().state;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber[300],
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            result.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.access_time,
                            color: Colors.white70,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${result.cookTime} min',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (result.mealType.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      result.mealType.join(', ').toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (result.summary.isNotEmpty) ...[
                  Text(
                    'Overview',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result.summary,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                ],

                if (result.ingredients.isNotEmpty) ...[
                  Text(
                    'Ingredients',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _buildIngredientsList(result.ingredients),
                  const SizedBox(height: 24),
                ],

                if (result.mealSteps.isNotEmpty) ...[
                  Text(
                    'Cooking Steps',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _buildStepsList(result.mealSteps),
                ],
              ],
            ),
          ),

          BlocBuilder<AISuggestionCubit, AISuggestionState>(
            builder: (context, cubitState) {
              final isSaving = cubitState is AISuggestionSaving;
              final isLoading = cubitState is AISuggestionLoading;
              final canSave = cubitState is AISuggestionSuccess || 
                             cubitState is AISuggestionSaved ||
                             (cubitState is AISuggestionError && cubitState.previousSuggestion != null);

              return Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: (isSaving || isLoading || !canSave) ? null : _saveToFirestore,
                    icon: isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(isSaving ? 'Saving...' : 'Save to My Suggestions'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsList(List<MealIngredient> ingredients) {
    if (ingredients.isEmpty) return const SizedBox.shrink();
    
    List<Widget> items = [];
    
    for (int i = 0; i < ingredients.length; i++) {
      final ingredient = ingredients[i];
      final name = ingredient.name;
      final quantity = ingredient.quantity;

      items.add(
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    if (quantity.isNotEmpty)
                      Text(
                        quantity,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(children: items);
  }

  Widget _buildStepsList(List<String> steps) {
    if (steps.isEmpty) return const SizedBox.shrink();
    
    List<Widget> items = [];
    
    for (int i = 0; i < steps.length; i++) {
      final step = steps[i];
      if (step.isEmpty) continue;

      items.add(
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    step,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(children: items);
  }

}

