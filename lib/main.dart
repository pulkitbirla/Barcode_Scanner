import 'dart:async';

import 'package:camera/camera.dart';
import 'package:camera_features/wigets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

// Utilities
void _logError(String code, String? message) {
  // ignore: avoid_print
  print('Error: $code${message == null ? '' : '\nError Message: $message'}');
}

/// Returns a suitable camera icon for [direction].
IconData getCameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
  }
  // This enum is from a different package, so a new value could be added at
  // any time. The example should keep working if that happens.
  // ignore: dead_code
  return Icons.camera;
}

/// Camera example home widget.
class CameraExampleHome extends StatefulWidget {
  /// Default Constructor
  const CameraExampleHome({super.key});

  @override
  State<CameraExampleHome> createState() {
    return _CameraExampleHomeState();
  }
}

class _CameraExampleHomeState extends State<CameraExampleHome>
    with WidgetsBindingObserver {
  CameraController? controller;
  bool enableAudio = true;
  final barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.all]);

  // This is a crucial conversion function
  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final Uint8List nv21Bytes = convertYUV420toNV21(image)!;
    if (kDebugMode) {
      print('---------------------$nv21Bytes-----------------------');
      print(
        '---------------------${nv21Bytes.lengthInBytes}-----------------------',
      );
    }

    final camera = controller!.description;
    final sensorOrientation = camera.sensorOrientation;

    // Get image rotation
    // This is calculated based on the device orientation and sensor orientation
    // For most devices, this will be 90.
    final rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    if (rotation == null) return null;
    if (kDebugMode) {
      print(
        '---------------------started changing the format-----------------------',
      );
    }
    for (var item in image.planes) {
      if (kDebugMode) {
        print('---------------------${item.bytes}-----------------------');
      }
    }
    if (kDebugMode) {
      print(
        '---------------------${controller!.imageFormatGroup!.name}-----------------------',
      );
    }
    if (kDebugMode) {
      print('---------------------${image.format.raw}-----------------------');
      print(
        '---------------------${image.format.group}-----------------------',
      );
    }
    // Get image format
    final format = InputImageFormatValue.fromRawValue(17); //image.format.raw);
    if (format == null) return null;

    // Create InputImage from bytes
    return InputImage.fromBytes(
      bytes: nv21Bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: nv21Bytes.lengthInBytes,
      ),
    );
  }

  scan(CameraImage image) async {
    if (kDebugMode) {
      print(
        '---------------------image format group: ${controller!.imageFormatGroup}-----------------------',
      );
    }
    if (kDebugMode) {
      print('---------------------${image.format.raw}-----------------------');
      print(
        '---------------------${image.format.group}-----------------------',
      );
    }
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) return;
    if (kDebugMode) {
      print(
        '---------------------image format group: ${controller!.imageFormatGroup}-----------------------',
      );
    }
    final List<Barcode> barcodes = await barcodeScanner.processImage(
      inputImage,
    );

    for (Barcode barcode in barcodes) {
      final BarcodeType type = barcode.type;
      final Rect boundingBox = barcode.boundingBox;
      final String? displayValue = barcode.displayValue;
      final String? rawValue = barcode.rawValue;
      if (kDebugMode) {
        print(
          '------------------------$boundingBox, $displayValue, $rawValue--------------------------',
        );
      }

      // See API reference for complete list of supported types
      switch (type) {
        case BarcodeType.wifi:
          final barcodeWifi = barcode.value as BarcodeWifi;
          if (kDebugMode) {
            print(
              '------------------------$barcodeWifi--------------------------',
            );
          }
          break;
        case BarcodeType.url:
          final barcodeUrl = barcode.value as BarcodeUrl;
          if (kDebugMode) {
            print(
              '------------------------$barcodeUrl--------------------------',
            );
          }
          break;
        case BarcodeType.unknown:
          if (kDebugMode) {
            print('driverLicense');
          }
          break;
        case BarcodeType.contactInfo:
          if (kDebugMode) {
            print('driverLicense');
          }
          break;
        case BarcodeType.email:
          if (kDebugMode) {
            print('driverLicense');
          }
          break;
        case BarcodeType.isbn:
          if (kDebugMode) {
            print('driverLicense');
          }
          break;
        case BarcodeType.phone:
          if (kDebugMode) {
            print('driverLicense');
          }
          break;
        case BarcodeType.product:
          if (kDebugMode) {
            print('driverLicense');
          }
          break;
        case BarcodeType.sms:
          if (kDebugMode) {
            print('driverLicense');
          }
          break;
        case BarcodeType.text:
          if (kDebugMode) {
            print('driverLicense');
          }
          break;
        case BarcodeType.geoCoordinates:
          if (kDebugMode) {
            print('driverLicense');
          }
          break;
        case BarcodeType.calendarEvent:
          if (kDebugMode) {
            print('driverLicense');
          }
          break;
        case BarcodeType.driverLicense:
          if (kDebugMode) {
            print('driverLicense');
          }
          break;
      }
    }
  }

  @override
  void dispose() {
    // 4. Dispose controllers to free up resources
    controller?.dispose();
    barcodeScanner.close();
    super.dispose();
  }

  // #docregion AppLifecycle
  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      if (kDebugMode) {
        print(
          '---------------------App life cycle is inactive-----------------------',
        );
      }
      if (kDebugMode) {
        print(
          '---------------------image stream stoped-----------------------',
        );
      }
      controller!.stopImageStream();
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (kDebugMode) {
        print(
          '---------------------App life cycle is resumed-----------------------',
        );
      }
      await _initializeCameraController(cameraController.description);
      if (kDebugMode) {
        print(
          '---------------------image stream started-----------------------',
        );
      }
      controller!.startImageStream(scan);
    }
  }
  // #enddocregion AppLifecycle

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: Colors.black),
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Center(child: _cameraPreviewWidget()),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: _cameraTogglesRowWidget(),
          ),
        ],
      ),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return const Text(
        'Tap a camera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return CameraPreview(controller!);
    }
  }

  /// Display a row of toggle to select the camera (or a message if no camera is available).
  Widget _cameraTogglesRowWidget() {
    final List<Widget> toggles = <Widget>[];

    void onChanged(CameraDescription? description) {
      if (description == null) {
        return;
      }
      onNewCameraSelected(description);
    }

    if (_cameras.isEmpty) {
      SchedulerBinding.instance.addPostFrameCallback((_) async {
        showInSnackBar('No camera found.');
      });
      return const Text('None');
    } else {
      for (final CameraDescription cameraDescription in _cameras) {
        toggles.add(
          SizedBox(
            width: 90.0,
            child: RadioListTile<CameraDescription>(
              title: Icon(getCameraLensIcon(cameraDescription.lensDirection)),
              groupValue: controller?.description,
              value: cameraDescription,
              onChanged: onChanged,
            ),
          ),
        );
      }
    }

    return Row(children: toggles);
  }

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      if (kDebugMode) {
        print(
          '---------------------New camera selected-----------------------',
        );
      }
      controller!.stopImageStream();
      if (kDebugMode) {
        print(
          '---------------------image stream stoped-----------------------',
        );
      }
      controller!.setDescription(cameraDescription);

      if (kDebugMode) {
        print(
          '---------------------image format group: ${controller!.imageFormatGroup}-----------------------',
        );
      }

      controller!.startImageStream(scan);
      if (kDebugMode) {
        print(
          '---------------------image stream started-----------------------',
        );
      }
    } else {
      if (kDebugMode) {
        print('---------------------Controller is null-----------------------');
      }
      await _initializeCameraController(cameraDescription);
      if (kDebugMode) {
        print(
          '---------------------image format group: ${controller!.imageFormatGroup}-----------------------',
        );
      }

      controller!.startImageStream(scan);
      if (kDebugMode) {
        print(
          '---------------------image stream started-----------------------',
        );
      }
    }
  }

  Future<void> _initializeCameraController(
    CameraDescription cameraDescription,
  ) async {
    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.low,
      enableAudio: enableAudio,
      imageFormatGroup: defaultTargetPlatform == TargetPlatform.android
          ? ImageFormatGroup
                .nv21 // Good for Android processing
          : ImageFormatGroup.bgra8888,
    );
    if (kDebugMode) {
      print(
        '---------------------Initializing camera controller-----------------------',
      );
    }

    if (kDebugMode) {
      print(
        '---------------------image format group: ${cameraController.imageFormatGroup}-----------------------',
      );
    }
    controller = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (cameraController.value.hasError) {
        showInSnackBar(
          'Camera error ${cameraController.value.errorDescription}',
        );
      }
    });

    try {
      await cameraController.initialize();
      if (kDebugMode) {
        print('---------------------Camera initialized-----------------------');
      }
    } on CameraException catch (e) {
      switch (e.code) {
        case 'CameraAccessDenied':
          showInSnackBar('You have denied camera access.');
        case 'CameraAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar('Please go to Settings app to enable camera access.');
        case 'CameraAccessRestricted':
          // iOS only
          showInSnackBar('Camera access is restricted.');
        case 'AudioAccessDenied':
          showInSnackBar('You have denied audio access.');
        case 'AudioAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar('Please go to Settings app to enable audio access.');
        case 'AudioAccessRestricted':
          // iOS only
          showInSnackBar('Audio access is restricted.');
        default:
          _showCameraException(e);
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _showCameraException(CameraException e) {
    _logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }
}

/// CameraApp is the Main Application.
class CameraApp extends StatelessWidget {
  /// Default Constructor
  const CameraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: CameraExampleHome());
  }
}

List<CameraDescription> _cameras = <CameraDescription>[];

Future<void> main() async {
  // Fetch the available cameras before initializing the app.
  try {
    WidgetsFlutterBinding.ensureInitialized();
    _cameras = await availableCameras();
  } on CameraException catch (e) {
    _logError(e.code, e.description);
  }
  runApp(const CameraApp());
}
