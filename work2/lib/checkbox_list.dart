import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import 'dart:io';

class CheckboxList extends StatefulWidget {
  final String selectedOption;
  const CheckboxList({super.key, required this.selectedOption});

  @override
  State<CheckboxList> createState() => _CheckboxListState();
}

class _CheckboxListState extends State<CheckboxList> {
  List<bool> _isChecked = [];
  List<bool> _isVisible = [];
  List<String> _taskTexts = [];

  @override
  void initState() {
    super.initState();
    _loadTasksFromXml();
  }

  @override
  void didUpdateWidget(CheckboxList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedOption != widget.selectedOption) {
      _loadTasksFromXml();
    }
  }

  Future<void> _loadTasksFromXml() async {
    try {
      String xmlString;

      // Different loading approach for web
      if (kIsWeb) {
        try {
          xmlString = await rootBundle.loadString('assets/tasks.xml');
        } catch (e) {
          print('Error loading from assets: $e');
          final response = await html.HttpRequest.getString('http://localhost:8080/tasks.xml');
          xmlString = response;
        }
      } else {
        final file = File('c:/Users/cesar/Documents/tasks.xml');
        xmlString = await file.readAsString();
      }

      // Parse the XML
      final document = XmlDocument.parse(xmlString);
      final taskList = document.findAllElements('taskList')
          .firstWhere((element) => element.getAttribute('id') == widget.selectedOption);
      final tasks = taskList.findAllElements('task');

      if (mounted) {
        setState(() {
          _isChecked = List.generate(tasks.length, (index) {
            final task = tasks.elementAt(index);
            return task.getAttribute('checked')?.toLowerCase() == 'true';
          });

          _isVisible = List.generate(tasks.length, (index) {
            final task = tasks.elementAt(index);
            return task.getAttribute('visible')?.toLowerCase() == 'true';
          });

          _taskTexts = List.generate(tasks.length, (index) {
            final task = tasks.elementAt(index);
            return task.text;
          });
        });
      }
    } catch (e) {
      print('Error loading XML: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading tasks: $e')),
        );
        setState(() {
          _isChecked = [];
          _isVisible = [];
          _taskTexts = [];
        });
      }
    }
  }

  Future<void> _saveTaskState() async {
    // Create XML document
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0"');
    builder.element('taskLists', nest: () {
      builder.element('taskList', nest: () {
        builder.attribute('id', widget.selectedOption);
        for (var i = 0; i < _isChecked.length; i++) {
          builder.element('task', nest: () {
            builder.attribute('id', i.toString());
            builder.attribute('checked', _isChecked[i].toString());
            builder.attribute('visible', _isVisible[i].toString());
            builder.text(_taskTexts[i]);
          });
        }
      });
    });

    final document = builder.buildDocument();
    
    try {
      if (kIsWeb) {
        // Handle web saving (you might want to implement a server endpoint)
        print('Saving not implemented for web');
      } else {
        final file = File('c:/Users/cesar/Documents/tasks.xml');
        await file.writeAsString(document.toString());
      }
    } catch (e) {
      print('Error saving XML: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving tasks: $e')),
        );
      }
    }
  }

  void _updateTaskState(int index, bool? checked) {
    if (checked != null) {
      setState(() {
        _isChecked[index] = checked;
        if (checked && index < _isVisible.length - 1) {
          _isVisible[index + 1] = true;
        }
        _saveTaskState(); // Save state after each update
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        backgroundColor: Colors.brown[200],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _loadTasksFromXml();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Loading XML file...')),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _isChecked.length,
        itemBuilder: (context, index) {
          if (!_isVisible[index]) {
            return const SizedBox.shrink();
          }
          return CheckboxListTile(
            title: Text(
              _taskTexts[index],
              style: TextStyle(
                color: _isChecked[index] ? Colors.white : Colors.black54,
                fontWeight: _isChecked[index] ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            value: _isChecked[index],
            onChanged: (bool? value) => _updateTaskState(index, value),
          );
        },
      ),
    );
  }
}
