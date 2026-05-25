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

/// Maps a canonical muscle name → overlay SVG element IDs (front_overlay.svg).
const Map<String, List<String>> _kFrontOverlayIds = {
  'chest':     ['chest_l', 'chest_r'],
  'shoulders': ['shoulders_l', 'shoulders_r'],
  'biceps':    ['biceps_l', 'biceps_r'],
  'forearms':  ['forearms_l', 'forearms_r'],
  'abs':       ['abs'],
  'quads':     ['quads_l', 'quads_r'],
  'calves':    ['calves_l', 'calves_r'],
};

/// Maps a canonical muscle name → overlay SVG element IDs (back_overlay.svg).
const Map<String, List<String>> _kBackOverlayIds = {
  'traps':      ['traps'],
  'back':       ['back_l', 'back_r'],
  'triceps':    ['triceps_l', 'triceps_r'],
  'forearms':   ['forearms_l', 'forearms_r'],
  'glutes':     ['glutes_l', 'glutes_r'],
  'hamstrings': ['hamstrings_l', 'hamstrings_r'],
  'calves':     ['calves_l', 'calves_r'],
};

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

/// Returns an opacity value based on how many sets were performed.
String _opacityForSets(int setCount) {
  if (setCount <= 0) return '0';
  if (setCount <= 3) return '0.40';
  if (setCount <= 7) return '0.60';
  return '0.80'; // 8+
}

/// Applies muscle highlighting to the overlay SVG string.
///
/// For each muscle in [muscleSetCounts] that has a matching entry in [idMap],
/// the path's `fill` is set to [_kHighlightColor] and `opacity` is set
/// according to the intensity tier.
String _applyOverlayHighlights(
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

// Tap regions aligned with the overlay SVG shape positions (318×564 space).
const List<_TapRegion> _kFrontTapRegions = [
  _TapRegion('chest',     120, 128, 78, 36),
  _TapRegion('shoulders',  82, 106, 38, 44),
  _TapRegion('shoulders', 198, 106, 38, 44),
  _TapRegion('biceps',     74, 140, 28, 52),
  _TapRegion('biceps',    210, 140, 28, 52),
  _TapRegion('forearms',   62, 190, 28, 60),
  _TapRegion('forearms',  228, 190, 28, 60),
  _TapRegion('abs',       134, 170, 50, 74),
  _TapRegion('quads',     110, 256, 36, 114),
  _TapRegion('quads',     170, 256, 36, 114),
  _TapRegion('calves',    110, 390, 28, 84),
  _TapRegion('calves',    174, 390, 28, 84),
];

const List<_TapRegion> _kBackTapRegions = [
  _TapRegion('traps',     122, 96,  74, 44),
  _TapRegion('back',      108, 134, 102, 100),
  _TapRegion('triceps',    72, 136, 30, 60),
  _TapRegion('triceps',   216, 136, 30, 60),
  _TapRegion('forearms',   60, 196, 28, 62),
  _TapRegion('forearms',  230, 196, 28, 62),
  _TapRegion('glutes',    112, 240, 96, 66),
  _TapRegion('hamstrings',108, 300, 38, 92),
  _TapRegion('hamstrings',174, 300, 38, 92),
  _TapRegion('calves',    108, 396, 28, 82),
  _TapRegion('calves',    182, 396, 28, 82),
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
  // Base body art SVGs (rendered as-is).
  String? _frontBase;
  String? _backBase;

  // Overlay SVGs (highlights applied to these).
  String? _frontOverlay;
  String? _backOverlay;

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
        rootBundle.loadString('assets/images/front_overlay.svg'),
        rootBundle.loadString('assets/images/back_overlay.svg'),
      ]);
      if (mounted) {
        setState(() {
          _frontBase    = results[0];
          _backBase     = results[1];
          _frontOverlay = results[2];
          _backOverlay  = results[3];
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
    if (count <= 3) return const Color(0xFFFF9999);
    if (count <= 7) return const Color(0xFFFF4444);
    return const Color(0xFFCC1111);
  }

  // ── Tap handler ───────────────────────────────────────────────────────────

  void _onTap(String muscle) {
    setState(() {
      _selectedMuscle = (_selectedMuscle == muscle) ? null : muscle;
    });
  }

  // ── Build helpers ─────────────────────────────────────────────────────────

  Widget _buildSvgPanel(
    String baseSvg,
    String overlaySvg,
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

    final highlightedOverlay =
        _applyOverlayHighlights(overlaySvg, widget.muscleSetCounts, idMap);

    return SizedBox(
      width: displayW,
      height: displayH,
      child: Stack(
        children: [
          // Layer 1: Base anatomy SVG (untouched)
          SvgPicture.string(
            baseSvg,
            width: displayW,
            height: displayH,
            fit: BoxFit.contain,
          ),
          // Layer 2: Muscle overlay with highlights
          SvgPicture.string(
            highlightedOverlay,
            width: displayW,
            height: displayH,
            fit: BoxFit.contain,
          ),
          // Layer 3: Transparent tap zones
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

    if (_frontBase == null || _backBase == null ||
        _frontOverlay == null || _backOverlay == null) {
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
          // The two SVG views (base + overlay stacked)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSvgPanel(
                _frontBase!,
                _frontOverlay!,
                _kFrontOverlayIds,
                _kFrontTapRegions,
                panelW,
              ),
              const SizedBox(width: 20),
              _buildSvgPanel(
                _backBase!,
                _backOverlay!,
                _kBackOverlayIds,
                _kBackTapRegions,
                panelW,
              ),
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
