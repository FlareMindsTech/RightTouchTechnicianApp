class KycImageHelper {
  static String? parseImgValue(dynamic val) {
    if (val == null) return null;
    if (val is String && val.isNotEmpty) return val;
    if (val is List && val.isNotEmpty) {
      return parseImgValue(val[0]);
    }
    if (val is Map) {
      return val['url']?.toString() ??
          val['path']?.toString() ??
          val['image']?.toString() ??
          val['secure_url']?.toString();
    }
    return null;
  }

  static String? getImg(Map<String, dynamic> map, List<String> keys) {
    for (final k in keys) {
      final val = map[k];
      if (val != null) {
        final res = parseImgValue(val);
        if (res != null) return res;
      }
    }
    final docs = map['documents'];
    if (docs is Map<String, dynamic>) {
      for (final k in keys) {
        final val = docs[k];
        if (val != null) {
          final res = parseImgValue(val);
          if (res != null) return res;
        }
      }
    }
    return null;
  }
}
