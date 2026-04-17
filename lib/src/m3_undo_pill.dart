import 'package:flutter/material.dart';

/// A floating pill that shows a timed undo affordance after a destructive action.
///
/// The pill contains:
///   - A label describing the action.
///   - A progress bar that drains from right to left as the timer counts down.
///   - An [undoLabel] button — tapping it calls [onCancel] and restores the item.
///   - A dismiss icon button — tapping it calls [onComplete] immediately,
///     confirming the deletion without waiting for the timer.
///
/// When the timer expires naturally, [onComplete] is also called.
///
/// Intended to be placed inside a [Stack] above your scrollable content.
///
/// ```dart
/// Stack(
///   children: [
///     ListView(...),
///     M3UndoPill(
///       label: 'Item removed',
///       onComplete: () => _permanentlyDelete(item),
///       onCancel: () => _restoreItem(item),
///     ),
///   ],
/// )
/// ```
class M3UndoPill extends StatefulWidget {
  /// Text shown in the pill describing the action that was taken.
  final String label;

  /// Label for the undo button. Defaults to 'Undo'.
  final String undoLabel;

  /// How long the pill waits before calling [onComplete]. Defaults to 4 seconds.
  final Duration duration;

  /// Called when the countdown expires naturally, or when the user taps the
  /// dismiss icon to confirm the deletion immediately.
  final VoidCallback onComplete;

  /// Called when the user taps the undo button to cancel the deletion.
  final VoidCallback onCancel;

  /// Background color of the pill track.
  /// Defaults to [ColorScheme.surfaceContainerLow].
  final Color? backgroundColor;

  /// Color of the progress bar that drains as the timer runs.
  /// Defaults to [ColorScheme.surfaceContainerHighest].
  final Color? progressColor;

  /// Color of the undo button label.
  /// Defaults to [ColorScheme.primary].
  final Color? accentColor;

  /// Color of the pill label text.
  /// Defaults to [ColorScheme.onSurface].
  final Color? foregroundColor;

  /// Icon shown in the dismiss button. Defaults to [Symbols.close_rounded].
  final IconData dismissIcon;

  /// Horizontal inset from the screen edges. Defaults to 48.
  final double horizontalPadding;

  const M3UndoPill({
    super.key,
    required this.label,
    required this.onComplete,
    required this.onCancel,
    this.undoLabel = 'Undo',
    this.duration = const Duration(seconds: 4),
    this.backgroundColor,
    this.progressColor,
    this.accentColor,
    this.foregroundColor,
    this.dismissIcon = Icons.close_rounded,
    this.horizontalPadding = 48,
  });

  @override
  State<M3UndoPill> createState() => _M3UndoPillState();
}

class _M3UndoPillState extends State<M3UndoPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _settled = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: 1.0,
    )
      ..addListener(() {
        if (mounted) setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.dismissed && !_settled) {
          _settle(widget.onComplete);
        }
      })
      ..reverse();
  }

  @override
  void dispose() {
    if (!_settled) _settled = true;
    _ctrl.dispose();
    super.dispose();
  }

  void _settle(VoidCallback callback) {
    if (_settled) return;
    _settled = true;
    _ctrl.stop();
    callback();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bgColor = widget.backgroundColor ?? cs.surfaceContainerLow;
    final progressColor = widget.progressColor ?? cs.surfaceContainerHighest;
    final accentColor = widget.accentColor ?? cs.primary;
    final fgColor = widget.foregroundColor ?? cs.onSurface;
    final safeBottom = MediaQuery.of(context).padding.bottom;
    const r = 28.0;

    return Positioned(
      left: widget.horizontalPadding,
      right: widget.horizontalPadding,
      bottom: safeBottom > 0 ? safeBottom + 16 : 32,
      child: Material(
        color: Colors.transparent,
        child: Container(
          height: 64,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(r),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Draining progress bar
              Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: _ctrl.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: progressColor,
                      borderRadius: BorderRadius.circular(r),
                    ),
                  ),
                ),
              ),
              // Content row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: fgColor,
                        ),
                      ),
                    ),
                    // Undo: cancels the deletion
                    GestureDetector(
                      onTap: () => _settle(widget.onCancel),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: progressColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.undoLabel,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // X: confirms deletion immediately
                    GestureDetector(
                      onTap: () => _settle(widget.onComplete),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: progressColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.dismissIcon,
                          size: 16,
                          color: accentColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}