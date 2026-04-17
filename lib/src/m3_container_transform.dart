import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Navigates to [pageBuilder] with a morph animation that expands from the
/// widget identified by [sourceKey] to fill the screen.
///
/// ```dart
/// final _key = GlobalKey();
///
/// // On the source widget:
/// Container(key: _key, ...)
///
/// // To navigate:
/// await openContainerTransform(
///   context: context,
///   sourceKey: _key,
///   closedColor: theme.colorScheme.primaryContainer,
///   closedRadius: BorderRadius.circular(28),
///   pageBuilder: (_) => const DetailPage(),
/// );
/// ```
Future<void> openContainerTransform({
  required BuildContext context,
  required GlobalKey sourceKey,
  required Color closedColor,
  required BorderRadius closedRadius,
  required WidgetBuilder pageBuilder,
  VoidCallback? onReturn,
}) async {
  final box =
      sourceKey.currentContext?.findRenderObject() as RenderBox?;
  if (box == null) return;
  final origin = box.localToGlobal(Offset.zero);
  final sourceRect = origin & box.size;
  final screenSize = MediaQuery.of(context).size;

  await Navigator.of(context).push(
    _ContainerTransformRoute(
      sourceRect: sourceRect,
      screenSize: screenSize,
      closedColor: closedColor,
      closedRadius: closedRadius,
      openColor: Theme.of(context).colorScheme.surface,
      scrimColor: Colors.black,
      pageBuilder: pageBuilder,
      skipOpenAnimation: false,
    ),
  );
  onReturn?.call();
}

/// A button that supports both tap and upward drag to trigger a Material 3
/// container transform transition.
///
/// On tap: the container immediately morphs to fill the screen and navigates.
/// On drag up: the morph follows the finger. Releasing above 40% of the screen
/// height (or with a fast enough flick) commits the navigation. Releasing
/// below that threshold snaps back with a spring.
///
/// During the drag preview the morph is painted in an [Overlay] so it renders
/// above the navigation bar and all other content.
///
/// ```dart
/// DraggableContainerButton(
///   closedColor: theme.colorScheme.primaryContainer,
///   closedRadius: const BorderRadius.only(
///     topLeft: Radius.circular(32),
///     topRight: Radius.circular(32),
///     bottomLeft: Radius.circular(16),
///     bottomRight: Radius.circular(16),
///   ),
///   pageBuilder: (_) => const DetailPage(),
///   onReturn: _refreshData,
///   child: MyButtonWidget(),
/// )
/// ```
class DraggableContainerButton extends StatefulWidget {
  /// Background color of the button in its closed state.
  final Color closedColor;

  /// Corner radii of the button in its closed state.
  final BorderRadius closedRadius;

  /// Builds the destination page.
  final WidgetBuilder pageBuilder;

  /// The button content.
  final Widget child;

  /// Called after the user returns from the destination page.
  final VoidCallback? onReturn;

  /// How many pixels of upward drag equals t=1.0.
  /// Defaults to 35% of the screen height.
  final double? triggerDistance;

  /// Called on every drag frame and after snap/commit with t in [0, 1].
  /// Use this to drive external widgets (e.g. a nav bar) in sync.
  final void Function(double t)? onProgressUpdate;

  /// Async validation run before a tap commits. Return false to abort.
  final Future<bool> Function()? onTapValidation;

  /// Sync validation run at the start of a drag. Return false to abort.
  final bool Function()? onDragValidation;

  /// Set to false to disable drag (e.g. when a required form field is empty).
  final bool enableDrag;

  /// Background color of the destination page surface.
  /// Defaults to [ColorScheme.surface] from the ambient theme.
  final Color? openColor;

  /// Color of the scrim that fades in behind the morphing container.
  /// Defaults to [Colors.black].
  final Color? scrimColor;

  const DraggableContainerButton({
    super.key,
    required this.closedColor,
    required this.closedRadius,
    required this.pageBuilder,
    required this.child,
    this.onReturn,
    this.triggerDistance,
    this.onProgressUpdate,
    this.onTapValidation,
    this.onDragValidation,
    this.enableDrag = true,
    this.openColor,
    this.scrimColor,
  });

  @override
  State<DraggableContainerButton> createState() =>
      _DraggableContainerButtonState();
}

