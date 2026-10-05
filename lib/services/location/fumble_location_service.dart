import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:fumble/utils/constant.dart';
import 'package:fumble/view/screens/setting_screen/components/setting_actions.dart';

/// Lat/lng captured for a fumble (meeting place).
class FumbleLocation {
  const FumbleLocation({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  GeoPoint toGeoPoint() => GeoPoint(latitude, longitude);

  Map<String, double> toMap() => {
        'latitude': latitude,
        'longitude': longitude,
      };

  factory FumbleLocation.fromGeoPoint(GeoPoint point) {
    return FumbleLocation(
      latitude: point.latitude,
      longitude: point.longitude,
    );
  }

  static FumbleLocation? fromFirestore(dynamic value) {
    if (value is GeoPoint) return FumbleLocation.fromGeoPoint(value);
    if (value is Map) {
      final lat = value['latitude'];
      final lng = value['longitude'];
      if (lat is num && lng is num) {
        return FumbleLocation(
          latitude: lat.toDouble(),
          longitude: lng.toDouble(),
        );
      }
    }
    return null;
  }

  factory FumbleLocation.fromPosition(Position position) {
    return FumbleLocation(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}

/// Location permission + GPS helpers for onboarding country + fumble place.
abstract final class FumbleLocationService {
  /// Requests location when needed. Opens Settings if permanently denied.
  static Future<bool> ensurePermission(BuildContext context) async {
    var status = await Permission.locationWhenInUse.status;
    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      if (!context.mounted) return false;
      await _showSettingsSheet(context);
      return (await Permission.locationWhenInUse.status).isGranted;
    }

    status = await Permission.locationWhenInUse.request();
    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      if (!context.mounted) return false;
      await _showSettingsSheet(context);
      return (await Permission.locationWhenInUse.status).isGranted;
    }
    return false;
  }

  static Future<void> _showSettingsSheet(BuildContext context) {
    return SettingActions.showConfirmSheet(
      context: context,
      title: AppConstant.locationPermissionTitle,
      description: AppConstant.locationPermissionSettings,
      primaryCta: AppConstant.openSettings,
      destructive: false,
      onPrimaryTap: openAppSettings,
    );
  }

  static Future<bool> hasPermission() async {
    return Permission.locationWhenInUse.isGranted;
  }

  /// Current coordinates when permission + services allow; otherwise null.
  static Future<FumbleLocation?> currentLocation() async {
    try {
      if (!await hasPermission()) return null;
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return FumbleLocation.fromPosition(position);
    } catch (_) {
      return null;
    }
  }

  /// Request permission (if needed) then return current coordinates.
  static Future<FumbleLocation?> capture(
    BuildContext context, {
    bool promptIfDenied = true,
  }) async {
    if (!context.mounted) return null;
    final allowed = promptIfDenied
        // ignore: use_build_context_synchronously — guarded by mounted above
        ? await ensurePermission(context)
        : await hasPermission();
    if (!allowed) return null;
    return currentLocation();
  }

  /// Reverse-geocodes coordinates to a street/city label. Null when offline
  /// or the platform geocoder has no result.
  static Future<String?> placeLabel(FumbleLocation location) async {
    try {
      final marks = await Geocoding().placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      if (marks.isEmpty) return null;
      return labelFromPlacemark(marks.first);
    } catch (_) {
      return null;
    }
  }

  /// Builds "street, city, region" from a platform placemark.
  static String? labelFromPlacemark(Placemark p) {
    final streetParts = [
      p.subThoroughfare?.trim(),
      p.thoroughfare?.trim(),
    ].whereType<String>().where((s) => s.isNotEmpty);
    var street = streetParts.join(' ');
    if (street.isEmpty) {
      final fallback = (p.street?.trim().isNotEmpty ?? false)
          ? p.street!.trim()
          : (p.name?.trim() ?? '');
      if (fallback.isNotEmpty &&
          fallback != p.locality?.trim() &&
          !RegExp(r'^-?\d+(\.\d+)?$').hasMatch(fallback)) {
        street = fallback;
      }
    }
    final city = (p.locality?.trim().isNotEmpty ?? false)
        ? p.locality!.trim()
        : (p.subAdministrativeArea?.trim() ?? '');
    final region = p.administrativeArea?.trim() ?? '';
    final label = [
      if (street.isNotEmpty) street,
      if (city.isNotEmpty) city,
      if (region.isNotEmpty && region != city) region,
    ].join(', ');
    return label.isEmpty ? null : label;
  }
}

