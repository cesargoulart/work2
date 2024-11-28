// dropdown_widget.dart
import 'package:flutter/material.dart';

class DropdownWidget extends StatefulWidget {
  final Function(String) onOptionSelected;
  const DropdownWidget({super.key, required this.onOptionSelected});

  @override
  State<DropdownWidget> createState() => _DropdownWidgetState();
}

class _DropdownWidgetState extends State<DropdownWidget> {
  String _selectedOption = 'Option 1';
  final List<String> _options = ['Option 1', 'Option 2', 'Option 3'];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedOption,
          isExpanded: true,
          icon: Icon(
            Icons.arrow_drop_down,
            color: _selectedOption != 'Option 1' ? Colors.blue : Colors.grey,
          ),
          elevation: 16,
          style: TextStyle(
            color: _selectedOption != 'Option 1' ? Colors.blue : Colors.black87,
            fontSize: 16,
            fontWeight: _selectedOption != 'Option 1' ? FontWeight.bold : FontWeight.normal,
          ),
          dropdownColor: Colors.white,
          menuMaxHeight: 200,
          borderRadius: BorderRadius.circular(8),
          onChanged: (String? newValue) {
            setState(() {
              _selectedOption = newValue!;
            });
            widget.onOptionSelected(_selectedOption);
          },
          items: _options.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyle(
                  color: value == _selectedOption ? Colors.blue : Colors.black87,
                  fontWeight: value == _selectedOption ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}