# m3_expressive

Material 3 Expressive components for Flutter.

Google's Android 16 design language introduces a new generation of motion and
shape work that Flutter's built-in widgets do not yet cover. This package fills
that gap with five production-ready components that follow the M3 Expressive
spec as closely as possible.

> Record a short screen capture of each component in motion and replace the
> placeholder lines below with the embedded GIFs before publishing.

| Component | Preview |
|---|---|
| M3LoadingIndicator | *(add GIF)* |
| M3RefreshIndicator | *(add GIF)* |
| M3DismissibleListItem | *(add GIF)* |
| M3UndoPill | *(add GIF)* |
| DraggableContainerButton | *(add GIF)* |

---

## Installation

```yaml
dependencies:
  m3_expressive: ^1.0.0
```

```bash
flutter pub get
```

Then import once in any file that needs it:

```dart
import 'package:m3_expressive/m3_expressive.dart';
```

---

## Components

### M3LoadingIndicator

A morphing square that cycles through four corner-radius configurations while
rotating. Drop-in replacement for `CircularProgressIndicator`.

```dart
// Defaults: size 48, color from Theme.colorScheme.primary
const M3LoadingIndicator()

// Custom
M3LoadingIndicator(
  size: 32,
  color: Colors.teal,
  duration: const Duration(milliseconds: 1000),
)
```

**Parameters**

| Parameter | Type | Default | Description |
|---|---|---|---|
| `size` | `double` | `48` | Width and height of the indicator |
| `color` | `Color?` | `colorScheme.primary` | Fill color |
| `duration` | `Duration` | `1400 ms` | Duration of one full morph cycle |

---

### M3RefreshIndicator

Pull-to-refresh with a circular container that scales in from the top as the
user pulls. Inside the circle, a shape morphs continuously through seven M3
Expressive forms using Catmull-Rom interpolation.

```dart
// Minimal usage
M3RefreshIndicator(
  onRefresh: _handleRefresh,
  child: ListView(...),
)

// Custom colors
M3RefreshIndicator(
  onRefresh: _handleRefresh,
  backgroundColor: Colors.indigo.shade100,
  shapeColor: Colors.indigo,
  child: ListView(...),
)
```

**Parameters**

| Parameter | Type | Default | Description |
|---|---|---|---|
| `onRefresh` | `Future<void> Function()` | required | Called when refresh is triggered |
| `child` | `Widget` | required | The scrollable content |
| `indicatorSize` | `double` | `56` | Diameter of the indicator circle |
| `triggerDistance` | `double` | `80` | Pull distance required to trigger |
| `backgroundColor` | `Color?` | `colorScheme.primaryContainer` | Circle background |
| `shapeColor` | `Color?` | `colorScheme.primary` | Shape fill color |
| `morphDuration` | `Duration` | `1600 ms` | Duration of one shape cycle while dragging |

The underlying painter is also public as `M3ShapeMorphPainter` for embedding
in your own `CustomPaint`.

---

### M3DismissibleListItem

A list card with a morphing swipe-to-dismiss gesture. As the user drags
horizontally, the card corners round toward a pill shape and a colored slab
emerges from behind. The delete icon springs in past the halfway point.
Releasing above the commit threshold (or with a fast fling) dismisses the
item. Releasing below it snaps back with an elastic spring.

```dart
M3DismissibleListItem(
  onDismissed: () => _deleteItem(item),
  onTap: () => _openItem(item),
  child: MyItemContent(item),
)

// Custom colors and icon
M3DismissibleListItem(
  onDismissed: () => _archiveItem(item),
  onTap: () => _openItem(item),
  deleteColor: Colors.orange,
  deleteIcon: Icons.archive_rounded,
  cardColor: theme.colorScheme.primaryContainer,
  child: MyItemContent(item),
)
```

**Parameters**

| Parameter | Type | Default | Description |
|---|---|---|---|
| `onDismissed` | `VoidCallback` | required | Called when dismiss is committed |
| `onTap` | `VoidCallback` | required | Called on tap |
| `child` | `Widget` | required | Card content |
| `cardColor` | `Color?` | `colorScheme.surfaceContainerHighest` | Card background |
| `borderColor` | `Color?` | same as `cardColor` | Card border |
| `deleteColor` | `Color?` | `colorScheme.error` | Slab background at full reveal |
| `deleteOnColor` | `Color?` | `colorScheme.onError` | Icon color at full reveal |
| `deleteIcon` | `IconData` | `Symbols.delete_rounded` | Slab icon |
| `morphThreshold` | `double` | `72` | Pixels to fully morph the radius |
| `commitThreshold` | `double` | `72` | Pixels to commit the dismiss |
| `velocityThreshold` | `double` | `900` | px/s to commit regardless of distance |
| `radiusMin` | `double` | `18` | Corner radius at rest |
| `radiusMax` | `double` | `40` | Corner radius at full morph |

