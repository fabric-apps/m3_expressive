import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:m3_expressive/m3_expressive.dart';

void main() {
  runApp(const ExampleApp());
}

const _bg = Color(0xFF08090F);
const _card = Color(0xFF0C0E18);
const _teal = Color(0xFF00BFA5);
const _mint = Color(0xFF80CBC4);
const _purple = Color(0xFF7C4DFF);
const _purpleLight = Color(0xFFB39DDB);
const _onBg = Color(0xFFE8EAF6);
const _onBgMuted = Color(0xFF7986CB);

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'm3_expressive',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _purple,
          brightness: Brightness.dark,
        ).copyWith(
          surface: _bg,
          primary: _teal,
          primaryContainer: _card,
          error: const Color(0xFFCF6679),
          onError: Colors.black,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: _bg,
        appBarTheme: const AppBarTheme(
          backgroundColor: _bg,
          surfaceTintColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          titleTextStyle: TextStyle(
            color: _onBg,
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ),
      home: const DemoShell(),
    );
  }
}

class DemoShell extends StatefulWidget {
  const DemoShell({super.key});

  @override
  State<DemoShell> createState() => _DemoShellState();
}

class _DemoShellState extends State<DemoShell> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = <(String, Widget)>[
    ('M3 Components', _LoadingPage()),
    ('M3 Components', _RefreshPage()),
    ('M3 Components', _DismissPage()),
    ('M3 Components', _UndoPage()),
    ('M3 Components', _TransformPage()),
  ];

  void _goTo(int page) {
    _controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pages[_page].$1),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded,
                color: _onBgMuted, size: 28),
            onPressed: _page > 0 ? () => _goTo(_page - 1) : null,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded,
                color: _onBg, size: 28),
            onPressed:
            _page < _pages.length - 1 ? () => _goTo(_page + 1) : null,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: PageView.builder(
        controller: _controller,
        onPageChanged: (i) => setState(() => _page = i),
        itemCount: _pages.length,
        itemBuilder: (_, i) => _pages[i].$2,
      ),
    );
  }
}

