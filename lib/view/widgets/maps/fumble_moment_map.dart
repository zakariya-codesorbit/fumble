import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:fumble/core/config/app_config.dart';
import 'package:fumble/core/theme/colors.dart';
import 'package:fumble/services/location/fumble_location_service.dart';
import 'package:fumble/utils/constant.dart';
import 'package:fumble/utils/style.dart';
import 'package:fumble/view/widgets/extention/int_extension.dart';
import 'package:fumble/view/widgets/extention/string_extension.dart';
import 'package:fumble/view/widgets/extention/widget_extension.dart';

/// Compact OpenStreetMap preview with a pin for a saved fumble meeting place.
class FumbleMomentMap extends StatefulWidget {
  const FumbleMomentMap({
    super.key,
    required this.location,
    this.height = 160,
    this.showOpenInMaps = true,
  });

  final FumbleLocation location;
  final double height;
  final bool showOpenInMaps;

  static Future<void> openInMaps(FumbleLocation location) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query='
      '${location.latitude},${location.longitude}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  State<FumbleMomentMap> createState() => _FumbleMomentMapState();
}

class _FumbleMomentMapState extends State<FumbleMomentMap> {
  late final MapController _mapController;

  LatLng get _point =>
      LatLng(widget.location.latitude, widget.location.longitude);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void didUpdateWidget(covariant FumbleMomentMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.location.latitude != widget.location.latitude ||
        oldWidget.location.longitude != widget.location.longitude) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _mapController.move(_point, _mapController.camera.zoom);
      });
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _centerOnPin() {
    _mapController.move(_point, _mapController.camera.zoom);
  }

  @override
  Widget build(BuildContext context) {
    final point = _point;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppStyle.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppStyle.radiusMd),
              topRight: Radius.circular(AppStyle.radiusMd),
            ),
            child: SizedBox(
              height: widget.height,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: point,
                      initialZoom: 15,
                      // Re-center after layout — iOS often misses initialCenter.
                      onMapReady: _centerOnPin,
                      interactionOptions: const InteractionOptions(
                        // No drag: fixed overlay pin stays on the meeting point.
                        flags: InteractiveFlag.pinchZoom |
                            InteractiveFlag.doubleTapZoom,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: AppConfig.androidApplicationId,
                      ),
                    ],
                  ),
                  // Overlay pin — always visually centered (reliable on iOS).
                  // Shift up so the tip sits on the map center, not the icon body.
                  const IgnorePointer(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 36),
                      child: Icon(
                        Icons.location_on,
                        color: Color(0xFFE53935),
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (widget.showOpenInMaps) ...[
            12.height,
            Row(
                  children: [
                    Expanded(
                      child: AppConstant.openInMaps.toText(
                        color: AppColors.gold,
                        fontSize: 14,
                        fontWeight: AppStyle.w600,
                      ),
                    ),
                    const Icon(
                      Icons.open_in_new,
                      size: 16,
                      color: AppColors.gold,
                    ),
                  ],
                )
                .onPress(() => FumbleMomentMap.openInMaps(widget.location))
                .paddingOnly(left: 5.w, right: 5.w, bottom: 10.h),
          ],
        ],
      ),
    );
  }
}
