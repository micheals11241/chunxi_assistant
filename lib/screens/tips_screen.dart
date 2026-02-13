import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chunxi_assistant/theme/app_theme.dart';
import 'package:chunxi_assistant/utils/greetings_data.dart';

class TipsScreen extends StatefulWidget {
  const TipsScreen({super.key});

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  GreetingCategory _selectedCategory = GreetingCategory.general;
  final Map<int, bool> _copiedFlags = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text, int index) {
    Clipboard.setData(ClipboardData(text: text));
    setState(() {
      _copiedFlags[index] = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('已复制到剪贴板'),
        backgroundColor: AppTheme.primaryRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 1),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _copiedFlags[index] = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Tab栏
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                gradient: AppTheme.festiveGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              tabs: const [
                Tab(text: '拜年吉祥话'),
                Tab(text: '应对尴尬提问'),
              ],
            ),
          ),

          // Tab内容
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _GreetingsTab(
                  selectedCategory: _selectedCategory,
                  onCategoryChanged: (category) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  onCopy: _copyToClipboard,
                  copiedFlags: _copiedFlags,
                ),
                _AwkwardQATab(
                  onCopy: _copyToClipboard,
                  copiedFlags: _copiedFlags,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GreetingsTab extends StatelessWidget {
  final GreetingCategory selectedCategory;
  final Function(GreetingCategory) onCategoryChanged;
  final Function(String, int) onCopy;
  final Map<int, bool> copiedFlags;

  const _GreetingsTab({
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onCopy,
    required this.copiedFlags,
  });

  @override
  Widget build(BuildContext context) {
    final greetings = GreetingsData.getGreetings(selectedCategory);

    return Column(
      children: [
        // 分类选择
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: GreetingCategory.values.map((category) {
              final isSelected = category == selectedCategory;
              return GestureDetector(
                onTap: () => onCategoryChanged(category),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppTheme.festiveGradient : null,
                    color: isSelected ? null : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        category.icon,
                        size: 18,
                        color: isSelected ? Colors.white : Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        category.label,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),

        // 吉祥话列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: greetings.length,
            itemBuilder: (context, index) {
              final greeting = greetings[index];
              final isCopied = copiedFlags[index] ?? false;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: AppTheme.festiveBoxDecoration,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: Text(
                    greeting,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  trailing: IconButton(
                    onPressed: () => onCopy(greeting, index),
                    icon: Icon(
                      isCopied ? Icons.check : Icons.copy,
                      color: isCopied ? Colors.green : AppTheme.primaryRed,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AwkwardQATab extends StatelessWidget {
  final Function(String, int) onCopy;
  final Map<int, bool> copiedFlags;

  const _AwkwardQATab({
    required this.onCopy,
    required this.copiedFlags,
  });

  @override
  Widget build(BuildContext context) {
    final questions = AwkwardQAData.questions;
    int globalIndex = 1000; // 偏移量，避免与吉祥话index冲突

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: questions.length,
      itemBuilder: (context, index) {
        final qa = questions[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: AppTheme.festiveBoxDecoration,
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.help_outline,
                    color: AppTheme.primaryRed,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    qa.question,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            children: qa.answers.map((answer) {
              final currentIndex = globalIndex++;
              final isCopied = copiedFlags[currentIndex] ?? false;

              return Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        answer,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => onCopy(answer, currentIndex),
                      icon: Icon(
                        isCopied ? Icons.check : Icons.copy,
                        size: 20,
                        color: isCopied ? Colors.green : AppTheme.primaryRed,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
