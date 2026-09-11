import 'dart:async';
import 'package:flutter/material.dart';
import 'app_theme.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.background;
    final cardColor = isDark ? AppColors.cardDark : AppColors.card;
    final textColor = isDark ? AppColors.textDark : AppColors.textPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark, textColor),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                children: [
                  _ConvoTile(
                    name: 'Unknown',
                    preview: 'Hey, are you there?',
                    time: '2:37 AM',
                    unread: true,
                    cardColor: cardColor,
                    textColor: textColor,
                    isDark: isDark,
                    onTap: () => _openChat(context, 'Unknown', isDark),
                  ),
                  _ConvoTile(
                    name: 'Mom',
                    preview: 'Call me when you get this.',
                    time: 'Yesterday',
                    unread: false,
                    cardColor: cardColor,
                    textColor: textColor,
                    isDark: isDark,
                    onTap: () => _openChat(context, 'Mom', isDark),
                  ),
                  _ConvoTile(
                    name: 'No Name',
                    preview: 'I saw what you did.',
                    time: '3:12 AM',
                    unread: true,
                    cardColor: cardColor,
                    textColor: textColor,
                    isDark: isDark,
                    onTap: () => _openChat(context, 'No Name', isDark),
                  ),
                  _ConvoTile(
                    name: '+1 (555) 000 0000',
                    preview: 'You shouldn\'t have opened this app.',
                    time: 'Now',
                    unread: true,
                    cardColor: cardColor,
                    textColor: textColor,
                    isDark: isDark,
                    onTap: () => _openChat(context, '+1 (555) 000 0000', isDark),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: textColor),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          Text(
            'Messages',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  void _openChat(BuildContext context, String name, bool isDark) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ChatScreen(name: name, isDark: isDark),
      ),
    );
  }
}

// ─── CONVERSATION TILE ──────────────────────────────────────────

class _ConvoTile extends StatelessWidget {
  final String name;
  final String preview;
  final String time;
  final bool unread;
  final Color cardColor;
  final Color textColor;
  final bool isDark;
  final VoidCallback onTap;

