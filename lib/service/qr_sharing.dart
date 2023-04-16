import 'dart:io';

import 'package:share/share.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

void shareQrCode(ScreenshotController screenshotController) async {
  final directory = (await getApplicationDocumentsDirectory()).path;
  try {
    final image = await screenshotController.capture();

    if (image != null) {
      final fileName = DateTime.now().microsecondsSinceEpoch.toString();
      final imagePath = await File('$directory/$fileName.png').create();
      if (imagePath != null) {
        await imagePath.writeAsBytes(image);
        Share.shareFiles([imagePath.path]);
      }
    }
  } catch (error) {
    print('Error --->> $error');
  }
}