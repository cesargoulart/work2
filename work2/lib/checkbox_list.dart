import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;

class CheckboxList extends StatefulWidget {
  final String selectedOption;
  const CheckboxList({super.key, required this.selectedOption});

  @override
  State<CheckboxList> createState() => _CheckboxListState();
}

class _CheckboxListState extends State<CheckboxList> {
  List<TaskItem> _tasks = [];
  Set<int> _expandedItems = {};
  late XmlDocument _xmlDocument;

  @override
  void initState() {
    super.initState();
    print('Initializing CheckboxListState');
    _loadTasksFromXml();
    if (kIsWeb) {
      // Force a rebuild after the frame is rendered
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
  }

  Future<void> _loadTasksFromXml() async {
    try {
      String xmlString;
      if (kIsWeb) {
        final stored = html.window.localStorage['tasks_xml'];
        if (stored != null) {
          xmlString = stored;
        } else {
          xmlString = await rootBundle.loadString('assets/tasks.xml');
          html.window.localStorage['tasks_xml'] = xmlString;
        }
      } else {
        xmlString = await rootBundle.loadString('assets/tasks.xml');
      }

      _xmlDocument = XmlDocument.parse(xmlString);
      _loadTasksForCurrentOption();
      
      // Ensure all items start collapsed
      setState(() {
        _expandedItems.clear();
      });
    } catch (e) {
      print('Error loading XML: $e');
      if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading tasks: $e')),
          );
        });
      }
    }
  }

  void _loadTasksForCurrentOption() {
    try {
      final taskList = _xmlDocument.findAllElements('taskList')
          .firstWhere((element) => element.getAttribute('id') == widget.selectedOption,
            orElse: () => XmlElement(XmlName('taskList')),
        );

      if (taskList.name.local == 'taskList') {
        if (mounted) {
          setState(() {
            _tasks = taskList.findElements('task').map((task) {
              // Get only the direct text nodes, ignoring subtask elements
              final textNodes = task.children.whereType<XmlText>();
              final taskText = textNodes.isEmpty ? '' : textNodes.first.text.trim();
              print('Loaded task: ${taskText}, Checked: ${task.getAttribute('checked')}'); // Log task details
              return TaskItem(
                id: int.parse(task.getAttribute('id') ?? '0'),
                text: taskText,
                isChecked: task.getAttribute('checked')?.toLowerCase() == 'true',
                isVisible: task.getAttribute('visible')?.toLowerCase() == 'true',
                subTasks: task.findElements('subtask').map((subtask) => 
                  TaskItem(
                    id: int.parse(subtask.getAttribute('id') ?? '0'),
                    text: subtask.text.trim(),
                    isChecked: subtask.getAttribute('checked')?.toLowerCase() == 'true',
                    isVisible: true,
                    subTasks: [],
                    isSubTask: true,
                  )
                ).toList(),
              );
            }).toList();
            print('Total tasks loaded: ${_tasks.length}'); // Log total tasks loaded
          });
        }
      }
      else {
       if (mounted) {
          setState(() {
            _tasks = [];
          });
        }
      }
    } catch (e) {
      print('Error loading tasks for option: $e');
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading tasks: $e')),
          );
        });
      }
    }
  }

  List<TaskItem> _parseTaskList(XmlElement taskList) {
    return taskList.findElements('task').map((task) {
            final textNodes = task.children.whereType<XmlText>();
            final taskText = textNodes.isEmpty ? '' : textNodes.first.text.trim();
      return TaskItem(
        id: int.parse(task.getAttribute('id') ?? '0'),
        text: taskText,
        isChecked: task.getAttribute('checked')?.toLowerCase() == 'true',
        isVisible: task.getAttribute('visible')?.toLowerCase() == 'true',
        subTasks: task.findElements('subtask').map((subtask) => 
          TaskItem(
            id: int.parse(subtask.getAttribute('id') ?? '0'),
            text: subtask.text.trim(),
            isChecked: subtask.getAttribute('checked')?.toLowerCase() == 'true',
            isVisible: true,
            subTasks: [],
            isSubTask: true,
          )
        ).toList(),
      );
    }).toList();
  }

  @override
  void didUpdateWidget(CheckboxList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedOption != widget.selectedOption) {
      _loadTasksForCurrentOption();
      // Ensure all items start collapsed when changing options
      setState(() {
        _expandedItems.clear();
      });
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
      // Show subtasks when adding a new one
      _expandedItems.add(parentIndex);
    });
    _saveTaskState();
  }

  Future<void> _saveTaskState() async {
    try {
      final taskList = _xmlDocument.findAllElements('taskList')
          .firstWhere((element) => element.getAttribute('id') == widget.selectedOption);

      // Store the taskList's attributes
      final taskListAttributes = taskList.attributes.toList();
      final parentNode = taskList.parent;
      
      // Create a new taskList element
      final newTaskList = XmlElement(XmlName('taskList'));
      
      // Restore the attributes
      for (var attr in taskListAttributes) {
        newTaskList.setAttribute(attr.name.local, attr.value);
      }

      // Add updated tasks
      for (var task in _tasks) {
        final taskElement = XmlElement(XmlName('task'));
        taskElement.setAttribute('id', task.id.toString());
        taskElement.setAttribute('checked', task.isChecked.toString());
        taskElement.setAttribute('visible', task.isVisible.toString());
        
        // Add task text as a separate text node
        taskElement.children.add(XmlText('\n    ' + task.text + '\n    '));
        
        // Add subtasks
        for (var subtask in task.subTasks) {
          final subtaskElement = XmlElement(XmlName('subtask'));
          subtaskElement.setAttribute('id', subtask.id.toString());
          subtaskElement.setAttribute('checked', subtask.isChecked.toString());
          subtaskElement.setAttribute('visible', subtask.isVisible.toString());
          subtaskElement.children.add(XmlText(subtask.text));
          taskElement.children.add(subtaskElement);
        }
        
        newTaskList.children.add(taskElement);
      }
      
      // Replace the old taskList with the new one
      final index = parentNode!.children.indexOf(taskList);
      parentNode.children[index] = newTaskList;

      if (kIsWeb) {
        html.window.localStorage['tasks_xml'] = _xmlDocument.toString();
      }
    } catch (e) {
      print('Error saving XML: $e');
      if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving tasks: $e')),
          );
        });
      }
    }
  }

  Widget _buildSubtasks(TaskItem task, int parentIndex, double indentation) {
    if (!_expandedItems.contains(parentIndex)) {
      return const SizedBox.shrink();
    }
    
    return Column(
      children: task.subTasks.map((subtask) {
        return Container(
          padding: EdgeInsets.only(left: indentation),
          child: Row(
            children: [
              const SizedBox(width: 32), // Space for alignment
              // Subtask text
              Expanded(
                child: Text(
                  subtask.text,
                  style: TextStyle(
                    color: subtask.isChecked ? Colors.grey : Colors.yellow,
                    decoration: subtask.isChecked ? TextDecoration.lineThrough : null,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Checkbox for subtask
              Transform.scale(
                scale: 0.8,
                child: Checkbox(
                  value: subtask.isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      subtask.isChecked = value ?? false;
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
        );
      }).toList(),
    );
  }

  Widget _buildTaskItem(TaskItem task, int index) {
    bool hasSubtasks = task.subTasks.isNotEmpty;
    bool isExpanded = _expandedItems.contains(index);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Toggle button (yellow circle with arrow)
            if (hasSubtasks)
              IconButton(
                icon: Icon(
                  isExpanded ? Icons.expand_more : Icons.chevron_right,
                  color: Colors.yellow,
                ),
                onPressed: () => _toggleExpanded(index),
              )
            else
              const SizedBox(width: 40),
            const SizedBox(width: 8),
            // Task text
            Expanded(
              child: Text(
                task.text,
                style: TextStyle(
                  color: task.isChecked ? Colors.grey : Colors.yellow,
                  decoration: task.isChecked ? TextDecoration.lineThrough : null,
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
            // Wrap checkbox in Material widget to ensure proper rendering on web
            Material(
              color: Colors.transparent,
              child: Transform.scale(
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
                  side: BorderSide(
                    color: Colors.grey,
                    width: kIsWeb ? 2.0 : 1.0, // Thicker border on web
                  ),
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
            ),
          ],
        ),
        // Subtasks
        _buildSubtasks(task, index, 40),
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