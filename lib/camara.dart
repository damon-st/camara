library camara;

import 'dart:typed_data';

import 'package:camara/background_loading.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

enum CameraSelect { frontal, posterior }

class Camera extends StatefulWidget {
  const Camera(
      {Key? key,
      this.cameraSelect = CameraSelect.posterior,
      this.resolution = ResolutionPreset.high})
      : super(key: key);
  final CameraSelect cameraSelect;
  final ResolutionPreset resolution;
  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> with WidgetsBindingObserver {
  List<CameraDescription> cameras = [];
  CameraController? controller;
  bool cargando = true;
  bool tomando = false;
  bool existeFoto = false;
  XFile? photo;
  Uint8List? photoBytes;
  int selectedCamera = 0;
  FlashMode flashMode = FlashMode.off;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.delayed(Duration.zero, () async {
      try {
        cameras = await availableCameras();

        if (cameras.length > 1) {
          if (widget.cameraSelect == CameraSelect.frontal) {
            selectedCamera = 1;
          } else {
            selectedCamera = 0;
          }
        } else {
          selectedCamera = 0;
        }
        controller = CameraController(
            cameras[selectedCamera], widget.resolution,
            enableAudio: false);
        await controller?.initialize();
        await controller?.setFlashMode(flashMode);
        setState(() {
          cargando = false;
        });
      } catch (e) {
        debugPrint("$e");
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    debugPrint("$state");
    if (controller == null) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
    } else if (state == AppLifecycleState.resumed) {
      if (controller != null) {
        cameras.add(controller!.description);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return cargando
        ? const BackgroundLoading()
        : Scaffold(
            backgroundColor: Colors.black,
            body: SizedBox(
              width: size.width,
              height: size.height,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CameraPreview(controller!),
                  Positioned(
                    bottom: 50,
                    child: InkWell(
                      onTap: () {
                        tomarFoto(context);
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.white,
                                  blurRadius: 8,
                                  spreadRadius: 1)
                            ],
                            border: Border.all(
                              color: Colors.black,
                              width: 12,
                            )),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 30,
                    bottom: 50,
                    child: IconButton(
                      iconSize: 40,
                      onPressed: () {
                        changedCamera(context);
                      },
                      icon: const Icon(
                        Icons.cameraswitch_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 30,
                    bottom: 50,
                    child: IconButton(
                      iconSize: 40,
                      onPressed: () {
                        setFlash(context);
                      },
                      icon: Icon(
                        flashMode == FlashMode.off
                            ? Icons.flash_off
                            : flashMode == FlashMode.auto
                                ? Icons.flash_auto
                                : Icons.flash_on,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  existeFoto
                      ? SizedBox(
                          width: size.width,
                          height: size.height,
                          child: Stack(
                            children: [
                              Image(
                                image: MemoryImage(photoBytes!),
                                fit: BoxFit.contain,
                              ),
                              Positioned(
                                  bottom: 50,
                                  left: 50,
                                  right: 50,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          aceptar(context);
                                        },
                                        child: Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 3,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          nuevaFoto(context);
                                        },
                                        child: Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.red,
                                              width: 3,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ))
                            ],
                          ),
                        )
                      : const SizedBox(),
                  tomando
                      ? const BackgroundLoading(
                          title: "Capturando",
                        )
                      : const SizedBox()
                ],
              ),
            ),
          );
  }

  void tomarFoto(BuildContext context) async {
    if (tomando) return;
    setState(() {
      tomando = true;
    });
    try {
      await controller?.pausePreview();
      await Future.delayed(const Duration(milliseconds: 200));
      photo = await controller?.takePicture();
      await controller?.resumePreview();
      // photoBytes = await photo?.readAsBytes();
      if (!mounted) return;

      setState(() {
        // existeFoto = true;
        tomando = false;
      });
    } on CameraException catch (e) {
      debugPrint("$e");
      setState(() {
        tomando = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error $e")));
    }
  }

  void aceptar(BuildContext context) {
    Navigator.pop(context, photo);
  }

  void nuevaFoto(BuildContext context) {
    setState(() {
      existeFoto = false;
      photoBytes = null;
      photo = null;
    });
  }

  void changedCamera(BuildContext context) async {
    if (cameras.length > 1) {
      if (selectedCamera == 1) {
        selectedCamera = 0;
      } else {
        selectedCamera = 1;
      }
    } else {
      selectedCamera = 0;
    }
    controller = CameraController(cameras[selectedCamera], widget.resolution,
        enableAudio: false);
    try {
      await controller?.initialize();
      setState(() {});
    } catch (e) {
      debugPrint("$e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error $e")));
    }
  }

  void setFlash(context) async {
    if (flashMode == FlashMode.off) {
      flashMode = FlashMode.auto;
    } else if (flashMode == FlashMode.auto) {
      flashMode = FlashMode.always;
    } else if (flashMode == FlashMode.always) {
      flashMode = FlashMode.off;
    }
    await controller?.setFlashMode(flashMode);
    setState(() {});
  }
}
