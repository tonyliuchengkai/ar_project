import './body_tracking_page.dart';
import './camera_properties_page.dart';
import './check_support_page.dart';
import './custom_animation_page.dart';
import './custom_object_page.dart';
import './load_gltf_or_glb_page.dart';
import './distance_tracking_page.dart';
import './custom_light_page.dart';
import './earth_page.dart';
import './hello_world.dart';
import './image_detection_page.dart';
import './light_estimate_page.dart';
import './manipulation_page.dart';
import './measure_page.dart';
import './midas_page.dart';
import './network_image_detection.dart';
import './occlusion_page.dart';
import './physics_page.dart';
import './plane_detection_page.dart';
import './snapshot_depth_scene.dart';
import './snapshot_scene.dart';
import './tap_page.dart';
import './face_detection_page.dart';
import './panorama_page.dart';
import './video_page.dart';
import './widget_projection.dart';
import './real_time_updates.dart';
import 'package:flutter/material.dart';
import './model_test.dart';

void main() => runApp(const MaterialApp(home: MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final samples = [
      Sample(
        'Hello World',
        'The simplest scene with all geometries.',
        Icons.home,
        () => Navigator.of(
          context,
        ).push<void>(MaterialPageRoute(builder: (c) => const HelloWorldPage())),
      ),
      Sample(
        'Check configuration',
        'Shows which kinds of AR configuration are supported on the device',
        Icons.settings,
        () => Navigator.of(context).push<void>(
          MaterialPageRoute(builder: (c) => const CheckSupportPage()),
        ),
      ),
      Sample(
        'Earth',
        'Sphere with an image texture and rotation animation.',
        Icons.language,
        () => Navigator.of(
          context,
        ).push<void>(MaterialPageRoute(builder: (c) => const EarthPage())),
      ),
      Sample(
        'Tap',
        'Sphere which handles tap event.',
        Icons.touch_app,
        () => Navigator.of(
          context,
        ).push<void>(MaterialPageRoute(builder: (c) => const TapPage())),
      ),
      Sample(
        'Midas',
        'Turns walls, floor, and Earth itself into gold by tap.',
        Icons.touch_app,
        () => Navigator.of(
          context,
        ).push<void>(MaterialPageRoute(builder: (c) => const MidasPage())),
      ),
      Sample(
        'Plane Detection',
        'Detects horizontal plane.',
        Icons.blur_on,
        () => Navigator.of(context).push<void>(
          MaterialPageRoute(builder: (c) => const PlaneDetectionPage()),
        ),
      ),
      Sample(
        'Distance tracking',
        'Detects horizontal plane and track distance on it.',
        Icons.blur_on,
        () => Navigator.of(context).push<void>(
          MaterialPageRoute(builder: (c) => const DistanceTrackingPage()),
        ),
      ),
      Sample(
        'Measure',
        'Measures distances',
        Icons.linear_scale,
        () => Navigator.of(
          context,
        ).push<void>(MaterialPageRoute(builder: (c) => const MeasurePage())),
      ),
      Sample(
        'Physics',
        'A sphere and a plane with dynamic and static physics',
        Icons.file_download,
        () => Navigator.of(
          context,
        ).push<void>(MaterialPageRoute(builder: (c) => const PhysicsPage())),
      ),
      Sample(
        'Image Detection',
        'Detects Earth photo and puts a 3D object near it.',
        Icons.collections,
        () => Navigator.of(context).push<void>(
          MaterialPageRoute(builder: (c) => const ImageDetectionPage()),
        ),
      ),
      Sample(
        'Network Image Detection',
        'Detects Mars photo and puts a 3D object near it.',
        Icons.collections,
        () => Navigator.of(context).push<void>(
          MaterialPageRoute(builder: (c) => const NetworkImageDetectionPage()),
        ),
      ),
      Sample(
        'Custom Light',
        'Hello World scene with a custom light spot.',
        Icons.lightbulb_outline,
        () => Navigator.of(context).push<void>(
          MaterialPageRoute(builder: (c) => const CustomLightPage()),
        ),
      ),
      Sample(
        'Light Estimation',
        'Estimates and applies the light around you.',
        Icons.brightness_6,
        () => Navigator.of(context).push<void>(
          MaterialPageRoute(builder: (c) => const LightEstimatePage()),
        ),
      ),
      Sample(
        'Custom Object',
        'Place custom object on plane with coaching overlay.',
        Icons.nature,
        () => Navigator.of(context).push<void>(
          MaterialPageRoute(builder: (c) => const CustomObjectPage()),
        ),
      ),
      Sample(
        'Load .gltf or .glb',
        'Load .gltf or .glb from the Flutter assets or the Documents folder',
        Icons.folder_copy,
        () => Navigator.of(context).push<void>(
          MaterialPageRoute(builder: (c) => const LoadGltfOrGlbFilePage()),
        ),
      ),
      Sample(
        'Load clothwaremodel',
        'Load clothwaremodel from the Flutter assets or the Documents folder',
        Icons.folder_copy,
        () => Navigator.of(context).push<void>(
          MaterialPageRoute(builder: (c) => const ClothWareModelTestPage()),
        ),
      ),
      Sample(
        'Occlusion',
        'Spheres which are not visible after horizontal and vertical planes.',
        Icons.blur_circular,
        () => Navigator.of(
          context,
        ).push<void>(MaterialPageRoute(builder: (c) => const OcclusionPage())),
      ),
      Sample(
        'Manipulation',
        'Custom objects with pinch and rotation events.',
        Icons.threed_rotation,
        () => Navigator.of(context).push<void>(
          MaterialPageRoute(builder: (c) => const ManipulationPage()),
        ),
      ),
      Sample(
        'Face Tracking',
        'Face mask sample.',
        Icons.face,
        () => Navigator.of(context).push<void>(
          MaterialPageRoute(builder: (c) => const FaceDetectionPage()),
        ),
      ),
      Sample(
        'Body Tracking',
        'Dash that follows your hand.',
        Icons.person,
        () => Navigator.of(context).push<void>(
          MaterialPageRoute(builder: (c) => const BodyTrackingPage()),
        ),
      ),
      Sample(
        'Panorama',
        '360 photo sample.',
        Icons.panorama,
        () => Navigator.of(
          context,
        ).push<void>(MaterialPageRoute(builder: (c) => const PanoramaPage())),
      ),
      Sample(
        'Video',
        '360 video sample.',
        Icons.videocam,
        () => Navigator.of(
          context,
        ).push<void>(MaterialPageRoute(builder: (c) => const VideoPage())),
      ),
      Sample(
        'Custom Animation',
        'Custom object animation. Port of https://github.com/eh3rrera/ARKitAnimation',
        Icons.accessibility_new,
        () => Navigator.of(context).push<void>(
          MaterialPageRoute(builder: (c) => const CustomAnimationPage()),
        ),
      ),
      Sample(
        'Widget Projection',
        'Flutter widgets in AR',
        Icons.widgets,
        () => Navigator.of(context).push<void>(
          MaterialPageRoute(builder: (c) => const WidgetProjectionPage()),
        ),
      ),
      Sample(
        'Real Time Updates',
        'Calls a function once per frame',
        Icons.timer,
        () => Navigator.of(context).push<void>(
          MaterialPageRoute(builder: (c) => const RealTimeUpdatesPage()),
        ),
      ),
      Sample(
        'Snapshot',
        'Make a photo of AR content',
        Icons.camera,
        () => Navigator.of(context).push<void>(
          MaterialPageRoute(builder: (c) => const SnapshotScenePage()),
        ),
      ),
      Sample(
        'Camera properties',
        'Shows position, Intrinsic, and resolution of the camera',
        Icons.location_on,
        () => Navigator.of(context).push<void>(
          MaterialPageRoute(builder: (c) => const CameraPropertiesPage()),
        ),
      ),
      Sample(
        'Depth Scene Snapshot',
        'Make a photo of the depth scene using LiDAR',
        Icons.camera,
        () => Navigator.of(context).push<void>(
          MaterialPageRoute(builder: (c) => SnapshotDepthScenePage()),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('ARKit Demo')),
      body: ListView(
        children: samples.map((s) => SampleItem(item: s)).toList(),
      ),
    );
  }
}

class SampleItem extends StatelessWidget {
  const SampleItem({required this.item, super.key});
  final Sample item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => item.onTap(),
        child: ListTile(
          leading: Icon(item.icon),
          title: Text(
            item.title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle: Text(
            item.description,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
      ),
    );
  }
}

class Sample {
  const Sample(this.title, this.description, this.icon, this.onTap);
  final String title;
  final String description;
  final IconData icon;
  final Function onTap;
}
