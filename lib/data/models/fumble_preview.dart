class FumblePreview {
  const FumblePreview({
    required this.peerUid,
    required this.name,
    this.email,
    this.photoUrl,
  });

  final String peerUid;
  final String name;
  final String? email;
  final String? photoUrl;

  factory FumblePreview.fromMap(Map<String, dynamic> data) {
    return FumblePreview(
      peerUid: (data['uid'] as String?) ??
          (data['peerUid'] as String?) ??
          '',
      name: (data['name'] as String?)?.trim() ?? '',
      email: (data['email'] as String?)?.trim(),
      photoUrl: data['photoUrl'] as String?,
    );
  }
}
