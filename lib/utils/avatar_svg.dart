import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// These avatar files keep color in a `<style>` class sheet
/// (`.cls-1 { fill:#fcc19c }`). flutter_svg does not apply that sheet,
/// so every path paints with the SVG default, which is black.
/// Copy fill and opacity onto the elements before drawing.
String inlineSvgClassStyles(String svg) {
  final style = RegExp(r'<style[^>]*>([\s\S]*?)</style>').firstMatch(svg);
  if (style == null) return svg;

  final props = <String, Map<String, String>>{};
  for (final rule in RegExp(
    r'([^{}]+)\{([^{}]+)\}',
  ).allMatches(style.group(1)!)) {
    final decls = <String, String>{};
    for (final part in rule.group(2)!.split(';')) {
      final split = part.split(':');
      if (split.length < 2) continue;
      final key = split.first.trim();
      final value = split.sublist(1).join(':').trim();
      if (key == 'fill' || key == 'opacity' || key == 'stroke') {
        decls[key] = value;
      }
    }
    if (decls.isEmpty) continue;
    for (final selector in rule.group(1)!.split(',')) {
      final name = selector.trim();
      if (!name.startsWith('.')) continue;
      props.putIfAbsent(name.substring(1), () => {}).addAll(decls);
    }
  }

  var prepared = svg.replaceAll(RegExp(r'<style[^>]*>[\s\S]*?</style>'), '');
  prepared = prepared.replaceAllMapped(RegExp(r'\sclass="([^"]+)"'), (match) {
    final attrs = <String>[];
    for (final name in match.group(1)!.split(RegExp(r'\s+'))) {
      final values = props[name];
      if (values == null) continue;
      for (final entry in values.entries) {
        attrs.add('${entry.key}="${entry.value}"');
      }
    }
    return attrs.isEmpty ? '' : ' ${attrs.join(' ')}';
  });
  return prepared;
}

class AvatarSvg {
  static final _cache = <String, Future<String>>{};

  static Future<String> load(String asset) {
    return _cache.putIfAbsent(asset, () async {
      final raw = await rootBundle.loadString(asset);
      return inlineSvgClassStyles(raw);
    });
  }
}

/// Bundled avatar drawn with its stylesheet colors inlined.
class AvatarSvgPicture extends StatelessWidget {
  const AvatarSvgPicture({super.key, required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: AvatarSvg.load(asset),
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) return const SizedBox.expand();
        return SvgPicture.string(data, fit: BoxFit.contain);
      },
    );
  }
}
