import 'package:flutter/material.dart';

class DotWaveLoader extends StatefulWidget {
  final double size;
  final Color color;
  final String? text;
  final bool showCard;

  const DotWaveLoader({
    super.key,
    this.size = 12,
    this.color = const Color(0xFF207FA7),
    this.text,
    this.showCard = false,
  });

  @override
  State<DotWaveLoader> createState() => _DotWaveLoaderState();
}

class _DotWaveLoaderState extends State<DotWaveLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _scaleValue(int index) {
    final progress = (_controller.value - (index * 0.15)) % 1.0;
    if (progress < 0.5) {
      return 0.8 + (progress / 0.5) * 0.5;
    } else {
      return 1.3 - ((progress - 0.5) / 0.5) * 0.5;
    }
  }

  double _opacityValue(int index) {
    final progress = (_controller.value - (index * 0.15)) % 1.0;
    if (progress < 0.5) {
      return 0.4 + (progress / 0.5) * 0.6;
    } else {
      return 1.0 - ((progress - 0.5) / 0.5) * 0.6;
    }
  }

  Widget _buildDots() {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) {
              final scale = _scaleValue(index);
              final opacity = _opacityValue(index);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(opacity),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDots(),
        if (widget.text != null) ...[
          const SizedBox(height: 14),
          Text(
            widget.text!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ],
    );

    if (!widget.showCard) return content;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: content,
    );
  }
}