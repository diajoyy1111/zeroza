import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';
import 'app_widgets.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final List<_TodoItem> _todos = [];
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showCompleted = false;

  int _restoreCount = 0;
  String _restoreMessage = '';
  bool _showRestoreMessage = false;
  bool _showDeleteMessage = false;
  String _deleteMessage = '';

  void _addTodo() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      _todos.add(_TodoItem(text: text, completed: false));
      _controller.clear();
    });
  }

  void _deleteTodo(int index) {
    HapticFeedback.mediumImpact();
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
    HapticFeedback.lightImpact();

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
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.background;
    final cardColor = isDark ? AppColors.cardDark : AppColors.card;
    final textColor = isDark ? AppColors.textDark : AppColors.textPrimary;
    final inputColor = isDark ? AppColors.cardDark : AppColors.card;

    final active = _todos.where((t) => !t.completed).toList();
    final completed = _todos.where((t) => t.completed).toList();

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            const RongScreenTitle(title: 'To-Do'),
            AnimatedOpacity(
              opacity: _showRestoreMessage ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: AnimatedSlide(
                offset: _showRestoreMessage ? Offset.zero : const Offset(0, -0.2),
                duration: const Duration(milliseconds: 250),
                child: _showRestoreMessage
                    ? Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2A1E0E) : const Color(0xFFFFF8EE),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? const Color(0xFF5A4020) : const Color(0xFFFFE0B2),
                          ),
                        ),
                        child: Text(
                          _restoreMessage,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFFFFB74D) : const Color(0xFFE65100),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            AnimatedOpacity(
              opacity: _showDeleteMessage ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: AnimatedSlide(
                offset: _showDeleteMessage ? Offset.zero : const Offset(0, -0.2),
                duration: const Duration(milliseconds: 250),
                child: _showDeleteMessage
                    ? Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2A0E0E) : const Color(0xFFFFF0F0),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? const Color(0xFF5A2020) : const Color(0xFFFFCDD2),
                          ),
                        ),
                        child: Text(
                          _deleteMessage,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFFEF5350) : const Color(0xFFC62828),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      onSubmitted: (_) => _addTodo(),
                      style: TextStyle(color: textColor, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Add a task...',
                        hintStyle: TextStyle(color: AppColors.textSecondary),
                        filled: true,
                        fillColor: inputColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: isDark ? AppColors.borderDark : AppColors.border,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Material(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: _addTodo,
                      child: const SizedBox(
                        width: 48,
                        height: 48,
                        child: Icon(Icons.add_rounded, color: Colors.white, size: 24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
            Expanded(
              child: (_showCompleted ? completed : active).isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _showCompleted ? Icons.check_circle_outline_rounded : Icons.task_alt_rounded,
                            size: 48,
                            color: AppColors.textSecondary.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _showCompleted ? 'No completed tasks.' : 'No tasks yet.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                          ),
                          if (!_showCompleted) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Add a task to get started',
                              style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.6), fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      itemCount: (_showCompleted ? completed : active).length,
                      itemBuilder: (context, index) {
                        final list = _showCompleted ? completed : active;
                        final item = list[index];
                        final realIndex = _todos.indexOf(item);
                        return Dismissible(
                          key: ValueKey(item),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => _deleteTodo(realIndex),
                          background: Container(
                            alignment: Alignment.centerRight,
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: AppColors.stopwatchIcon,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 20),
                          ),
                          child: _TodoTile(
                            item: item,
                            cardColor: cardColor,
                            textColor: textColor,
                            isDark: isDark,
                            index: index,
                            onToggle: () => _toggleTodo(realIndex),
                            onDelete: () => _deleteTodo(realIndex),
                          ),
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
  final bool isDark;
  final int index;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _TodoTile({
    required this.item,
    required this.cardColor,
    required this.textColor,
    required this.isDark,
    required this.index,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Subtle wrongness: checkbox alignment shifts slightly based on index
    final checkboxOffset = (index % 3 == 0) ? 2.0 : 0.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppShadows.subtle,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 1),
        leading: GestureDetector(
          onTap: onToggle,
          child: Transform.translate(
            offset: Offset(0, checkboxOffset),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: item.completed ? AppColors.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: item.completed ? AppColors.accent : AppColors.textSecondary,
                  width: 1.8,
                ),
              ),
              child: item.completed
                  ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                  : null,
            ),
          ),
        ),
        title: Text(
          item.text,
          style: TextStyle(
            fontSize: 14,
            decoration: item.completed ? TextDecoration.lineThrough : null,
            color: item.completed ? AppColors.textSecondary : textColor,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.textSecondary),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accent
              : (isDark ? AppColors.borderDark : AppColors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
