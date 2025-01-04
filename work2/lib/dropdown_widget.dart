import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    if (widget.initialOptions.contains(widget.selectedOption)) {
      _selectedOption = widget.selectedOption;
    } else if (widget.initialOptions.isNotEmpty) {
      _selectedOption = widget.initialOptions.first;
    }
  }

 @override
Widget build(BuildContext context) {
  return Column( // Wrap in a Column to stack the TextField and DropdownButton
    children: [
      TextField(
        controller: _textController,
        decoration: InputDecoration(
          labelText: 'Enter text',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 8), // Add some space between the TextField and DropdownButton
      DropdownButton<String>(
        value: _selectedOption,
        items: widget.initialOptions.map((option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(
              option,
              style: const TextStyle(color: Colors.white), // Added text style
            ),
          );
        }).toList(),
        onChanged: (newValue) {
          if (newValue != null) {
            setState(() {
              _selectedOption = newValue;
            });
            widget.onOptionSelected(newValue);
          }
        },
        isExpanded: true,
        underline: Container(),
      ),
    ],
  );
}
}