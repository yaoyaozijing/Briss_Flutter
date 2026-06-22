import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import 'l10n/app_localizations.dart';
import 'models/crop_rect.dart';
import 'models/page_cluster.dart';
import 'models/pdf_project.dart';
import 'widgets/windows_window_controls.dart';

class PdfCropPreviewPage extends StatefulWidget {
  const PdfCropPreviewPage({
    required this.project,
    required this.clusters,
    super.key,
  });

  final PdfProject project;
  final List<PageCluster> clusters;

  @override
  State<PdfCropPreviewPage> createState() => _PdfCropPreviewPageState();
}

class _PdfCropPreviewPageState extends State<PdfCropPreviewPage> {
  final TextEditingController _pageController = TextEditingController();
  int _currentPage = 1;
  _RenderedPreviewData? _previewData;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _pageController.text = '1';
    _loadPreviewForPage(1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PdfCropPreviewPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.project != widget.project || oldWidget.clusters != widget.clusters) {
      _currentPage = _currentPage.clamp(1, widget.project.pageCount);
      _pageController.text = '$_currentPage';
      _loadPreviewForPage(_currentPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.cropPreview),
        actions: const [
          WindowsWindowControls(),
          SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _currentPage > 1 ? () => _goToPage(_currentPage - 1) : null,
                  icon: const Icon(Icons.chevron_left_rounded),
                  label: Text(context.l10n.previousPage),
                ),
                const Spacer(),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _currentPage < widget.project.pageCount
                      ? () => _goToPage(_currentPage + 1)
                      : null,
                  icon: const Icon(Icons.chevron_right_rounded),
                  label: Text(context.l10n.nextPage),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 88),
                            child: TextField(
                              controller: _pageController,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.go,
                              onSubmitted: (_) => _submitPageJump(),
                              decoration: InputDecoration(
                                isDense: true,
                                border: const OutlineInputBorder(),
                                labelText: context.l10n.pageNumber,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            context.l10n.totalPageCount(widget.project.pageCount),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Center(
                          child: _buildPreviewBody(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewBody(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (_error != null) {
      return Text(
        _error.toString(),
        style: TextStyle(color: colorScheme.error),
      );
    }
    if (_previewData == null) {
      return const CircularProgressIndicator();
    }
    return _PreviewCanvas(
      preview: _previewData!,
      cropRects: _cropRectsForPage(_currentPage),
    );
  }

  Future<void> _loadPreviewForPage(int pageNumber) async {
    setState(() {
      _previewData = null;
      _error = null;
    });
    try {
      final page = widget.project.document.pages[pageNumber - 1];
      final longestSide = page.width > page.height ? page.width : page.height;
      final scale = 1400 / longestSide;
      final image = await page.render(
        fullWidth: (page.width * scale).clamp(1, 2200).toDouble(),
        fullHeight: (page.height * scale).clamp(1, 2200).toDouble(),
      );
      if (image == null) {
        throw StateError('Preview render returned null.');
      }
      final rawPixels = Uint8List.fromList(image.pixels);
      final previewImage = img.Image.fromBytes(
        width: image.width,
        height: image.height,
        bytes: rawPixels.buffer,
        numChannels: 4,
        order: img.ChannelOrder.bgra,
      );
      final pngBytes = Uint8List.fromList(img.encodePng(previewImage));
      final size = Size(image.width.toDouble(), image.height.toDouble());
      image.dispose();
      if (!mounted || pageNumber != _currentPage) {
        return;
      }
      setState(() {
        _previewData = _RenderedPreviewData(
          pngBytes: pngBytes,
          size: size,
        );
      });
    } catch (error) {
      if (!mounted || pageNumber != _currentPage) {
        return;
      }
      setState(() {
        _error = error;
      });
    }
  }

  void _goToPage(int pageNumber) {
    final nextPage = pageNumber.clamp(1, widget.project.pageCount);
    if (nextPage == _currentPage) {
      return;
    }
    setState(() {
      _currentPage = nextPage;
      _pageController.text = '$nextPage';
    });
    _loadPreviewForPage(nextPage);
  }

  void _submitPageJump() {
    final parsed = int.tryParse(_pageController.text.trim());
    if (parsed == null) {
      _pageController.text = '$_currentPage';
      return;
    }
    _goToPage(parsed);
  }

  List<CropRect> _cropRectsForPage(int pageNumber) {
    for (final cluster in widget.clusters) {
      if (cluster.pages.contains(pageNumber)) {
        return cluster.cropRects.where((rect) => rect.isValid).toList();
      }
    }
    return const [CropRect.full];
  }
}

class _RenderedPreviewData {
  const _RenderedPreviewData({
    required this.pngBytes,
    required this.size,
  });

  final Uint8List pngBytes;
  final Size size;
}

class _PreviewCanvas extends StatelessWidget {
  const _PreviewCanvas({
    required this.preview,
    required this.cropRects,
  });

  final _RenderedPreviewData preview;
  final List<CropRect> cropRects;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final maxHeight = constraints.maxHeight;
        final fittedSize = applyBoxFit(
          BoxFit.contain,
          preview.size,
          Size(maxWidth, maxHeight),
        ).destination;
        return SizedBox(
          width: fittedSize.width,
          height: fittedSize.height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.memory(
                preview.pngBytes,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
              CustomPaint(
                painter: _OutsideDimPainter(
                  cropRects: cropRects,
                  imageSize: preview.size,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OutsideDimPainter extends CustomPainter {
  const _OutsideDimPainter({
    required this.cropRects,
    required this.imageSize,
  });

  final List<CropRect> cropRects;
  final Size imageSize;

  @override
  void paint(Canvas canvas, Size size) {
    final fittedRect = Alignment.center.inscribe(
      applyBoxFit(BoxFit.contain, imageSize, size).destination,
      Offset.zero & size,
    );

    final overlayPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.18);

    final fullPath = Path()..addRect(fittedRect);
    final cropPath = Path();

    if (cropRects.isEmpty) {
      canvas.drawPath(fullPath, overlayPaint);
      return;
    }

    for (final cropRect in cropRects) {
      final previewRect = cropRect.toPreviewRect(imageSize);
      final scaledRect = Rect.fromLTWH(
        fittedRect.left + (previewRect.left / imageSize.width) * fittedRect.width,
        fittedRect.top + (previewRect.top / imageSize.height) * fittedRect.height,
        (previewRect.width / imageSize.width) * fittedRect.width,
        (previewRect.height / imageSize.height) * fittedRect.height,
      );
      cropPath.addRect(scaledRect);
    }

    final outsidePath = Path.combine(
      ui.PathOperation.difference,
      fullPath,
      cropPath,
    );
    canvas.drawPath(outsidePath, overlayPaint);

    final borderPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(cropPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _OutsideDimPainter oldDelegate) {
    return oldDelegate.cropRects != cropRects ||
        oldDelegate.imageSize != imageSize;
  }
}
