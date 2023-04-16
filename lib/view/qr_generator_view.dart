import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_reader_and_generator/service/qr_code_database.dart';
import 'package:screenshot/screenshot.dart';
import '../service/qr_sharing.dart';
import '../model/qr_code.dart';

class QrGenerator extends StatefulWidget {
  QrGenerator({super.key});

  @override
  _QrGeneratorState createState() => _QrGeneratorState();
}

class _QrGeneratorState extends State<QrGenerator> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  MaterialColor mainColor = Colors.pink;
  TextEditingController qrCodeTextController = TextEditingController();
  ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor: Colors.black54,
          body: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 25.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: mainColor,
                              width: 10.0,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.black54),
                        child: Screenshot(
                          controller: screenshotController,
                          child: QrImage(
                            data: qrCodeTextController.text.trim(),
                            version: QrVersions.auto,
                            size: 230,
                            foregroundColor: mainColor,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 60),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: mainColor,
                                width: 2,
                              ),
                            ),
                            child: Ink(
                              decoration: const ShapeDecoration(
                                color: Colors.white,
                                shape: CircleBorder(),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.ios_share,
                                  color: Colors.pink,
                                ),
                                onPressed: () {
                                  shareQrCode(screenshotController);
                                },
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 16.0, bottom: 16.0, left: 70),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: mainColor,
                                width: 2,
                              ),
                            ),
                            child: Ink(
                              decoration: const ShapeDecoration(
                                color: Colors.white,
                                shape: CircleBorder(),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.save,
                                  color: Colors.pink,
                                ),
                                onPressed: () {
                                  QrCodeDatabase.instance.addQrCode(QRCode(
                                      id: null,
                                      prioritise: false,
                                      content: qrCodeTextController.text,
                                      createdTime: DateTime.now()));

                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Qr code is saved!')));
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Center(
                      child: QrCodeGeneratingInput(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Widget QrCodeGeneratingInput() {
    final ThemeData themeData = Theme.of(context);
    return Theme(
      data: themeData.copyWith(
          inputDecorationTheme: themeData.inputDecorationTheme.copyWith(
        suffixIconColor: MaterialStateColor.resolveWith(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.focused)) {
              return mainColor;
            }
            if (states.contains(MaterialState.error)) {
              return Colors.red;
            }
            return Colors.grey;
          },
        ),
        prefixIconColor: MaterialStateColor.resolveWith(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.focused)) {
              return mainColor;
            }
            if (states.contains(MaterialState.error)) {
              return Colors.red;
            }
            return Colors.grey;
          },
        ),
      )),
      child: Container(
        height: 150,
        width: 250,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          shape: BoxShape.rectangle,
          border: Border.all(
            color: mainColor,
            width: 2,
          ),
        ),
        child: SingleChildScrollView(
          child: TextField(
            maxLines: null,
            cursorColor: mainColor,
            controller: qrCodeTextController,
            onChanged: (value) {
              setState(() {
                qrCodeTextController.text == value;
              });
            },
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.clear,
                ),
                onPressed: () {
                  //#TODO change QR code image when the text is cleaned
                  setState(() {
                    qrCodeTextController.text = '';
                  });
                },
              ),
              prefixIcon: const Icon(
                Icons.qr_code_2,
              ),
              hintText: 'Write text here...',
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}
