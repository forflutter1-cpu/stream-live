int eduInt(dynamic value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

double eduDouble(dynamic value, [double fallback = 0]) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

bool eduBool(dynamic value, [bool fallback = false]) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.toLowerCase().trim();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
  }
  return fallback;
}

String eduString(dynamic value, [String fallback = '']) {
  if (value == null) return fallback;
  return value.toString();
}

int? eduRelatedId(dynamic value) {
  if (value == null) return null;
  if (value is Map) return eduInt(value['id']);
  return eduInt(value);
}

List<int> eduIdList(dynamic value) {
  if (value is List) {
    return value
        .map(eduRelatedId)
        .whereType<int>()
        .where((id) => id > 0)
        .toList();
  }
  if (value is String && value.trim().isNotEmpty) {
    return value
        .split(',')
        .map((item) => int.tryParse(item.trim()))
        .whereType<int>()
        .where((id) => id > 0)
        .toList();
  }
  return const [];
}
