import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mrz_scanner/flutter_mrz_scanner.dart';
import 'package:path_provider/path_provider.dart';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  bool isParsed = false;
  bool isScan = false;
  MRZController? controller;
  File? filePhoto;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MRZScanner(
        withOverlay: true,
        onControllerCreated: onControllerCreated,
        iconButton: iconButtonScan(isScan, onPressButton),
        closeButton: closeButon(),
      ),
    );
  }

  Future<File> convertUint8ListToFile(
      Uint8List uint8List, String filename) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$filename');

    await file.writeAsBytes(uint8List);

    return file;
  }

  Uint8List convertIntListToUint8List(List<int> intList) {
    final byteData = ByteData(intList.length);
    for (int i = 0; i < intList.length; i++) {
      byteData.setUint8(i, intList[i]);
    }

    final byteBuffer = byteData.buffer;

    return byteBuffer.asUint8List();
  }

  void onPressButton() {
    controller?.takePhoto(crop: false).then(
      (value) {
        final decodelList = convertIntListToUint8List(value ?? []);
        convertUint8ListToFile(
          decodelList,
          DateTime.now().microsecondsSinceEpoch.toString(),
        ).then((value) {
          filePhoto = value;
        });
      },
    );
    setState(() {
      isScan = true;
    });
  }

  Widget iconButtonScan(bool isScan, Function() onPress) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(left: 15, bottom: 40),
        child: SizedBox(
          height: 35,
          width: 35,
          child: isScan
              ? const CircularProgressIndicator(
                  color: Colors.blueAccent,
                )
              : FloatingActionButton(
                  heroTag: null,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  onPressed: onPress,
                  child: const Icon(Icons.camera, color: Colors.black),
                ),
        ),
      ),
    );
  }

  Widget closeButon() {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 15, top: 40),
        child: SizedBox(
          height: 35,
          width: 35,
          child: FloatingActionButton(
            heroTag: null,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            onPressed: () {},
            child: const Icon(Icons.close, color: Colors.black),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    isScan = true;
    controller?.stopPreview();
    super.dispose();
  }

  void onControllerCreated(MRZController controller) {
    this.controller = controller;
    controller.onParsed = (result) async {
      if (isParsed) {
        return;
      }
      isParsed = true;

      await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
                  content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('Document type: ${result.documentType}'),
                  Text('Country: ${result.countryCode}'),
                  Text('Surnames: ${result.surnames}'),
                  Text('Given names: ${result.givenNames}'),
                  Text('Document number: ${result.documentNumber}'),
                  Text('Nationality code: ${result.nationalityCountryCode}'),
                  Text('Birthdate: ${result.birthDate}'),
                  Text('Sex: ${result.sex}'),
                  Text('Expriy date: ${result.expiryDate}'),
                  Text('Personal number: ${result.personalNumber}'),
                  Text('Personal number 2: ${result.personalNumber2}'),
                  Text('File patch: ${filePhoto?.path}'),
                  ElevatedButton(
                    child: const Text('ok'),
                    onPressed: () {
                      isParsed = false;
                      return Navigator.pop(context, true);
                    },
                  ),
                ],
              )));
    };
    controller.onError = (error) => print(error);

    controller.startPreview();
  }
}