class _DraggableContainerButtonState extends State<DraggableContainerButton>
    with SingleTickerProviderStateMixin {
  final GlobalKey _btnKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  late final AnimationController _snapCtrl;

  double _dragT = 0.0;
  bool _committing = false;
  Rect _sourceRect = Rect.zero;

  @override
  void initState() {
    super.initState();
    _snapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _snapCtrl.dispose();
    super.dispose();
  }

  Rect _captureRect() {
    final box =
        _btnKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return Rect.zero;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  Color get _openColor =>
      widget.openColor ?? Theme.of(context).colorScheme.surface;

  Color get _scrimColor => widget.scrimColor ?? Colors.black;

  void _showOverlay(double initialT) {
    _overlayEntry?.remove();
    final screen = MediaQuery.of(context).size;
    _overlayEntry = OverlayEntry(builder: (_) {
      return _DragMorphOverlay(
        animation: _snapCtrl,
        dragTGetter: () => _dragT,
        committing: _committing,
        sourceRect: _sourceRect,
        screenSize: screen,
        closedColor: widget.closedColor,
        closedRadius: widget.closedRadius,
        openColor: _openColor,
        scrimColor: _scrimColor,
        pageBuilder: widget.pageBuilder,
      );
    });
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _onTap() async {
    if (widget.onTapValidation != null) {
      final ok = await widget.onTapValidation!();
      if (!ok) return;
    }
    HapticFeedback.mediumImpact();
    _sourceRect = _captureRect();
    _commit();
  }

  void _onDragStart(DragStartDetails _) {
    if (_committing) return;
    if (!widget.enableDrag) return;
    if (widget.onDragValidation != null &&
        !widget.onDragValidation!()) {
      return;
    }
    _sourceRect = _captureRect();
    _dragT = 0.0;
    _snapCtrl.value = 0.0;
    _committing = false;
    _showOverlay(0.0);
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_committing) return;
    final screen = MediaQuery.of(context).size;
    final trigger =
        widget.triggerDistance ?? screen.height * 0.35;
    final upDelta = -details.delta.dy;
    _dragT = (_dragT + upDelta / trigger).clamp(0.0, 1.0);

    if (_dragT >= 1.0) HapticFeedback.lightImpact();

    widget.onProgressUpdate?.call(_dragT);
    _overlayEntry?.markNeedsBuild();
  }

  void _onDragEnd(DragEndDetails details) {
    if (_committing) return;
    final velocity = -details.velocity.pixelsPerSecond.dy;
    final screen = MediaQuery.of(context).size;
    final trigger =
        widget.triggerDistance ?? screen.height * 0.35;

    if (_dragT >= 0.4 || velocity > trigger * 1.5) {
      _commit();
    } else {
      _snapBack();
    }
  }

  Future<void> _commit() async {
    _committing = true;
    if (_overlayEntry == null) {
      _sourceRect = _captureRect();
      _showOverlay(_dragT);
    }
    HapticFeedback.mediumImpact();

    _snapCtrl.value = _dragT;
    await _snapCtrl.animateTo(
      1.0,
      duration: Duration(
          milliseconds:
              (300 * (1 - _dragT)).round().clamp(120, 300)),
      curve: Curves.easeOutCubic,
    );

    if (!mounted) return;
    _removeOverlay();
    _dragT = 0.0;
    _committing = false;
    _snapCtrl.value = 0.0;

    await Navigator.of(context).push(
      _ContainerTransformRoute(
        sourceRect: _sourceRect,
        screenSize: MediaQuery.of(context).size,
        closedColor: widget.closedColor,
        closedRadius: widget.closedRadius,
        openColor: _openColor,
        scrimColor: _scrimColor,
        pageBuilder: widget.pageBuilder,
        skipOpenAnimation: true,
      ),
    );
    widget.onProgressUpdate?.call(0.0);
    widget.onReturn?.call();
  }

  Future<void> _snapBack() async {
    _snapCtrl.value = _dragT;
    await _snapCtrl.animateTo(
      0.0,
      duration: Duration(
          milliseconds: (280 * _dragT).round().clamp(80, 280)),
      curve: Curves.easeInCubic,
    );
    _removeOverlay();
    _dragT = 0.0;
    _snapCtrl.value = 0.0;
    widget.onProgressUpdate?.call(0.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      onVerticalDragStart: _onDragStart,
      onVerticalDragUpdate: _onDragUpdate,
      onVerticalDragEnd: _onDragEnd,
      behavior: HitTestBehavior.opaque,
      child: KeyedSubtree(key: _btnKey, child: widget.child),
    );
  }
}

// Internal overlay widget painted above everything during drag/snap.

class _DragMorphOverlay extends StatelessWidget {
  final AnimationController animation;
  final double Function() dragTGetter;
  final bool committing;
  final Rect sourceRect;
  final Size screenSize;
  final Color closedColor;
  final BorderRadius closedRadius;
  final Color openColor;
  final Color scrimColor;
  final WidgetBuilder pageBuilder;

  const _DragMorphOverlay({
    required this.animation,
    required this.dragTGetter,
    required this.committing,
    required this.sourceRect,
    required this.screenSize,
    required this.closedColor,
    required this.closedRadius,
    required this.openColor,
    required this.scrimColor,
    required this.pageBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = committing || animation.isAnimating
            ? animation.value
            : dragTGetter();
        return _morphWidget(context, t);
      },
    );
  }

  Widget _morphWidget(BuildContext context, double t) {
    final te =
        Curves.easeInOutCubicEmphasized.transform(t.clamp(0.0, 1.0));

    final targetRect =
        Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);
    final currentRect = Rect.lerp(sourceRect, targetRect, te)!;
    final br = BorderRadius.lerp(closedRadius, BorderRadius.zero, te)!;
    final color = Color.lerp(closedColor, openColor, te)!;
    final contentOpacity = ((te - 0.6) / 0.4).clamp(0.0, 1.0);
    final scrimOpacity = (te * 2).clamp(0.0, 1.0) * 0.5;

    Widget? pageContent;
    if (contentOpacity > 0) {
      pageContent = Builder(builder: pageBuilder);
    }

    return Stack(
      children: [
        if (scrimOpacity > 0)
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: scrimOpacity,
                child: ColoredBox(color: scrimColor),
              ),
            ),
          ),
        Positioned(
          left: currentRect.left,
          top: currentRect.top,
          width: currentRect.width,
          height: currentRect.height,
          child: ClipRRect(
            borderRadius: br,
            child: ColoredBox(
              color: color,
              child: pageContent != null
                  ? Opacity(
                      opacity: contentOpacity, child: pageContent)
                  : const SizedBox.expand(),
            ),
          ),
        ),
      ],
    );
  }
}

