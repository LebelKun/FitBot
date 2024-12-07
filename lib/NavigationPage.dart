import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NavigationPage(),
    );
  }
}

class NavigationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Navigation'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => DietPage()));
            },
            child: Text('Diet'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PageTwo()));
            },
            child: Text('Interactive'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PageThree()));
            },
            child: Text('Solo'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PageFive()));
            },
            child: Text('Trainer'),
          ),
        ],
      ),
    );
  }
}

class DietPage extends StatefulWidget {
  @override
  _DietPageState createState() => _DietPageState();
}

class _DietPageState extends State<DietPage> {
  TextEditingController _caloriesController = TextEditingController();
  int _totalCalories = 0;
  List<DayCalories> _dailyCalories = [];
  late DatabaseHelper _dbHelper;

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _caloriesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter Calories',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _totalCalories += int.parse(_caloriesController.text);
                  _caloriesController.clear();
                });
              },
              child: Text('Add Calories'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _totalCalories -= int.parse(_caloriesController.text);
                  _caloriesController.clear();
                });
              },
              child: Text('Calories Burned'),
            ),
            SizedBox(height: 20),
            Text(
              'Total Calories: $_totalCalories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () {
                _calculateTotalCalories(context);
              },
              child: Text('Calculate Now'),
            ),
            ElevatedButton(
              onPressed: () {
                _saveData(); // Call the save function here
              },
              child: Text('Save Calories'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _dailyCalories.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      '${_dailyCalories[index].date}: ${_dailyCalories[index].calories} calories',
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _deleteEntry(_dailyCalories[index].id);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _calculateTotalCalories(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Total Calories'),
          content: Text('You had $_totalCalories total calories for today.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _deleteEntry(int id) {
    _dbHelper.deleteEntry('DietEntries', id);
    _loadData(); // Reload data after deletion
  }

  void _loadData() async {
    List<Map<String, dynamic>> entries = await _dbHelper.getAllEntries('DietEntries');
    setState(() {
      _dailyCalories = entries.map((entry) {
        return DayCalories(
          id: entry['id'],
          date: entry['date'],
          calories: entry['calories'],
        );
      }).toList();
    });
  }

  void _saveData() async {
    // Create a new entry with today's date and total calories
    Map<String, dynamic> newEntry = {
      'date': DateTime.now().toIso8601String(), // Save the current date
      'calories': _totalCalories,
    };

    await _dbHelper.insertEntry('DietEntries', newEntry); // Save to database
    _loadData(); // Reload data after saving
    setState(() {
      _totalCalories = 0; // Reset total calories after saving
    });
  }
}

class DayCalories {
  final int id;
  final String date;
  final int calories;

  DayCalories({required this.id, required this.date, required this.calories});
}

class PageTwo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Interactive'),
      ),
      body: InteractivePage(),
    );
  }
}

class InteractivePage extends StatefulWidget {
  @override
  _InteractivePageState createState() => _InteractivePageState();
}

class _InteractivePageState extends State<InteractivePage> {
  Timer? _timer;
  int _counter = 0;
  bool _isTimerRunning = false;
  final TextEditingController _timeController = TextEditingController();

  void _startTimer() {
    if (_timeController.text.isNotEmpty) {
      setState(() {
        _counter = int.parse(_timeController.text);
        _isTimerRunning = true;
      });

      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (_counter > 0) {
          setState(() {
            _counter--;
          });
        } else {
          _stopTimer(); // Stop the timer when it reaches zero
        }
      });
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isTimerRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _counter = 0;
      _isTimerRunning = false;
      _timeController.clear(); // Clear the input field
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Added padding for the entire layout
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Countdown Timer: $_counter seconds',
                style: TextStyle(fontSize: 20), // Reduced font size
              ),
              SizedBox(height: 12), // Reduced space
              TextField(
                controller: _timeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter time in seconds',
                  border: OutlineInputBorder(), // Added border for better visibility
                ),
                style: TextStyle(fontSize: 16), // Smaller text for input
              ),
              SizedBox(height: 12), // Reduced space
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _isTimerRunning ? null : _startTimer,
                    child: Text('Start', style: TextStyle(fontSize: 14)), // Smaller button text
                  ),
                  ElevatedButton(
                    onPressed: _stopTimer,
                    child: Text('Stop', style: TextStyle(fontSize: 14)), // Smaller button text
                  ),
                  ElevatedButton(
                    onPressed: _resetTimer,
                    child: Text('Reset', style: TextStyle(fontSize: 14)), // Smaller button text
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timeController.dispose();
    super.dispose();
  }
}

