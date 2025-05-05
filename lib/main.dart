import 'package:flutter/material.dart';
//AR Flutter Plugin
import 'package:ar_flutter_plugin_2/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_2/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_2/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_2/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_2/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin_2/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin_2/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_2/models/ar_node.dart';
//Other custom imports
import 'dart:io';
import 'dart:math';
import 'package:vector_math/vector_math_64.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:flutter_archive/flutter_archive.dart';
// import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: LocalAndWebObjects());
  }
}

class LocalAndWebObjects extends StatefulWidget {
  const LocalAndWebObjects({super.key});

  @override
  State<LocalAndWebObjects> createState() => _LocalAndWebObjectsState();
}

class _LocalAndWebObjectsState extends State<LocalAndWebObjects> {
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  //String localObjectReference;
  ARNode? localObjectNode;
  //String webObjectReference;
  ARNode? webObjectNode;
  ARNode? fileSystemNode;
  HttpClient? httpClient;

  @override
  void dispose() {
    arSessionManager?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Local & Web Objects')),
      body: Stack(
        children: [
          ARView(
            onARViewCreated: onARViewCreated,
            planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
          ),
          buildControls(),
        ],
      ),
    );
  }

  Widget buildControls() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: onFileSystemObjectAtOriginButtonPressed,
            child: const Text("Add/Remove Filesystem\nObject at Origin"),
          ),
          ElevatedButton(
            onPressed: onLocalObjectAtOriginButtonPressed,
            child: const Text("Add/Remove Local\nObject at Origin"),
          ),
          ElevatedButton(
            onPressed: onWebObjectAtOriginButtonPressed,
            child: const Text("Add/Remove Web\nObject at Origin"),
          ),
          ElevatedButton(
            onPressed: onLocalObjectShuffleButtonPressed,
            child: Text("Shuffle Local\nobject at Origin"),
          ),
          ElevatedButton(
            onPressed: onWebObjectShuffleButtonPressed,
            child: Text("Shuffle Web\nObject at Origin"),
          ),
        ],
      ),
    );
  }

  void onARViewCreated(
    ARSessionManager arSessionManager,
    ARObjectManager arObjectManager,
    ARAnchorManager arAnchorManager,
    ARLocationManager arLocationManager,
  ) {
    this.arSessionManager = arSessionManager;
    this.arObjectManager = arObjectManager;

    this.arSessionManager?.onInitialize(
      showFeaturePoints: false,
      showPlanes: true,
      customPlaneTexturePath: "Images/triangle.png",
      showWorldOrigin: true,
      handleTaps: false,
    );
    this.arObjectManager?.onInitialize();

    httpClient = HttpClient();
    _downloadFile(
      "https://github.com/KhronosGroup/glTF-Sample-Models/raw/refs/heads/main/2.0/Duck/glTF-Binary/Duck.glb",
      "LocalDuck.glb",
    );
    // Alternative to use type fileSystemAppFolderGLTF2:
    //_downloadAndUnpack(
    //    "https://drive.google.com/uc?export=download&id=1fng7yiK0DIR0uem7XkV2nlPSGH9PysUs",
    //    "Chicken_01.zip");
  }

  Future<File> _downloadFile(String url, String filename) async {
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      String dir = (await getApplicationDocumentsDirectory()).path;
      File file = File('$dir/$filename');
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } else {
      throw Exception("Failed to download file");
    }
  }

  // Future<void> _downloadAndUnpack(String url, String filename) async {
  //   var request = await httpClient!.getUrl(Uri.parse(url));
  //   var response = await request.close();
  //   var bytes = await consolidateHttpClientResponseBytes(response);
  //   String dir = (await getApplicationDocumentsDirectory()).path;
  //   File file = File('$dir/$filename');
  //   await file.writeAsBytes(bytes);
  //   print("Downloading finished, path: " + '$dir/$filename');

  //   // To print all files in the directory: print(Directory(dir).listSync());
  //   try {
  //     await ZipFile.extractToDirectory(
  //       zipFile: File('$dir/$filename'),
  //       destinationDir: Directory(dir),
  //     );
  //     print("Unzipping successful");
  //   } catch (e) {
  //     print("Unzipping failed: " + e.toString());
  //   }
  // }

  Future<void> onLocalObjectAtOriginButtonPressed() async {
    if (localObjectNode != null) {
      arObjectManager?.removeNode(localObjectNode!);
      localObjectNode = null;
    } else {
      var newNode = ARNode(
        type: NodeType.localGLTF2,
        //uri: "assets/models/Chicken_01/Chicken_01.gltf",
        uri: "assets/gltf/Box.gltf",
        scale: Vector3(0.2, 0.2, 0.2),
        position: Vector3(0.0, 0.0, 0.0),
        rotation: Vector4(1.0, 0.0, 0.0, 0.0),
      );
      bool? didAdd = await arObjectManager?.addNode(newNode);
      localObjectNode = didAdd == true ? newNode : null;
    }
  }

  Future<void> onWebObjectAtOriginButtonPressed() async {
    if (webObjectNode != null) {
      arObjectManager?.removeNode(webObjectNode!);
      webObjectNode = null;
    } else {
      var newNode = ARNode(
        type: NodeType.webGLB,
        uri:
            "https://github.com/KhronosGroup/glTF-Sample-Models/raw/refs/heads/main/2.0/Duck/glTF-Binary/Duck.glb",
        scale: Vector3(0.2, 0.2, 0.2),
      );
      bool? didAdd = await arObjectManager?.addNode(newNode);
      webObjectNode = didAdd == true ? newNode : null;
    }
  }

  Future<void> onFileSystemObjectAtOriginButtonPressed() async {
    if (fileSystemNode != null) {
      arObjectManager?.removeNode(fileSystemNode!);
      fileSystemNode = null;
    } else {
      var newNode = ARNode(
        type: NodeType.fileSystemAppFolderGLB,
        uri: "LocalDuck.glb",
        scale: Vector3(0.2, 0.2, 0.2),
      );
      //Alternative to use type fileSystemAppFolderGLTF2:
      //var newNode = ARNode(
      //    type: NodeType.fileSystemAppFolderGLTF2,
      //    uri: "Chicken_01.gltf",
      //    scale: Vector3(0.2, 0.2, 0.2));
      bool? didAdd = await arObjectManager?.addNode(newNode);
      fileSystemNode = didAdd == true ? newNode : null;
    }
  }

  Future<void> onLocalObjectShuffleButtonPressed() async {
    if (localObjectNode != null) {
      var newScale = Random().nextDouble() / 3;
      var newTranslationAxis = Random().nextInt(3);
      var newTranslationAmount = Random().nextDouble() / 3;
      var newTranslation = Vector3(0, 0, 0);
      newTranslation[newTranslationAxis] = newTranslationAmount;
      var newRotationAxisIndex = Random().nextInt(3);
      var newRotationAmount = Random().nextDouble();
      var newRotationAxis = Vector3(0, 0, 0);
      newRotationAxis[newRotationAxisIndex] = 1.0;

      final newTransform = Matrix4.identity();

      newTransform.setTranslation(newTranslation);
      newTransform.rotate(newRotationAxis, newRotationAmount);
      newTransform.scale(newScale);

      localObjectNode!.transform = newTransform;
    }
  }

  Future<void> onWebObjectShuffleButtonPressed() async {
    if (webObjectNode != null) {
      var newScale = Random().nextDouble() / 3;
      var newTranslationAxis = Random().nextInt(3);
      var newTranslationAmount = Random().nextDouble() / 3;
      var newTranslation = Vector3(0, 0, 0);
      newTranslation[newTranslationAxis] = newTranslationAmount;
      var newRotationAxisIndex = Random().nextInt(3);
      var newRotationAmount = Random().nextDouble();
      var newRotationAxis = Vector3(0, 0, 0);
      newRotationAxis[newRotationAxisIndex] = 1.0;

      final newTransform = Matrix4.identity();

      newTransform.setTranslation(newTranslation);
      newTransform.rotate(newRotationAxis, newRotationAmount);
      newTransform.scale(newScale);

      webObjectNode!.transform = newTransform;
    }
  }
}
