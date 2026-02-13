import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:chunxi_assistant/theme/app_theme.dart';
import 'package:chunxi_assistant/models/gift_record.dart';
import 'package:chunxi_assistant/widgets/gift_card.dart';
import 'package:chunxi_assistant/services/storage_service.dart';

class GiftBookScreen extends StatefulWidget {
  const GiftBookScreen({super.key});

  @override
  State<GiftBookScreen> createState() => _GiftBookScreenState();
}

class _GiftBookScreenState extends State<GiftBookScreen> {
  final List<GiftRecord> _records = [];
  final StorageService _storageService = StorageService();
  int _recordCounter = 0;
  bool _isLoading = true;

  double get _totalIncome => _records
      .where((r) => r.isIncome)
      .fold(0, (sum, r) => sum + r.amount);

  double get _totalExpense => _records
      .where((r) => !r.isIncome)
      .fold(0, (sum, r) => sum + r.amount);

  double get _netAmount => _totalIncome - _totalExpense;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final records = await _storageService.loadGiftRecords();
    setState(() {
      _records.clear();
      _records.addAll(records);
      _recordCounter = records.length;
      _isLoading = false;
    });
  }

  Future<void> _saveRecords() async {
    await _storageService.saveGiftRecords(_records);
  }

  void _addRecord() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddRecordSheet(
        onAdd: (record) async {
          setState(() {
            _records.insert(0, record);
            _recordCounter++;
          });
          await _saveRecords();
        },
        counter: _recordCounter,
      ),
    );
  }

  void _deleteRecord(String id) async {
    setState(() {
      _records.removeWhere((r) => r.id == id);
    });
    await _saveRecords();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryRed,
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          // 统计卡片
          Container(
            margin: const EdgeInsets.all(16),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                      label: '总收入',
                      value: '¥${_totalIncome.toStringAsFixed(0)}',
                      color: Colors.green[300]!,
                    ),
                    Container(
                      height: 40,
                      width: 1,
                      color: Colors.white30,
                    ),
                    _StatItem(
                      label: '总支出',
                      value: '¥${_totalExpense.toStringAsFixed(0)}',
                      color: Colors.orange[300]!,
                    ),
                    Container(
                      height: 40,
                      width: 1,
                      color: Colors.white30,
                    ),
                    _StatItem(
                      label: '净额',
                      value: '¥${_netAmount.toStringAsFixed(0)}',
                      color: Colors.white,
                      isBold: true,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 记录列表
          Expanded(
            child: _records.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.book_outlined,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '暂无记录',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '点击右下角按钮添加礼金记录',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: _records.length,
                    itemBuilder: (context, index) {
                      return Dismissible(
                        key: Key(_records[index].id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.delete,
                            color: Colors.red[400],
                          ),
                        ),
                        onDismissed: (direction) => _deleteRecord(_records[index].id),
                        child: GiftCard(
                          record: _records[index],
                          onDelete: () => _deleteRecord(_records[index].id),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addRecord,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isBold;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 18 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _AddRecordSheet extends StatefulWidget {
  final Function(GiftRecord) onAdd;
  final int counter;

  const _AddRecordSheet({
    required this.onAdd,
    required this.counter,
  });

  @override
  State<_AddRecordSheet> createState() => _AddRecordSheetState();
}

class _AddRecordSheetState extends State<_AddRecordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isIncome = true;
  DateTime _selectedDate = DateTime.now();

  // 快捷金额选项
  final List<int> _quickAmounts = [100, 200, 500, 1000, 2000];

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final record = GiftRecord(
        id: 'record_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text,
        amount: double.parse(_amountController.text),
        isIncome: _isIncome,
        date: _selectedDate,
        note: _noteController.text.isEmpty ? null : _noteController.text,
      );
      widget.onAdd(record);
      Navigator.pop(context);
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('zh', 'CN'),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppTheme.festiveGradient,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '添加礼金记录',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // 收支类型
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isIncome = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _isIncome ? Colors.green.withOpacity(0.3) : Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '收入 (收到红包)',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _isIncome ? Colors.white : Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isIncome = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !_isIncome ? AppTheme.primaryRed.withOpacity(0.3) : Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '支出 (回礼)',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: !_isIncome ? Colors.white : Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // 姓名
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '姓名',
                      prefixIcon: Icon(Icons.person),
                      hintText: '输入对方姓名',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入姓名';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // 金额
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: '金额',
                      prefixIcon: Icon(Icons.attach_money),
                      hintText: '输入金额',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入金额';
                      }
                      if (double.tryParse(value) == null) {
                        return '请输入有效数字';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  // 快捷金额
                  Wrap(
                    spacing: 8,
                    children: _quickAmounts.map((amount) {
                      return ActionChip(
                        label: Text('¥$amount'),
                        backgroundColor: Colors.grey[100],
                        side: const BorderSide(color: AppTheme.gold),
                        onPressed: () {
                          _amountController.text = amount.toString();
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  // 日期
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
                      onTap: _selectDate,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('yyyy-MM-dd').format(_selectedDate),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_drop_down, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 备注
                  TextFormField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: '备注（可选）',
                      prefixIcon: Icon(Icons.note),
                      hintText: '如：婚礼红包、过年压岁钱等',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 30),
                  // 提交按钮
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      '保存',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
