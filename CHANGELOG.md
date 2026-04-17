# Changelog

All notable changes to this project will be documented in this file.
Format based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [1.0.0] - 2026-04-17

### Added
- `M3LoadingIndicator`: morphing square that cycles through four corner-radius
  configurations while rotating. Drop-in for `CircularProgressIndicator`.
- `M3RefreshIndicator`: pull-to-refresh with a circle container that scales in
  and a shape that morphs through seven M3 Expressive forms (Pill, Circle,
  Cookie, Sunny, Arrow, Pentagon, Clover) using Catmull-Rom interpolation.
- `M3ShapeMorphPainter`: the underlying `CustomPainter` exposed publicly for
  advanced embedding in custom widgets.
- `M3DismissibleListItem`: swipe-to-dismiss card with morphing corner radius,
  emerging delete slab, spring snap-back, and velocity-based commit.
- `M3UndoPill`: timed floating pill with progress bar, undo button, and
  dismiss icon. Fully parameterized for label, colors, duration, and icon.
- `DraggableContainerButton`: wraps any widget and adds tap and upward-drag
  container transform navigation with overlay drag preview.
- `openContainerTransform`: programmatic entry point for the same transition
  using a `GlobalKey` to capture the source rect.
