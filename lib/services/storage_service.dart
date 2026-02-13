import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chunxi_assistant/models/gift_record.dart';

/// 本地存储服务
/// 使用 SharedPreferences 进行数据持久化
class StorageService {
  static const String _giftRecordsKey = 'gift_records';
  static const String _relationHistoryKey = 'relation_history';

  /// 保存礼金记录列表
  Future<void> saveGiftRecords(List<GiftRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = records.map((r) => r.toMap()).toList();
    await prefs.setString(_giftRecordsKey, jsonEncode(jsonList));
  }

  /// 加载礼金记录列表
  Future<List<GiftRecord>> loadGiftRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_giftRecordsKey);
    if (jsonString == null) return [];

    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => GiftRecord.fromMap(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// 保存亲戚关系搜索历史
  Future<void> saveRelationHistory(List<String> history) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_relationHistoryKey, jsonEncode(history));
  }

  /// 加载亲戚关系搜索历史
  Future<List<String>> loadRelationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_relationHistoryKey);
    if (jsonString == null) return [];

    try {
      final list = jsonDecode(jsonString) as List;
      return list.cast<String>();
    } catch (e) {
      return [];
    }
  }

  /// 清除所有数据
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_giftRecordsKey);
    await prefs.remove(_relationHistoryKey);
  }
}
