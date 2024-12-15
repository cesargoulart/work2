import 'package:flutter/material.dart';
import 'package:work2/dropdown_widget.dart';
import 'checkbox_list.dart';
import 'template.dart';
import 'package:xml/xml.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:window_manager/window_manager.dart';
import 'dart:io' show Platform;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (!kIsWeb) {
    await windowManager.ensureInitialized();
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DarkTemplate(
        child: const TaskScreen(),
      ),
    );
  }
}

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> with WindowListener {
  String _selectedOption = '';
  List<String> _options = [];
  bool _isLoading = true;

  bool _isAlwaysOnTop = false;

  @override
  void initState() {
    super.initState();
    _loadOptionsFromXml();
    if (!kIsWeb) {
      windowManager.addListener(this);
    }
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  Future<void> _toggleAlwaysOnTop() async {
    if (kIsWeb) return;
    
    setState(() {
      _isAlwaysOnTop = !_isAlwaysOnTop;
    });
    await windowManager.setAlwaysOnTop(_isAlwaysOnTop);
  }

   Future<void> _loadOptionsFromXml() async {
    try{
      String xmlString;
      xmlString = await rootBundle.loadString('assets/tasks.xml');
      final xmlDocument = XmlDocument.parse(xmlString);
       final taskLists = xmlDocument.findAllElements('taskList').toList();
       if (taskLists.isNotEmpty){
          _options = taskLists
          .map((element) => element.getAttribute('id') ?? '')
          .toList();
        if (_options.isNotEmpty) {
          setState(() {
            _selectedOption = _options.first;
          });
        }
      }
    }
      catch (e) {
      print('Error loading XML: $e');
        if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading tasks: $e')),
          );
        });
      }
      }
      finally {
        setState(() {
          _isLoading = false;
        });
      }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
      ),
      floatingActionButton: !kIsWeb && Platform.isWindows ? FloatingActionButton(
        onPressed: () {
          if (kIsWeb) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Always on top is only available on desktop platforms'),
                duration: Duration(seconds: 2),
              ),
            );
          } else {
            _toggleAlwaysOnTop();
          }
        },
        child: Icon(_isAlwaysOnTop ? Icons.push_pin : Icons.push_pin_outlined),
      ) : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          StyledCard(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
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
          ),
          Expanded(
            child: CheckboxList(selectedOption: _selectedOption),
          ),
        ],
      ),
    );
  }
}
