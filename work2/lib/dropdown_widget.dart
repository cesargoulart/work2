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
    return DropdownButton<String>(
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
    );
  }
}