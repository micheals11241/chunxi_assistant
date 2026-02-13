import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chunxi_assistant/theme/app_theme.dart';
import 'package:chunxi_assistant/utils/relation_calculator.dart';
import 'package:chunxi_assistant/services/storage_service.dart';

class RelativeScreen extends StatefulWidget {
  const RelativeScreen({super.key});

  @override
  State<RelativeScreen> createState() => _RelativeScreenState();
}

class _RelativeScreenState extends State<RelativeScreen> {
  final _textController = TextEditingController();
  final StorageService _storageService = StorageService();
  String _result = '';
  List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await _storageService.loadRelationHistory();
    setState(() {
      _history = history;
    });
  }

  Future<void> _saveHistory() async {
    await _storageService.saveRelationHistory(_history);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _calculate() {
    final input = _textController.text.trim();
    if (input.isEmpty) {
      setState(() {
        _result = '请输入关系描述';
      });
      return;
    }

    final result = RelationCalculator.calculate(input);
    setState(() {
      _result = result;
      if (!_history.contains(input)) {
        _history.insert(0, input);
        if (_history.length > 10) {
          _history.removeLast();
        }
      }
    });
    _saveHistory();
  }

  void _useQuickRelation(QuickRelation qr) {
    _textController.text = qr.label;
    _calculate();
  }

  void _useHistory(String history) {
    _textController.text = history;
    _calculate();
  }

  void _clearHistory() {
    setState(() {
      _history.clear();
    });
    _saveHistory();
  }

  void _copyResult() {
    if (_result.isNotEmpty && _result != '请输入关系描述') {
      Clipboard.setData(ClipboardData(text: _result));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('已复制到剪贴板'),
          backgroundColor: AppTheme.primaryRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final quickRelations = RelationCalculator.getQuickRelations();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 输入区域
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.festiveBoxDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: AppTheme.goldGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.family_restroom,
                          color: AppTheme.primaryRed,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        '亲戚关系计算器',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '输入关系描述，自动计算应该怎么称呼',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: '例如：爸爸的哥哥的儿子',
                      suffixIcon: IconButton(
                        onPressed: () => _textController.clear(),
                        icon: const Icon(Icons.clear),
                      ),
                    ),
                    onSubmitted: (_) => _calculate(),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _calculate,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        '计算称呼',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 结果区域
            if (_result.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppTheme.festiveGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryRed.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      '计算结果',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _result,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: _copyResult,
                          icon: const Icon(
                            Icons.copy,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // 快捷查询
            const Text(
              '快捷查询',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: quickRelations.map((qr) {
                return ActionChip(
                  backgroundColor: Colors.grey[100],
                  side: const BorderSide(color: AppTheme.gold),
                  label: Text(qr.label),
                  onPressed: () => _useQuickRelation(qr),
                );
              }).toList(),
            ),

            // 搜索历史
            if (_history.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '搜索历史',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: _clearHistory,
                    child: const Text('清空'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _history.map((h) {
                  return ActionChip(
                    backgroundColor: Colors.grey[200],
                    label: Text(h),
                    onPressed: () => _useHistory(h),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 24),

            // 使用说明
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        '使用说明',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoText('支持的关系词：爸爸/父亲、妈妈/母亲'),
                  _buildInfoText('兄弟姐妹：哥哥、弟弟、姐姐、妹妹'),
                  _buildInfoText('晚辈：儿子/子、女儿/女'),
                  _buildInfoText('配偶：丈夫/老公、妻子/老婆'),
                  _buildInfoText('用"的"连接，如：妈妈的哥哥的儿子'),
                ],
              ),
            ),

            // 更多关系图
            const SizedBox(height: 24),
            const Text(
              '常用关系速查',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildRelationTable(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelationTable() {
    final relations = [
      {'关系': '爷爷', '称呼': '爸爸的爸爸'},
      {'关系': '奶奶', '称呼': '爸爸的妈妈'},
      {'关系': '外公', '称呼': '妈妈的爸爸'},
      {'关系': '外婆', '称呼': '妈妈的妈妈'},
      {'关系': '伯父', '称呼': '爸爸的哥哥'},
      {'关系': '叔叔', '称呼': '爸爸的弟弟'},
      {'关系': '姑姑', '称呼': '爸爸的姐妹'},
      {'关系': '舅舅', '称呼': '妈妈的兄弟'},
      {'关系': '姨妈', '称呼': '妈妈的姐妹'},
      {'关系': '堂兄弟', '称呼': '爸爸兄弟的子女'},
      {'关系': '表兄弟', '称呼': '爸爸姐妹或妈妈的子女'},
      {'关系': '侄子/侄女', '称呼': '兄弟的子女'},
      {'关系': '外甥/外甥女', '称呼': '姐妹的子女'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.gold),
      ),
      child: Column(
        children: relations.map((r) {
          final index = relations.indexOf(r);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: index < relations.length - 1
                  ? Border(bottom: BorderSide(color: Colors.grey[200]!))
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  r['关系']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryRed,
                  ),
                ),
                Text(
                  r['称呼']!,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
