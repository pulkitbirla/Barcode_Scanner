import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import 'devdoot.dart';
import 'image_conversion.dart';

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
  bool isStreaming = false;
  final barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.all]);

  scan(CameraImage image) async {
    final inputImage = inputImageFromCameraImage(image, controller);
    if (inputImage == null) return;

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
          isStreaming = false;
          await controller!.stopImageStream();
          showAlertDialog(
            'Wifi\', \'SSID: ${barcodeWifi.ssid}',
            'Password: ${barcodeWifi.password}\'\n\'Encryption type: ${barcodeWifi.encryptionType}',
            context,
          );

          break;
        case BarcodeType.url:
          final barcodeUrl = barcode.value as BarcodeUrl;
          isStreaming = false;
          await controller!.stopImageStream();
          showAlertDialog(barcodeUrl.title!, barcodeUrl.url!, context);

          break;
        case BarcodeType.contactInfo:
          final barcodeContact = barcode.value as BarcodeContactInfo;
          isStreaming = false;
          await controller!.stopImageStream();
          showAlertDialog(
            'Contact Info',
            'Name : ${barcodeContact.firstName} ${barcodeContact.middleName}  ${barcodeContact.lastName}\nAddress: ${barcodeContact.addresses}\nEmail: ${barcodeContact.emails}\nPhone: ${barcodeContact.phoneNumbers}\nOrganization: ${barcodeContact.organizationName}\'',
            context,
          );
          break;
        case BarcodeType.email:
          final barcodeEmail = barcode.value as BarcodeEmail;
          isStreaming = false;
          await controller!.stopImageStream();
          showAlertDialog(
            barcodeEmail.type.toString(),
            'Subject: ${barcodeEmail.subject}\nBody: ${barcodeEmail.body}\nAddress: ${barcodeEmail.address}',
            context,
          );
          break;
        case BarcodeType.isbn:
          final barcodeIsbn = barcode.value.toString();
          isStreaming = false;
          await controller!.stopImageStream();
          showAlertDialog('Contact Isbn', 'ISBN: $barcodeIsbn', context);
          break;
        case BarcodeType.phone:
          final barcodePhone = barcode.value as BarcodePhone;
          isStreaming = false;
          await controller!.stopImageStream();
          showAlertDialog(
            barcodePhone.type as String,
            barcodePhone.number!,
            context,
          );
          break;
        case BarcodeType.product:
          final barcodeProduct = barcode.value.toString();
          isStreaming = false;
          await controller!.stopImageStream();
          showAlertDialog(
            'Product Details',
            'Details: $barcodeProduct',
            context,
          );
          break;
        case BarcodeType.sms:
          final barcodeSms = barcode.value as BarcodeSMS;
          isStreaming = false;
          await controller!.stopImageStream();
          showAlertDialog(
            barcodeSms.phoneNumber!,
            barcodeSms.message!,
            context,
          );
          break;
        case BarcodeType.text:
          final barcodeText = barcode.value.toString();
          isStreaming = false;
          await controller!.stopImageStream();
          showAlertDialog('Text type barcode', barcodeText, context);
          break;
        case BarcodeType.geoCoordinates:
          final barcodeGC = barcode.value as BarcodeGeoPoint;
          isStreaming = false;
          await controller!.stopImageStream();
          showAlertDialog(
            '$barcodeGC',
            'latitude: ${barcodeGC.latitude.toString()}, longitude: ${barcodeGC.longitude.toString()} ',
            context,
          );
          break;
        case BarcodeType.calendarEvent:
          final barcodeCalenderEvent = barcode.value as BarcodeCalenderEvent;
          isStreaming = false;
          await controller!.stopImageStream();
          showAlertDialog(
            barcodeCalenderEvent.organizer!,
            'Description: ${barcodeCalenderEvent.description}\n Start time: ${barcodeCalenderEvent.start}\n End time: ${barcodeCalenderEvent.end}\n Location: ${barcodeCalenderEvent.location}\n Status: ${barcodeCalenderEvent.status}\n Summary: ${barcodeCalenderEvent.summary}',
            context,
          );
          break;
        case BarcodeType.driverLicense:
          final barcodeDL = barcode.value as BarcodeDriverLicense;
          isStreaming = false;
          await controller!.stopImageStream();
          showAlertDialog('Driving License', 'Details: $barcodeDL', context);
          break;
        case BarcodeType.unknown:
          final barcodeUnknown = barcode.value.toString();
          isStreaming = false;
          await controller!.stopImageStream();
          showAlertDialog(
            'Unknown type barcode',
            'Content: $barcodeUnknown',
            context,
          );
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
      if (isStreaming == true) {
        isStreaming = false;
        controller!.stopImageStream();
      }
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      await _initializeCameraController(cameraController.description);
      isStreaming = true;
      controller!.startImageStream(scan);
    }
  }
  // #enddocregion AppLifecycle

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
            ElevatedButton(
              onPressed: () {
                if (controller != null && !isStreaming) {
                  controller!.startImageStream(scan);
                }
              },
              child: Text('Scan'),
            ),
          ],
        ),
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
        showInSnackBar('No camera found.', context);
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

  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      if (isStreaming == true) {
        isStreaming = false;
        await controller!.stopImageStream();
      }

      await controller!.setDescription(cameraDescription);
      isStreaming = true;
      controller!.startImageStream(scan);
    } else {
      await _initializeCameraController(cameraDescription);
      isStreaming = true;
      controller!.startImageStream(scan);
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

    controller = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (cameraController.value.hasError) {
        showInSnackBar(
          'Camera error ${cameraController.value.errorDescription}',
          context,
        );
      }
    });

    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      switch (e.code) {
        case 'CameraAccessDenied':
          showInSnackBar('You have denied camera access.', context);
        case 'CameraAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar(
            'Please go to Settings app to enable camera access.',
            context,
          );
        case 'CameraAccessRestricted':
          // iOS only
          showInSnackBar('Camera access is restricted.', context);
        case 'AudioAccessDenied':
          showInSnackBar('You have denied audio access.', context);
        case 'AudioAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar(
            'Please go to Settings app to enable audio access.',
            context,
          );
        case 'AudioAccessRestricted':
          // iOS only
          showInSnackBar('Audio access is restricted.', context);
        default:
          showCameraException(e, context);
      }
    }

    if (mounted) {
      setState(() {});
    }
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
    logError(e.code, e.description);
  }
  runApp(const CameraApp());
}
