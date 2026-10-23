// Verhoeff checksum algorithm implementation for Aadhaar number validation.
// Based on the dihedral group D5.

class Verhoeff {
  static const List<List<int>> _d = [
    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
    [1, 2, 3, 4, 0, 6, 7, 8, 9, 5],
    [2, 3, 4, 0, 1, 7, 8, 9, 5, 6],
    [3, 4, 0, 1, 2, 8, 9, 5, 6, 7],
    [4, 0, 1, 2, 3, 9, 5, 6, 7, 8],
    [5, 9, 8, 7, 6, 0, 4, 3, 2, 1],
    [6, 5, 9, 8, 7, 1, 0, 4, 3, 2],
    [7, 6, 5, 9, 8, 2, 1, 0, 4, 3],
    [8, 7, 6, 5, 9, 3, 2, 1, 0, 4],
    [9, 8, 7, 6, 5, 4, 3, 2, 1, 0],
  ];

  static const List<List<int>> _p = [
    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
    [1, 5, 7, 6, 2, 8, 3, 0, 9, 4],
    [5, 8, 0, 3, 7, 9, 6, 1, 4, 2],
    [8, 9, 1, 6, 0, 4, 3, 5, 2, 7],
    [9, 4, 5, 3, 1, 2, 6, 8, 7, 0],
    [4, 2, 8, 6, 5, 7, 3, 9, 0, 1],
    [2, 7, 9, 3, 8, 0, 6, 4, 1, 5],
    [7, 0, 4, 6, 9, 1, 3, 2, 5, 8],
  ];

  static const List<int> _inv = [0, 4, 3, 2, 1, 5, 6, 7, 8, 9];

  /// Validates whether [numStr] satisfies the Verhoeff checksum.
  static bool validate(String numStr) {
    if (numStr.isEmpty) return false;
    int c = 0;
    final clean = numStr.replaceAll(RegExp(r'\s+'), '');
    final len = clean.length;

    for (int i = 0; i < len; i++) {
      final codeUnit = clean.codeUnitAt(len - 1 - i);
      if (codeUnit < 48 || codeUnit > 57) return false; // not 0-9
      final digit = codeUnit - 48;
      c = _d[c][_p[i % 8][digit]];
    }

    return c == 0;
  }

  /// Calculates the Verhoeff check digit for [numStr].
  static int generateCheckDigit(String numStr) {
    int c = 0;
    final clean = numStr.replaceAll(RegExp(r'\s+'), '');
    final len = clean.length;

    for (int i = 0; i < len; i++) {
      final codeUnit = clean.codeUnitAt(len - 1 - i);
      if (codeUnit < 48 || codeUnit > 57) {
        throw ArgumentError('Input string contains non-digit character');
      }
      final digit = codeUnit - 48;
      c = _d[c][_p[(i + 1) % 8][digit]];
    }

    return _inv[c];
  }
}
