import 'package:flutter/material.dart';
import '../../../core/constants/api_constants.dart';

/// Renders an exercise GIF through the backend proxy so the RapidAPI key
/// is never exposed to the Flutter client. Falls back to a dumbbell icon
/// if the proxy request fails.
class ExerciseGifWidget extends StatefulWidget {
  final String gifUrl;
  final double width;
  final double height;
  final BoxFit fit;

  const ExerciseGifWidget({
    super.key,
    required this.gifUrl,
    this.width = double.infinity,
    this.height = 220,
    this.fit = BoxFit.contain,
  });

  @override
  State<ExerciseGifWidget> createState() => _ExerciseGifWidgetState();
}

class _ExerciseGifWidgetState extends State<ExerciseGifWidget> {
  bool _loading = true;
  bool _error = false;

  /// Routes the GIF through our backend so auth headers are added server-side.
  String get _proxiedUrl {
    if (widget.gifUrl.isEmpty) return '';
    final encoded = Uri.encodeComponent(widget.gifUrl);
    return '${ApiConstants.baseUrl}/exercises/gif-proxy?url=$encoded';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.gifUrl.isEmpty) {
      return _buildFallback();
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background fill
            Container(color: const Color(0xFF1A1A1A)),

            if (_error)
              _buildFallback()
            else
              Image.network(
                _proxiedUrl,
                width: widget.width,
                height: widget.height,
                fit: widget.fit,
                gaplessPlayback: true,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _loading = false);
                    });
                    return child;
                  }
                  return const SizedBox.shrink();
                },
                errorBuilder: (context, error, stack) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() { _loading = false; _error = true; });
                  });
                  return const SizedBox.shrink();
                },
              ),

            if (_loading && !_error)
              const CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.blue,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallback() {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fitness_center, color: Colors.white24, size: 48),
          SizedBox(height: 8),
          Text('Preview unavailable', style: TextStyle(color: Colors.white24, fontSize: 12)),
        ],
      ),
    );
  }
}
