import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart';
import 'package:flutter/services.dart' show rootBundle;

class DropdownWidget extends StatefulWidget {
  final Function(String) onOptionSelected;
  final List<String> initialOptions;
  final String selectedOption;

  const DropdownWidget({
    super.key,
    required this.onOptionSelected,
    required this.initialOptions,
    required this.selectedOption,
  });

  @override
  State<DropdownWidget> createState() => _DropdownWidgetState();
}

class _DropdownWidgetState extends State<DropdownWidget> {
  final TextEditingController _textController = TextEditingController();
  String? _selectedOption;

  bool _mrChecked = false;
  bool _coChecked = false;
  bool _dev1Checked = false;
  bool _dev2Checked = false;
  bool _rec1Checked = false;
  bool _rec2Checked = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialOptions.contains(widget.selectedOption)) {
      _selectedOption = widget.selectedOption;
    } else if (widget.initialOptions.isNotEmpty) {
      _selectedOption = widget.initialOptions.first;
    }
    _loadStateForOption(widget.selectedOption);
  }

  Future<void> _loadStateForOption(String option) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/assets';
      final file = File('$path/projectos.xml');

      if (!await file.exists()) {
        print('File does not exist yet');
        return;
      }

      String xmlString = await file.readAsString();
      final xmlDocument = XmlDocument.parse(xmlString);
      
      // Find the entry element for the selected option
      final entry = xmlDocument.findAllElements('entry')
          .firstWhere((element) => element.getAttribute('text') == option,
              orElse: () => throw Exception('Entry not found'));

      setState(() {
        // Load text content
        _textController.text = entry.getAttribute('text') ?? '';
        
        // Load checkbox states
        _mrChecked = entry.getAttribute('MR')?.toLowerCase() == 'true';
        _coChecked = entry.getAttribute('CO')?.toLowerCase() == 'true';
        _dev1Checked = entry.getAttribute('DEV1')?.toLowerCase() == 'true';
        _dev2Checked = entry.getAttribute('DEV2')?.toLowerCase() == 'true';
        _rec1Checked = entry.getAttribute('REC1')?.toLowerCase() == 'true';
        _rec2Checked = entry.getAttribute('REC2')?.toLowerCase() == 'true';
      });
    } catch (e) {
      print('Error loading state: $e');
    }
  }

  Future<void> _saveToFile() async {
    if (_textController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter text before saving')),
        );
      }
      return;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/assets';
      final file = File('$path/projectos.xml');
      
      // Create directory if it doesn't exist
      await Directory(path).create(recursive: true);
      
      // Create or load XML document
      XmlDocument xmlDocument;
      if (await file.exists()) {
        String xmlString = await file.readAsString();
        try {
          xmlDocument = XmlDocument.parse(xmlString);
        } catch (e) {
          // If parsing fails, create a new document
          xmlDocument = XmlDocument([
            XmlDeclaration([XmlAttribute(XmlName('version'), '1.0')]),
            XmlElement(XmlName('entries'), [])
          ]);
        }
      } else {
        // Create new XML document if file doesn't exist
        xmlDocument = XmlDocument([
          XmlDeclaration([XmlAttribute(XmlName('version'), '1.0')]),
          XmlElement(XmlName('entries'), [])
        ]);
      }
      
      // Ensure we have a root element
      var rootElement = xmlDocument.rootElement;
      if (rootElement == null) {
        rootElement = XmlElement(XmlName('entries'), []);
        xmlDocument.children.add(rootElement);
      }

      // Check if an entry with this text already exists
      var existingEntries = rootElement.findElements('entry')
          .where((element) => element.getAttribute('text') == _textController.text);
      
      XmlElement? existingEntry;
      if (existingEntries.isNotEmpty) {
        existingEntry = existingEntries.first;

      if (existingEntry != null) {
        // If entry exists, update it
        existingEntry.setAttribute('MR', _mrChecked.toString());
        existingEntry.setAttribute('CO', _coChecked.toString());
        existingEntry.setAttribute('DEV1', _dev1Checked.toString());
        existingEntry.setAttribute('DEV2', _dev2Checked.toString());
        existingEntry.setAttribute('REC1', _rec1Checked.toString());
        existingEntry.setAttribute('REC2', _rec2Checked.toString());
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Entry updated successfully')),
          );
        }
      } else {
        // If entry doesn't exist, create new one
        final newEntry = XmlElement(XmlName('entry'));
        newEntry.setAttribute('text', _textController.text);
        newEntry.setAttribute('MR', _mrChecked.toString());
        newEntry.setAttribute('CO', _coChecked.toString());
        newEntry.setAttribute('DEV1', _dev1Checked.toString());
        newEntry.setAttribute('DEV2', _dev2Checked.toString());
        newEntry.setAttribute('REC1', _rec1Checked.toString());
        newEntry.setAttribute('REC2', _rec2Checked.toString());
        
        // Add the new entry to the root element
        rootElement.children.add(newEntry);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('New entry saved successfully')),
          );
        }
      }
      
      // Save the updated XML
      await file.writeAsString(xmlDocument.toString());
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving file: $e')),
        );
      }
    }
  }

  Widget _buildCheckboxWithLabel(String label, bool value, Function(bool?) onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          side: const BorderSide(color: Colors.white),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // First row with text field and buttons
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  labelText: 'Enter text',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _saveToFile,
              icon: const Icon(Icons.save),
              label: const Text('Save'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                // Add H button functionality here
              },
              child: const Text('H'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                minimumSize: const Size(48, 48),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Second row with checkboxes
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildCheckboxWithLabel('MR', _mrChecked, (value) {
                setState(() => _mrChecked = value ?? false);
              }),
              _buildCheckboxWithLabel('CO', _coChecked, (value) {
                setState(() => _coChecked = value ?? false);
              }),
              _buildCheckboxWithLabel('DEV1', _dev1Checked, (value) {
                setState(() => _dev1Checked = value ?? false);
              }),
              _buildCheckboxWithLabel('DEV2', _dev2Checked, (value) {
                setState(() => _dev2Checked = value ?? false);
              }),
              _buildCheckboxWithLabel('REC1', _rec1Checked, (value) {
                setState(() => _rec1Checked = value ?? false);
              }),
              _buildCheckboxWithLabel('REC2', _rec2Checked, (value) {
                setState(() => _rec2Checked = value ?? false);
              }),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Dropdown
        DropdownButton<String>(
          value: _selectedOption,
          items: widget.initialOptions.map((option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(
                option,
                style: const TextStyle(color: Colors.white),
              ),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              setState(() {
                _selectedOption = newValue;
              });
              widget.onOptionSelected(newValue);
              _loadStateForOption(newValue);
            }
          },
          isExpanded: true,
          underline: Container(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}