// widgets/slider_row.dart
import 'package:carbgremover/widgets/GradientSliderTrackShape.dart';
import 'package:flutter/material.dart';

class SliderRow extends StatefulWidget {
  final String label;

  const SliderRow({super.key, required this.label});

  @override
  State<SliderRow> createState() => _SliderRowState();
}

class _SliderRowState extends State<SliderRow> {
  double _value = 0.5;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${widget.label}: ${(_value * 100).round()}%",
          style: const TextStyle(color: Colors.white,fontSize: 12),
        ),

        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            trackShape: GradientSliderTrackShape(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF00E5FF), // cyan
                  Color(0xFF29B6F6), // blue
                ],
              ),
            ),
            thumbColor: const Color(0xFF00E5FF),
          ),

          child: Slider(
            value: _value,
            onChanged: (v) {
              setState(() => _value = v);
            },
          ),
        ),

        const SizedBox(height: 6),
      ],
    );
  }
}
