// lib/apple_app_template.dart
import 'package:flutter/material.dart';
import 'dropdown_widget.dart';
import 'checkbox_list.dart';
import 'package:xml/xml.dart';
import 'package:flutter/services.dart' show rootBundle;

class AppleAppTemplate extends StatelessWidget {
  const AppleAppTemplate({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apple App Template',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 16.0, color: Colors.grey),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 18.0),
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedOption = '';
  List<String> _options = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOptionsFromXml();
  }

  Future<void> _loadOptionsFromXml() async {
    try {
      String xmlString = await rootBundle.loadString('assets/tasks.xml');
      final xmlDocument = XmlDocument.parse(xmlString);
      final taskLists = xmlDocument.findAllElements('taskList').toList();
      if (taskLists.isNotEmpty) {
        _options = taskLists
            .map((element) => element.getAttribute('id') ?? '')
            .toList();
        if (_options.isNotEmpty) {
          setState(() {
            _selectedOption = _options.first;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading XML: $e');
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading tasks: $e')),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownWidget(
                    onOptionSelected: (option) {
                      setState(() {
                        _selectedOption = option;
                      });
                    },
                    initialOptions: _options,
                    selectedOption: _selectedOption,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'My Tasks',
                            style: TextStyle(
                                fontSize: 24.0, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          CheckboxList(selectedOption: _selectedOption),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SecondScreen()),
                              );
                            },
                            child: const Text('Go to Second Screen'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Screen'),
        backgroundColor: Colors.blueAccent,
      ),
      body: const Center(
        child: Text(
          'This is the second screen.',
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}