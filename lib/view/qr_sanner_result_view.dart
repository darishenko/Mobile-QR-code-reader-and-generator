import 'package:flutter/material.dart';
import 'package:qr_reader_and_generator/view/scrollable_app_bar.dart';
import 'package:qr_reader_and_generator/view/web_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:regexed_validator/regexed_validator.dart';

import 'package:flutter/services.dart';

MaterialColor mainColor = Colors.pink;

changeRssDialog(context, result) {
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
      Row(
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
                        content: Text('Copied to your clipboard !')));
                  });
                },
              ),
            ),
          ),
          if (validator.url(result))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                    if(await canLaunch(result)){
                      await launch(result);
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}
