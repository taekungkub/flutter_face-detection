import 'dart:io';

import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as DartImage;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

Future<String> getAssetPath(String asset) async {
  final path = await getLocalPath(asset);
  await Directory(dirname(path)).create(recursive: true);
  final file = File(path);
  if (!await file.exists()) {
    final byteData = await rootBundle.load(asset);
    await file.writeAsBytes(
      byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
    );
  }
  return file.path;
}

Future<String> getLocalPath(String path) async {
  return '${(await getApplicationSupportDirectory()).path}/$path';
}

DartImage.Image decodeYUV420SP(InputImage image) {
  final width = image.metadata!.size.width.toInt();
  final height = image.metadata!.size.height.toInt();

  Uint8List yuv420sp = image.bytes!;
  var rotationOfCamera = 0;
  if (image.metadata != null && image.metadata!.rotation.rawValue != 0) {
    rotationOfCamera = image.metadata!.rotation.rawValue;
  }
  return decodeYUV420SP_from_camera(width, height, yuv420sp, rotationOfCamera);
}

DartImage.Image decodeYUV420SP_from_camera(
  int width,
  int height,
  Uint8List yuv420sp,
  int rotationOfCamera,
) {
  var outImg = DartImage.Image(width: width, height: height);

  final int frameSize = width * height;

  for (int j = 0, yp = 0; j < height; j++) {
    int uvp = frameSize + (j >> 1) * width;
    int u = 0, v = 0;

    for (int i = 0; i < width; i++, yp++) {
      int y = (0xff & yuv420sp[yp]) - 16;
      if (y < 0) y = 0;
      if ((i & 1) == 0) {
        u = (0xff & yuv420sp[uvp++]) - 128; // U component
        v = (0xff & yuv420sp[uvp++]) - 128; // V component
      }

      // Corrected conversion formula (handling U and V correctly)
      int r = (1192 * y + 1634 * v);
      int g = (1192 * y - 833 * v - 400 * u);
      int b = (1192 * y + 2066 * u);

      // Clamping to valid color range [0, 255]
      r = (r >> 10).clamp(0, 255);
      g = (g >> 10).clamp(0, 255);
      b = (b >> 10).clamp(0, 255);

      outImg.setPixelRgb(i, j, r, g, b);
    }
  }

  if (rotationOfCamera != 0) {
    outImg = DartImage.copyRotate(outImg, angle: rotationOfCamera);
  }
  return outImg;
}
