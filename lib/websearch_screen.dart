import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';
import 'app_widgets.dart';

class WebSearchScreen extends StatefulWidget {
  const WebSearchScreen({super.key});

  @override
  State<WebSearchScreen> createState() => _WebSearchScreenState();
}

class _WebSearchScreenState extends State<WebSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasSearched = false;
  bool _isLoading = false;
  String _query = '';

  final List<String> _dontKnowResponses = [
    "I don't know.",
    "I have no idea.",
    "Beats me.",
    "No clue.",
    "I literally have no idea what that is.",
    "I don't know and I never will.",
    "¯\\_(ツ)_/¯",
    "Error 404: Knowledge not found.",
    "I was never taught this.",
    "Ask someone else.",
    "I'm just a phone app, I don't know things.",
    "That's beyond my pay grade.",
    "I forgot.",
    "Wait, what was the question?",
    "I don't know. Next question.",
    "My sources tell me... nothing.",
    "I searched everywhere. Found nothing.",
    "The internet is down. Just kidding, I just don't know.",
    "I know nothing. I am nothing.",
    "Please try again never.",
  ];

  void _search() {
    final query = _controller.text.trim();
    if (query.isEmpty) return;
    HapticFeedback.lightImpact();
    _focusNode.unfocus();

    setState(() {
      _isLoading = true;
      _query = query;
      _hasSearched = false;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasSearched = true;
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

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            const RongScreenTitle(title: 'Web Search'),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppShadows.card,
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        onSubmitted: (_) => _search(),
                        style: TextStyle(color: textColor, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search anything...',
                          hintStyle: TextStyle(color: AppColors.textSecondary),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    if (_controller.text.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.clear_rounded, color: AppColors.textSecondary, size: 18),
                        onPressed: () {
                          setState(() {
                            _controller.clear();
                            _hasSearched = false;
                          });
                        },
                      ),
                    GestureDetector(
                      onTap: _search,
                      child: Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Search',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 36,
                            height: 36,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.accent,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Searching...',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  : _hasSearched
                      ? _buildResult(cardColor, textColor, isDark)
                      : _buildPlaceholder(textColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.search_rounded, size: 36, color: AppColors.accent.withValues(alpha: 0.35)),
          ),
          const SizedBox(height: 18),
          Text(
            'Search the web',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Type anything and hit search',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult(Color cardColor, Color textColor, bool isDark) {
    final random = _dontKnowResponses[_query.hashCode.abs() % _dontKnowResponses.length];

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.04) : AppColors.border,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.search_off_rounded, size: 36, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            Text(
              '"$_query"',
              style: TextStyle(
                fontSize: 15,
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: AppShadows.card,
              ),
              child: Column(
                children: [
                  Text(
                    random,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '0 results found',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Maybe try searching something else?',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
