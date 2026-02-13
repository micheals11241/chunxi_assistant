class GiftRecord {
  final String id;
  final String name;
  final double amount;
  final bool isIncome; // true: 收入, false: 支出
  final DateTime date;
  final String? note;

  GiftRecord({
    required this.id,
    required this.name,
    required this.amount,
    required this.isIncome,
    required this.date,
    this.note,
  });

  GiftRecord copyWith({
    String? id,
    String? name,
    double? amount,
    bool? isIncome,
    DateTime? date,
    String? note,
  }) {
    return GiftRecord(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      isIncome: isIncome ?? this.isIncome,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'isIncome': isIncome,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory GiftRecord.fromMap(Map<String, dynamic> map) {
    return GiftRecord(
      id: map['id'],
      name: map['name'],
      amount: map['amount'],
      isIncome: map['isIncome'],
      date: DateTime.parse(map['date']),
      note: map['note'],
    );
  }

  String get formattedDate {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