---

### M3UndoPill

A floating pill with a timed progress bar. Appears after a destructive action
and counts down until calling `onComplete`. The user can cancel at any time
by tapping the undo button or the dismiss icon.

Intended to be placed inside a `Stack` above your scrollable content.

```dart
Stack(
  children: [
    ListView(...),
    M3UndoPill(
      label: 'Item removed',
      onComplete: () => _permanentlyDelete(item),
      onCancel: () => _restoreItem(item),
    ),
  ],
)

// Custom
M3UndoPill(
  label: 'Message deleted',
  undoLabel: 'Restore',
  duration: const Duration(seconds: 6),
  accentColor: Colors.teal,
  onComplete: _onComplete,
  onCancel: _onCancel,
)
```

**Parameters**

| Parameter | Type | Default | Description |
|---|---|---|---|
| `label` | `String` | required | Text describing the action |
| `onComplete` | `VoidCallback` | required | Called when the timer expires |
| `onCancel` | `VoidCallback` | required | Called when the user cancels |
| `undoLabel` | `String` | `'Undo'` | Undo button text |
| `duration` | `Duration` | `4 seconds` | Countdown duration |
| `backgroundColor` | `Color?` | `colorScheme.surfaceContainerLow` | Pill track color |
| `progressColor` | `Color?` | `colorScheme.surfaceContainerHighest` | Progress bar color |
| `accentColor` | `Color?` | `colorScheme.primary` | Undo button text color |
| `foregroundColor` | `Color?` | `colorScheme.onSurface` | Label and icon color |
| `dismissIcon` | `IconData` | `Symbols.close_rounded` | Dismiss button icon |
| `horizontalPadding` | `double` | `48` | Inset from screen edges |

---

### DraggableContainerButton and openContainerTransform

A Material 3 container transform transition with both tap and drag support.

**DraggableContainerButton** wraps any widget. On tap it immediately commits
the navigation. On upward drag it follows the finger with a live morph preview
painted in an Overlay above the navigation bar. Releasing above 40% of the
trigger distance (or with a fast enough flick) navigates forward. Releasing
below snaps back with a spring.

```dart
DraggableContainerButton(
  closedColor: theme.colorScheme.primaryContainer,
  closedRadius: BorderRadius.circular(28),
  pageBuilder: (_) => const DetailPage(),
  onReturn: _refreshData,
  child: MyButton(),
)
```

**openContainerTransform** is the programmatic equivalent for cases where you
manage the tap gesture yourself.

```dart
final _key = GlobalKey();

// On the source widget:
Container(key: _key, child: ...)

// On tap:
await openContainerTransform(
  context: context,
  sourceKey: _key,
  closedColor: theme.colorScheme.primaryContainer,
  closedRadius: BorderRadius.circular(28),
  pageBuilder: (_) => const DetailPage(),
);
```

**DraggableContainerButton parameters**

| Parameter | Type | Default | Description |
|---|---|---|---|
| `closedColor` | `Color` | required | Button color in closed state |
| `closedRadius` | `BorderRadius` | required | Button radii in closed state |
| `pageBuilder` | `WidgetBuilder` | required | Builds the destination page |
| `child` | `Widget` | required | Button content |
| `onReturn` | `VoidCallback?` | `null` | Called after the user returns |
| `triggerDistance` | `double?` | 35% screen height | Upward drag to reach t=1 |
| `onProgressUpdate` | `void Function(double)?` | `null` | Drag progress in [0, 1] |
| `onTapValidation` | `Future<bool> Function()?` | `null` | Async guard before tap commit |
| `onDragValidation` | `bool Function()?` | `null` | Sync guard before drag starts |
| `enableDrag` | `bool` | `true` | Enable or disable drag gesture |
| `openColor` | `Color?` | `colorScheme.surface` | Destination page background |
| `scrimColor` | `Color?` | `Colors.black` | Scrim color |

---

## Theming

All color parameters default to values from the ambient `Theme.of(context).colorScheme`.
An app using standard Material 3 theming requires no color customization at all.
Dynamic color, dark mode, and custom color schemes are all handled automatically.

---

## Requirements

Shape definitions provided by the [material_shapes](https://github.com/ksokolovskyi/material_shapes) library by Kostiantyn Sokolovskyi, used under the MIT license.

- Flutter 3.10 or higher
- Dart 3.0 or higher

---

## License

MIT. See [LICENSE](LICENSE).
