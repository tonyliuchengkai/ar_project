import 'package:flutter/material.dart';

// AR Flutter Plugin
import 'package:ar_flutter_plugin_2/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_2/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_2/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_2/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_2/models/ar_anchor.dart';
import 'package:ar_flutter_plugin_2/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin_2/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin_2/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_2/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin_2/models/ar_node.dart';
import 'package:ar_flutter_plugin_2/models/ar_hittest_result.dart';

// Other imports
//import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart';
//import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: ObjectsOnPlanes());
  }
}

class ObjectsOnPlanes extends StatefulWidget {
  const ObjectsOnPlanes({super.key, this.width, this.height});

  final double? width;
  final double? height;

  @override
  State<ObjectsOnPlanes> createState() => _ObjectsOnPlanesState();
}

class _ObjectsOnPlanesState extends State<ObjectsOnPlanes> {
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  ARAnchorManager? arAnchorManager;

  List<ARNode> nodes = [];
  List<ARAnchor> anchors = [];

  @override
  void dispose() {
    super.dispose();
    arSessionManager?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Anchors & Objects on Planes')),
      body: Stack(
        children: [
          ARView(
            onARViewCreated: onARViewCreated,
            planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
              onPressed: onRemoveEverything,
              child: const Text("Remove Everything"),
            ),
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
    this.arAnchorManager = arAnchorManager;

    this.arSessionManager!.onInitialize(
      showFeaturePoints: false,
      showPlanes: true,
      customPlaneTexturePath: "Images/triangle.png",
      showWorldOrigin: true,
    );
    this.arObjectManager!.onInitialize();

    this.arSessionManager!.onPlaneOrPointTap = onPlaneOrPointTapped;
    this.arObjectManager!.onNodeTap = onNodeTapped;
  }

  Future<void> onRemoveEverything() async {
    for (var anchor in anchors) {
      await arAnchorManager?.removeAnchor(anchor);
    }
    anchors.clear();
  }

  Future<void> onNodeTapped(List<String> nodes) async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Information"),
            content: Text("Tapped ${nodes.length} node(s)"),
          ),
    );
  }

  Future<void> onPlaneOrPointTapped(
    List<ARHitTestResult> hitTestResults,
  ) async {
    var singleHitTestResult = hitTestResults.firstWhere(
      (hitTestResult) => hitTestResult.type == ARHitTestResultType.plane,
    );

    var newAnchor = ARPlaneAnchor(
      transformation: singleHitTestResult.worldTransform,
    );
    bool? didAddAnchor = await arAnchorManager?.addAnchor(newAnchor);

    if (didAddAnchor == true) {
      anchors.add(newAnchor);
      // Add note to anchor
      var newNode = ARNode(
        type: NodeType.webGLB,
        uri:
            "https://github.com/KhronosGroup/glTF-Sample-Models/raw/refs/heads/main/2.0/Duck/glTF-Binary/Duck.glb",
        scale: Vector3(0.2, 0.2, 0.2),
        position: Vector3.zero(),
        rotation: Vector4(1.0, 0.0, 0.0, 0.0),
      );
      bool? didAddNodeToAnchor = await arObjectManager?.addNode(
        newNode,
        planeAnchor: newAnchor,
      );

      if (didAddNodeToAnchor == true) {
        nodes.add(newNode);
      } else {
        if (!mounted) {
          return; // Ensure the state is still mounted before showing the dialog
        }
        showDialog(
          context: context,
          builder:
              (context) => const AlertDialog(
                title: Text("Error"),
                content: Text("Adding Node to Anchor failed"),
              ),
        );
      }
    } else {
      if (!mounted) {
        return; // Ensure the state is still mounted before showing the dialog
      }
      showDialog(
        context: context,
        builder:
            (context) => const AlertDialog(
              title: Text("Error"),
              content: Text("Adding Anchor failed"),
            ),
      );
    }
    /*
      // To add a node to the tapped position without creating an anchor, use the following code (Please mind: the function onRemoveEverything has to be adapted accordingly!):
      var newNode = ARNode(
          type: NodeType.localGLTF2,
          uri: "Models/Chicken_01/Chicken_01.gltf",
          scale: Vector3(0.2, 0.2, 0.2),
          transformation: singleHitTestResult.worldTransform);
      bool didAddWebNode = await this.arObjectManager.addNode(newNode);
      if (didAddWebNode) {
        this.nodes.add(newNode);
      }*/
  }
}
