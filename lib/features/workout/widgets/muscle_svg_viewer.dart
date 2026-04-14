// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/muscle_utils.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TAP REGION
// ─────────────────────────────────────────────────────────────────────────────

class _Region {
  final String muscle;
  final double x, y, w, h;
  const _Region(this.muscle, this.x, this.y, this.w, this.h);
}

// SVG coordinate space: 140 × 320
const double _kSvgW = 140;
const double _kSvgH = 320;

const List<_Region> _kFrontRegions = [
  _Region('shoulders', 12, 56, 24, 32),
  _Region('shoulders', 104, 56, 24, 32),
  _Region('chest',     46, 54, 48, 42),
  _Region('biceps',    12, 56, 20, 54),
  _Region('biceps',    108, 56, 20, 54),
  _Region('forearms',  10, 112, 18, 46),
  _Region('forearms',  112, 112, 18, 46),
  _Region('abs',       46, 96, 48, 54),
  _Region('quads',     44, 152, 22, 72),
  _Region('quads',     74, 152, 22, 72),
  _Region('calves',    46, 228, 18, 68),
  _Region('calves',    76, 228, 18, 68),
];

const List<_Region> _kBackRegions = [
  _Region('traps',      36, 54, 68, 32),
  _Region('back',       42, 86, 56, 64),
  _Region('triceps',    12, 56, 20, 54),
  _Region('triceps',    108, 56, 20, 54),
  _Region('forearms',   10, 112, 18, 46),
  _Region('forearms',   112, 112, 18, 46),
  _Region('glutes',     44, 154, 52, 44),
  _Region('hamstrings', 44, 200, 22, 72),
  _Region('hamstrings', 74, 200, 22, 72),
  _Region('calves',     46, 276, 18, 38),
  _Region('calves',     76, 276, 18, 38),
];

// ─────────────────────────────────────────────────────────────────────────────
// SVG TEMPLATES  — %MUSCLE_NAME% are replaced at runtime with hex colors
// ─────────────────────────────────────────────────────────────────────────────

const _d = '#1A1A1C'; // decorative (head, neck)
const _s = '#4A4A4D'; // stroke color
const _sw = '0.8';    // stroke-width

final String _kFrontSvg = '''
<svg width="140" height="320" viewBox="0 0 140 320" xmlns="http://www.w3.org/2000/svg">
  <ellipse cx="70" cy="24" rx="20" ry="22" fill="$_d" stroke="$_s" stroke-width="$_sw"/>
  <rect x="63" y="44" width="14" height="13" rx="4" fill="$_d" stroke="$_s" stroke-width="$_sw"/>
  <ellipse cx="34" cy="72" rx="21" ry="14" fill="%SHOULDERS%" stroke="$_s" stroke-width="$_sw"/>
  <ellipse cx="106" cy="72" rx="21" ry="14" fill="%SHOULDERS%" stroke="$_s" stroke-width="$_sw"/>
  <rect x="13" y="56" width="19" height="54" rx="8" fill="%BICEPS%" stroke="$_s" stroke-width="$_sw"/>
  <rect x="108" y="56" width="19" height="54" rx="8" fill="%BICEPS%" stroke="$_s" stroke-width="$_sw"/>
  <rect x="46" y="54" width="48" height="42" rx="10" fill="%CHEST%" stroke="$_s" stroke-width="$_sw"/>
  <rect x="11" y="112" width="17" height="46" rx="7" fill="%FOREARMS%" stroke="$_s" stroke-width="$_sw"/>
  <rect x="112" y="112" width="17" height="46" rx="7" fill="%FOREARMS%" stroke="$_s" stroke-width="$_sw"/>
  <rect x="46" y="96" width="48" height="54" rx="8" fill="%ABS%" stroke="$_s" stroke-width="$_sw"/>
  <rect x="44" y="152" width="22" height="74" rx="9" fill="%QUADS%" stroke="$_s" stroke-width="$_sw"/>
  <rect x="74" y="152" width="22" height="74" rx="9" fill="%QUADS%" stroke="$_s" stroke-width="$_sw"/>
  <rect x="46" y="230" width="18" height="68" rx="7" fill="%CALVES%" stroke="$_s" stroke-width="$_sw"/>
  <rect x="76" y="230" width="18" height="68" rx="7" fill="%CALVES%" stroke="$_s" stroke-width="$_sw"/>
</svg>
''';

