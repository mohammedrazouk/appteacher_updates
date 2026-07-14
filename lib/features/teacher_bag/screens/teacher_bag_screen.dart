import 'package:flutter/material.dart';

class TeacherBagScreen extends StatelessWidget {
  const TeacherBagScreen({super.key});

  static const List<String> images = [
    'assets/image/حقيبة معلم الرشيدي والسفرة_Page_00.webp',
    'assets/image/حقيبة معلم الرشيدي والسفرة_Page_01.webp',
    'assets/image/حقيبة معلم الرشيدي والسفرة_Page_02.webp',
    'assets/image/حقيبة معلم الرشيدي والسفرة_Page_03.webp',
    'assets/image/حقيبة معلم الرشيدي والسفرة_Page_04.webp',
    'assets/image/حقيبة معلم الرشيدي والسفرة_Page_05.webp',
    'assets/image/حقيبة معلم الرشيدي والسفرة_Page_06.webp',
    'assets/image/حقيبة معلم الرشيدي والسفرة_Page_07.webp',
    'assets/image/حقيبة معلم الرشيدي والسفرة_Page_08.webp',
    'assets/image/حقيبة معلم الرشيدي والسفرة_Page_09.webp',
    'assets/image/حقيبة معلم الرشيدي والسفرة_Page_10.webp',
    'assets/image/حقيبة معلم الرشيدي والسفرة_Page_11.webp',
    'assets/image/حقيبة معلم الرشيدي والسفرة_Page_12.webp',
    'assets/image/حقيبة معلم الرشيدي والسفرة_Page_13.webp',
    'assets/image/حقيبة معلم الرشيدي والسفرة_Page_14.webp',
    'assets/image/حقيبة معلم الرشيدي والسفرة_Page_15.webp',
    'assets/image/حقيبة معلم الرشيدي والسفرة_Page_16.webp',
    'assets/image/حقيبة معلم الرشيدي والسفرة_Page_17.webp',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('حقيبة المعلم'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _FullScreenViewer(
                    images: images,
                    initialIndex: index,
                  ),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  images[index],
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    color: Colors.white12,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.broken_image, size: 40, color: Colors.white38),
                          SizedBox(height: 8),
                          Text('تعذر تحميل الصورة', style: TextStyle(color: Colors.white38)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FullScreenViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  const _FullScreenViewer({required this.images, required this.initialIndex});

  @override
  State<_FullScreenViewer> createState() => _FullScreenViewerState();
}

class _FullScreenViewerState extends State<_FullScreenViewer> {
  late final PageController _pageController;
  late int _currentPage;
  bool _zoomed = false;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('الصفحة ${_currentPage + 1} من ${widget.images.length}'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        physics: _zoomed ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
        onPageChanged: (page) => setState(() => _currentPage = page),
        itemBuilder: (context, index) => _ZoomablePage(
          imagePath: widget.images[index],
          onZoomChanged: (zoomed) {
            if (zoomed != _zoomed) setState(() => _zoomed = zoomed);
          },
        ),
      ),
    );
  }
}

class _ZoomablePage extends StatefulWidget {
  final String imagePath;
  final ValueChanged<bool> onZoomChanged;
  const _ZoomablePage({required this.imagePath, required this.onZoomChanged});

  @override
  State<_ZoomablePage> createState() => _ZoomablePageState();
}

class _ZoomablePageState extends State<_ZoomablePage> {
  final TransformationController _tc = TransformationController();
  static const List<double> _levels = [1.0, 1.5, 2.0, 2.5, 3.0, 4.0, 5.0];
  int _zoomIndex = 0;

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  void _notifyZoom() {
    final scale = _tc.value.getMaxScaleOnAxis();
    widget.onZoomChanged(scale > 1.05);
  }

  void _syncZoomIndex() {
    final scale = _tc.value.getMaxScaleOnAxis();
    for (int i = _levels.length - 1; i >= 0; i--) {
      if (scale >= _levels[i] - 0.05) {
        _zoomIndex = i;
        break;
      }
    }
  }

  void _zoomIn() {
    if (_zoomIndex < _levels.length - 1) {
      _zoomIndex++;
      _setScale(_levels[_zoomIndex]);
    }
  }

  void _zoomOut() {
    if (_zoomIndex > 0) {
      _zoomIndex--;
      _setScale(_levels[_zoomIndex]);
    }
  }

  void _resetZoom() {
    _zoomIndex = 0;
    _tc.value = Matrix4.identity();
    _notifyZoom();
    setState(() {});
  }

  void _setScale(double scale) {
    final size = MediaQuery.of(context).size;
    final cx = size.width / 2;
    final cy = size.height / 2;
    _tc.value = Matrix4.identity()
      ..translate(cx, cy)
      ..scale(scale)
      ..translate(-cx, -cy);
    _notifyZoom();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: InteractiveViewer(
            transformationController: _tc,
            minScale: 1.0,
            maxScale: 5.0,
            boundaryMargin: const EdgeInsets.all(double.infinity),
            panEnabled: true,
            scaleEnabled: true,
            onInteractionStart: (_) {},
            onInteractionEnd: (_) {
              _syncZoomIndex();
              _notifyZoom();
              setState(() {});
            },
            child: Center(
              child: Image.asset(
                widget.imagePath,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.broken_image, size: 64, color: Colors.white54),
                      SizedBox(height: 12),
                      Text('تعذر تحميل الصورة', style: TextStyle(color: Colors.white54, fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Container(
          color: Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ZoomBtn(icon: Icons.zoom_out, onTap: _zoomOut, enabled: _zoomIndex > 0),
                const SizedBox(width: 20),
                _ZoomBtn(icon: Icons.fit_screen_outlined, onTap: _resetZoom, enabled: _zoomIndex > 0, size: 22),
                const SizedBox(width: 20),
                _ZoomBtn(icon: Icons.zoom_in, onTap: _zoomIn, enabled: _zoomIndex < _levels.length - 1),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ZoomBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  final double size;
  const _ZoomBtn({required this.icon, required this.onTap, required this.enabled, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? Colors.white.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: enabled ? onTap : null,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, color: enabled ? Colors.white : Colors.white24, size: size),
        ),
      ),
    );
  }
}
