import 'package:flutter/material.dart';

/// A list item that reveals a morphing delete affordance when swiped.
///
/// As the user drags horizontally, the card's corner radius grows from a
/// resting value toward a fully rounded pill, while a colored slab emerges
/// from behind the card. The slab color transitions from transparent to
/// [deleteColor] and the delete icon pops in with a spring once the drag
/// crosses 50% of the morph threshold.
///
/// Releasing past [commitThreshold] pixels (or with sufficient velocity)
/// commits the dismiss and calls [onDismissed]. Releasing before the threshold
/// snaps the card back with an elastic spring.
///
/// The card surface — color, border, and content — is fully controlled by
/// the caller. This widget only owns the drag mechanics and the slab reveal.
///
/// ```dart
/// M3DismissibleListItem(
///   onDismissed: () => _deleteItem(item),
///   onTap: () => _openItem(item),
///   child: MyItemCard(item: item),
/// )
///
/// M3DismissibleListItem(
///   onDismissed: () => _deleteItem(item),
///   onTap: () => _openItem(item),
///   deleteColor: Colors.red,
///   deleteIcon: Icons.archive_rounded,
///   cardColor: theme.colorScheme.primaryContainer,
///   child: MyItemCard(item: item),
/// )
/// ```
class M3DismissibleListItem extends StatefulWidget {
  /// The content displayed inside the card.
  final Widget child;

  /// Called when the item is dismissed (swipe committed).
  final VoidCallback onDismissed;

  /// Called when the item is tapped without dragging.
  final VoidCallback onTap;

  /// Background color of the card surface.
  /// Defaults to [ColorScheme.surfaceContainerHighest].
  final Color? cardColor;

  /// Border color of the card surface.
  /// Defaults to [cardColor] (no visible border).
  final Color? borderColor;

  /// Background color of the delete slab.
  /// Defaults to [ColorScheme.error].
  final Color? deleteColor;

  /// Icon color when the slab is fully revealed.
  /// Defaults to [ColorScheme.onError].
  final Color? deleteOnColor;

  /// Icon shown in the delete slab. Defaults to [Icons.delete_rounded].
  final IconData deleteIcon;

  /// Pixels of drag required to fully morph the card radius and reveal the
  /// slab icon. Defaults to 72.
  final double morphThreshold;

  /// Pixels of drag (or velocity in px/s) required to commit the dismiss.
  /// Defaults to 72 px or 900 px/s.
  final double commitThreshold;

  /// Velocity in px/s that commits a dismiss even if [commitThreshold] is
  /// not reached by distance alone. Defaults to 900.
  final double velocityThreshold;

  /// Corner radius of the card at rest. Defaults to 18.
  final double radiusMin;

  /// Corner radius of the card at maximum morph. Defaults to 40.
  final double radiusMax;

  const M3DismissibleListItem({
    super.key,
    required this.child,
    required this.onDismissed,
    required this.onTap,
    this.cardColor,
    this.borderColor,
    this.deleteColor,
    this.deleteOnColor,
    this.deleteIcon = Icons.delete_rounded,
    this.morphThreshold = 72.0,
    this.commitThreshold = 72.0,
    this.velocityThreshold = 900.0,
    this.radiusMin = 18.0,
    this.radiusMax = 40.0,
  });

  @override
  State<M3DismissibleListItem> createState() =>
      _M3DismissibleListItemState();
}

