import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/prediction_cubit.dart';
import '../models/heart_disease_prediction.dart';
import '../widgets/lang_toggle_button.dart';
import '../localization/app_localizations.dart';

class HeartPredictionScreen extends StatefulWidget {
  const HeartPredictionScreen({super.key});

  @override
  State<HeartPredictionScreen> createState() => _HeartPredictionScreenState();
}

class _HeartPredictionScreenState extends State<HeartPredictionScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for form fields
  final _ageController = TextEditingController();
  final _sexController = TextEditingController();
  final _cpController = TextEditingController();
  final _trestbpsController = TextEditingController();
  final _cholController = TextEditingController();
  final _fbsController = TextEditingController();
  final _restecgController = TextEditingController();
  final _thalachController = TextEditingController();
  final _exangController = TextEditingController();
  final _oldpeakController = TextEditingController();
  final _slopeController = TextEditingController();
  final _caController = TextEditingController();
  final _thalController = TextEditingController();

  @override
  void dispose() {
    _ageController.dispose();
    _sexController.dispose();
    _cpController.dispose();
    _trestbpsController.dispose();
    _cholController.dispose();
    _fbsController.dispose();
    _restecgController.dispose();
    _thalachController.dispose();
    _exangController.dispose();
    _oldpeakController.dispose();
    _slopeController.dispose();
    _caController.dispose();
    _thalController.dispose();
    super.dispose();
  }

  void _submitPrediction() {
    if (!_formKey.currentState!.validate()) return;

    final request = HeartDiseasePredictionRequest(
      age: int.parse(_ageController.text),
      sex: int.parse(_sexController.text),
      cp: int.parse(_cpController.text),
      trestbps: int.parse(_trestbpsController.text),
      chol: int.parse(_cholController.text),
      fbs: int.parse(_fbsController.text),
      restecg: int.parse(_restecgController.text),
      thalach: int.parse(_thalachController.text),
      exang: int.parse(_exangController.text),
      oldpeak: double.parse(_oldpeakController.text),
      slope: int.parse(_slopeController.text),
      ca: int.parse(_caController.text),
      thal: int.parse(_thalController.text),
    );

    context.read<PredictionCubit>().predictHeartDisease(request);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Heart Disease Prediction'),
        actions: const [LangToggleButton()],
      ),
      body: BlocBuilder<PredictionCubit, PredictionState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Enter Patient Information',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Based on UCI Heart Disease Dataset',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Age
                  TextFormField(
                    controller: _ageController,
                    decoration: const InputDecoration(
                      labelText: 'Age (years)',
                      hintText: 'e.g., 63',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      final age = int.tryParse(v);
                      if (age == null || age < 0 || age > 120) {
                        return 'Age must be between 0-120';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Sex
                  DropdownButtonFormField<int>(
                    value: _sexController.text.isEmpty ? null : int.tryParse(_sexController.text),
                    decoration: const InputDecoration(
                      labelText: 'Sex',
                      hintText: 'Select sex',
                    ),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Female')),
                      DropdownMenuItem(value: 1, child: Text('Male')),
                    ],
                    onChanged: (v) {
                      if (v != null) _sexController.text = v.toString();
                    },
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),

                  // Chest Pain Type
                  DropdownButtonFormField<int>(
                    value: _cpController.text.isEmpty ? null : int.tryParse(_cpController.text),
                    decoration: const InputDecoration(
                      labelText: 'Chest Pain Type (cp)',
                      hintText: 'Select type',
                    ),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Typical angina')),
                      DropdownMenuItem(value: 1, child: Text('Atypical angina')),
                      DropdownMenuItem(value: 2, child: Text('Non-anginal pain')),
                      DropdownMenuItem(value: 3, child: Text('Asymptomatic')),
                    ],
                    onChanged: (v) {
                      if (v != null) _cpController.text = v.toString();
                    },
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),

                  // Resting Blood Pressure
                  TextFormField(
                    controller: _trestbpsController,
                    decoration: const InputDecoration(
                      labelText: 'Resting Blood Pressure (mm Hg)',
                      hintText: 'e.g., 145',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      final bp = int.tryParse(v);
                      if (bp == null || bp < 0 || bp > 300) {
                        return 'Valid range: 0-300';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Serum Cholesterol
                  TextFormField(
                    controller: _cholController,
                    decoration: const InputDecoration(
                      labelText: 'Serum Cholesterol (mg/dl)',
                      hintText: 'e.g., 233',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      final chol = int.tryParse(v);
                      if (chol == null || chol < 0 || chol > 600) {
                        return 'Valid range: 0-600';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Fasting Blood Sugar
                  DropdownButtonFormField<int>(
                    value: _fbsController.text.isEmpty ? null : int.tryParse(_fbsController.text),
                    decoration: const InputDecoration(
                      labelText: 'Fasting Blood Sugar > 120 mg/dl',
                      hintText: 'Select',
                    ),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('False')),
                      DropdownMenuItem(value: 1, child: Text('True')),
                    ],
                    onChanged: (v) {
                      if (v != null) _fbsController.text = v.toString();
                    },
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),

                  // Resting ECG
                  DropdownButtonFormField<int>(
                    value: _restecgController.text.isEmpty ? null : int.tryParse(_restecgController.text),
                    decoration: const InputDecoration(
                      labelText: 'Resting ECG',
                      hintText: 'Select',
                    ),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Normal')),
                      DropdownMenuItem(value: 1, child: Text('ST-T wave abnormality')),
                      DropdownMenuItem(value: 2, child: Text('Left ventricular hypertrophy')),
                    ],
                    onChanged: (v) {
                      if (v != null) _restecgController.text = v.toString();
                    },
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),

                  // Maximum Heart Rate
                  TextFormField(
                    controller: _thalachController,
                    decoration: const InputDecoration(
                      labelText: 'Maximum Heart Rate Achieved',
                      hintText: 'e.g., 150',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      final hr = int.tryParse(v);
                      if (hr == null || hr < 0 || hr > 250) {
                        return 'Valid range: 0-250';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Exercise Induced Angina
                  DropdownButtonFormField<int>(
                    value: _exangController.text.isEmpty ? null : int.tryParse(_exangController.text),
                    decoration: const InputDecoration(
                      labelText: 'Exercise Induced Angina',
                      hintText: 'Select',
                    ),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('No')),
                      DropdownMenuItem(value: 1, child: Text('Yes')),
                    ],
                    onChanged: (v) {
                      if (v != null) _exangController.text = v.toString();
                    },
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),

                  // ST Depression
                  TextFormField(
                    controller: _oldpeakController,
                    decoration: const InputDecoration(
                      labelText: 'ST Depression (oldpeak)',
                      hintText: 'e.g., 2.3',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      final val = double.tryParse(v);
                      if (val == null || val < 0 || val > 10) {
                        return 'Valid range: 0-10';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Slope
                  DropdownButtonFormField<int>(
                    value: _slopeController.text.isEmpty ? null : int.tryParse(_slopeController.text),
                    decoration: const InputDecoration(
                      labelText: 'Slope of Peak Exercise ST Segment',
                      hintText: 'Select',
                    ),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Upsloping')),
                      DropdownMenuItem(value: 1, child: Text('Flat')),
                      DropdownMenuItem(value: 2, child: Text('Downsloping')),
                    ],
                    onChanged: (v) {
                      if (v != null) _slopeController.text = v.toString();
                    },
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),

                  // Number of Major Vessels
                  DropdownButtonFormField<int>(
                    value: _caController.text.isEmpty ? null : int.tryParse(_caController.text),
                    decoration: const InputDecoration(
                      labelText: 'Number of Major Vessels (0-3)',
                      hintText: 'Select',
                    ),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('0')),
                      DropdownMenuItem(value: 1, child: Text('1')),
                      DropdownMenuItem(value: 2, child: Text('2')),
                      DropdownMenuItem(value: 3, child: Text('3')),
                    ],
                    onChanged: (v) {
                      if (v != null) _caController.text = v.toString();
                    },
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),

                  // Thalassemia
                  DropdownButtonFormField<int>(
                    value: _thalController.text.isEmpty ? null : int.tryParse(_thalController.text),
                    decoration: const InputDecoration(
                      labelText: 'Thalassemia',
                      hintText: 'Select',
                    ),
                    items: const [
                      DropdownMenuItem(value: 3, child: Text('Normal')),
                      DropdownMenuItem(value: 6, child: Text('Fixed defect')),
                      DropdownMenuItem(value: 7, child: Text('Reversable defect')),
                    ],
                    onChanged: (v) {
                      if (v != null) _thalController.text = v.toString();
                    },
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  ElevatedButton(
                    onPressed: state.isLoading ? null : _submitPrediction,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: state.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Predict Heart Disease'),
                  ),

                  // Error Display
                  if (state.error != null) ...[
                    const SizedBox(height: 16),
                    Card(
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline,
                                color: Theme.of(context).colorScheme.onErrorContainer),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                state.error!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onErrorContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Prediction Result
                  if (state.prediction != null) ...[
                    const SizedBox(height: 24),
                    Card(
                      color: state.prediction!.hasDisease
                          ? Theme.of(context).colorScheme.errorContainer
                          : Theme.of(context).colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  state.prediction!.hasDisease
                                      ? Icons.warning
                                      : Icons.check_circle,
                                  color: state.prediction!.hasDisease
                                      ? Theme.of(context).colorScheme.onErrorContainer
                                      : Theme.of(context).colorScheme.onPrimaryContainer,
                                  size: 32,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        state.prediction!.hasDisease
                                            ? 'Heart Disease Detected'
                                            : 'No Heart Disease',
                                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          color: state.prediction!.hasDisease
                                              ? Theme.of(context).colorScheme.onErrorContainer
                                              : Theme.of(context).colorScheme.onPrimaryContainer,
                                        ),
                                      ),
                                      Text(
                                        'Risk Level: ${state.prediction!.riskLevel}',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: state.prediction!.hasDisease
                                              ? Theme.of(context).colorScheme.onErrorContainer
                                              : Theme.of(context).colorScheme.onPrimaryContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            LinearProgressIndicator(
                              value: state.prediction!.probability,
                              backgroundColor: Theme.of(context).colorScheme.surface,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Probability: ${(state.prediction!.probability * 100).toStringAsFixed(1)}%',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: state.prediction!.hasDisease
                                    ? Theme.of(context).colorScheme.onErrorContainer
                                    : Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.prediction!.recommendation,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: state.prediction!.hasDisease
                                    ? Theme.of(context).colorScheme.onErrorContainer
                                    : Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Model: ${state.prediction!.model}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: state.prediction!.hasDisease
                                    ? Theme.of(context).colorScheme.onErrorContainer
                                    : Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

