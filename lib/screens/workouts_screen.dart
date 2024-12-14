import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../styles/styles.dart';
import '../api services/workout_api_service.dart';

class Exercise {
  final String id;
  final String name;
  final String bodyPart;
  final String equipment;
  final String gifUrl;
  bool isCompleted; // Added to track completion status
  String notes; // Added to store user notes

  Exercise({
    required this.id,
    required this.name,
    required this.bodyPart,
    required this.equipment,
    required this.gifUrl,
    this.isCompleted = false,
    this.notes = '',
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unnamed Exercise',
      bodyPart: json['bodyPart'] ?? 'Unknown',
      equipment: json['equipment'] ?? 'No Equipment',
      gifUrl: json['gifUrl'] ?? '',
    );
  }

  void loadFromPrefs(SharedPreferences prefs) {
    isCompleted = prefs.getBool('exercise_${id}_completed') ?? false;
    notes = prefs.getString('exercise_${id}_notes') ?? '';
  }

  void saveToPrefs(SharedPreferences prefs) {
    prefs.setBool('exercise_${id}_completed', isCompleted);
    prefs.setString('exercise_${id}_notes', notes);
  }
}

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});
  static const String routeName = '/workouts';

  @override
  _WorkoutsScreenState createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  final WorkoutApiService _workoutApiService = WorkoutApiService();
  late Future<List<Exercise>> _gymWorkouts;
  late Future<List<Exercise>> _bodyWeightWorkouts;

  SharedPreferences? _prefs;
  final TextEditingController _overallNotesController = TextEditingController();
  final String _overallNotesKey = 'overall_notes';

  @override
  void initState() {
    super.initState();
    _initializePrefsAndFetchWorkouts();
  }

  Future<void> _initializePrefsAndFetchWorkouts() async {
    _prefs = await SharedPreferences.getInstance();

    _overallNotesController.text = _prefs?.getString(_overallNotesKey) ?? '';

    setState(() {
      _gymWorkouts = fetchGymWorkouts();
      _bodyWeightWorkouts = fetchWorkouts(equipment: 'body weight');
    });
  }

  Future<List<Exercise>> fetchWorkouts({String? bodyPart, String? equipment}) async {
    try {
      final workouts = await _workoutApiService.fetchWorkouts(
        bodyPart: bodyPart,
        equipment: equipment,
      );
      List<Exercise> exercises = workouts.map((workout) => Exercise.fromJson(workout)).toList();

      if (_prefs != null) {
        for (var exercise in exercises) {
          exercise.loadFromPrefs(_prefs!);
        }
      }

      return exercises;
    } catch (e) {
      throw Exception('Failed to fetch workouts: $e');
    }
  }

  Future<List<Exercise>> fetchGymWorkouts() async {
    try {
      List<String> gymEquipment = [
        'barbell',
        'dumbbell',
        'cable',
        'leverage machine',
        'smith machine',
        'kettlebell',
        'medicine ball',
        'band',
        'ez barbell',
      ];

      List<Exercise> allExercises = [];

      for (String equipment in gymEquipment) {
        await Future.delayed(const Duration(milliseconds: 500));
        final exercises = await fetchWorkouts(equipment: equipment);
        allExercises.addAll(exercises);
      }

      Map<String, Exercise> exerciseMap = {
        for (var exercise in allExercises) exercise.id: exercise
      };

      if (_prefs != null) {
        for (var exercise in exerciseMap.values) {
          exercise.loadFromPrefs(_prefs!);
        }
      }

      return exerciseMap.values.toList();
    } catch (e) {
      throw Exception('Failed to fetch gym workouts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Workouts', style: AppTextStyles.title.copyWith(color: Colors.white)),
        backgroundColor: AppColors.background,
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: true, // Prevents overflow when keyboard appears
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/better_you.webp',
                    height: 200,
                    width: 200,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Stay consistent and embrace the challenge. Every rep and every set gets you closer to a stronger, healthier you. Let's do this!",
                    style: AppTextStyles.body.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                _buildWorkoutSection('Gym Workouts', _gymWorkouts),
                _buildWorkoutSection('Body Weight Workouts', _bodyWeightWorkouts),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildNotesSection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutSection(String title, Future<List<Exercise>> workouts) {
    return FutureBuilder<List<Exercise>>(
      future: workouts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Error: ${snapshot.error}',
                style: AppTextStyles.body.copyWith(color: Colors.white)),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('No workouts found.',
                style: AppTextStyles.body.copyWith(color: Colors.white)),
          );
        } else {
          return _buildWorkoutList(title, snapshot.data!);
        }
      },
    );
  }

  Widget _buildWorkoutList(String title, List<Exercise> exercises) {
    return Card(
      color: AppColors.cardBackground,
      margin: const EdgeInsets.all(8.0),
      child: ExpansionTile(
        title: Text(title, style: AppTextStyles.subtitle.copyWith(color: Colors.white)),
        children: exercises.map((exercise) {
          return CheckboxListTile(
            title: Text(exercise.name,
                style: AppTextStyles.body.copyWith(color: Colors.white)),
            subtitle: Text(
              'Equipment: ${exercise.equipment}',
              style: TextStyle(
                color: Colors.white70,
              ),
            ),
            activeColor: AppColors.primary,
            checkColor: Colors.white,
            value: exercise.isCompleted,
            onChanged: (bool? value) {
              setState(() {
                exercise.isCompleted = value ?? false;
                if (_prefs != null) {
                  exercise.saveToPrefs(_prefs!);
                }
              });
            },
            secondary: IconButton(
              icon: Icon(Icons.info_outline, color: Colors.white),
              onPressed: () => _showExerciseDetails(context, exercise),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Overall Notes:',
            style: AppTextStyles.subtitle.copyWith(color: Colors.white)),
        const SizedBox(height: 8),
        TextField(
          controller: _overallNotesController,
          decoration: InputDecoration(
            hintText: 'Add your notes here...',
            hintStyle: TextStyle(color: Colors.white70),
            border: OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white70),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
          maxLines: 3,
          style: TextStyle(color: Colors.white),
          onChanged: (value) {
            _prefs?.setString(_overallNotesKey, value);
          },
        ),
      ],
    );
  }

  void _showExerciseDetails(BuildContext context, Exercise exercise) {
    TextEditingController _notesController =
    TextEditingController(text: exercise.notes);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: Text(exercise.name,
              style: AppTextStyles.dialogTitle.copyWith(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (exercise.gifUrl.isNotEmpty) Image.network(exercise.gifUrl),
                const SizedBox(height: 8),
                Text('Body Part: ${exercise.bodyPart}',
                    style: TextStyle(color: Colors.white)),
                Text(
                  'Equipment: ${exercise.equipment}',
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: 'Notes',
                    labelStyle: TextStyle(color: Colors.white),
                    hintText: 'Add your notes here...',
                    hintStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  maxLines: 3,
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  exercise.notes = _notesController.text;
                  if (_prefs != null) {
                    exercise.saveToPrefs(_prefs!);
                  }
                });
                Navigator.pop(context);
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
