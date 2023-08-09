import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_tflite/flutter_tflite.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String title = '';
  ImagePicker? imagePicker;
  File? image;
  Future<File>? imageFile;

  Future<void> getImage({ImageSource imageSource = ImageSource.gallery}) async {
    XFile? pickedImage;
    switch (imageSource) {
      case ImageSource.gallery:
        pickedImage = await imagePicker?.pickImage(source: ImageSource.gallery);
        break;
      case ImageSource.camera:
        pickedImage = await imagePicker?.pickImage(source: ImageSource.camera);
        break;
      default:
        if (kDebugMode) {
          print("Invalid Image Source");
        }
    }
    image = File(pickedImage!.path);
    setState(() {
      image;
      imageClassification();
    });
  }

  Future<void> loadDataModel() async {
    String? output = await Tflite.loadModel(
      model: 'assets/model_unquant.tflite',
      labels: 'assets/labels.txt',
      numThreads: 2,
      isAsset: true,
      useGpuDelegate: false,
    );
    printStatement(output);
  }

  void imageClassification() async {
    List<dynamic>? recognitions = await Tflite.runModelOnImage(
        path: image!.path,
        imageMean: 0.0,
        imageStd: 255.0,
        numResults: 1,
        threshold: 0.1,
        asynch: true);

    printStatement(recognitions!.length.toString());

    setState(() {
      title = '';
    });
    for (var value in recognitions) {
      printStatement(value.toString());
      if (value['confidence'] > 0.90) {
        title += value['label'] + '\n\n';
      } else {
        title = 'Not a marrvel charracter';
      }
    }
  }

  @override
  void initState() {
    imagePicker = ImagePicker();
    loadDataModel();
    super.initState();
  }

  void printStatement(var string) {
    if (kDebugMode) {
      print(string);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          image != null
              ? Image.file(
                  image!,
                  height: 200,
                  width: 200,
                )
              : const SizedBox(
                  height: 200,
                  width: 200,
                ),
          const SizedBox(height: 40),
          TextButton(
              onPressed: () {
                getImage(imageSource: ImageSource.gallery);
              },
              child: const Text("Select Image from Gallery")),
          const SizedBox(height: 10),
          TextButton(
              onPressed: () {
                getImage(imageSource: ImageSource.camera);
              },
              child: const Text("Select Image from Camera")),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
                fontSize: 32, color: Colors.black, fontWeight: FontWeight.bold),
          )
        ],
      ),
    ));
  }
}
