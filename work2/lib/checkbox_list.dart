// checkbox_list.dart
import 'package:flutter/material.dart';

class CheckboxList extends StatefulWidget {
  const CheckboxList({super.key});

  @override
  State<CheckboxList> createState() => _CheckboxListState();
}

class _CheckboxListState extends State<CheckboxList> {
  List<bool> _isChecked = List.generate(5, (_) => false);
  List<bool> _isVisible = List.generate(5, (index) => index == 0);  // Only first task visible

  void _handleCheckbox(int index, bool? value) {
    setState(() {
      _isChecked[index] = value!;
      
      // Show next task when checked
      if (index < 4 && value) {
        _isVisible[index + 1] = true;
      }
      // Hide task above when checked
      if (index > 0 && value) {
        _isVisible[index - 1] = false;
      }
      
      // Show task above when unchecked
      if (index > 0 && !value) {
        _isVisible[index - 1] = true;
      }
      // Hide next task when unchecked
      if (index < 4 && !value) {
        _isVisible[index + 1] = false;
        _isChecked[index + 1] = false;  // Uncheck next task
      }
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