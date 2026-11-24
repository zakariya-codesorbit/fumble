import 'package:fumble/services/location/fumble_location_service.dart';

/// Public profile fields from a `fumbleCodes` card (what peers see / scan).
class PublicFumbleProfile {
  const PublicFumbleProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.bio,
    this.aboutMe,
    this.location,
    this.phone,
    this.whatsApp,
    this.sharePhone = true,
    this.shareEmail = true,
    this.shareWhatsApp = true,
    this.fumbleLocation,
    this.fumblePlace,
    this.createdAt,
  });

  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String? bio;
  final String? aboutMe;
  final String? location;
  final String? phone;
  final String? whatsApp;
  final bool sharePhone;
  final bool shareEmail;
  final bool shareWhatsApp;
  final FumbleLocation? fumbleLocation;
  final String? fumblePlace;
  final DateTime? createdAt;
}
