// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:xml/xml.dart';
import '../utils/muscle_utils.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONSTANTS
// ─────────────────────────────────────────────────────────────────────────────

/// Highlight colour applied to active muscles.
const String _kHighlightColor = '#FF3B30';

/// Maps a canonical muscle name to the SVG element IDs used in front.svg.
const Map<String, List<String>> _kFrontIds = {
  'chest':     ['chest'],
  'shoulders': ['shoulders_l', 'shoulders_r'],
  'biceps':    ['biceps_l', 'biceps_r'],
  'forearms':  ['forearms_l', 'forearms_r'],
  'abs':       ['abs'],
  'quads':     ['quads_l', 'quads_r'],
  'calves':    ['calves_l', 'calves_r'],
};

/// Maps a canonical muscle name to the SVG element IDs used in back.svg.
const Map<String, List<String>> _kBackIds = {
  'traps':      ['traps'],
  'back':       ['back'],
  'triceps':    ['triceps_l', 'triceps_r'],
  'forearms':   ['forearms_l', 'forearms_r'],
  'glutes':     ['glutes'],
  'hamstrings': ['hamstrings_l', 'hamstrings_r'],
  'calves':     ['calves_l', 'calves_r'],
};

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

/// Returns an opacity value based on how many sets were performed.
String _opacityForSets(int setCount) {
  if (setCount <= 0) return '0';
  if (setCount == 1) return '0.35';
  if (setCount == 2) return '0.55';
  return '0.75'; // 3+
}

/// Applies muscle highlighting to a raw SVG string using XML DOM manipulation.
///
/// For each muscle in [muscleSetCounts] that has a matching entry in [idMap],
/// the overlay element's `fill` is set to [_kHighlightColor] and `opacity`
/// is set according to the intensity tier.
String _applySvgHighlights(
  String rawSvg,
  Map<String, int> muscleSetCounts,
  Map<String, List<String>> idMap,
) {
  final doc = XmlDocument.parse(rawSvg);

  // Build a lookup: elementId → setCount
  final Map<String, int> idToCount = {};
  for (final entry in idMap.entries) {
    final count = muscleSetCounts[entry.key] ?? 0;
    if (count > 0) {
      for (final id in entry.value) {
        idToCount[id] = count;
      }
    }
  }

  if (idToCount.isEmpty) return rawSvg;

  // Walk the document and update matching elements.
  for (final element in doc.descendants.whereType<XmlElement>()) {
    final id = element.getAttribute('id');
    if (id != null && idToCount.containsKey(id)) {
      final count = idToCount[id]!;
      element.setAttribute('fill', _kHighlightColor);
      element.setAttribute('opacity', _opacityForSets(count));
    }
  }

  return doc.toXmlString();
}

// ─────────────────────────────────────────────────────────────────────────────
// TAP REGION — used for invisible hit-test overlays
// ─────────────────────────────────────────────────────────────────────────────

class _TapRegion {
  final String muscle;
  final double x, y, w, h;
  const _TapRegion(this.muscle, this.x, this.y, this.w, this.h);
}

// Approximate tap regions in the 318×564 SVG coordinate space.
const List<_TapRegion> _kFrontTapRegions = [
  _TapRegion('chest',     105, 92,  90, 56),
  _TapRegion('shoulders',  58, 92,  44, 36),
  _TapRegion('shoulders', 198, 92,  44, 36),
  _TapRegion('biceps',     18, 100, 26, 58),
  _TapRegion('biceps',    274, 100, 26, 58),
  _TapRegion('forearms',   14, 160, 24, 52),
  _TapRegion('forearms',  280, 160, 24, 52),
  _TapRegion('abs',       120, 150, 60, 68),
  _TapRegion('quads',      92, 310, 40, 75),
  _TapRegion('quads',     186, 310, 40, 75),
  _TapRegion('calves',    100, 435, 28, 70),
  _TapRegion('calves',    190, 435, 28, 70),
];

const List<_TapRegion> _kBackTapRegions = [
  _TapRegion('traps',     102, 80,  96, 40),
  _TapRegion('back',      100, 130, 100, 80),
  _TapRegion('triceps',    20, 125, 26, 58),
  _TapRegion('triceps',   254, 125, 26, 58),
  _TapRegion('forearms',   16, 185, 24, 52),
  _TapRegion('forearms',  260, 185, 24, 52),
  _TapRegion('glutes',     98, 228, 104, 64),
  _TapRegion('hamstrings', 93, 300, 38, 75),
  _TapRegion('hamstrings',170, 300, 38, 75),
  _TapRegion('calves',    100, 400, 28, 65),
  _TapRegion('calves',    175, 400, 28, 65),
];

