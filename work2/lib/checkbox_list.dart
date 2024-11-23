import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'dart:html' as html;
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

  Future<void> _loadTasksFromXml() async {
    try {
      String xmlString;
      
      // Different loading approach for web
      if (kIsWeb) {
        try {
          // For web, try to load from assets first
          xmlString = await rootBundle.loadString('assets/tasks.xml');
        } catch (e) {
          print('Error loading from assets: $e');
          // If that fails, try loading from a URL (you can set up a local server)
          final response = await html.HttpRequest.getString('http://localhost:8080/tasks.xml');
          xmlString = response;
        }
      } else {
        // For desktop/mobile, read from Documents
        final file = File('c:/Users/cesar/Documents/tasks.xml');
        xmlString = await file.readAsString();
      }

      print('Loaded XML content: $xmlString'); // Debug print

      // Parse the XML
      final document = XmlDocument.parse(xmlString);
      final tasks = document.findAllElements('task');

      if (mounted) {
        setState(() {
          // Update lists with proper length based on actual tasks
          _isChecked = List.generate(tasks.length, (index) {
            final task = tasks.elementAt(index);
            return task.getAttribute('checked')?.toLowerCase() == 'true';
          });

          _isVisible = List.generate(tasks.length, (index) {
            final task = tasks.elementAt(index);
            return task.getAttribute('visible')?.toLowerCase() == 'true';
          });
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tasks loaded successfully')),
        );
      }
    } catch (e) {
      print('Error loading XML: $e');
      if (mounted) {
        // Show error message to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading tasks: $e')),
        );
        // Provide fallback data
        setState(() {
          _isChecked = List.generate(5, (_) => false);
          _isVisible = List.generate(5, (index) => index == 0);
        });
      }
    }
  }

  Future<void> _saveTaskState() async {
    // Create XML document
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0"');
    builder.element('tasks', nest: () {
      for (var i = 0; i < _isChecked.length; i++) {
        builder.element('task', nest: () {
          builder.attribute('checked', _isChecked[i].toString());
          builder.attribute('visible', _isVisible[i].toString());
          builder.text('Task ${i + 1}');
        });
      }
    });

    final document = builder.buildDocument();

    // Here you would implement the saving mechanism
    // For web, you might want to use localStorage or IndexedDB
    if (kIsWeb) {
      html.window.localStorage['tasks'] = document.toString();
    } else {
      // Implement desktop saving logic here
      // You might want to use path_provider package for desktop
      print('Saving for desktop: ${document.toString()}');
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
            title: Text('Task ${index + 1}'),
            value: _isChecked[index],
            onChanged: (bool? value) => _updateTaskState(index, value),
          );
        },
      ),
    );
  }
}
