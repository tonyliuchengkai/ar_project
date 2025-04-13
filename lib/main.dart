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

//Other custom imports
//import 'dart:convert';
import 'package:vector_math/vector_math_64.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
//import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: CloudAnchor());
  }
}

class CloudAnchor extends StatefulWidget {
  const CloudAnchor({super.key, this.width, this.height});

  final double? width;
  final double? height;

  @override
  State<CloudAnchor> createState() => _CloudAnchorState();
}

class _CloudAnchorState extends State<CloudAnchor> {
  // Firebase stuff
  bool _initialized = false;
  bool _error = false;
  FirebaseManager firebaseManager = FirebaseManager();
  Map<String, Map> anchorsInDownloadProgress = <String, Map>{};

  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  ARAnchorManager? arAnchorManager;
  ARLocationManager? arLocationManager;

  List<ARNode> nodes = [];
  List<ARAnchor> anchors = [];
  String lastUploadedAnchor = "";

  bool readyToUpload = false;
  bool readyToDownload = true;

  @override
  void initState() {
    firebaseManager.initializeFlutterFire().then(
      (value) => setState(() {
        _initialized = value;
        _error = !value;
      }),
    );

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    arSessionManager!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show error message if initialization failed
    if (_error) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cloud Anchors')),
        body: Center(
          child: Column(
            children: [
              Text("Firebase initialization failed"),
              ElevatedButton(
                child: Text("Retry"),
                onPressed: () => {initState()},
              ),
            ],
          ),
        ),
      );
    }

    // Show a loader until FlutterFire is initialized
    if (!_initialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cloud Anchors')),
        body: Center(
          child: Column(
            children: [
              CircularProgressIndicator(),
              Text("Initializing Firebase"),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Cloud Anchors')),
      body: Stack(
        children: [
          ARView(
            onARViewCreated: onARViewCreated,
            planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
          ),
          Align(
            alignment: FractionalOffset.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: onRemoveEverything,
                  child: Text("Remove Everything"),
                ),
              ],
            ),
          ),
          Align(
            alignment: FractionalOffset.topCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Visibility(
                  visible: readyToUpload,
                  child: ElevatedButton(
                    onPressed: onUploadButtonPressed,
                    child: Text("Upload"),
                  ),
                ),
                Visibility(
                  visible: readyToDownload,
                  child: ElevatedButton(
                    onPressed: onDownloadButtonPressed,
                    child: Text("Download"),
                  ),
                ),
              ],
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
    this.arLocationManager = arLocationManager;

    this.arSessionManager!.onInitialize(
      showFeaturePoints: false,
      showPlanes: true,
      customPlaneTexturePath: "Images/triangle.png",
      showWorldOrigin: true,
    );
    this.arObjectManager!.onInitialize();
    this.arAnchorManager!.initGoogleCloudAnchorMode();

    this.arSessionManager!.onPlaneOrPointTap = onPlaneOrPointTapped;
    this.arObjectManager!.onNodeTap = onNodeTapped;
    this.arAnchorManager!.onAnchorUploaded = onAnchorUploaded;
    this.arAnchorManager!.onAnchorDownloaded = onAnchorDownloaded;

    this.arSessionManager!.onError = (String error) {
      Map<String, String> errorTranslations = getErrorTranslations();
      String translatedError = error;
      errorTranslations.forEach((key, value) {
        if (error.contains(key)) {
          translatedError = value;
        }
      });
      AlertDialog(title: Text("Error"), content: Text(translatedError));
    };

    this.arLocationManager!.startLocationUpdates().then((value) => null).onError((
      error,
      stackTrace,
    ) {
      switch (error.toString()) {
        case 'Location services disabled':
          {
            if (!mounted) return;
            showAlertDialog(
              context,
              "Action Required",
              "To use cloud anchor functionality, please enable your location services",
              "Settings",
              this.arLocationManager!.openLocationServicesSettings,
              "Cancel",
            );
            break;
          }

        case 'Location permissions denied':
          {
            if (!mounted) return;
            showAlertDialog(
              context,
              "Action Required",
              "To use cloud anchor functionality, please allow the app to access your device's location",
              "Retry",
              this.arLocationManager!.startLocationUpdates,
              "Cancel",
            );
            break;
          }

        case 'Location permissions permanently denied':
          {
            if (!mounted) return;
            showAlertDialog(
              context,
              "Action Required",
              "To use cloud anchor functionality, please allow the app to access your device's location",
              "Settings",
              this.arLocationManager!.openAppPermissionSettings,
              "Cancel",
            );
            break;
          }

        default:
          {
            AlertDialog(title: Text("Error"), content: Text(error.toString()));
            break;
          }
      }
    });
  }

  Future<void> onRemoveEverything() async {
    for (var anchor in anchors) {
      arAnchorManager!.removeAnchor(anchor);
    }
    anchors = [];
    if (lastUploadedAnchor != "") {
      setState(() {
        readyToDownload = true;
        readyToUpload = false;
      });
    } else {
      setState(() {
        readyToDownload = true;
        readyToUpload = false;
      });
    }
  }

  Future<void> onNodeTapped(List<String> nodeNames) async {
    var foregroundNode = nodes.firstWhere(
      (element) => element.name == nodeNames.first,
    );
    AlertDialog(
      title: Text("Information"),
      content: Text(foregroundNode.data!["onTapText"]),
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
      ttl: 2,
    );
    bool? didAddAnchor = await arAnchorManager!.addAnchor(newAnchor);
    if (didAddAnchor ?? false) {
      anchors.add(newAnchor);
      // Add note to anchor
      var newNode = ARNode(
        type: NodeType.webGLB,
        uri:
            "https://github.com/KhronosGroup/glTF-Sample-Models/raw/refs/heads/main/2.0/Duck/glTF-Binary/Duck.glb",
        scale: Vector3(0.2, 0.2, 0.2),
        position: Vector3(0.0, 0.0, 0.0),
        rotation: Vector4(1.0, 0.0, 0.0, 0.0),
        data: {"onTapText": "Ouch, that hurt!"},
      );
      bool? didAddNodeToAnchor = await arObjectManager!.addNode(
        newNode,
        planeAnchor: newAnchor,
      );
      if (didAddNodeToAnchor ?? false) {
        nodes.add(newNode);
        setState(() {
          readyToUpload = true;
        });
      } else {
        AlertDialog(
          title: Text("Information"),
          content: Text("Adding Node to Anchor failed"),
        );
      }
    } else {
      AlertDialog(
        title: Text("Information"),
        content: Text("Adding Anchor failed"),
      );
    }
  }

  Future<void> onUploadButtonPressed() async {
    arAnchorManager!.uploadAnchor(anchors.last);
    setState(() {
      readyToUpload = false;
    });
  }

  onAnchorUploaded(ARAnchor anchor) {
    // Upload anchor information to firebase
    firebaseManager.uploadAnchor(
      anchor,
      currentLocation: arLocationManager!.currentLocation,
    );
    // Upload child nodes to firebase
    if (anchor is ARPlaneAnchor) {
      for (var nodeName in anchor.childNodes) {
        firebaseManager.uploadObject(
          nodes.firstWhere((element) => element.name == nodeName),
        );
      }
    }
    setState(() {
      readyToDownload = true;
      readyToUpload = false;
    });
    AlertDialog(title: Text("Information"), content: Text("Upload successful"));
  }

  ARAnchor onAnchorDownloaded(Map<String, dynamic> serializedAnchor) {
    final anchor = ARPlaneAnchor.fromJson(
      anchorsInDownloadProgress[serializedAnchor["cloudanchorid"]]
          as Map<String, dynamic>,
    );
    anchorsInDownloadProgress.remove(anchor.cloudanchorid);
    anchors.add(anchor);

    // Download nodes attached to this anchor
    firebaseManager.getObjectsFromAnchor(anchor, (snapshot) {
      for (var objectDoc in snapshot.docs) {
        ARNode object = ARNode.fromMap(
          objectDoc.data() as Map<String, dynamic>,
        );
        arObjectManager!.addNode(object, planeAnchor: anchor);
        nodes.add(object);
      }
    });

    return anchor;
  }

  Future<void> onDownloadButtonPressed() async {
    firebaseManager.downloadAnchorsByLocation(
      (snapshot) {
        final cloudAnchorId = snapshot.get("cloudanchorid");
        anchorsInDownloadProgress[cloudAnchorId] =
            snapshot.data() as Map<String, dynamic>;
        arAnchorManager!.downloadAnchor(cloudAnchorId);
      },
      arLocationManager!.currentLocation,
      0.1,
    );
    setState(() {
      readyToDownload = false;
    });
  }

  void showAlertDialog(
    BuildContext context,
    String title,
    String content,
    String buttonText,
    Function buttonFunction,
    String cancelButtonText,
  ) {
    // set up the buttons
    Widget cancelButton = ElevatedButton(
      child: Text(cancelButtonText),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget actionButton = ElevatedButton(
      child: Text(buttonText),
      onPressed: () {
        buttonFunction();
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [cancelButton, actionButton],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

// Class for managing interaction with Firebase (in your own app, this can be put in a separate file to keep everything clean and tidy)
typedef FirebaseListener = void Function(QuerySnapshot snapshot);
typedef FirebaseDocumentStreamListener =
    void Function(DocumentSnapshot snapshot);

class FirebaseManager {
  FirebaseFirestore? firestore;
  //GeoFlutterFire? geo;
  CollectionReference? anchorCollection;
  CollectionReference? objectCollection;

  // Firebase initialization function
  Future<bool> initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize
      await Firebase.initializeApp();
      // geo = GeoFlutterFire();
      firestore = FirebaseFirestore.instance;
      anchorCollection = FirebaseFirestore.instance.collection('anchors');
      objectCollection = FirebaseFirestore.instance.collection('objects');
      return true;
    } catch (e) {
      return false;
    }
  }

  void uploadAnchor(ARAnchor anchor, {Position? currentLocation}) {
    if (firestore == null) return;

    var serializedAnchor = anchor.toJson();
    var expirationTime =
        DateTime.now().millisecondsSinceEpoch / 1000 +
        serializedAnchor["ttl"] * 24 * 60 * 60;
    serializedAnchor["expirationTime"] = expirationTime;
    // 添加位置
    if (currentLocation != null) {
      // 創建GeoFirePoint
      final geoFirePoint = GeoFirePoint(
        GeoPoint(currentLocation.latitude, currentLocation.longitude),
      );

      // 將地理數據添加到serializedAnchor
      serializedAnchor["position"] = geoFirePoint.data;
    }

    anchorCollection!.add(serializedAnchor)
    // .then(
    //   (value) =>
    //       print("Successfully added anchor: " + serializedAnchor["name"]),
    // )
    // .catchError((error) => print("Failed to add anchor: $error"))
    ;
  }

  void uploadObject(ARNode node) {
    if (firestore == null) return;

    var serializedNode = node.toMap();

    objectCollection!.add(serializedNode)
    // .then(
    //   (value) =>
    //       print("Successfully added object: " + serializedNode["name"]),
    // )
    // .catchError((error) => print("Failed to add object: $error"))
    ;
  }

  void downloadLatestAnchor(FirebaseListener listener) {
    anchorCollection!
        .orderBy("expirationTime", descending: false)
        .limitToLast(1)
        .get()
        .then((value) => listener(value))
    // .catchError(
    //   (error) => (error) => print("Failed to download anchor: $error"),
    // )
    ;
  }

  // 依位置下載錨點
  void downloadAnchorsByLocation(
    FirebaseDocumentStreamListener listener,
    Position location,
    double radius,
  ) {
    // 創建中心點
    final center = GeoFirePoint(
      GeoPoint(location.latitude, location.longitude),
    );

    // 從文檔獲取GeoPoint的函數
    GeoPoint geopointFrom(Map<String, dynamic> data) {
      try {
        return (data['position'] as Map<String, dynamic>)['geopoint']
            as GeoPoint;
      } catch (e) {
        // 處理格式錯誤
        //print("Error extracting geopoint: $e");
        // 返回一個默認值或拋出異常
        return GeoPoint(0, 0);
      }
    }

    // 使用GeoCollectionReference進行地理查詢
    final stream = GeoCollectionReference<Map<String, dynamic>>(
      anchorCollection as CollectionReference<Map<String, dynamic>>,
    ).subscribeWithin(
      center: center,
      radiusInKm: radius,
      field: 'position',
      geopointFrom: geopointFrom,
    );

    // 處理查詢結果
    stream.listen((List<DocumentSnapshot<Map<String, dynamic>>> documents) {
      for (var doc in documents) {
        listener(doc);
      }
    });
  }

  void downloadAnchorsByChannel() {}

  void getObjectsFromAnchor(ARPlaneAnchor anchor, FirebaseListener listener) {
    objectCollection!
        .where("name", whereIn: anchor.childNodes)
        .get()
        .then((value) => listener(value))
    // .catchError((error) => print("Failed to download objects: $error"))
    ;
  }

  void deleteExpiredDatabaseEntries() {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    anchorCollection!
        .where(
          "expirationTime",
          isLessThan: DateTime.now().millisecondsSinceEpoch / 1000,
        )
        .get()
        .then((anchorSnapshot) {
          for (var anchorDoc in anchorSnapshot.docs) {
            // Delete all objects attached to the expired anchor
            objectCollection!
                .where("name", arrayContainsAny: anchorDoc.get("childNodes"))
                .get()
                .then((objectSnapshot) {
                  for (var objectDoc in objectSnapshot.docs) {
                    batch.delete(objectDoc.reference);
                  }
                });

            // Delete the expired anchor
            batch.delete(anchorDoc.reference);
          }
        });
    batch.commit();
  }
}

Map<String, String> getErrorTranslations() {
  return {
    "Cloud anchor id not found": "ID d'ancre cloud non trouvé",
    "Dataset processing failed, feature map insufficient":
        "On n'a pas assez d'infos sur ton environnement, fais le tour de la pièce avec ta caméra afin qu'on puisse analyser les surfaces autour de toi, puis repositionne l'indice.",
    "Hosting service unavailable":
        "Problème de connexion : les serveurs Eskape sont inaccessibles. Réessaie ou contacte-nous pour débloquer la situation.",
    "Internal error":
        "Erreur interne. Réessaie ou contacte-nous pour débloquer la situation.",
    "Authentication failed: Not Authorized":
        "Échec de l'authentification : déconnecte-toi puis reconnecte-toi. Si la situation persiste, contacte-nous.",
    "Resolving Sdk version too new":
        "Version du SDK trop récente. Contacte-nous pour débloquer la situation.",
    "Resolving Sdk version too old":
        "Version du SDK trop ancienne. Contacte-nous pour débloquer la situation.",
    "Resource exhausted":
        "Ressource épuisée : Contacte-nous pour débloquer la situation.",
    "Empty state": "État vide : Contacte-nous pour débloquer la situation.",
    "Task in progress": "Tâche en cours",
    "Success": "Succès",
    "Cloud Anchor Service unavailable":
        "Service d'Ancre Cloud indisponible : Contacte-nous pour débloquer la situation.",
    "No match":
        "Aucune correspondance : Contacte-nous pour débloquer la situation.",
    "Unknown": "Erreure inconnue : Contacte-nous pour débloquer la situation.",
  };
}
