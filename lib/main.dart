import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data/remote/supabase_service.dart';
import 'core/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load();

  // Initialize Supabase
  try {
    await SupabaseService.instance.initialize();
    Logger.instance.info('Supabase initialized successfully in main');
  } catch (e) {
    Logger.instance.error('Failed to initialize Supabase in main: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Voice Todo App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const SupabaseTestPage(title: 'Supabase Test Page'),
    );
  }
}

class SupabaseTestPage extends StatefulWidget {
  const SupabaseTestPage({super.key, required this.title});

  final String title;

  @override
  State<SupabaseTestPage> createState() => _SupabaseTestPageState();
}

class _SupabaseTestPageState extends State<SupabaseTestPage> {
  final SupabaseService _supabaseService = SupabaseService.instance;
  String _status = 'Initializing...';
  String _testResult = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkSupabaseStatus();
  }

  Future<void> _checkSupabaseStatus() async {
    setState(() {
      _status = 'Checking Supabase status...';
    });

    try {
      final isInitialized = _supabaseService.isInitialized;
      final isAuthenticated = _supabaseService.isAuthenticated;

      setState(() {
        _status =
            'Supabase Status: ${isInitialized ? "Connected" : "Disconnected"} | Auth: ${isAuthenticated ? "Yes" : "No"}';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    }
  }

  Future<void> _testDatabaseConnection() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Testing database connection...';
    });

    try {
      // Test database connection by querying tasks table
      final response = await _supabaseService.from('tasks').select().limit(1);

      setState(() {
        _testResult = '✅ Database connection successful!\nResponse: $response';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _testResult = '❌ Database connection failed: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testStorageConnection() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Testing storage connection...';
    });

    try {
      // Test storage connection by getting bucket info
      final bucket = _supabaseService.bucket('audio-files');

      setState(() {
        _testResult = '✅ Storage connection successful!\nBucket: $bucket';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _testResult = '❌ Storage connection failed: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testInsertTask() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Testing task insertion...';
    });

    try {
      // Debug authentication status
      final supa = Supabase.instance.client;
      print('DEBUG currentUser: ${supa.auth.currentUser?.id}');
      print('DEBUG currentUser email: ${supa.auth.currentUser?.email}');
      print('DEBUG isAuthenticated: ${supa.auth.currentUser != null}');

      // Check if user is authenticated
      if (supa.auth.currentUser == null) {
        setState(() {
          _testResult = '❌ User not authenticated!\nPlease sign in first.';
          _isLoading = false;
        });
        return;
      }

      // Test inserting a task with user_id
      final testTask = {
        'user_id': supa.auth.currentUser!.id,
        'title': 'RLS Test Task ${DateTime.now().millisecondsSinceEpoch}',
        'description': 'This is a test task for RLS policy testing',
        'priority': 'medium',
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      print('DEBUG payload: $testTask');

      final response = await _supabaseService
          .from('tasks')
          .insert(testTask)
          .select();

      setState(() {
        _testResult =
            '✅ Task insertion successful!\nInserted: ${response.first}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _testResult = '❌ Task insertion failed: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testSignIn() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Testing sign in...';
    });

    try {
      final supa = Supabase.instance.client;

      // Try to sign in with test credentials
      final response = await supa.auth.signInWithPassword(
        email: 'gokhan@birkinapps.com',
        password: 'testpassword123',
      );

      print('DEBUG Sign in response: ${response.user?.id}');
      print('DEBUG Sign in user: ${response.user}');
      print('DEBUG Sign in session: ${response.session}');

      setState(() {
        _testResult =
            '✅ Sign in successful!\nUser ID: ${response.user?.id}\nEmail: ${response.user?.email}';
        _isLoading = false;
      });

      // Refresh the status
      _checkSupabaseStatus();
    } catch (e) {
      setState(() {
        _testResult = '❌ Sign in failed: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testSignUp() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Testing sign up...';
    });

    try {
      final supa = Supabase.instance.client;

      // Try to sign up with test credentials
      final response = await supa.auth.signUp(
        email: 'gokhan@birkinapps.com',
        password: 'testpassword123',
      );

      print('DEBUG Sign up response: ${response.user?.id}');
      print('DEBUG Sign up user: ${response.user}');
      print('DEBUG Sign up session: ${response.session}');

      setState(() {
        _testResult =
            '✅ Sign up successful!\nUser ID: ${response.user?.id}\nEmail: ${response.user?.email}';
        _isLoading = false;
      });

      // Refresh the status
      _checkSupabaseStatus();
    } catch (e) {
      setState(() {
        _testResult = '❌ Sign up failed: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Supabase Connection Status',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(_status),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testDatabaseConnection,
                    child: const Text('Test Database'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testStorageConnection,
                    child: const Text('Test Storage'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _testInsertTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Test Task Insertion'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Test Sign In'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Test Sign Up'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Test Results',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator())
                      else
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(
                              _testResult.isEmpty
                                  ? 'No test results yet'
                                  : _testResult,
                              style: const TextStyle(fontFamily: 'monospace'),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
