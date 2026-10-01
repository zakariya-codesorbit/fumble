class AppAvatars {
  static const String avatar1 = 'assets/avatars/avatar-1.svg';
  static const String avatar2 = 'assets/avatars/avatar-2.svg';
  static const String avatar3 = 'assets/avatars/avatar-3.svg';
  static const String avatar4 = 'assets/avatars/avatar-4.svg';
  static const String avatar5 = 'assets/avatars/avatar-5.svg';
  static const String avatar6 = 'assets/avatars/avatar-6.svg';
  static const String avatar7 = 'assets/avatars/avatar-7.svg';
  static const String avatar8 = 'assets/avatars/avatar-8.svg';
  static const String avatar9 = 'assets/avatars/avatar-9.svg';
  static const String avatar10 = 'assets/avatars/avatar-10.svg';
  static const String avatar11 = 'assets/avatars/avatar-11.svg';
  static const String avatar12 = 'assets/avatars/avatar-12.svg';

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

  static bool isAsset(String? path) => path != null && all.contains(path);
}