class _PagePadding extends StatelessWidget {
  final Widget child;
  const _PagePadding({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        text,
        style: const TextStyle(
          color: _onBgMuted,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

class _DarkCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const _DarkCard({
    required this.child,
    this.padding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: child,
    );
  }
}

class _LoadingPage extends StatelessWidget {
  const _LoadingPage();

  @override
  Widget build(BuildContext context) {
    return const _PagePadding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel('M3LoadingIndicator'),
          _DarkCard(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    M3LoadingIndicator(size: 32, color: _mint),
                    M3LoadingIndicator(size: 48, color: _teal),
                    M3LoadingIndicator(size: 64, color: _purple),
                  ],
                ),
                SizedBox(height: 28),
                Divider(color: Color(0xFF1A1D2E)),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    M3LoadingIndicator(
                        size: 40,
                        color: _purpleLight,
                        morphDuration:
                        Duration(milliseconds: 600)),
                    M3LoadingIndicator(
                        size: 40,
                        color: _teal,
                        morphDuration:
                        Duration(milliseconds: 1200)),
                    M3LoadingIndicator(
                        size: 40,
                        color: Color(0xFFF48FB1),
                        morphDuration:
                        Duration(milliseconds: 400)),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  'default  -  slow  -  fast',
                  style: TextStyle(
                      color: _onBgMuted, fontSize: 11, letterSpacing: 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RefreshPage extends StatelessWidget {
  const _RefreshPage();

  @override
  Widget build(BuildContext context) {
    return _PagePadding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('M3RefreshIndicator'),
          const Text(
            'Pull down on the list.',
            style: TextStyle(color: _onBgMuted, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _DarkCard(
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: M3RefreshIndicator(
                  onRefresh: () async =>
                      Future.delayed(const Duration(seconds: 2)),
                  backgroundColor: _onBg,
                  shapeColor: _onBgMuted,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: 12,
                    itemBuilder: (_, i) => ListTile(
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _teal.withAlpha(28),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                                color: _teal, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      title: Text(
                        'Item ${i + 1}',
                        style: const TextStyle(color: _onBg, fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DismissPage extends StatefulWidget {
  const _DismissPage();

  @override
  State<_DismissPage> createState() => _DismissPageState();
}

class _DismissPageState extends State<_DismissPage> {
  final List<(Color, Color, String)> _items = [
    (_teal.withAlpha(28), _teal, 'Swipe me left or right'),
    (_purple.withAlpha(28), _purple, 'I will disappear'),
    (const Color(0xFF1A1D2E), _onBgMuted, 'Both directions work'),
    (_mint.withAlpha(20), _mint, 'Release past threshold'),
    (const Color(0xFF1A0A1E), _purpleLight, 'Or fling fast'),
  ];

  @override
  Widget build(BuildContext context) {
    return _PagePadding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('M3DismissibleListItem'),
          ..._items.map((item) {
            final (bg, accent, label) = item;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: M3DismissibleListItem(
                key: ValueKey(label),
                onDismissed: () =>
                    setState(() => _items.remove(item)),
                onTap: () {},
                cardColor: bg,
                borderColor: accent.withAlpha(60),
                deleteColor: const Color(0xFFCF6679),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        label,
                        style: const TextStyle(
                          color: _onBg,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              ),
            );
          }),
          if (_items.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 40),
                child: Text('All dismissed.',
                    style: TextStyle(color: _onBgMuted)),
              ),
            ),
        ],
      ),
    );
  }
}

class _UndoPage extends StatefulWidget {
  const _UndoPage();

  @override
  State<_UndoPage> createState() => _UndoPageState();
}

class _UndoPageState extends State<_UndoPage> {
  bool _showPill = false;
  String _status = 'Tap Delete to trigger the pill.';

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _PagePadding(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionLabel('M3UndoPill'),
              _DarkCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _status,
                      style: const TextStyle(
                          color: _onBgMuted, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFCF6679),
                            foregroundColor: Colors.black,
                          ),
                          onPressed: _showPill
                              ? null
                              : () => setState(() {
                            _showPill = true;
                            _status =
                            'Pill visible. Undo to restore, X to confirm now.';
                          }),
                          child: const Text('Delete item'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_showPill)
          M3UndoPill(
            label: 'Item removed',
            backgroundColor: _onBg,
            progressColor: _purpleLight,
            foregroundColor: _bg,
            accentColor: _bg,
            onComplete: () => setState(() {
              _showPill = false;
              _status = 'Deleted.';
            }),
            onCancel: () => setState(() {
              _showPill = false;
              _status = 'Restored.';
            }),
          ),
      ],
    );
  }
}

class _TransformPage extends StatelessWidget {
  const _TransformPage();

  @override
  Widget build(BuildContext context) {
    return _PagePadding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('Draggable Container Transform'),
          Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Tap or drag up on the card.',
                      style: TextStyle(color: _onBgMuted, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    DraggableContainerButton(
                      closedColor: _card,
                      closedRadius: BorderRadius.circular(24),
                      openColor: _onBg,
                      pageBuilder: (_) => const _DetailPage(),
                      child: Container(
                        width: double.infinity,
                        height: 160,
                        decoration: BoxDecoration(
                          color: _card,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                              color: _purple.withAlpha(60), width: 1),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: _purple.withAlpha(40),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.open_in_full_rounded,
                                  color: _purpleLight, size: 22),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Open detail page',
                              style: TextStyle(
                                color: _onBg,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'tap or drag up',
                              style: TextStyle(color: _onBgMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ],
                ),
              )
          )
        ],
      ),
    );
  }
}

class _DetailPage extends StatelessWidget {
  const _DetailPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _onBg,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: _onBg,
        title: const Text('Detail', style: TextStyle(color: _card),),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _card),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const Center(
        child: Text(
          'Navigated via\ncontainer transform.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _card, fontSize: 16),
        ),
      ),
    );
  }
}