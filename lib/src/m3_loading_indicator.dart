import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:material_shapes/material_shapes.dart';

import 'shape_morph_painter.dart';

/// A Material 3 Expressive loading indicator.
///
/// A shape continuously morphs through a random sequence of M3 forms,
/// rotating smoothly as it transitions. Each morph cycle picks a new shape
/// at random (never the same shape twice in a row).
///
/// ```dart
/// const M3LoadingIndicator()
///
/// M3LoadingIndicator(size: 32, color: Colors.teal)
/// ```
class M3LoadingIndicator extends StatefulWidget {
  /// Width and height of the painted area. Defaults to 48.
  final double size;

  /// Fill color of the morphing shape.
  /// Defaults to [ColorScheme.primary] from the ambient theme.
  final Color? color;

  /// Duration of one full morph cycle. Defaults to 900 ms.
  final Duration morphDuration;

  const M3LoadingIndicator({
    super.key,
    this.size = 48,
    this.color,
    this.morphDuration = const Duration(milliseconds: 900),
  });

  @override
  State<M3LoadingIndicator> createState() => _M3LoadingIndicatorState();
}

class _M3LoadingIndicatorState extends State<M3LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final _rng = math.Random();

  // Pool of shapes used during loading — varied enough to be interesting.
  static final _pool = <RoundedPolygon>[
    MaterialShapes.circle,
    MaterialShapes.gem,
    MaterialShapes.pentagon,
    MaterialShapes.diamond,
    MaterialShapes.arrow,
    MaterialShapes.pill,
    MaterialShapes.sunny,
    MaterialShapes.verySunny,
    MaterialShapes.clover4Leaf,
    MaterialShapes.softBurst,
    MaterialShapes.puffyDiamond,
    MaterialShapes.flower,
    MaterialShapes.cookie4Sided,
    MaterialShapes.softBoom,
  ];

  late RoundedPolygon _shapeA;
  late RoundedPolygon _shapeB;
  double _baseRotation = 0;

  // Radians added to the accumulated rotation each cycle.
  static const _rotationPerCycle = math.pi * 1.1;

  @override
  void initState() {
    super.initState();
    _shapeA = _pick(null);
    _shapeB = _pick(_shapeA);
    _ctrl = AnimationController(vsync: this, duration: widget.morphDuration)
      ..addStatusListener(_onCycleEnd);
    _ctrl.forward();
  }

  RoundedPolygon _pick(RoundedPolygon? exclude) {
    final pool = exclude == null
        ? _pool
        : _pool.where((s) => s != exclude).toList();
    return pool[_rng.nextInt(pool.length)];
  }

  void _onCycleEnd(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      setState(() {
        _shapeA = _shapeB;
        _shapeB = _pick(_shapeA);
        _baseRotation += _rotationPerCycle;
      });
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void didUpdateWidget(M3LoadingIndicator old) {
    super.didUpdateWidget(old);
    if (old.morphDuration != widget.morphDuration) {
      _ctrl.duration = widget.morphDuration;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final eased = Curves.easeInOutCubic.transform(_ctrl.value);
        return CustomPaint(
          size: Size.square(widget.size),
          painter: M3ShapeMorphPainter(
            shapeA: _shapeA,
            shapeB: _shapeB,
            morphProgress: eased,
            color: color,
            rotationAngle: _baseRotation + eased * _rotationPerCycle,
          ),
        );
      },
    );
  }
}