  const _ConvoTile({
    required this.name,
    required this.preview,
    required this.time,
    required this.unread,
    required this.cardColor,
    required this.textColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppShadows.subtle,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.border,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  name[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 11,
                          color: unread
                              ? const Color(0xFF8B0000)
                              : AppColors.textSecondary,
                          fontWeight: unread ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: unread
                          ? (isDark ? AppColors.textDark : AppColors.textPrimary)
                          : AppColors.textSecondary,
                      fontWeight: unread ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            if (unread)
              Container(
                margin: const EdgeInsets.only(left: 8),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF8B0000),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── CHAT SCREEN ────────────────────────────────────────────────

class _ChatScreen extends StatefulWidget {
  final String name;
  final bool isDark;
  const _ChatScreen({required this.name, required this.isDark});

  @override
  State<_ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<_ChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _showCreepy = false;

  @override
  void initState() {
    super.initState();
    // Seed the conversation with initial creepy messages
    _messages.add(_ChatMessage(
      text: _getInitialMessage(widget.name),
      isMe: false,
      time: '2:37 AM',
    ));
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _getInitialMessage(String name) {
    switch (name) {
      case 'Unknown':
        return 'Hey, are you there?';
      case 'Mom':
        return 'Call me when you get this.';
      case 'No Name':
        return 'I saw what you did.';
      case '+1 (555) 000 0000':
        return "You shouldn't have opened this app.";
      default:
        return 'Hello.';
    }
  }

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isMe: true, time: _now()));
    });
    _inputController.clear();

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });

    // After a few messages, trigger the creepy reveal
    if (_messages.length >= 3 && !_showCreepy) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showCreepy = true;
            _messages.add(_ChatMessage(
              text: 'I AM WATCHING YOU',
              isMe: false,
              time: _now(),
              isCreepy: true,
            ));
          });
          Future.delayed(const Duration(milliseconds: 200), () {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }
      });
    }

    // Wrong reply after each message
    if (!_showCreepy || _messages.length < 5) {
      Future.delayed(Duration(milliseconds: 800 + (_messages.length * 200)), () {
        if (mounted) {
          setState(() {
            _messages.add(_ChatMessage(
              text: _getWrongReply(),
              isMe: false,
              time: _now(),
            ));
          });
          Future.delayed(const Duration(milliseconds: 100), () {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
              );
            }
          });
        }
      });
    }
  }

  String _getWrongReply() {
    final replies = [
      'I don\'t understand what you mean.',
      'Who is this?',
      'That\'s not what I said.',
      'Why are you texting me at this hour?',
      'Please stop.',
      'You\'re not supposed to be here.',
      'I already know.',
      'Can\'t stop thinking about it.',
      'Don\'t look behind you.',
      '...',
      'How did you get this number?',
    ];
    final idx = _messages.length % replies.length;
    return replies[idx];
  }

  String _now() {
    final now = DateTime.now();
    final h = now.hour;
    final m = now.minute.toString().padLeft(2, '0');
    final ampm = h >= 12 ? 'PM' : 'AM';
    final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$h12:$m $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDark ? AppColors.backgroundDark : AppColors.background;
    final cardColor = widget.isDark ? AppColors.cardDark : AppColors.card;
    final textColor = widget.isDark ? AppColors.textDark : AppColors.textPrimary;
    final inputBg = widget.isDark ? const Color(0xFF1A1528) : const Color(0xFFF0EDF5);
    final border = widget.isDark ? AppColors.borderDark : AppColors.border;

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
                    icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: textColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: border,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        widget.name[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.videocam_outlined, size: 20, color: textColor),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.call_outlined, size: 20, color: textColor),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: border),

            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _messages.length,
                itemBuilder: (context, i) {
                  final msg = _messages[i];
                  if (msg.isCreepy) return _buildCreepyMessage(cardColor);
                  return _buildChatBubble(msg, cardColor, textColor, border);
                },
              ),
            ),

            // Input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: bgColor,
                border: Border(top: BorderSide(color: border)),
              ),
              child: Row(
                children: [
                  Icon(Icons.add_circle_outline, size: 24, color: AppColors.textSecondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: inputBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _inputController,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => _sendMessage(),
                        style: TextStyle(fontSize: 14, color: textColor),
                        decoration: InputDecoration(
                          hintText: 'Message...',
                          hintStyle: TextStyle(color: AppColors.textSecondary),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded, size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(_ChatMessage msg, Color cardColor, Color textColor, Color border) {
    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: msg.isMe
              ? AppColors.accent
              : cardColor,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: msg.isMe ? const Radius.circular(4) : null,
            bottomLeft: !msg.isMe ? const Radius.circular(4) : null,
          ),
          border: !msg.isMe ? Border.all(color: border) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              msg.text,
              style: TextStyle(
                fontSize: 14,
                color: msg.isMe ? Colors.white : textColor,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              msg.time,
              style: TextStyle(
                fontSize: 10,
                color: msg.isMe
                    ? Colors.white.withValues(alpha: 0.6)
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreepyMessage(Color cardColor) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        width: double.infinity,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B0000).withValues(alpha: 0.15),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
          border: Border.all(
            color: const Color(0xFF8B0000).withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.visibility_rounded,
              size: 36,
              color: const Color(0xFF8B0000).withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'I AM WATCHING YOU',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF8B0000),
                letterSpacing: 3,
                height: 1.2,
                shadows: [
                  Shadow(
                    color: const Color(0xFF8B0000).withValues(alpha: 0.4),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Did you really think this was a normal messages app?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isMe;
  final String time;
  final bool isCreepy;

  const _ChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
    this.isCreepy = false,
  });
}
