// main.dart
import 'package:flutter/material.dart';
import 'package:work2/dropdown_widget.dart';
import 'checkbox_list.dart';
import 'template.dart';

void main() {
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

class _TaskScreenState extends State<TaskScreen> {
  String _selectedOption = 'Option 1';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
      ),
      body: Column(
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
