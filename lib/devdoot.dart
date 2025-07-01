import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void showInSnackBar(String message, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

// Utilities
void logError(String code, String? message) {
  if (kDebugMode) {
    print('Error: $code${message == null ? '' : '\nError Message: $message'}');
  }
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

void showCameraException(CameraException e, BuildContext context) {
  logError(e.code, e.description);
  showInSnackBar('Error: ${e.code}\n${e.description}', context);
}

// This function is triggered when the user presses the button
showAlertDialog(String title, String content, BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              // Closes the dialog
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
