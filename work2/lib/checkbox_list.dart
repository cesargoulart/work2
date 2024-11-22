// checkbox_list.dart
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class CheckboxList extends StatefulWidget {
  const CheckboxList({super.key});

  @override
  State<CheckboxList> createState() => _CheckboxListState();
}

class _CheckboxListState extends State<CheckboxList> {
  List<bool> _isChecked = List.generate(5, (_) => false);
  List<bool> _isVisible = List.generate(5, (index) => index == 0);

  @override
  void initState() {
    super.initState();
    _loadTasksFromXml();
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/tasks.xml');
  }

  Future<void> _saveTasksToXml() async {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0"');
    builder.element('tasks', nest: () {
      for (int i = 0; i < _isChecked.length; i++) {
        builder.element('task', nest: () {
          builder.attribute('id', i.toString());
          builder.attribute('checked', _isChecked[i].toString());
          builder.attribute('visible', _isVisible[i].toString());
        });
      }
    });

    final file = await _localFile;
    await file.writeAsString(builder.buildDocument().toString());
  }

  Future<void> _loadTasksFromXml() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) return;

      final contents = await file.readAsString();
      final document = XmlDocument.parse(contents);
      final tasks = document.findAllElements('task');

      setState(() {
        for (var task in tasks) {
          final id = int.parse(task.getAttribute('id')!);
          _isChecked[id] = task.getAttribute('checked') == 'true';
          _isVisible[id] = task.getAttribute('visible') == 'true';
        }
      });
    } catch (e) {
      // If there's an error reading the file, just use default values
      print('Error loading tasks: $e');
    }
  }

  void _handleCheckbox(int index, bool? value) {
    setState(() {
      _isChecked[index] = value!;
      
      if (index < 4 && value) {
        _isVisible[index + 1] = true;
      }
      if (index > 0 && value) {
        _isVisible[index - 1] = false;
      }
      if (index > 0 && !value) {
        _isVisible[index - 1] = true;
      }
      if (index < 4 && !value) {
        _isVisible[index + 1] = false;
        _isChecked[index + 1] = false;
      }
      
      // Save tasks whenever there's a change
      _saveTasksToXml();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        if (!_isVisible[index]) {
          return Container();  // Hidden task
        }
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Checkbox(
                  value: _isChecked[index],
                  onChanged: (value) => _handleCheckbox(index, value),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Task ${index + 1}',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 16,
                      decoration: _isChecked[index]
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}