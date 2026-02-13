/// 亲戚关系计算器
/// 支持父系/母系三代内的主要亲戚关系计算
class RelationCalculator {
  // 基础关系映射
  static const Map<String, String> _baseRelations = {
    '父': '爸爸',
    '母': '妈妈',
    '兄': '哥哥',
    '弟': '弟弟',
    '姐': '姐姐',
    '妹': '妹妹',
    '子': '儿子',
    '女': '女儿',
    '夫': '丈夫',
    '妻': '妻子',
  };

  // 父系关系
  static const Map<String, String> _paternalRelations = {
    '父': '父亲',
    '父父': '爷爷',
    '父母': '奶奶',
    '父父父': '曾祖父',
    '父父母': '曾祖母',
    '父兄': '伯父',
    '父弟': '叔叔',
    '父姐': '姑妈',
    '父妹': '姑姑',
    '父兄妻': '伯母',
    '父弟妻': '婶婶',
    '父姐夫': '姑父',
    '父妹夫': '姑父',
    '父兄子': '堂哥',
    '父兄女': '堂姐',
    '父弟子': '堂弟',
    '父弟女': '堂妹',
    '父兄子妻': '堂嫂',
    '父弟子妻': '堂弟媳',
    '父姐子': '表哥',
    '父姐女': '表姐',
    '父妹子': '表弟',
    '父妹女': '表妹',
  };

  // 母系关系
  static const Map<String, String> _maternalRelations = {
    '母': '母亲',
    '母父': '外公',
    '母母': '外婆',
    '母父父': '外曾祖父',
    '母父母': '外曾祖母',
    '母兄': '舅舅',
    '母弟': '舅舅',
    '母姐': '姨妈',
    '母妹': '姨妈',
    '母兄妻': '舅妈',
    '母弟妻': '舅妈',
    '母姐夫': '姨父',
    '母妹夫': '姨父',
    '母兄子': '表哥',
    '母兄女': '表姐',
    '母弟子': '表弟',
    '母弟女': '表妹',
    '母姐子': '表哥',
    '母姐女': '表姐',
    '母妹子': '表弟',
    '母妹女': '表妹',
  };

  // 配偶关系
  static const Map<String, String> _spouseRelations = {
    '夫': '丈夫',
    '妻': '妻子',
    '夫父': '公公',
    '夫母': '婆婆',
    '妻父': '岳父',
    '妻母': '岳母',
    '夫兄': '大伯子',
    '夫弟': '小叔子',
    '夫姐': '大姑子',
    '夫妹': '小姑子',
    '妻兄': '大舅子',
    '妻弟': '小舅子',
    '妻姐': '大姨子',
    '妻妹': '小姨子',
    '夫子': '继子',
    '妻女': '继女',
  };

  // 晚辈关系
  static const Map<String, String> _offspringRelations = {
    '子': '儿子',
    '女': '女儿',
    '子子': '孙子',
    '子女': '孙女',
    '女子': '外孙',
    '女女': '外孙女',
    '子妻': '儿媳',
    '女夫': '女婿',
    '子子子': '曾孙',
    '子女子': '曾孙女',
    '兄子': '侄子',
    '兄弟': '侄子',
    '兄女': '侄女',
    '弟子': '侄子',
    '弟女': '侄女',
    '姐子': '外甥',
    '妹子': '外甥',
    '姐女': '外甥女',
    '妹女': '外甥女',
    '姐夫': '姐夫',
    '妹夫': '妹夫',
    '兄妻': '嫂子',
    '弟妻': '弟妹',
    '子兄': '孙子',
    '子弟': '孙子',
  };

  // 完整关系映射表
  static final Map<String, String> _allRelations = {
    ..._paternalRelations,
    ..._maternalRelations,
    ..._spouseRelations,
    ..._offspringRelations,
    ..._baseRelations,
    '': '自己',
  };

  /// 计算亲戚关系
  /// 输入格式: "爸爸的哥哥的儿子" 或 "父亲的兄的儿子"
  static String calculate(String input) {
    if (input.isEmpty) {
      return '请输入关系描述';
    }

    // 标准化输入
    String normalized = _normalizeInput(input);

    // 直接匹配
    if (_allRelations.containsKey(normalized)) {
      return _allRelations[normalized]!;
    }

    // 尝试反向匹配（如：叔叔的儿子 = 堂弟）
    String? reverseResult = _reverseMatch(normalized);
    if (reverseResult != null) {
      return reverseResult;
    }

    // 尝试模糊匹配
    String? fuzzyResult = _fuzzyMatch(normalized);
    if (fuzzyResult != null) {
      return fuzzyResult;
    }

    return '未找到对应称呼，请检查输入';
  }

