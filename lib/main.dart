import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: TodoList(),
      ),
    );
  }
}

class TodoList extends StatefulWidget {
  const TodoList({Key? key}) : super(key: key);

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  final List<String> _todoItems = [];
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    _getItemsFromFile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ToDo List"),
      ),
      body: ListView(
        children: _todoItems
            .map((item) => TodoItemWidget(
                  itemText: item,
                  deleteItem: _deleteTodoItem,
                ))
            .toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _displayAddDialog(context),
        tooltip: "Add task",
        child: const Icon(Icons.add),
      ),
    );
  }

  void _saveItemsToFile() async {
    final docsDirectory = await getApplicationDocumentsDirectory();
    final file = File("${docsDirectory.path}/todo.txt");
    await file.writeAsString(_todoItems.join("~~BOUNDARY~~"));
  }

  void _getItemsFromFile() async {
    final docsDirectory = await getApplicationDocumentsDirectory();
    final file = File("${docsDirectory.path}/todo.txt");
    if (await file.exists()) {
      final contents = await file.readAsString();
      final items = contents.split("~~BOUNDARY~~");
      setState(() {
        _todoItems.addAll(items);
      });
    }
  }

  void _addTodoItem() {
    _saveItemsToFile();
    setState(() {
      _todoItems.add(_textController.text);
    });
    _textController.clear();
  }

  void _deleteTodoItem(String item) {
    _saveItemsToFile();
    setState(() {
      int index = _todoItems.indexWhere((element) => element.contains(item));
      _todoItems.removeAt(index);
    });
  }

  Future<Future> _displayAddDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add a new task"),
          content: TextField(
            controller: _textController,
            decoration: const InputDecoration(hintText: "Enter a task"),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Add"),
              onPressed: () {
                _addTodoItem();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class TodoItemWidget extends StatelessWidget {
  String _itemText = "";
  Function _delItemFunc = () {};

  TodoItemWidget(
      {super.key, required String itemText, required Function deleteItem}) {
    _itemText = itemText;
    _delItemFunc = deleteItem;
  }

  @override
  Column build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                " ↣ $_itemText",
                style: const TextStyle(fontSize: 23),
                overflow: TextOverflow.fade,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Deleted"),
                  ),
                ),
                _delItemFunc(_itemText)
              },
            ),
          ],
        ),
        const Divider(
          color: Colors.black,
        ),
      ],
    );
  }
}
