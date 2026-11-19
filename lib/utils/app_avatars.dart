class AppAvatars {
  static const String avatar1 = 'assets/avatars/avatar-1.png';
  static const String avatar2 = 'assets/avatars/avatar-2.png';
  static const String avatar3 = 'assets/avatars/avatar-3.png';
  static const String avatar4 = 'assets/avatars/avatar-4.png';
  static const String avatar5 = 'assets/avatars/avatar-5.png';
  static const String avatar6 = 'assets/avatars/avatar-6.png';
  static const String avatar7 = 'assets/avatars/avatar-7.png';
  static const String avatar8 = 'assets/avatars/avatar-8.png';
  static const String avatar9 = 'assets/avatars/avatar-9.png';
  static const String avatar10 = 'assets/avatars/avatar-10.png';
  static const String avatar11 = 'assets/avatars/avatar-11.png';
  static const String avatar12 = 'assets/avatars/avatar-12.png';

  static const List<String> all = [
    avatar1,
    avatar2,
    avatar3,
    avatar4,
    avatar5,
    avatar6,
    avatar7,
    avatar8,
    avatar9,
    avatar10,
    avatar11,
    avatar12,
  ];

  /// Resolves a bundled avatar path, including legacy `.svg` photoUrls.
  static String? resolve(String? path) {
    if (path == null || path.isEmpty) return null;
    if (all.contains(path)) return path;
    if (path.endsWith('.svg')) {
      final png = '${path.substring(0, path.length - 4)}.png';
      if (all.contains(png)) return png;
    }
    return null;
  }

  static bool isAsset(String? path) => resolve(path) != null;
}