  /// 标准化输入
  static String _normalizeInput(String input) {
    String result = input
        .replaceAll('的', '')
        .replaceAll('我的', '')
        .replaceAll('我', '')
        // 父亲相关
        .replaceAll('爷爷', '父父')
        .replaceAll('奶奶', '父母')
        .replaceAll('伯父', '父兄')
        .replaceAll('伯伯', '父兄')
        .replaceAll('叔叔', '父弟')
        .replaceAll('婶婶', '父弟妻')
        .replaceAll('伯母', '父兄妻')
        .replaceAll('姑姑', '父妹')
        .replaceAll('姑妈', '父姐')
        .replaceAll('姑父', '父姐夫')
        // 母亲相关
        .replaceAll('外公', '母父')
        .replaceAll('外婆', '母母')
        .replaceAll('姥姥', '母母')
        .replaceAll('姥爷', '母父')
        .replaceAll('舅舅', '母兄')
        .replaceAll('舅妈', '母兄妻')
        .replaceAll('姨妈', '母姐')
        .replaceAll('姨父', '母姐夫')
        // 父母
        .replaceAll('爸爸', '父')
        .replaceAll('父亲', '父')
        .replaceAll('妈妈', '母')
        .replaceAll('母亲', '母')
        // 兄弟姐妹
        .replaceAll('哥哥', '兄')
        .replaceAll('弟弟', '弟')
        .replaceAll('姐姐', '姐')
        .replaceAll('妹妹', '妹')
        .replaceAll('嫂子', '兄妻')
        .replaceAll('嫂嫂', '兄妻')
        .replaceAll('弟妹', '弟妻')
        // 晚辈
        .replaceAll('儿子', '子')
        .replaceAll('女儿', '女')
        .replaceAll('孙子', '子子')
        .replaceAll('孙女', '子女')
        .replaceAll('外孙', '女子')
        .replaceAll('外孙女', '女女')
        .replaceAll('侄子', '兄子')
        .replaceAll('侄女', '兄女')
        .replaceAll('外甥', '姐子')
        .replaceAll('外甥女', '姐女')
        // 配偶
        .replaceAll('丈夫', '夫')
        .replaceAll('老公', '夫')
        .replaceAll('妻子', '妻')
        .replaceAll('老婆', '妻')
        .replaceAll('爱人', '妻')
        .replaceAll('儿媳', '子妻')
        .replaceAll('女婿', '女夫')
        // 配偶亲属
        .replaceAll('公公', '夫父')
        .replaceAll('婆婆', '夫母')
        .replaceAll('岳父', '妻父')
        .replaceAll('岳母', '妻母')
        .replaceAll('丈人', '妻父')
        .replaceAll('丈母娘', '妻母');

    return result;
  }

  /// 反向匹配
  /// 处理一些特殊情况
  static String? _reverseMatch(String normalized) {
    // 处理 "父弟子" = 叔叔的儿子 = 堂弟
    // 处理 "父兄子" = 伯伯的儿子 = 堂哥/堂弟
    if (normalized == '父兄子' || normalized == '父弟子') {
      return '堂兄弟';
    }
    if (normalized == '父兄女' || normalized == '父弟女') {
      return '堂姐妹';
    }
    if (normalized.contains('母') &&
        (normalized.endsWith('子') || normalized.endsWith('女'))) {
      String gender = normalized.endsWith('子') ? '表兄弟' : '表姐妹';
      return gender;
    }

    // 大爷/二大爷 等
    if (normalized == '父父兄' || normalized == '父父弟') {
      return '叔祖父';
    }
    if (normalized == '父母姐' || normalized == '父母妹') {
      return '姨奶奶';
    }

    return null;
  }

  /// 模糊匹配
  static String? _fuzzyMatch(String normalized) {
    // 尝试去除性别后缀
    if (normalized.endsWith('子') || normalized.endsWith('女')) {
      String base = normalized.substring(0, normalized.length - 1);
      if (_allRelations.containsKey('$base子')) {
        return _allRelations['$base子']!;
      }
      if (_allRelations.containsKey('$base女')) {
        return _allRelations['$base女']!;
      }
    }

    // 尝试关系组合
    for (var entry in _allRelations.entries) {
      if (entry.key.contains(normalized) || normalized.contains(entry.key)) {
        return entry.value;
      }
    }

    return null;
  }

  /// 获取快捷查询选项
  static List<QuickRelation> getQuickRelations() {
    return [
      QuickRelation(label: '爸爸的哥哥', relation: '伯父'),
      QuickRelation(label: '爸爸的弟弟', relation: '叔叔'),
      QuickRelation(label: '爸爸的姐姐', relation: '姑妈'),
      QuickRelation(label: '爸爸的妹妹', relation: '姑姑'),
      QuickRelation(label: '妈妈的哥哥', relation: '舅舅'),
      QuickRelation(label: '妈妈的姐姐', relation: '姨妈'),
      QuickRelation(label: '爷爷', relation: '爷爷'),
      QuickRelation(label: '奶奶', relation: '奶奶'),
      QuickRelation(label: '外公', relation: '外公'),
      QuickRelation(label: '外婆', relation: '外婆'),
      QuickRelation(label: '哥哥的儿子', relation: '侄子'),
      QuickRelation(label: '姐姐的儿子', relation: '外甥'),
      QuickRelation(label: '儿子的儿子', relation: '孙子'),
      QuickRelation(label: '女儿的儿子', relation: '外孙'),
      QuickRelation(label: '伯父的儿子', relation: '堂兄弟'),
      QuickRelation(label: '舅舅的儿子', relation: '表兄弟'),
      QuickRelation(label: '姑姑的儿子', relation: '表兄弟'),
      QuickRelation(label: '姨妈的儿子', relation: '表兄弟'),
      QuickRelation(label: '爷爷的哥哥', relation: '伯祖父'),
      QuickRelation(label: '爷爷的弟弟', relation: '叔祖父'),
      QuickRelation(label: '奶奶的姐妹', relation: '姨奶奶'),
    ];
  }
}

/// 快捷关系查询项
class QuickRelation {
  final String label;
  final String relation;

  QuickRelation({required this.label, required this.relation});
}