class PageThree extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SoloPage(),
    );
  }
}

class SoloPage extends StatefulWidget {
  @override
  _SoloPageState createState() => _SoloPageState();
}

class _SoloPageState extends State<SoloPage> {
  List<Task> _tasks = [
    Task(id: 1, name: 'Running', completed: false),
    Task(id: 2, name: 'Sit ups', completed: false),
    Task(id: 3, name: 'Pull-ups', completed: false),
    Task(id: 4, name: 'Jumping Jacks', completed: false),
    Task(id: 5, name: 'Wall Sits', completed: false),
    Task(id: 6, name: 'Abdominal Crunch', completed: false),
    Task(id: 7, name: 'Squat', completed: false),
    Task(id: 8, name: 'Plank', completed: false),
    Task(id: 9, name: 'Lunge', completed: false),
    Task(id: 10, name: 'Side Plank', completed: false),
    Task(id: 11, name: 'High Knees', completed: false),
    Task(id: 12, name: '30-second Workout of Choice', completed: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Solo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Workouts',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    title: Text(_tasks[index].name),
                    value: _tasks[index].completed,
                    onChanged: (bool? value) {
                      setState(() {
                        _tasks[index].completed = value!;
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Task {
  final int id;
  final String name;
  bool completed;

  Task({required this.id, required this.name, required this.completed});
}

class PageFive extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trainer'),
      ),
      body: TrainerPage(),
    );
  }
}

class TrainerPage extends StatelessWidget {
  final List<Map<String, String>> trainers = [
    {'name': 'Stephen', 'specialty': 'Running', 'description': 'An expert in running techniques to improve endurance and speed.'},
    {'name': 'Amy', 'specialty': 'Sit-ups', 'description': 'Focuses on core-strengthening exercises, including effective sit-up techniques.'},
    {'name': 'Brad', 'specialty': 'Pull-ups', 'description': 'Specializes in upper body strength and perfecting pull-up form.'},
    {'name': 'Cynthia', 'specialty': 'Jumping Jacks', 'description': 'Leads high-energy cardio sessions incorporating jumping jacks.'},
    {'name': 'Marilyn', 'specialty': 'Wall Sits', 'description': 'Teaches techniques to build leg strength and endurance through wall sits.'},
    {'name': 'David', 'specialty': 'Abdominal Crunch', 'description': 'A core training expert, focusing on safe and effective crunch variations.'},
    {'name': 'Max', 'specialty': 'Squat', 'description': 'Specializes in lower body strength training with squats as a cornerstone exercise.'},
    {'name': 'Ben', 'specialty': 'Plank', 'description': 'Teaches planking techniques to improve core stability and endurance.'},
    {'name': 'Samantha', 'specialty': 'Lunge', 'description': 'Focuses on building strength and balance through lunges and related exercises.'},
    {'name': 'Selena', 'specialty': 'Side Plank', 'description': 'Combines core stability and oblique strengthening with side plank exercises.'},
    {'name': 'Justin', 'specialty': 'High Knees', 'description': 'Incorporates high knees into dynamic cardio workouts for agility and endurance.'},
    {'name': 'Jonathan', 'specialty': '30-second Workouts', 'description': 'Designs intense 30-second workout routines tailored to individual needs.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: trainers.length,
        itemBuilder: (context, index) {
          final trainer = trainers[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text(trainer['name']![0]),
            ),
            title: Text(trainer['name']!),
            subtitle: Text(trainer['specialty']!),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TrainerDetailPage(trainer: trainer),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class TrainerDetailPage extends StatelessWidget {
  final Map<String, String> trainer;

  TrainerDetailPage({required this.trainer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(trainer['name']!),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              trainer['name']!,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Specialty: ${trainer['specialty']}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              trainer['description']!,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}


class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'diet_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE DietEntries(id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, calories INTEGER)',
        );
      },
    );
  }

  Future<void> insertEntry(String table, Map<String, dynamic> data) async {
    final db = await database;
    await db.insert(table, data);
  }

  Future<List<Map<String, dynamic>>> getAllEntries(String table) async {
    final db = await database;
    return await db.query(table);
  }

  Future<void> deleteEntry(String table, int id) async {
    final db = await database;
    await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }
}
