import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

/// Converts a [CameraImage] from `yuv420` format to `NV21` format.
///
/// This is useful for passing image data to certain native libraries that
/// expect the NV21 format. This version is updated for `camera` package >= 0.10.0.
///
/// [cameraImage] The image to convert, which must be in `yuv420` format.
///
/// Returns a `Uint8List` containing the image data in `NV21` format,
/// or `null` if the image format is not `yuv420`.
Uint8List? convertYUV420toNV21(CameraImage cameraImage) {
  // 1. Check the image format.
  if (cameraImage.format.group != ImageFormatGroup.yuv420) {
    debugPrint('Error: Image format is not YUV420');
    return null;
  }

  // 2. Get image dimensions.
  final int width = cameraImage.width;
  final int height = cameraImage.height;

  // 3. Unpack the planes.
  final Plane yPlane = cameraImage.planes[0];
  final Plane uPlane = cameraImage.planes[1];
  final Plane vPlane = cameraImage.planes[2];

  // 4. Allocate the buffer for the NV21 data.
  final int ySize = width * height;
  final int uvSize = (width * height) ~/ 2;
  final Uint8List nv21Bytes = Uint8List(ySize + uvSize);

  // 5. Copy the Y (luminance) plane.
  // This part is the same as before.
  int yIndex = 0;
  for (int i = 0; i < height; i++) {
    nv21Bytes.setRange(
      yIndex,
      yIndex + width,
      yPlane.bytes,
      i * yPlane.bytesPerRow,
    );
    yIndex += width;
  }

  // 6. Copy the interleaved V and U (chrominance) planes.
  final int uvWidth = width ~/ 2;
  final int uvHeight = height ~/ 2;

  final int uRowStride = uPlane.bytesPerRow;
  final int vRowStride = vPlane.bytesPerRow;
  final int uBytesPerPixel = uPlane.bytesPerPixel!;
  final int vBytesPerPixel = vPlane.bytesPerPixel!;

  int uvIndex = ySize; // Start writing VU data after the Y data.

  for (int i = 0; i < uvHeight; i++) {
    for (int j = 0; j < uvWidth; j++) {
      // Calculate the index for the V and U pixels in their respective planes.
      // The logic is the same, just using the new property name.
      final int vIndex = i * vRowStride + j * vBytesPerPixel;
      final int uIndex = i * uRowStride + j * uBytesPerPixel;

      // For NV21, the order is V, then U.
      if (vIndex < vPlane.bytes.length && uIndex < uPlane.bytes.length) {
        nv21Bytes[uvIndex++] = vPlane.bytes[vIndex]; // V
        nv21Bytes[uvIndex++] = uPlane.bytes[uIndex]; // U
      }
    }
  }

  return nv21Bytes;
}

// This is a crucial conversion function
InputImage? inputImageFromCameraImage(
  CameraImage image,
  CameraController? controller,
) {
  final Uint8List nv21Bytes = convertYUV420toNV21(image)!;

  final camera = controller!.description;
  final sensorOrientation = camera.sensorOrientation;

  // Get image rotation
  // This is calculated based on the device orientation and sensor orientation
  // For most devices, this will be 90.
  final rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
  if (rotation == null) return null;

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
