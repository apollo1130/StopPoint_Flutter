import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:video_app/router.dart';

class CameraWidget extends StatefulWidget {
  @override
  _CameraWidgetState createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  List<CameraDescription> cameras;
  CameraController controller;
  int actualCamera = 1;

  @override
  void initState() {
    _initCameras();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          color: Colors.black,
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: <Widget>[
                    GestureDetector(
                        onTap: () {
                          FlowRouter.router.pop(context);
                        },
                        child: Icon(
                          FontAwesomeIcons.chevronLeft,
                          color: Colors.white,
                        ))
                  ],
                ),
              ),
              Expanded(
                child: !controller.value.isInitialized
                    ? Container()
                    : AspectRatio(
                        aspectRatio: 4 / 3, child: CameraPreview(controller)),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Container(
                      child: Icon(
                        FontAwesomeIcons.photoVideo,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.red),
                    ),
                    _cameraSwitch()
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _initCameras() async {
    cameras = await availableCameras();
    if (controller != null) {
      controller.dispose();
    }
    controller =
        CameraController(cameras[actualCamera], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }

      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  _cameraSwitch() {
    return GestureDetector(
        onTap: () {
          if (controller.description.lensDirection ==
              CameraLensDirection.front) {
            onNewCameraSelected(cameras[0]);
          } else {
            onNewCameraSelected(cameras[1]);
          }
        },
        child: Icon(FontAwesomeIcons.camera, color: Colors.white));
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
    );

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        print('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      print(e);
    }

    if (mounted) {
      setState(() {});
    }
  }
}