final String _kBackSvg = '''
<svg width="140" height="320" viewBox="0 0 140 320" xmlns="http://www.w3.org/2000/svg">
  <ellipse cx="70" cy="24" rx="20" ry="22" fill="$_d" stroke="$_s" stroke-width="$_sw"/>
  <rect x="63" y="44" width="14" height="13" rx="4" fill="$_d" stroke="$_s" stroke-width="$_sw"/>
  <path d="M46 55 Q70 70 94 55 L104 55 Q110 72 104 86 Q88 94 70 94 Q52 94 36 86 Q30 72 36 55 Z"
        fill="%TRAPS%" stroke="$_s" stroke-width="$_sw"/>
  <rect x="13" y="56" width="19" height="54" rx="8" fill="%TRICEPS%" stroke="$_s" stroke-width="$_sw"/>
  <rect x="108" y="56" width="19" height="54" rx="8" fill="%TRICEPS%" stroke="$_s" stroke-width="$_sw"/>
  <rect x="42" y="88" width="56" height="64" rx="10" fill="%BACK%" stroke="$_s" stroke-width="$_sw"/>
  <rect x="11" y="112" width="17" height="46" rx="7" fill="%FOREARMS%" stroke="$_s" stroke-width="$_sw"/>
  <rect x="112" y="112" width="17" height="46" rx="7" fill="%FOREARMS%" stroke="$_s" stroke-width="$_sw"/>
  <rect x="44" y="154" width="52" height="44" rx="10" fill="%GLUTES%" stroke="$_s" stroke-width="$_sw"/>
  <rect x="44" y="202" width="22" height="72" rx="9" fill="%HAMSTRINGS%" stroke="$_s" stroke-width="$_sw"/>
  <rect x="74" y="202" width="22" height="72" rx="9" fill="%HAMSTRINGS%" stroke="$_s" stroke-width="$_sw"/>
  <rect x="46" y="278" width="18" height="36" rx="7" fill="%CALVES%" stroke="$_s" stroke-width="$_sw"/>
  <rect x="76" y="278" width="18" height="36" rx="7" fill="%CALVES%" stroke="$_s" stroke-width="$_sw"/>
</svg>
''';

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
  String? _selectedMuscle;

  // ── Color helpers ───────────────────────────────────────────────────────────

  String _coloredSvg(String template) {
    String svg = template;
    for (final m in kAllUiMuscles) {
      final count = widget.muscleSetCounts[m] ?? 0;
      svg = svg.replaceAll('%${m.toUpperCase()}%', muscleColor(count));
    }
    return svg;
  }

  Color _tooltipColor(int count) {
    if (count == 0) return const Color(0xFF3A3A3C);
    if (count <= 2) return const Color(0xFFFF9999);
    if (count <= 4) return const Color(0xFFFF4444);
    if (count <= 6) return const Color(0xFFCC1111);
    return const Color(0xFF881111);
  }

  // ── Tap handler ─────────────────────────────────────────────────────────────

  void _onTap(String muscle) {
    setState(() {
      _selectedMuscle = (_selectedMuscle == muscle) ? null : muscle;
    });
  }

  // ── Build helpers ───────────────────────────────────────────────────────────

  Widget _buildSvgPanel(String svgTemplate, List<_Region> regions, double displayW) {
    final displayH = (_kSvgH / _kSvgW) * displayW;
    final sx = displayW / _kSvgW;
    final sy = displayH / _kSvgH;

    return SizedBox(
      width: displayW,
      height: displayH,
      child: Stack(
        children: [
          SvgPicture.string(
            _coloredSvg(svgTemplate),
            width: displayW,
            height: displayH,
            fit: BoxFit.fill,
          ),
          // Transparent tap zones overlaid on each muscle region
          for (final r in regions)
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

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
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
              SizedBox(width: panelW, child: const Center(child: Text('FRONT', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)))),
              const SizedBox(width: 20),
              SizedBox(width: panelW, child: const Center(child: Text('BACK', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)))),
            ],
          ),
          const SizedBox(height: 6),
          // The two SVG views
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSvgPanel(_kFrontSvg, _kFrontRegions, panelW),
              const SizedBox(width: 20),
              _buildSvgPanel(_kBackSvg, _kBackRegions, panelW),
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
