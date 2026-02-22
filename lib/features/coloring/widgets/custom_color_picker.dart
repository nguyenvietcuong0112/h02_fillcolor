import 'package:flutter/material.dart';

class CustomColorPicker extends StatefulWidget {
  final Color initialColor;
  final Function(Color) onColorChanged;

  const CustomColorPicker({
    super.key,
    required this.initialColor,
    required this.onColorChanged,
  });

  @override
  State<CustomColorPicker> createState() => _CustomColorPickerState();
}

class _CustomColorPickerState extends State<CustomColorPicker> {
  late HSLColor _hslColor;

  @override
  void initState() {
    super.initState();
    _hslColor = HSLColor.fromColor(widget.initialColor);
  }

  void _updateColor() {
    widget.onColorChanged(_hslColor.toColor());
  }

  static const List<Color> _proSwatches = [
    Colors.redAccent, Colors.orangeAccent, Colors.amberAccent,
    Colors.lightGreenAccent, Colors.tealAccent, Colors.cyanAccent,
    Colors.lightBlueAccent, Colors.indigoAccent, Colors.purpleAccent,
    Colors.pinkAccent,
  ];

  @override
  Widget build(BuildContext context) {
    final Color currentColor = _hslColor.toColor();
    final isDark = currentColor.computeLuminance() < 0.2;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Premium Color Preview
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: currentColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? Colors.white24 : Colors.black12, 
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: currentColor.withValues(alpha: 0.4),
                blurRadius: 30,
                spreadRadius: 5,
              ),
              const BoxShadow(
                color: Colors.white,
                blurRadius: 2,
                spreadRadius: -5,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.colorize_rounded,
              color: currentColor.computeLuminance() > 0.5 ? Colors.black38 : Colors.white38,
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: 32),

        // 2. Pro Swatches (Quick Selection)
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _proSwatches.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final color = _proSwatches[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _hslColor = HSLColor.fromColor(color);
                    _updateColor();
                  });
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 32),
        
        // 3. Hue Slider (Spectrum)
        _buildGradientSlider(
          label: 'Hue',
          value: _hslColor.hue,
          min: 0,
          max: 360,
          gradient: const LinearGradient(
            colors: [
              Colors.red, Colors.yellow, Colors.green, 
              Colors.cyan, Colors.blue, Colors.purpleAccent, Colors.red
            ],
          ),
          onChanged: (val) {
            setState(() {
              _hslColor = _hslColor.withHue(val);
              _updateColor();
            });
          },
        ),
        
        // Saturation Slider
        _buildGradientSlider(
          label: 'Saturation',
          value: _hslColor.saturation,
          min: 0,
          max: 1.0,
          gradient: LinearGradient(
            colors: [
              _hslColor.withSaturation(0).toColor(),
              _hslColor.withSaturation(1).toColor(),
            ],
          ),
          onChanged: (val) {
            setState(() {
              _hslColor = _hslColor.withSaturation(val);
              _updateColor();
            });
          },
        ),
        
        // Lightness Slider
        _buildGradientSlider(
          label: 'Lightness',
          value: _hslColor.lightness,
          min: 0,
          max: 1.0,
          gradient: LinearGradient(
            colors: [
              _hslColor.withLightness(0).toColor(),
              _hslColor.withLightness(0.5).toColor(),
              _hslColor.withLightness(1).toColor(),
            ],
          ),
          onChanged: (val) {
            setState(() {
              _hslColor = _hslColor.withLightness(val);
              _updateColor();
            });
          },
        ),
      ],
    );
  }

  Widget _buildGradientSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required Gradient gradient,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w800, 
                  color: Colors.blueGrey[800],
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                label == 'Hue' ? '${value.toInt()}°' : '${(value * 100).toInt()}%',
                style: TextStyle(
                  color: Colors.blueGrey[400], 
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            alignment: Alignment.center,
            children: [
              // Track Gradient
              Container(
                height: 12,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              // Invisible Slider for interaction
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.transparent,
                  inactiveTrackColor: Colors.transparent,
                  thumbColor: Colors.white,
                  overlayColor: Colors.white.withValues(alpha: 0.2),
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 10,
                    elevation: 5,
                    pressedElevation: 8,
                  ),
                  trackHeight: 12,
                ),
                child: Slider(
                  value: value,
                  min: min,
                  max: max,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