// Route used for both the tap commit and the return animation.

class _ContainerTransformRoute<T> extends PageRoute<T> {
  final Rect sourceRect;
  final Size screenSize;
  final Color closedColor;
  final BorderRadius closedRadius;
  final Color openColor;
  final Color scrimColor;
  final WidgetBuilder pageBuilder;
  final bool skipOpenAnimation;

  _ContainerTransformRoute({
    required this.sourceRect,
    required this.screenSize,
    required this.closedColor,
    required this.closedRadius,
    required this.openColor,
    required this.scrimColor,
    required this.pageBuilder,
    required this.skipOpenAnimation,
  }) : super(fullscreenDialog: false);

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => skipOpenAnimation
      ? Duration.zero
      : const Duration(milliseconds: 500);

  @override
  Duration get reverseTransitionDuration =>
      const Duration(milliseconds: 420);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) =>
      pageBuilder(context);

  @override
  Widget buildTransitions(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    if (skipOpenAnimation &&
        animation.status != AnimationStatus.reverse) {
      return child;
    }
    return _ContainerTransformWidget(
      animation: animation,
      sourceRect: sourceRect,
      screenSize: screenSize,
      closedColor: closedColor,
      closedRadius: closedRadius,
      openColor: openColor,
      scrimColor: scrimColor,
      child: child,
    );
  }
}

class _ContainerTransformWidget extends StatelessWidget {
  final Animation<double> animation;
  final Rect sourceRect;
  final Size screenSize;
  final Color closedColor;
  final BorderRadius closedRadius;
  final Color openColor;
  final Color scrimColor;
  final Widget child;

  const _ContainerTransformWidget({
    required this.animation,
    required this.sourceRect,
    required this.screenSize,
    required this.closedColor,
    required this.closedRadius,
    required this.openColor,
    required this.scrimColor,
    required this.child,
  });

  static const _openCurve = Curves.easeInOutCubicEmphasized;
  static const _closeCurve = Curves.easeInCubic;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final isOpen =
            animation.status != AnimationStatus.reverse;
        final curve = isOpen ? _openCurve : _closeCurve;
        final t = curve.transform(animation.value);

        final targetRect =
            Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);
        final currentRect = Rect.lerp(sourceRect, targetRect, t)!;
        final br =
            BorderRadius.lerp(closedRadius, BorderRadius.zero, t)!;
        final color = Color.lerp(closedColor, openColor, t)!;
        final contentT = ((t - 0.25) / 0.75).clamp(0.0, 1.0);
        final scrimT = (t * 2).clamp(0.0, 1.0);

        return Stack(
          children: [
            if (scrimT > 0)
              Positioned.fill(
                child: IgnorePointer(
                  child: Opacity(
                    opacity: scrimT * 0.6,
                    child: ColoredBox(color: scrimColor),
                  ),
                ),
              ),
            Positioned(
              left: currentRect.left,
              top: currentRect.top,
              width: currentRect.width,
              height: currentRect.height,
              child: ClipRRect(
                borderRadius: br,
                child: ColoredBox(
                  color: color,
                  child: Opacity(opacity: contentT, child: child),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Suppress unused import warning for lerpDouble — retained for potential
// future use in callers that extend this file.
// ignore: unused_element
double _unused = lerpDouble(0, 0, 0)!;
