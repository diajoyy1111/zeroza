import 'dart:async';
import 'package:flutter/material.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final List<_TodoItem> _todos = [];
  final TextEditingController _controller = TextEditingController();
  bool _showCompleted = false;

  int _restoreCount = 0;
  String _restoreMessage = '';
  bool _showRestoreMessage = false;
  bool _showDeleteMessage = false;
  String _deleteMessage = '';

  void _addTodo() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _todos.add(_TodoItem(text: text, completed: false));
      _controller.clear();
    });
  }

  void _deleteTodo(int index) {
    final item = _todos[index];
    final deletedText = item.text;

    setState(() {
      _todos.removeAt(index);
      _deleteMessage = '"$deletedText" has been deleted.';
      _showDeleteMessage = true;
    });

    // The RONG rule: deleted tasks refuse to stay deleted
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _todos.insert(index, _TodoItem(text: deletedText, completed: false));
          _showDeleteMessage = false;
        });
      }
    });
  }

  void _toggleTodo(int index) {
    final item = _todos[index];
    if (item.completed) return;

    setState(() {
      item.completed = true;
      _restoreCount++;

      if (_restoreCount >= 10) {
        _restoreMessage = '...seriously, stop.';
      } else if (_restoreCount >= 7) {
        _restoreMessage = 'Why are you like this?';
      } else if (_restoreCount >= 5) {
        _restoreMessage = 'Task restored again.';
      } else if (_restoreCount >= 3) {
        _restoreMessage = 'Task restored again.';
      } else {
        _restoreMessage = 'Task restored.';
      }
      _showRestoreMessage = true;
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => item.completed = false);
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) setState(() => _showRestoreMessage = false);
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0E0E12) : const Color(0xFFF5F5FA);
    final cardColor = isDark ? const Color(0xFF1E1E28) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1B1F);
    final inputColor = isDark ? const Color(0xFF1E1E28) : Colors.white;

    final active = _todos.where((t) => !t.completed).toList();
    final completed = _todos.where((t) => t.completed).toList();

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Text(
                    'To-Do',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            // Restore message
            AnimatedOpacity(
              opacity: _showRestoreMessage ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: AnimatedSlide(
                offset: _showRestoreMessage ? Offset.zero : const Offset(0, -0.3),
                duration: const Duration(milliseconds: 300),
                child: _showRestoreMessage
                    ? Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange[200]!),
                        ),
                        child: Text(
                          _restoreMessage,
                          style: TextStyle(fontSize: 13, color: Colors.orange[800], fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            // Delete message
            AnimatedOpacity(
              opacity: _showDeleteMessage ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: AnimatedSlide(
                offset: _showDeleteMessage ? Offset.zero : const Offset(0, -0.3),
                duration: const Duration(milliseconds: 300),
                child: _showDeleteMessage
                    ? Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Text(
                          _deleteMessage,
                          style: TextStyle(fontSize: 13, color: Colors.red[800], fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            // Input
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _addTodo(),
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Add a task...',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        filled: true,
                        fillColor: inputColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Material(
                    color: const Color(0xFF6750A4),
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: _addTodo,
                      child: const SizedBox(
                        width: 52,
                        height: 52,
                        child: Icon(Icons.add_rounded, color: Colors.white, size: 26),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  _TabButton(
                    label: 'Active (${active.length})',
                    selected: !_showCompleted,
                    onTap: () => setState(() => _showCompleted = false),
                  ),
                  const SizedBox(width: 8),
                  _TabButton(
                    label: 'Completed (${completed.length})',
                    selected: _showCompleted,
                    onTap: () => setState(() => _showCompleted = true),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // List
            Expanded(
              child: (_showCompleted ? completed : active).isEmpty
                  ? Center(
                      child: Text(
                        _showCompleted ? 'No completed tasks.' : 'No tasks yet.',
                        style: TextStyle(color: Colors.grey[500], fontSize: 15),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      itemCount: (_showCompleted ? completed : active).length,
                      itemBuilder: (context, index) {
                        final list = _showCompleted ? completed : active;
                        final item = list[index];
                        final realIndex = _todos.indexOf(item);
                        return _TodoTile(
                          item: item,
                          cardColor: cardColor,
                          textColor: textColor,
                          onToggle: () => _toggleTodo(realIndex),
                          onDelete: () => _deleteTodo(realIndex),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodoItem {
  final String text;
  bool completed;

  _TodoItem({required this.text, required this.completed});
}

class _TodoTile extends StatelessWidget {
  final _TodoItem item;
  final Color cardColor;
  final Color textColor;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _TodoTile({
    required this.item,
    required this.cardColor,
    required this.textColor,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: GestureDetector(
          onTap: onToggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: item.completed ? const Color(0xFF6750A4) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: item.completed ? const Color(0xFF6750A4) : Colors.grey[400]!,
                width: 2,
              ),
            ),
            child: item.completed
                ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
                : null,
          ),
        ),
        title: Text(
          item.text,
          style: TextStyle(
            fontSize: 15,
            decoration: item.completed ? TextDecoration.lineThrough : null,
            color: item.completed ? Colors.grey[500] : textColor,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline_rounded, size: 20, color: Colors.grey[500]),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF6750A4) : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}
