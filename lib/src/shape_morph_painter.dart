import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:material_shapes/material_shapes.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix4;

/// Paints a morphing M3 shape by interpolating between two [RoundedPolygon]s
/// using [Morph].
///
/// The shape is drawn centered in [size], scaled to fill it uniformly.
/// [rotationAngle] rotates the shape around its center (radians).
/// [morphProgress] drives the Morph from shapeA (0.0) to shapeB (1.0).
class M3ShapeMorphPainter extends CustomPainter {
  final RoundedPolygon shapeA;
  final RoundedPolygon shapeB;

  /// Interpolation from [shapeA] (0.0) to [shapeB] (1.0).
  final double morphProgress;

  /// Rotation in radians, applied around the shape center.
  final double rotationAngle;

  final Color color;

  M3ShapeMorphPainter({
    required this.shapeA,
    required this.shapeB,
    required this.morphProgress,
    required this.color,
    this.rotationAngle = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final t = morphProgress.clamp(0.0, 1.0);
    final morph = Morph(shapeA, shapeB);

    // The normalized shapes live in [0,1]x[0,1].
    // Scale them to fill the canvas, then center.
    final scale = size.shortestSide;
    final cx = size.width / 2;
    final cy = size.height / 2;

    canvas.save();
    // Move origin to center, rotate, move back
    canvas.translate(cx, cy);
    canvas.rotate(rotationAngle);
    canvas.translate(-cx, -cy);

    // Scale from unit square to canvas
    final matrix = Matrix4.identity()
      ..translate(cx - scale / 2, cy - scale / 2)
      ..scale(scale, scale);

    final path = morph.toPath(
      progress: t,
      rotationPivotX: 0.5,
      rotationPivotY: 0.5,
    ).transform(matrix.storage);

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill
        ..isAntiAlias = true,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(M3ShapeMorphPainter old) =>
      old.morphProgress != morphProgress ||
          old.rotationAngle != rotationAngle ||
          old.color != color ||
          old.shapeA != shapeA ||
          old.shapeB != shapeB;
}

/// A convenience that rotates [degrees] into radians.
double degreesToRadians(double degrees) => degrees * math.pi / 180;