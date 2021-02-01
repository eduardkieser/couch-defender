import 'package:image/image.dart' as imglib;
import 'package:camera/camera.dart';

imglib.Image convertCameraImageToWidgetImage(CameraImage cameraImage) {
  final int width = cameraImage.width;
  final int height = cameraImage.height;
  var img = imglib.Image(width, height);
  try {
    Plane plane = cameraImage.planes[0];
    const int shift = (0xFF << 24);
    for (int x = 0; x < width; x++) {
      for (int planeOffset = 0;
          planeOffset < height * width;
          planeOffset += width) {
        final pixelColor = plane.bytes[planeOffset + x];
        var newVal =
            shift | (pixelColor << 16) | (pixelColor << 8) | pixelColor;
        img.data[planeOffset + x] = newVal;
      }
    }
    // good so far
  } catch (e) {
    print(">>>>>>>>>>>> ERROR:" + e.toString());
    return null;
  }
  return img;
}

imglib.Image convertYUV420toImageColor(CameraImage image) {
  try {
    final int width = image.width;
    final int height = image.height;
    final int uvRowStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel;

    print("uvRowStride: " + uvRowStride.toString());
    print("uvPixelStride: " + uvPixelStride.toString());

    // imgLib -> Image package from https://pub.dartlang.org/packages/image
    var img = imglib.Image(width, height); // Create Image buffer

    // Fill image buffer with plane[0] from YUV420_888
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        final int uvIndex =
            uvPixelStride * (x / 2).floor() + uvRowStride * (y / 2).floor();
        final int index = y * width + x;

        final yp = image.planes[0].bytes[index];
        final up = image.planes[1].bytes[uvIndex];
        final vp = image.planes[2].bytes[uvIndex];
        // Calculate pixel color
        int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
            .round()
            .clamp(0, 255);
        int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
        // color: 0x FF  FF  FF  FF
        //           A   B   G   R
        img.data[index] = (0xFF << 24) | (b << 16) | (g << 8) | r;
      }
    }
    // muteYUVProcessing = false;
    // return Image.memory(png);
    return img;
  } catch (e) {
    print(">>>>>>>>>>>> ERROR:" + e.toString());
  }
  return null;
}

imglib.Image aVeryGoodCameraImageConverter(CameraImage image) {
  final int width = image.width;
  final int height = image.height;
  final int uvRowStride = image.planes[1].bytesPerRow;
  final int uvPixelStride = image.planes[1].bytesPerPixel;
  var img = imglib.Image(width, height);
  for (int x = 0; x < width; x++) {
    // Fill image buffer with plane[0] from YUV420_888
    for (int y = 0; y < height; y++) {
      final int uvIndex =
          uvPixelStride * (x / 2).floor() + uvRowStride * (y / 2).floor();
      final int index = y * uvRowStride +
          x; // Use the row stride instead of the image width as some devices pad the image data, and in those cases the image width != bytesPerRow. Using width will give you a distored image.
      final yp = image.planes[0].bytes[index];
      final up = image.planes[1].bytes[uvIndex];
      final vp = image.planes[2].bytes[uvIndex];
      int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255).toInt();
      int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
          .round()
          .clamp(0, 255)
          .toInt();
      int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255).toInt();
      img.setPixelRgba(x, y, r, g, b);
    }
  }
  return img;
}
