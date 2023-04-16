// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:qr_reader_and_generator/view/scrollable_app_bar.dart';
import 'package:qr_reader_and_generator/view/web_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:regexed_validator/regexed_validator.dart';

import 'package:flutter/services.dart';

import '../model/qr_code.dart';
import '../service/qr_code_database.dart';

MaterialColor mainColor = Colors.pink;

ReadQrCodeDialog(context, result) {
  return AlertDialog(
    backgroundColor: Colors.white,
    title: Row(
      children: [
        const Text('Reading QR code'),
        Padding(
          padding: const EdgeInsets.only(left: 60.0),
          child: IconButton(
            icon: const Icon(
              Icons.close,
              color: Colors.pink,
              size: 20.0,
            ),
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ScrollableAppBar()),
              );
            },
          ),
        ),
      ],
    ),
    titleTextStyle: const TextStyle(
      color: Colors.pink,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
    content: Container(
      height: 80,
      width: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.symmetric(
          horizontal: BorderSide(
            color: mainColor,
            width: 2.0,
          ),
        ),
      ),
      child: SingleChildScrollView(
        child: Text(result),
      ),
    ),
    actions: <Widget>[
      QrCodeActions(context, true, result),
    ],
  );
}

QrCodeActions(context, needSave, result) {
  return Row(
    children: [
      Ink(
        decoration: const ShapeDecoration(
          color: Colors.white,
          shape: CircleBorder(),
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: mainColor,
              width: 2,
            ),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.copy,
              color: Colors.pink,
              size: 20.0,
            ),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: result)).then((_) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Copied to your clipboard!')));
              });
            },
          ),
        ),
      ),
      if (needSave)
        Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 16.0, left: 18),
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
                      content: result,
                      createdTime: DateTime.now()));

                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Qr code is saved!')));
                },
              ),
            ),
          ),
        ),
      if (validator.url(result))
        Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Ink(
            decoration: const ShapeDecoration(
              color: Colors.white,
              shape: CircleBorder(),
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: mainColor,
                  width: 2,
                ),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.open_in_full,
                  color: Colors.pink,
                  size: 20.0,
                ),
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => WebViewWidget(url: result)),
                  );
                },
              ),
            ),
          ),
        ),
      if (validator.url(result))
        Padding(
          padding: const EdgeInsets.only(left: 18.0),
          child: Ink(
            decoration: const ShapeDecoration(
              color: Colors.white,
              shape: CircleBorder(),
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: mainColor,
                  width: 2,
                ),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.open_in_browser,
                  color: Colors.pink,
                  size: 20.0,
                ),
                onPressed: () async {
                  if (await canLaunch(result)) {
                    await launch(result);
                  }
                },
              ),
            ),
          ),
        ),
    ],
  );
}
