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
class FumbleMomentMap extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final point = LatLng(location.latitude, location.longitude);

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
              height: height,
              width: double.infinity,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: point,
                  initialZoom: 15,
                  interactionOptions: const InteractionOptions(
                    flags:
                        InteractiveFlag.drag |
                        InteractiveFlag.pinchZoom |
                        InteractiveFlag.doubleTapZoom,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: AppConfig.androidApplicationId,
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: point,
                        width: 40,
                        height: 40,
                        alignment: Alignment.topCenter,
                        child: const Icon(
                          Icons.location_on,
                          color: Color(0xFFE53935),
                          size: 36,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (showOpenInMaps) ...[
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
                .onPress(() => openInMaps(location))
                .paddingOnly(left: 5.w, right: 5.w, bottom: 10.h),
          ],
        ],
      ),
    );
  }
}
