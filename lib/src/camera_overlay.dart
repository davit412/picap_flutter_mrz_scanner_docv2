import 'package:flutter/material.dart';

class CameraOverlay extends StatelessWidget {
  const CameraOverlay({
    required this.child,
    required this.iconButton,
    required this.guideDocument,
    Key? key,
  }) : super(key: key);

  static const _documentFrameRatio =
      1.42; // Passport's size (ISO/IEC 7810 ID-3) is 125mm × 88mm //0xFF842AD2
  final Widget child;
  final Widget iconButton;
  final Widget guideDocument;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final overlayRect =
            _calculateOverlaySize(Size(c.maxWidth, c.maxHeight));
        return Stack(
          children: [
            child,
            ClipPath(
              clipper: _DocumentClipper(rect: overlayRect),
              child: Container(
                foregroundDecoration: const BoxDecoration(
                  color: Color.fromRGBO(13, 12, 10, 0.56),
                ),
              ),
            ),
            _WhiteOverlay(
              rect: overlayRect,
              guideDocument: guideDocument,
            ),
            iconButton,
          ],
        );
      },
    );
  }

  RRect _calculateOverlaySize(Size size) {
    double width, height;
    if (size.height > size.width) {
      width = size.width * 0.9;
      height = width / _documentFrameRatio;
    } else {
      height = size.height * 0.75;
      width = height * _documentFrameRatio;
    }
    final topOffset = (size.height - height) / 2;
    final leftOffset = (size.width - width) / 2;

    final rect = RRect.fromLTRBR(leftOffset, topOffset, leftOffset + width,
        topOffset + height, const Radius.circular(8));
    return rect;
  }
}

class _DocumentClipper extends CustomClipper<Path> {
  _DocumentClipper({
    required this.rect,
  });

  final RRect rect;

  @override
  Path getClip(Size size) => Path()
    ..addRRect(rect)
    ..addRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height))
    ..fillType = PathFillType.evenOdd;

  @override
  bool shouldReclip(_DocumentClipper oldClipper) => false;
}

class _WhiteOverlay extends StatelessWidget {
  const _WhiteOverlay({
    required this.rect,
    required this.guideDocument,
    Key? key,
  }) : super(key: key);
  final RRect rect;
  final Widget guideDocument;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: rect.left,
      top: rect.top,
      child: Container(
        width: rect.width,
        height: rect.height,
        decoration: BoxDecoration(
          border: Border.all(width: 2.0, color: const Color(0xFF842AD2)),
          borderRadius: BorderRadius.all(rect.tlRadius),
        ),
        child: FutureBuilder<bool>(
          future: Future.delayed(const Duration(seconds: 5), () => true),
          initialData: false,
          builder: (context, snapshot) => AnimatedOpacity(
            opacity: (snapshot.data ?? false) ? 0 : 1,
            duration: const Duration(milliseconds: 500),
            curve: Curves.decelerate,
            child: IgnorePointer(child: guideDocument),
          ),
        ),
      ),
    );
  }
}
