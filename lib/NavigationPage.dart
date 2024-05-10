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
    List<Map<String, dynamic>> data = [];
    _dailyCalories.forEach((entry) {
      data.add({
        'date': entry.date,
        'calories': entry.calories,
      });
    });

    // Delete existing data before saving new data to avoid duplication
    await _dbHelper.deleteAllEntries('DietEntries');

    await _dbHelper.insertMultipleEntries('DietEntries', data);
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

  void _startTimer() {
    if (!_isTimerRunning) {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          _counter++;
        });
      });
      _isTimerRunning = true;
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    _isTimerRunning = false;
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _counter = 0;
      _isTimerRunning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Timer: $_counter seconds'),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _startTimer,
                  child: Text('Start Timer'),
                ),
                ElevatedButton(
                  onPressed: _stopTimer,
                  child: Text('Stop Timer'),
                ),
                ElevatedButton(
                  onPressed: _resetTimer,
                  child: Text('Reset Timer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
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
              'Workouts should be 30 seconds each',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    title: Text(_tasks[index].name),
                    value: _tasks[index].completed,
                    onChanged: (value) {
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

  void _saveData() {
    // Save the data to a database or perform any necessary action
    print('Tasks: $_tasks');
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
  final List<String> contactNames = [
    'Stephen',
    'Brad',
    'Amy',
    'Marilyn',
    'Max',
    'Alfred',
    'Ben',
    'David',
    'Cynthia',
    'Samantha',
    'Alex',
    'Jacob',
    'Jamie',
    'Isabel',
    'Tiffany',
    'Justin',
    'Jonathan',
    'Ethan',
    'Selena',
    'Kate'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: contactNames.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              child: Text(contactNames[index][0]),
            ),
            title: Text(contactNames[index]),
          );
        },
      ),
    );
  }
}

class DatabaseHelper {
  static Database? _database;
  static const String dbName = 'my_database.db';

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), dbName);
    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
         CREATE TABLE DietEntries(
           id INTEGER PRIMARY KEY AUTOINCREMENT,
           date TEXT,
           calories INTEGER
         )
       ''');
    await db.execute('''
         CREATE TABLE SoloTasks(
           id INTEGER PRIMARY KEY AUTOINCREMENT,
           name TEXT,
           completed INTEGER
         )
       ''');
  }

  Future<List<Map<String, dynamic>>> getAllEntries(String tableName) async {
    final db = await database;
    return await db.query(tableName);
  }

  Future<void> deleteEntry(String tableName, int id) async {
    final db = await database;
    await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllEntries(String tableName) async {
    final db = await database;
    await db.delete(tableName);
  }

  Future<void> insertMultipleEntries(String tableName, List<Map<String, dynamic>> entries) async {
    final db = await database;
    await db.transaction((txn) async {
      for (var entry in entries) {
        await txn.insert(tableName, entry);
      }
    });
  }
}