class _M3DismissibleListItemState extends State<M3DismissibleListItem>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0.0;
  bool _isCommitting = false;

  late final AnimationController _springCtrl;
  late Animation<double> _springAnim;
  double _springFrom = 0.0;
  double _springTo = 0.0;

  @override
  void initState() {
    super.initState();
    _springCtrl = AnimationController(vsync: this)
      ..addListener(() {
        setState(() {
          _dragOffset = _springFrom +
              (_springTo - _springFrom) * _springAnim.value;
        });
      });
  }

  @override
  void dispose() {
    _springCtrl.dispose();
    super.dispose();
  }

  double get _morphT =>
      (_dragOffset.abs() / widget.morphThreshold).clamp(0.0, 1.0);

  double get _radius =>
      widget.radiusMin + _morphT * (widget.radiusMax - widget.radiusMin);

  double get _iconScale => Curves.easeOutBack.transform(
        ((_morphT - 0.5) / 0.5).clamp(0.0, 1.0),
      );

  double get _visualX {
    final abs = _dragOffset.abs();
    final sign = _dragOffset.sign;
    if (abs <= widget.commitThreshold) return _dragOffset;
    return sign *
        (widget.commitThreshold +
            (abs - widget.commitThreshold) * 0.35);
  }

  double get _slabWidth {
    final maxWidth = MediaQuery.of(context).size.width * 0.4;
    return _visualX.abs().clamp(0.0, maxWidth);
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (_isCommitting) return;
    _springCtrl.stop();
    setState(() => _dragOffset += d.delta.dx);
  }

  void _onDragEnd(DragEndDetails d) {
    if (_isCommitting) return;
    final velocity = d.velocity.pixelsPerSecond.dx;
    if (_dragOffset.abs() >= widget.commitThreshold ||
        velocity.abs() >= widget.velocityThreshold) {
      _commit();
    } else {
      _snapBack();
    }
  }

  void _commit() {
    _isCommitting = true;
    final sign = _dragOffset >= 0 ? 1.0 : -1.0;
    _animateTo(
      sign * 400.0,
      curve: Curves.easeInCubic,
      ms: 260,
      onDone: () {
        if (mounted) widget.onDismissed();
      },
    );
  }

  void _snapBack() => _animateTo(
        0.0,
        curve: Curves.elasticOut,
        ms: 500,
        onDone: () {
          if (mounted) setState(() => _isCommitting = false);
        },
      );

  void _animateTo(
    double target, {
    required Curve curve,
    required int ms,
    VoidCallback? onDone,
  }) {
    _springFrom = _dragOffset;
    _springTo = target;
    _springCtrl.duration = Duration(milliseconds: ms);
    _springAnim =
        CurvedAnimation(parent: _springCtrl, curve: curve);
    _springCtrl
      ..reset()
      ..forward().whenComplete(() => onDone?.call());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cardColor = widget.cardColor ?? cs.surfaceContainerHighest;
    final borderColor = widget.borderColor ?? cardColor;
    final deleteColor = widget.deleteColor ?? cs.error;
    final deleteOnColor = widget.deleteOnColor ?? cs.onError;

    final br = BorderRadius.circular(_radius);
    final goingLeft = _dragOffset < -1.0;
    final goingRight = _dragOffset > 1.0;

    return GestureDetector(
      onTap: widget.onTap,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (goingRight)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: _slabWidth,
              child: _DeleteSlab(
                width: _slabWidth,
                radius: _radius,
                morphT: _morphT,
                iconScale: _iconScale,
                deleteColor: deleteColor,
                deleteOnColor: deleteOnColor,
                deleteIcon: widget.deleteIcon,
                side: _SlabSide.left,
              ),
            ),
          if (goingLeft)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: _slabWidth,
              child: _DeleteSlab(
                width: _slabWidth,
                radius: _radius,
                morphT: _morphT,
                iconScale: _iconScale,
                deleteColor: deleteColor,
                deleteOnColor: deleteOnColor,
                deleteIcon: widget.deleteIcon,
                side: _SlabSide.right,
              ),
            ),
          Transform.translate(
            offset: Offset(_visualX, 0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: br,
                border: Border.all(
                  color: borderColor,
                  width: 1,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              ),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}

enum _SlabSide { left, right }

class _DeleteSlab extends StatelessWidget {
  final double width;
  final double radius;
  final double morphT;
  final double iconScale;
  final Color deleteColor;
  final Color deleteOnColor;
  final IconData deleteIcon;
  final _SlabSide side;

  const _DeleteSlab({
    required this.width,
    required this.radius,
    required this.morphT,
    required this.iconScale,
    required this.deleteColor,
    required this.deleteOnColor,
    required this.deleteIcon,
    required this.side,
  });

  @override
  Widget build(BuildContext context) {
    final t = Curves.easeOutCubic.transform(morphT);

    final bgColor = Color.lerp(Colors.transparent, deleteColor, t)!;
    final borderColor = Color.lerp(Colors.transparent, deleteColor, t)!;
    final iconColor = Color.lerp(
      deleteColor,
      deleteOnColor,
      ((t - 0.5) * 2).clamp(0.0, 1.0),
    )!;

    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: borderColor,
            width: 1,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Align(
          alignment: side == _SlabSide.left
              ? Alignment.centerLeft
              : Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: (radius * 0.55).clamp(10.0, 20.0),
            ),
            child: Transform.scale(
              scale: iconScale,
              child: Icon(deleteIcon, fill: 1, size: 22, color: iconColor),
            ),
          ),
        ),
      ),
    );
  }
}
