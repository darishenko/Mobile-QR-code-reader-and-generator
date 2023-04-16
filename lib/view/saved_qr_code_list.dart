// ignore_for_file: use_build_context_synchronously

import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_reader_and_generator/service/qr_code_database.dart';
import 'package:qr_reader_and_generator/view/qr_sanner_result_view.dart';
import '../model/slidable_action.dart';
import '../model/qr_code.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SavedQrCodeList extends StatefulWidget {
  SavedQrCodeList({super.key});

  @override
  _SavedQrCodeListState createState() => _SavedQrCodeListState();
}

class _SavedQrCodeListState extends State<SavedQrCodeList> {
  late List<QRCode> savedQrCodes;
  bool isLoading = false;

  MaterialColor mainColor = Colors.pink;

  @override
  void initState() {
    super.initState();
    refreshSavedQrCodeList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black54,
        body: Center(
          child: checkQrCodeState()
              ? qrCodeStateWidget()
              : ListView.builder(
                  itemCount: savedQrCodes.length,
                  itemBuilder: (context, index) {
                    final qrCode = savedQrCodes[index];
                    return Slidable(
                      key: Key(qrCode.content),
                      dismissal: SlidableDismissal(
                        child: const SlidableDrawerDismissal(),
                        onDismissed: (type) {
                          final action = type == SlideActionType.primary
                              ? SlidableAction.favorite
                              : SlidableAction.delete;
                          onDismissed(qrCode, action);
                        },
                      ),
                      actionExtentRatio: 0.45,
                      actionPane: const SlidableDrawerActionPane(),
                      actions: <Widget>[
                        IconSlideAction(
                          color: mainColor,
                          icon: Icons.favorite,
                          onTap: () {
                            onDismissed(qrCode, SlidableAction.favorite);
                          },
                        ),
                      ],
                      secondaryActions: <Widget>[
                        IconSlideAction(
                          color: Colors.amberAccent,
                          icon: Icons.delete,
                          foregroundColor: Colors.white,
                          onTap: () {
                            onDismissed(qrCode, SlidableAction.delete);
                          },
                        ),
                      ],
                      child: buildQrCode(qrCode),
                    );
                  },
                ),
        ),
      );

  Widget buildQrCode(QRCode qrCode) => Builder(
        builder: (context) => Card(
          color: Colors.white30,
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(7.0),
                child: Icon(
                  qrCode.prioritise ? Icons.favorite : null,
                  color: mainColor,
                ),
              ),
              Expanded(
                child: ListTile(
                  textColor: Colors.white,
                  titleTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  onTap: () async {
                    SavedQrCodeDialog(context, qrCode);
                    refreshSavedQrCodeList();
                  },
                  subtitle: Column(children: <Widget>[
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        qrCode.content,
                        maxLines: 2,
                        style: const TextStyle(
                            fontSize: 14, color: Colors.white70),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        '\n${DateFormat('yyyy-MM-dd – kk:mm').format(qrCode.createdTime)}',
                        maxLines: 4,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.pink,
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      );

  void onDismissed(QRCode qrCode, SlidableAction action) async {
    setState(() => savedQrCodes.remove(qrCode));

    switch (action) {
      case SlidableAction.delete:
        {
          deleteQrCodeDialog(qrCode);
          break;
        }
      case SlidableAction.favorite:
        {
          qrCode.changePrioritise();
          await QrCodeDatabase.instance.updateQrCode(qrCode);
          qrCode.prioritise
              ? showSnackBar(context, "QR code has been added to favorites.")
              : showSnackBar(
                  context, "QR code has been deleted from favorites.");
          break;
        }
    }
    refreshSavedQrCodeList();
  }

  void showSnackBar(BuildContext context, text) {
    if (text is String) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(text),
      ));
    } else if (text is Widget) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: text));
    }
  }

  Widget? qrCodeStateWidget() {
    if (isLoading) {
      return const CircularProgressIndicator(
        color: Colors.amberAccent,
      );
    }

    if (savedQrCodes.isEmpty) {
      return const Text(
        'No saved QR codes',
        style: TextStyle(
          color: Colors.pink,
        ),
      );
    }

    return null;
  }

  bool checkQrCodeState() {
    if (isLoading || savedQrCodes.isEmpty) return true;
    return false;
  }

  Future<void> deleteQrCodeDialog(QRCode qrCode) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white30,
          title: const Text('Delete QR code'),
          titleTextStyle: const TextStyle(
            color: Colors.amberAccent,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Would you like to delete this?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.pink,
                ),
              ),
              onPressed: () async {
                await deleteQrCode(qrCode);
                showSnackBar(context, "QR code has been deleted.");
                Navigator.of(context).pop();
                refreshSavedQrCodeList();
              },
            ),
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.pink,
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  deleteQrCode(QRCode qrCode) async {
    await QrCodeDatabase.instance.deleteQrCode(qrCode.id!);
  }

  Future refreshSavedQrCodeList() async {
    setState(() => isLoading = true);
    savedQrCodes = [];
    savedQrCodes = await QrCodeDatabase.instance.readAllQrCodes();
    setState(() => isLoading = false);
  }

  Future<void> SavedQrCodeDialog(context, QRCode qrCode) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
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
                      Navigator.of(context).pop();
                      refreshSavedQrCodeList();
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
            content: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: QrImage(
                data: qrCode.content,
                version: QrVersions.auto,
                size: 150,
                foregroundColor: mainColor,
                backgroundColor: Colors.white,
              ),
            ),
            actions: <Widget>[
              QrCodeActions(context, false, qrCode.content),
            ],
          );
        });
  }
}
