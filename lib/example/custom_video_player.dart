import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Camera example home widget.
class CustomVideoPlayer extends StatefulWidget {
  /// Default Constructor
  const CustomVideoPlayer({super.key});

  @override
  State<CustomVideoPlayer> createState() {
    return _CustomVideoPlayerState();
  }
}

void _logError(String code, String? message) {
  // ignore: avoid_print
  print('Error: $code${message == null ? '' : '\nError Message: $message'}');
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? controller;
  XFile? videoFile;
  VideoPlayerController? videoController;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;
  int _pointers = 0; // Counting pointers (number of user fingers on screen)
  Future<void>? _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    availableCameras().then((cameras) async {
      final camera = cameras.first;
      controller = CameraController(
          camera,
          enableAudio: true,
          ResolutionPreset.high,
          imageFormatGroup: ImageFormatGroup.jpeg);

      try {
        _initializeControllerFuture = controller?.initialize();
      } on CameraException catch (e) {
        switch (e.code) {
          case 'CameraAccessDenied':
            showInSnackBar('You have denied camera access.');
            break;
          case 'CameraAccessDeniedWithoutPrompt':
            // iOS only
            showInSnackBar(
                'Please go to Settings app to enable camera access.');
            break;
          case 'CameraAccessRestricted':
            // iOS only
            showInSnackBar('Camera access is restricted.');
            break;
          case 'AudioAccessDenied':
            showInSnackBar('You have denied audio access.');
            break;
          case 'AudioAccessDeniedWithoutPrompt':
            // iOS only
            showInSnackBar('Please go to Settings app to enable audio access.');
            break;
          case 'AudioAccessRestricted':
            // iOS only
            showInSnackBar('Audio access is restricted.');
            break;
          default:
            _showCameraException(e);
            break;
        }
      }

      await _initializeControllerFuture;
      setState(() {});
      _maxAvailableZoom = (await controller?.getMaxZoomLevel())!;
      _minAvailableZoom = (await controller?.getMinZoomLevel())!;

      ///If the controller is updated then update the UI.
      controller?.addListener(() {
        debugPrint('\u001b[31m listen............. \u001b[0m');
        if (mounted) setState(() {});
        if (controller!.value.hasError) {
          debugPrint(
              '\u001b[31m Camera error ${controller?.value.errorDescription} \u001b[0m');
        }
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    final CameraController? cameraController = controller;
    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCameraController(cameraController.description);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(
                  color:
                      controller != null && controller!.value.isRecordingVideo
                          ? Colors.redAccent
                          : Colors.grey,
                  width: 3.0,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Center(
                  child: _cameraPreviewWidget(),
                ),
              ),
            ),
          ),
          _captureControlRowWidget(),
        ],
      ),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return Listener(
        onPointerDown: (_) => _pointers++,
        onPointerUp: (_) => _pointers--,
        child: Stack(
            alignment: AlignmentDirectional.center,
            fit: StackFit.loose,
            children: [
              CameraPreview(
                controller!,
                child: LayoutBuilder(builder:
                    (BuildContext context, BoxConstraints constraints) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onScaleStart: _handleScaleStart,
                    onScaleUpdate: _handleScaleUpdate,
                    onTapDown: (TapDownDetails details) =>
                        onViewFinderTap(details, constraints),
                  );
                }),
              ),
              if (_pointers == 2)
                CircleAvatar(
                  backgroundColor: Colors.black45,
                  radius: 50.0,
                  child: Text(
                    'x${_currentScale.toStringAsFixed(1)}',
                    style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Colors.white),
                  ),
                ),
            ]),
      );
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    if (controller == null || _pointers != 2) {
      return;
    }
    _currentScale = (_baseScale * details.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);
    await controller!.setZoomLevel(_currentScale);
    setState(() {});
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    debugPrint('\u001b[31m onViewFinderTap............. \u001b[0m');
    if (controller == null) {
      return;
    }

    final CameraController cameraController = controller!;

    final Offset offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  /// 顯示錄影用控制按鈕
  Widget _captureControlRowWidget() {
    final CameraController? cameraController = controller;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.videocam),
          color: Colors.blue,
          onPressed: cameraController != null &&
                  cameraController.value.isInitialized &&
                  !cameraController.value.isRecordingVideo
              ? onVideoRecordButtonPressed
              : null,
        ),
        IconButton(
          icon: cameraController != null &&
                  cameraController.value.isRecordingPaused
              ? const Icon(Icons.play_arrow)
              : const Icon(Icons.pause),
          color: Colors.blue,
          onPressed: cameraController != null &&
                  cameraController.value.isInitialized &&
                  cameraController.value.isRecordingVideo
              ? (cameraController.value.isRecordingPaused)
                  ? onResumeButtonPressed
                  : onPauseButtonPressed
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.stop),
          color: Colors.red,
          onPressed: cameraController != null &&
                  cameraController.value.isInitialized &&
                  cameraController.value.isRecordingVideo
              ? onStopButtonPressed
              : null,
        ),
      ],
    );
  }

  void showInSnackBar(String message) {
    // ScaffoldMessenger.of(context)
    //     .showSnackBar(SnackBar(content: Text(message)));

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      elevation: 1.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 100,
          right: 20,
          left: 20),
    ));
  }

  Future<void> _initializeCameraController(
      CameraDescription cameraDescription) async {
    controller = CameraController(
        cameraDescription,
        enableAudio: true,
        ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.jpeg);

    try {
      _initializeControllerFuture = controller?.initialize();
    } on CameraException catch (e) {
      switch (e.code) {
        case 'CameraAccessDenied':
          showInSnackBar('You have denied camera access.');
          break;
        case 'CameraAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar('Please go to Settings app to enable camera access.');
          break;
        case 'CameraAccessRestricted':
          // iOS only
          showInSnackBar('Camera access is restricted.');
          break;
        case 'AudioAccessDenied':
          showInSnackBar('You have denied audio access.');
          break;
        case 'AudioAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar('Please go to Settings app to enable audio access.');
          break;
        case 'AudioAccessRestricted':
          // iOS only
          showInSnackBar('Audio access is restricted.');
          break;
        default:
          _showCameraException(e);
          break;
      }
    }
    await _initializeControllerFuture;
    setState(() {});
    _maxAvailableZoom = (await controller?.getMaxZoomLevel())!;
    _minAvailableZoom = (await controller?.getMinZoomLevel())!;

    ///If the controller is updated then update the UI.
    controller?.addListener(() {
      debugPrint('\u001b[31m listen............. \u001b[0m');
      if (mounted) setState(() {});
      if (controller!.value.hasError) {
        debugPrint(
            '\u001b[31m Camera error ${controller?.value.errorDescription} \u001b[0m');
      }
    });
    if (mounted) setState(() {});
  }

  ///no use
  Future<void> onCaptureOrientationLockButtonPressed() async {
    try {
      if (controller != null) {
        final CameraController cameraController = controller!;
        if (cameraController.value.isCaptureOrientationLocked) {
          await cameraController.unlockCaptureOrientation();
          showInSnackBar('Capture orientation unlocked');
        } else {
          await cameraController.lockCaptureOrientation();
          showInSnackBar(
              'Capture orientation locked to ${cameraController.value.lockedCaptureOrientation.toString().split('.').last}');
        }
      }
    } on CameraException catch (e) {
      _showCameraException(e);
    }
  }

  ///按錄影button -> 開始錄影
  void onVideoRecordButtonPressed() {
    startVideoRecording().then((_) {
      if (mounted) setState(() {});
      // showInSnackBar('開始錄影');
    });
  }

  ///按停止button -> 停止錄影
  void onStopButtonPressed() {
    stopVideoRecording().then((XFile? file) {
      if (mounted) setState(() {});
      if (file != null) {
        // showInSnackBar('錄影結束\n${file.path}');
        videoFile = file;
      }
    });
  }

  ///按暫停錄影button -> 暫停錄影
  void onPauseButtonPressed() {
    pauseVideoRecording().then((_) {
      if (mounted) setState(() {});
      // showInSnackBar('暫停錄影');
    });
  }

  ///按繼續錄影button -> 繼續錄影
  void onResumeButtonPressed() {
    resumeVideoRecording().then((_) {
      if (mounted) setState(() {});
      // showInSnackBar('繼續錄影');
    });
  }

  Future<void> startVideoRecording() async {
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return;
    }
    if (cameraController.value.isRecordingVideo) return;
    try {
      await cameraController.startVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return;
    }
  }

  Future<XFile?> stopVideoRecording() async {
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }
    try {
      return cameraController.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  Future<void> pauseVideoRecording() async {
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return;
    }
    try {
      await cameraController.pauseVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> resumeVideoRecording() async {
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return;
    }
    try {
      await cameraController.resumeVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  void _showCameraException(CameraException e) {
    _logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }
}
