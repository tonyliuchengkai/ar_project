import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class ClothWareModelTestPage extends StatefulWidget {
  const ClothWareModelTestPage({super.key});

  @override
  State<ClothWareModelTestPage> createState() => _ClothWareModelTestPageState();
}

class _ClothWareModelTestPageState extends State<ClothWareModelTestPage> {
  late ARKitController arkitController;
  String modelState = "請點擊按鈕加載模型";

  @override
  void dispose() {
    arkitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('模型加載測試')),
    body: Stack(
      children: [
        ARKitSceneView(
          showFeaturePoints: true,
          planeDetection: ARPlaneDetection.horizontalAndVertical,
          onARKitViewCreated: onARKitViewCreated,
        ),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () => loadBoxModel(),
                child: Text('加載Box模型'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () => loadMyModel(),
                child: Text('加載我的模型'),
              ),
            ],
          ),
        ),
        Positioned(
          top: 20,
          left: 0,
          right: 0,
          child: Container(
            color: Colors.black54,
            padding: EdgeInsets.all(8),
            child: Text(
              modelState,
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    ),
  );

  void onARKitViewCreated(ARKitController controller) {
    arkitController = controller;
  }

  void loadBoxModel() {
    try {
      // 清除之前的模型
      arkitController.remove("modelNode");

      final position = vector.Vector3(0, -0.1, -0.5);

      final node = ARKitGltfNode(
        name: "modelNode",
        assetType: AssetType.flutterAsset,
        url: 'assets/gltf/Box.gltf',
        scale: vector.Vector3(0.05, 0.05, 0.05),
        position: position,
      );

      arkitController.add(node);
      setState(() {
        modelState = "Box模型加載成功";
      });
    } catch (e) {
      setState(() {
        modelState = "Box模型加載失敗: $e";
      });
    }
  }

  void loadMyModel() {
    try {
      // 清除之前的模型
      arkitController.remove("modelNode");

      final position = vector.Vector3(0, -0.1, -0.5);

      final node = ARKitGltfNode(
        name: "modelNode",
        assetType: AssetType.flutterAsset,
        url: 'assets/gltf/1-1.gltf', // 您的模型文件
        scale: vector.Vector3(0.05, 0.05, 0.05),
        position: position,
      );

      arkitController.add(node);
      setState(() {
        modelState = "我的模型加載成功";
      });
    } catch (e) {
      setState(() {
        modelState = "我的模型加載失敗: $e";
      });
    }
  }
}
