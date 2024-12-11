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
  List<TaskItem> _tasks = [];
  Set<int> _expandedItems = {};

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

  void _toggleExpanded(int index) {
    setState(() {
      if (_expandedItems.contains(index)) {
        _expandedItems.remove(index);
      } else {
        _expandedItems.add(index);
      }
    });
  }

  Future<void> _loadTasksFromXml() async {
    try {
      String xmlString;

      if (kIsWeb) {
        try {
          xmlString = await rootBundle.loadString('assets/tasks.xml');
        } catch (e) {
          print('Error loading from assets: $e');
          final response = await html.HttpRequest.getString(
              'http://localhost:8080/tasks.xml');
          xmlString = response;
        }
      } else {
        final file = File('c:/Users/cesar/Documents/tasks.xml');
        xmlString = await file.readAsString();
      }

      final document = XmlDocument.parse(xmlString);
      final taskList = document.findAllElements('taskList').firstWhere(
          (element) => element.getAttribute('id') == widget.selectedOption);

      if (mounted) {
        setState(() {
          _tasks = taskList.findElements('task').map((task) {
            return TaskItem(
              id: int.parse(task.getAttribute('id') ?? '0'),
              text: task.text,
              isChecked: task.getAttribute('checked')?.toLowerCase() == 'true',
              isVisible: task.getAttribute('visible')?.toLowerCase() == 'true',
              subTasks: task
                  .findElements('subtask')
                  .map((subtask) => TaskItem(
                        id: int.parse(subtask.getAttribute('id') ?? '0'),
                        text: subtask.text,
                        isChecked:
                            subtask.getAttribute('checked')?.toLowerCase() ==
                                'true',
                        isVisible:
                            subtask.getAttribute('visible')?.toLowerCase() ==
                                'true',
                        subTasks: [],
                        isSubTask: true,
                      ))
                  .toList(),
            );
          }).toList();
        });
      }
    } catch (e) {
      print('Error loading XML: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading tasks: $e')),
        );
      }
    }
  }

  void _addSubTask(int parentIndex) {
    setState(() {
      _tasks[parentIndex].subTasks.add(
            TaskItem(
              id: _tasks[parentIndex].subTasks.length,
              text: 'New Sub-task',
              isChecked: false,
              isVisible: true,
              subTasks: [],
              isSubTask: true,
            ),
          );
      // Automatically expand when adding a new subtask
      _expandedItems.add(parentIndex);
    });
    _saveTaskState();
  }

  Future<void> _saveTaskState() async {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0"');
    builder.element('taskLists', nest: () {
      builder.element('taskList', nest: () {
        builder.attribute('id', widget.selectedOption);
        for (var task in _tasks) {
          builder.element('task', nest: () {
            builder.attribute('id', task.id.toString());
            builder.attribute('checked', task.isChecked.toString());
            builder.attribute('visible', task.isVisible.toString());
            builder.text(task.text);

            for (var subtask in task.subTasks) {
              builder.element('subtask', nest: () {
                builder.attribute('id', subtask.id.toString());
                builder.attribute('checked', subtask.isChecked.toString());
                builder.attribute('visible', subtask.isVisible.toString());
                builder.text(subtask.text);
              });
            }
          });
        }
      });
    });

    final document = builder.buildDocument();

    try {
      if (!kIsWeb) {
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

  Widget _buildTaskItem(TaskItem task, int index, {double indentation = 0}) {
    bool hasSubtasks = task.subTasks.isNotEmpty;
    bool isExpanded = _expandedItems.contains(index);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(left: indentation),
          child: Row(
            children: [
              // Toggle button (yellow circle with arrow)
              if (hasSubtasks)
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.yellow,
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_right,
                      size: 20,
                      color: Colors.black,
                    ),
                    onPressed: () => _toggleExpanded(index),
                  ),
                )
              else
                const SizedBox(width: 24),
              const SizedBox(width: 8),
              // Task text
              Expanded(
                child: Text(
                  task.text,
                  style: TextStyle(
                    color: task.isChecked ? Colors.grey : Colors.yellow,
                    decoration:
                        task.isChecked ? TextDecoration.lineThrough : null,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Plus button for adding subtasks
              IconButton(
                icon: const Icon(
                  Icons.add_circle,
                  size: 20,
                  color: Colors.purple,
                ),
                onPressed: () => _addSubTask(index),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              // Checkbox at the right
              Transform.scale(
                scale: 0.8,
                child: Checkbox(
                  value: task.isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      task.isChecked = value ?? false;
                      _saveTaskState();
                    });
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  side: const BorderSide(color: Colors.grey),
                  checkColor: Colors.white,
                  fillColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.selected)) {
                        return Colors.grey;
                      }
                      return Colors.transparent;
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        // Subtasks (only show if expanded)
        if (isExpanded)
          ...task.subTasks.asMap().entries.map((entry) {
            return _buildTaskItem(entry.value, index,
                indentation: indentation + 32);
          }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        final task = _tasks[index];
        if (!task.isVisible) return const SizedBox.shrink();
        return _buildTaskItem(task, index);
      },
    );
  }
}

class TaskItem {
  final int id;
  final String text;
  bool isChecked;
  bool isVisible;
  List<TaskItem> subTasks;
  final bool isSubTask;

  TaskItem({
    required this.id,
    required this.text,
    required this.isChecked,
    required this.isVisible,
    required this.subTasks,
    this.isSubTask = false,
  });
}
