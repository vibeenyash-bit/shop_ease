// Draws the ShopEase logo and saves it as PNG files in assets/icon/.
//
// Run:  flutter test tool/generate_icon.dart
// Then: dart run flutter_launcher_icons
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _size = 1024.0;
const _indigo = Color(0xFF3949AB);

void main() {
  testWidgets('generate app icon', (tester) async {
    await tester.runAsync(() async {
      Directory('assets/icon').createSync(recursive: true);
      // Full icon (iOS + older Android): indigo square with a white bag.
      await _save('assets/icon/icon.png', background: true, scale: 1);
      // Android adaptive icon: bag only, smaller so it fits any icon shape.
      await _save('assets/icon/icon_foreground.png', background: false, scale: 0.72);
    });
  });
}

Future<void> _save(String path, {required bool background, required double scale}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  if (background) {
    canvas.drawRect(const Rect.fromLTWH(0, 0, _size, _size), Paint()..color = _indigo);
  }
  canvas
    ..translate(_size / 2, _size / 2)
    ..scale(scale)
    ..translate(-_size / 2, -_size / 2 - 32); // -32 centers the bag vertically.
  _drawBag(canvas);

  final image = await recorder.endRecording().toImage(_size.toInt(), _size.toInt());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path).writeAsBytesSync(bytes!.buffer.asUint8List());
}

/// A white shopping bag with a handle and a smile.
void _drawBag(Canvas canvas) {
  final white = Paint()..color = Colors.white;

  // Handle.
  canvas.drawArc(
    Rect.fromCircle(center: const Offset(512, 420), radius: 120),
    math.pi,
    math.pi,
    false,
    Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 48
      ..strokeCap = StrokeCap.round,
  );

  // Bag body.
  canvas.drawRRect(
    RRect.fromLTRBR(290, 400, 734, 810, const Radius.circular(64)),
    white,
  );

  // Smile.
  canvas.drawArc(
    Rect.fromCircle(center: const Offset(512, 560), radius: 110),
    math.pi * 0.15,
    math.pi * 0.7,
    false,
    Paint()
      ..color = _indigo
      ..style = PaintingStyle.stroke
      ..strokeWidth = 40
      ..strokeCap = StrokeCap.round,
  );
}