// ─────────────────────────────────────────────────────────────────────────────
// MUSCLE SVG VIEWER WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class MuscleSvgViewer extends StatefulWidget {
  final Map<String, int> muscleSetCounts;

  const MuscleSvgViewer({super.key, required this.muscleSetCounts});

  @override
  State<MuscleSvgViewer> createState() => _MuscleSvgViewerState();
}

class _MuscleSvgViewerState extends State<MuscleSvgViewer> {
  String? _frontSvg;
  String? _backSvg;
  String? _selectedMuscle;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSvgs();
  }

  Future<void> _loadSvgs() async {
    try {
      final results = await Future.wait([
        rootBundle.loadString('assets/images/front.svg'),
        rootBundle.loadString('assets/images/back.svg'),
      ]);
      if (mounted) {
        setState(() {
          _frontSvg = results[0];
          _backSvg = results[1];
          _loading = false;
        });
      }
    } catch (e) {
      print('Error loading SVGs: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void didUpdateWidget(covariant MuscleSvgViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-highlight if counts changed (e.g. live workout updates).
    // Raw SVGs are cached; only the highlight pass runs again.
  }

  // ── Color helpers ─────────────────────────────────────────────────────────

  Color _tooltipColor(int count) {
    if (count == 0) return const Color(0xFF3A3A3C);
    if (count <= 2) return const Color(0xFFFF9999);
    if (count <= 4) return const Color(0xFFFF4444);
    if (count <= 6) return const Color(0xFFCC1111);
    return const Color(0xFF881111);
  }

  // ── Tap handler ───────────────────────────────────────────────────────────

  void _onTap(String muscle) {
    setState(() {
      _selectedMuscle = (_selectedMuscle == muscle) ? null : muscle;
    });
  }

  // ── Build helpers ─────────────────────────────────────────────────────────

  Widget _buildSvgPanel(
    String rawSvg,
    Map<String, List<String>> idMap,
    List<_TapRegion> tapRegions,
    double displayW,
  ) {
    // SVG viewBox is 318×564
    const double svgW = 318;
    const double svgH = 564;
    final displayH = (svgH / svgW) * displayW;
    final sx = displayW / svgW;
    final sy = displayH / svgH;

    final highlighted = _applySvgHighlights(rawSvg, widget.muscleSetCounts, idMap);

    return SizedBox(
      width: displayW,
      height: displayH,
      child: Stack(
        children: [
          SvgPicture.string(
            highlighted,
            width: displayW,
            height: displayH,
            fit: BoxFit.contain,
          ),
          // Transparent tap zones overlaid on each muscle region
          for (final r in tapRegions)
            Positioned(
              left: r.x * sx,
              top: r.y * sy,
              width: r.w * sx,
              height: r.h * sy,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _onTap(r.muscle),
                child: Container(color: Colors.transparent),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTooltip() {
    final muscle = _selectedMuscle;
    if (muscle == null) {
      return const SizedBox(height: 38);
    }
    final count = widget.muscleSetCounts[muscle] ?? 0;
    final chipColor = _tooltipColor(count);
    final setsLabel = count == 1 ? '1 set' : '$count sets';
    final label = '${capitalizeMuscle(muscle)} — $setsLabel';

    return SizedBox(
      height: 38,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: chipColor.withAlpha(50),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: chipColor.withAlpha(180)),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: count == 0 ? Colors.white38 : Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 300,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white38),
          ),
        ),
      );
    }

    if (_frontSvg == null || _backSvg == null) {
      return const SizedBox(
        height: 300,
        child: Center(
          child: Text(
            'Could not load muscle diagrams',
            style: TextStyle(color: Colors.white38, fontSize: 13),
          ),
        ),
      );
    }

    return LayoutBuilder(builder: (context, constraints) {
      // Each SVG panel gets half the available width minus gap/margin.
      final panelW = ((constraints.maxWidth - 20) / 2).clamp(80.0, 160.0);

      return Column(
        children: [
          // Tooltip (animated in/out)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: KeyedSubtree(
              key: ValueKey(_selectedMuscle),
              child: _buildTooltip(),
            ),
          ),
          const SizedBox(height: 10),
          // Front + back labels
          Row(
            children: [
              SizedBox(
                width: panelW,
                child: const Center(
                  child: Text(
                    'FRONT',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              SizedBox(
                width: panelW,
                child: const Center(
                  child: Text(
                    'BACK',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // The two SVG views
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSvgPanel(_frontSvg!, _kFrontIds, _kFrontTapRegions, panelW),
              const SizedBox(width: 20),
              _buildSvgPanel(_backSvg!, _kBackIds, _kBackTapRegions, panelW),
            ],
          ),
          const SizedBox(height: 4),
          // Tap hint
          const Text(
            'Tap a muscle group for details',
            style: TextStyle(color: Colors.white24, fontSize: 11),
          ),
        ],
      );
    });
  }
}
