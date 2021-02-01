import 'dart:io';
import 'package:image/image.dart' as imglib;
import 'package:af/application/image_utils.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

class ImageRecorderSingleton {
  // ##### Aparently this makes this class a singleton ########
  static final ImageRecorderSingleton _imageRecorderSingleton =
      ImageRecorderSingleton._internal();
  factory ImageRecorderSingleton() {
    return _imageRecorderSingleton;
  }
  ImageRecorderSingleton._internal() {
    pngEncoder = imglib.PngEncoder(level: 0, filter: 0);
    lastImageEntry = DateTime.now();
  }
  // ################  End of singleton logic ##################

  Directory imageDirectory;
  String imagePath;
  imglib.PngEncoder pngEncoder;
  DateTime lastImageEntry;

  Future<void> ensureImagePath() async {
    if (imageDirectory == null) {
      imageDirectory = await getExternalStorageDirectory();
    }
    if (imagePath == null) {
      imagePath = imageDirectory.path; // + '/images';
      // Directory.fromUri().create();
    }
  }

  String getImagePath() {
    String timeStr = '${DateTime.now()}'.substring(0, 19);
    return '$imagePath/$timeStr.png';
  }

  bool isTimeForNewImage() {
    return (DateTime.now().difference(lastImageEntry)) > Duration(seconds: 2);
  }

  Future<void> saveSnapshot(CameraImage image) async {
    print('saving snapshot I hope');
    await ensureImagePath();
    String filePath = getImagePath();
    imglib.Image convertedImage = aVeryGoodCameraImageConverter(image);
    convertedImage = imglib.copyRotate(convertedImage, 90);
    convertedImage = imglib.copyResize(convertedImage, width: 500);
    List<int> imageBytes = pngEncoder.encodeImage(convertedImage);
    print('saving image to $filePath');

    File imageFile = File(filePath);
    imageFile.create();
    imageFile.writeAsBytesSync(imageBytes);
    print('saved image');
  }
}
