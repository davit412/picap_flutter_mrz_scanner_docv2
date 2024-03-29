import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mrz_scanner/flutter_mrz_scanner.dart';
import 'package:path_provider/path_provider.dart';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  bool isParsed = false;
  bool isScaning = false;
  MRZController? controller;
  File? filePhoto;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MRZScanner(
        withOverlay: true,
        onControllerCreated: onControllerCreated,
        iconButton: iconButtonScan(isScaning, onPressButton),
        guideDocument: guideDocument(),
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
      isScaning = true;
    });
  }

  Widget iconButtonScan(bool isScan, Function() onPress) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.only(top: 10, bottom: 60),
        padding: const EdgeInsets.only(left: 10, bottom: 30),
        child: SizedBox(
          height: 50,
          width: 50,
          child: isScan
              ? const CircularProgressIndicator(
                  color: Colors.blueAccent,
                )
              : FloatingActionButton(
                  heroTag: null,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                  onPressed: onPress,
                  child: const Icon(Icons.camera, color: Colors.black),
                ),
        ),
      ),
    );
  }

  Widget guideDocument() => Container(
        decoration: const BoxDecoration(
            color: Color.fromARGB(113, 67, 195, 21),
            borderRadius: BorderRadius.all(Radius.circular(8))),
      );

  @override
  void dispose() {
    isScaning = true;
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
