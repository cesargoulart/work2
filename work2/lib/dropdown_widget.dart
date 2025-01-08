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
    return Column(
      children: [
        // First row with text field and buttons
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  labelText: 'Enter text',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Saved successfully')),
                );
              },
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
                minimumSize: Size(48, 48),
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
            }
          },
          isExpanded: true,
          underline: Container(),
        ),
      ],
    );
  }

  bool _mrChecked = false;
  bool _coChecked = false;
  bool _dev1Checked = false;
  bool _dev2Checked = false;
  bool _rec1Checked = false;
  bool _rec2Checked = false;

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
}