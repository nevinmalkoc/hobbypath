import 'package:flutter/material.dart';
import '../models/models.dart';

class InteractiveEventMap extends StatefulWidget {
  final List<EventModel> events;
  final EventModel? selectedEvent;
  final ValueChanged<EventModel> onSelectEvent;

  const InteractiveEventMap({
    super.key,
    required this.events,
    required this.selectedEvent,
    required this.onSelectEvent,
  });

  @override
  State<InteractiveEventMap> createState() => _InteractiveEventMapState();
}

class _InteractiveEventMapState extends State<InteractiveEventMap> {
  // Approximate bounding box for Greater Istanbul / Marmara events
  static const double minLat = 40.75;
  static const double maxLat = 41.25;
  static const double minLng = 28.85;
  static const double maxLng = 29.55;

  static const double mapCanvasWidth = 800.0;
  static const double mapCanvasHeight = 600.0;

  final TransformationController _transformController = TransformationController();

  Offset _projectCoordinates(double lat, double lng) {
    final clampedLat = lat.clamp(minLat, maxLat);
    final clampedLng = lng.clamp(minLng, maxLng);

    final x = (clampedLng - minLng) / (maxLng - minLng) * mapCanvasWidth;
    final y = (maxLat - clampedLat) / (maxLat - minLat) * mapCanvasHeight;

    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRect(
          child: InteractiveViewer(
            transformationController: _transformController,
            boundaryMargin: const EdgeInsets.all(100),
            minScale: 0.6,
            maxScale: 2.5,
            child: SizedBox(
              width: mapCanvasWidth,
              height: mapCanvasHeight,
              child: Stack(
                children: [
                  // Stylized Map Canvas (Istanbul Sea & Land Cartography)
                  CustomPaint(
                    size: const Size(mapCanvasWidth, mapCanvasHeight),
                    painter: _IstanbulCartographyPainter(),
                  ),

                  // Event Pins
                  ...widget.events.map((event) {
                    final lat = event.latitude ?? 41.0082;
                    final lng = event.longitude ?? 28.9784;
                    final pos = _projectCoordinates(lat, lng);
                    final isSelected = widget.selectedEvent?.id == event.id;

                    return Positioned(
                      left: pos.dx - 28,
                      top: pos.dy - 44,
                      child: GestureDetector(
                        onTap: () => widget.onSelectEvent(event),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Pin Badge
                              Container(
                                padding: EdgeInsets.all(isSelected ? 8 : 6),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.deepOrange : Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? Colors.white : Colors.blue.shade700,
                                    width: isSelected ? 3 : 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isSelected
                                          ? Colors.deepOrange.withValues(alpha: 0.5)
                                          : Colors.black26,
                                      blurRadius: isSelected ? 12 : 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  event.hobbyIcon,
                                  style: TextStyle(fontSize: isSelected ? 22 : 18),
                                ),
                              ),
                              // Pin Pointer Triangle
                              CustomPaint(
                                size: const Size(12, 6),
                                painter: _TrianglePainter(
                                  color: isSelected ? Colors.deepOrange : Colors.blue.shade700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              // Location Tag
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.deepOrange.shade900 : Colors.black87,
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: const [
                                    BoxShadow(color: Colors.black12, blurRadius: 4),
                                  ],
                                ),
                                child: Text(
                                  event.district ?? event.communityName,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) => oldDelegate.color != color;
}

class _IstanbulCartographyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Background (Land - modern soft map tone)
    final landPaint = Paint()..color = const Color(0xFFF3F4F6);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), landPaint);

    // Grid lines for modern radar/map feel
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.15)
      ..strokeWidth = 1.0;

    for (double x = 0; x < size.width; x += 80) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 80) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Water Paint (Sea of Marmara & Bosphorus & Black Sea)
    final waterPaint = Paint()
      ..color = const Color(0xFFBAE6FD) // Soft blue water
      ..style = PaintingStyle.fill;

    // Sea of Marmara (South)
    final marmaraPath = Path()
      ..moveTo(0, size.height * 0.72)
      ..cubicTo(size.width * 0.25, size.height * 0.68, size.width * 0.5, size.height * 0.75, size.width, size.height * 0.85)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(marmaraPath, waterPaint);

    // Black Sea (North)
    final blackSeaPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.12)
      ..cubicTo(size.width * 0.7, size.height * 0.18, size.width * 0.3, size.height * 0.10, 0, size.height * 0.16)
      ..close();
    canvas.drawPath(blackSeaPath, waterPaint);

    // Bosphorus Strait (Boğaz - connects Black Sea to Marmara)
    final bosphorusPaint = Paint()
      ..color = const Color(0xFF93C5FD)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 26.0;

    final bosphorusPath = Path()
      ..moveTo(size.width * 0.44, size.height * 0.12)
      ..cubicTo(size.width * 0.43, size.height * 0.32, size.width * 0.38, size.height * 0.45, size.width * 0.39, size.height * 0.72);
    canvas.drawPath(bosphorusPath, bosphorusPaint);

    // Golden Horn (Haliç)
    final halicPaint = Paint()
      ..color = const Color(0xFF93C5FD)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 14.0;

    final halicPath = Path()
      ..moveTo(size.width * 0.39, size.height * 0.56)
      ..lineTo(size.width * 0.32, size.height * 0.52);
    canvas.drawPath(halicPath, halicPaint);

    // Region Labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    void drawLabel(String text, Offset pos, {double fontSize = 11, Color color = Colors.black45, bool isBold = false}) {
      textPainter.text = TextSpan(
        text: text,
        style: TextStyle(fontSize: fontSize, color: color, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, letterSpacing: 1.2),
      );
      textPainter.layout();
      textPainter.paint(canvas, pos);
    }

    drawLabel('MARMARA DENİZİ 🌊', Offset(size.width * 0.28, size.height * 0.88), color: const Color(0xFF0369A1));
    drawLabel('KARADENİZ 🌊', Offset(size.width * 0.45, size.height * 0.05), color: const Color(0xFF0369A1));
    drawLabel('İSTANBUL BOĞAZI', Offset(size.width * 0.42, size.height * 0.38), fontSize: 9, color: Colors.blue.shade800);
    drawLabel('AVRUPA YAKASI', Offset(size.width * 0.18, size.height * 0.38), isBold: true);
    drawLabel('ANADOLU YAKASI', Offset(size.width * 0.60, size.height * 0.48), isBold: true);
    drawLabel('Belgrad Ormanı 🌲', Offset(size.width * 0.25, size.height * 0.22), fontSize: 10, color: Colors.green.shade800);
    drawLabel('Polonezköy 🐎', Offset(size.width * 0.65, size.height * 0.28), fontSize: 10, color: Colors.amber.shade900);
    drawLabel('Kadıköy & Moda 🏺', Offset(size.width * 0.45, size.height * 0.65), fontSize: 10, color: Colors.indigo.shade800);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
