import 'package:fumble/services/location/fumble_location_service.dart';

/// Public profile fields from a `fumbleCodes` card (what peers see / scan).
class PublicFumbleProfile {
  const PublicFumbleProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.bio,
    this.phone,
    this.sharePhone = true,
    this.shareEmail = true,
    this.fumbleLocation,
    this.fumblePlace,
  });

  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String? bio;
  final String? phone;
  final bool sharePhone;
  final bool shareEmail;
  final FumbleLocation? fumbleLocation;
  final String? fumblePlace;
}
