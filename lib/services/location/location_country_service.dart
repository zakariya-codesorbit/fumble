import 'package:country_code_picker/country_code_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:fumble/services/location/fumble_location_service.dart';

/// Resolves the user's country dial code from device location.
abstract final class LocationCountryService {
  /// Requests location permission, reads GPS, reverse-geocodes to ISO country.
  /// Returns null when permission is denied, services are off, or lookup fails.
  static Future<({String dialCode, String countryCode})?>
      resolveFromDeviceLocation() async {
    try {
      var status = await Permission.locationWhenInUse.status;
      if (!status.isGranted) {
        status = await Permission.locationWhenInUse.request();
      }
      if (!status.isGranted) return null;

      final coords = await FumbleLocationService.currentLocation();
      if (coords == null) return null;

      final placemarks = await Geocoding().placemarkFromCoordinates(
        coords.latitude,
        coords.longitude,
      );
      if (placemarks.isEmpty) return null;

      final iso = placemarks.first.isoCountryCode?.trim().toUpperCase();
      if (iso == null || iso.isEmpty) return null;

      return fromCountryIso(iso);
    } catch (_) {
      return null;
    }
  }

  static ({String dialCode, String countryCode})? fromCountryIso(String iso) {
    final country = iso.trim().toUpperCase();
    if (country.isEmpty) return null;
    final match = codes.firstWhere(
      (c) => (c['code'] ?? '').toUpperCase() == country,
      orElse: () => const <String, String>{},
    );
    if (match.isEmpty) return null;
    return (
      dialCode: match['dial_code'] ?? '+1',
      countryCode: match['code'] ?? 'US',
    );
  }
}
