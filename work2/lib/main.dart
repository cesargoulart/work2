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

class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
      ),
      body: Column(
        children: const [
          StyledCard(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: DropdownWidget(),
            ),
          ),
          Expanded(
            child: CheckboxList(),
          ),
        ],
      ),
    );
  }
}
