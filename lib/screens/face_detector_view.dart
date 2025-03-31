import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test_version/core/utils/utils.dart';
import 'package:flutter_test_version/painters/face_detector_painter.dart';
import 'package:flutter_test_version/vision_detector_views/detector_view.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'package:image/image.dart' as img;

class FaceDetectorView extends StatefulWidget {
  @override
  State<FaceDetectorView> createState() => _FaceDetectorViewState();
}

class _FaceDetectorViewState extends State<FaceDetectorView> {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(enableContours: true, enableLandmarks: true),
  );
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.front;
  String faceText = '';

  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DetectorView(
      title: 'Face Detector',
      customPaint: _customPaint,
      text: _text,
      onImage: _processImage,
      initialCameraLensDirection: _cameraLensDirection,
      onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
      faceText: faceText,
      expectStateText: _expectedStatesQueue.isNotEmpty ? _expectedStatesQueue.first : '',
    );
  }

  // Future<void> _processImage(InputImage inputImage) async {
  //   if (!_canProcess) return;
  //   if (_isBusy) return;
  //   _isBusy = true;
  //   setState(() {
  //     _text = '';
  //   });

  //   final double uncomputedProb = -1.0;
  //   final int uncompProb = -1;

  //   final faces = await _faceDetector.processImage(inputImage);
  //   if (inputImage.metadata?.size != null && inputImage.metadata?.rotation != null) {
  //     final painter = FaceDetectorPainter(
  //       faces,
  //       inputImage.metadata!.size,
  //       inputImage.metadata!.rotation,
  //       _cameraLensDirection,
  //     );
  //     _customPaint = CustomPaint(painter: painter);
  //   } else {
  //     String text = 'Faces found: ${faces.length}\n\n';
  //     for (final face in faces) {
  //       // Bounding Box
  //       text += 'Face Bounding Box: ${face.boundingBox}\n';

  //       // ตรวจสอบการยิ้ม
  //       if (face.smilingProbability != null) {
  //         text += 'Smile Probability: ${face.smilingProbability!.toStringAsFixed(2)}\n';
  //       }

  //       // ตรวจสอบการลืมตา
  //       if (face.rightEyeOpenProbability != null) {
  //         text +=
  //             'Right Eye Open Probability: ${face.rightEyeOpenProbability!.toStringAsFixed(2)}\n';
  //       }
  //       if (face.leftEyeOpenProbability != null) {
  //         text += 'Left Eye Open Probability: ${face.leftEyeOpenProbability!.toStringAsFixed(2)}\n';
  //       }

  //       // ตรวจสอบ Landmark: หูซ้าย
  //       final leftEar = face.landmarks[FaceLandmarkType.leftEar];
  //       if (leftEar != null) {
  //         text += 'Left Ear Position: (${leftEar.position.x}, ${leftEar.position.y})\n';
  //       }

  //       // ตรวจสอบ Tracking ID
  //       if (face.trackingId != null) {
  //         text += 'Tracking ID: ${face.trackingId}\n';
  //       }

  //       text += '\n'; // แบ่งข้อมูลใบหน้าแต่ละใบด้วยบรรทัดว่าง
  //     }
  //     _text = text;
  //     // TODO: set _customPaint to draw boundingRect on top of image
  //     _customPaint = null;
  //   }
  //   _isBusy = false;
  //   if (mounted) {
  //     setState(() {});
  //   }
  // }

  int _stateDuration = 0; // Counter for time in milliseconds
  bool _stateConfirmed = false; // Flag to confirm state after 5 seconds
  Timer? _stateTimer; // Timer for tracking duration

  final List<String> _expectedStatesQueue = ["TURN_LEFT", "TURN_RIGHT", "LOOK_STRAIGHT"];

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess || _isBusy) return;
    _isBusy = true;

    setState(() {
      _text = '';
    });

    final faces = await _faceDetector.processImage(inputImage);

    print('MyFace is ${faces.length}');

    int livenessStatus = -1;

    if (faces.isEmpty) {
      livenessStatus = 1; // Face not found
    } else if (faces.length > 1) {
      livenessStatus = 11; // Multiple faces
    } else {
      final face = faces[0];

      print('Bounding Box: ${face.boundingBox}');
      print('Smiling Probability: ${face.smilingProbability}');
      print('Left Eye Open Probability: ${face.leftEyeOpenProbability}');
      print('Right Eye Open Probability: ${face.rightEyeOpenProbability}');
      print('Head Euler Angle X (Pitch): ${face.headEulerAngleX}');
      print('Head Euler Angle Y (Yaw): ${face.headEulerAngleY}');
      print('Head Euler Angle Z (Roll): ${face.headEulerAngleZ}');
      print('Tracking ID: ${face.trackingId}');

      // ตรวจสอบว่ามี Landmark ใดบ้าง
      for (var entry in face.landmarks.entries) {
        print(
          'Landmark: ${entry.key}, Position: (${entry.value?.position.x}, ${entry.value?.position.y})',
        );
      }

      bool hasLeftEye = face.landmarks.containsKey(FaceLandmarkType.leftEye);
      bool hasRightEye = face.landmarks.containsKey(FaceLandmarkType.rightEye);
      bool hasNose = face.landmarks.containsKey(FaceLandmarkType.noseBase);
      bool hasLeftEar = face.landmarks.containsKey(FaceLandmarkType.leftEar);
      bool hasRightEar = face.landmarks.containsKey(FaceLandmarkType.rightEar);

      if (!hasLeftEye) {
        print("❌ No left eye detected");
      }

      if (!hasRightEye) {
        print("❌ No right eye detected");
      }

      if (!hasNose) {
        print("❌ No nose detected");
      }

      if (!hasLeftEar) {
        print("❌ No left ear detected");
      }

      if (!hasRightEar) {
        print("❌ No right ear detected");
      }

      if (hasLeftEye && hasRightEye && hasNose && hasLeftEar && hasRightEar) {
        print("✅ All key facial landmarks detected");
      }

      if (isFaceCovered(face)) {
        livenessStatus = 21; // Face is covered
      }

      // Face Orientation Check
      final pitch = face.headEulerAngleX ?? 0.0;
      final yaw = face.headEulerAngleY ?? 0.0;
      final roll = face.headEulerAngleZ ?? 0.0;

      if (yaw != null) {
        if (yaw > 15) {
          livenessStatus = 14; // Turn right
        } else if (yaw < -15) {
          livenessStatus = 13; // Turn left
        }
      }

      if (pitch != null && livenessStatus == -1) {
        if (pitch.abs() > 10) {
          livenessStatus = 2; // Not looking straight
        }
      }

      if (roll != null && livenessStatus == -1) {
        if (roll.abs() > 15) {
          livenessStatus = 2; // Not looking straight
        }
      }

      // Check facial landmarks (Eyes and Mouth)
      if (face.landmarks.isNotEmpty && livenessStatus == -1) {
        if (!face.landmarks.containsKey(FaceLandmarkType.leftEye)) {
          livenessStatus = 8; // No left eye
        }
        if (!face.landmarks.containsKey(FaceLandmarkType.rightEye)) {
          livenessStatus = 9; // No right eye
        }
        if (!face.landmarks.containsKey(FaceLandmarkType.bottomMouth) &&
            !face.landmarks.containsKey(FaceLandmarkType.leftMouth) &&
            !face.landmarks.containsKey(FaceLandmarkType.rightMouth)) {
          livenessStatus = 7; // No mouth
        }
      }

      // Check smiling probability
      if (face.smilingProbability != null) {
        if (face.smilingProbability! > 0.5) {
          livenessStatus = 16; // Smile detected
        }
      }

      // Check eye openness for blink detection
      if (face.leftEyeOpenProbability != null &&
          face.rightEyeOpenProbability != null &&
          livenessStatus == -1) {
        if (face.leftEyeOpenProbability! < 0.5 && face.rightEyeOpenProbability! < 0.5) {
          livenessStatus = 17; // Blink detected
        }
      }

      // Additional Liveness Detection Cases:

      // No face detected
      if (faces.isEmpty && livenessStatus == -1) {
        livenessStatus = 1; // Face not found
      }

      // Adding extra conditions to check for an extreme head tilt (pitch, roll, yaw combination)
      if (pitch != null && roll != null && yaw != null && livenessStatus == -1) {
        if (pitch.abs() > 20 || roll.abs() > 20 || yaw.abs() > 30) {
          livenessStatus = 20; // Extreme head tilt detected
        }
      }

      // Check eye openness for blink detection (considering glasses)
      if (face.leftEyeOpenProbability != null &&
          face.rightEyeOpenProbability != null &&
          livenessStatus == -1) {
        double leftEyeProb = face.leftEyeOpenProbability!;
        double rightEyeProb = face.rightEyeOpenProbability!;

        // Allow lower probability when glasses are detected
        bool isWearingGlasses = leftEyeProb < 0.3 && rightEyeProb < 0.3;
        bool eyesClosed = leftEyeProb < 0.5 && rightEyeProb < 0.5;

        if (isWearingGlasses) {
          livenessStatus = 18; // Glasses detected
        } else if (eyesClosed) {
          livenessStatus = 17; // Blink detected
        }
      }

      // Check if face landmarks are blocked or partially visible (gap or occlusion)
      if (face.landmarks.isNotEmpty && livenessStatus == -1) {
        bool leftEyeVisible = face.landmarks.containsKey(FaceLandmarkType.leftEye);
        bool rightEyeVisible = face.landmarks.containsKey(FaceLandmarkType.rightEye);
        bool mouthVisible =
            face.landmarks.containsKey(FaceLandmarkType.bottomMouth) ||
            face.landmarks.containsKey(FaceLandmarkType.leftMouth) ||
            face.landmarks.containsKey(FaceLandmarkType.rightMouth);

        if (!leftEyeVisible && !rightEyeVisible) {
          livenessStatus = 19; // Eyes not visible
        } else if (!mouthVisible) {
          livenessStatus = 7; // No mouth
        }
      }

      const double tolerance = 5.0; // กำหนดขอบเขตว่าค่ามุมเอียงได้แค่ไหน

      if (pitch.abs() <= tolerance && yaw.abs() <= tolerance && roll.abs() <= tolerance) {
        livenessStatus = 0; //  Look straight
      }

      // If no issue found, mark as looking straight
      if (livenessStatus == -1) {
        livenessStatus = 22; // N/A
      }

      // Get the current expected state
      String currentExpectedState = _expectedStatesQueue.first;

      bool isStateCorrect =
          (currentExpectedState == "TURN_LEFT" && livenessStatus == 13) ||
          (currentExpectedState == "TURN_RIGHT" && livenessStatus == 14) ||
          (currentExpectedState == "LOOK_STRAIGHT" && livenessStatus == 0);

      if (isStateCorrect) {
        if (!_stateConfirmed) {
          if (_stateTimer == null) {
            print("⏳ Holding $currentExpectedState for 2 seconds...");
            _stateTimer = Timer.periodic(Duration(seconds: 1), (timer) {
              _stateDuration += 1000;
              print("✅ Holding for ${_stateDuration ~/ 1000}s");

              if (_stateDuration >= 2000) {
                // Hold for 2 seconds
                _stateConfirmed = true;
                print("✅ State $currentExpectedState confirmed! Moving to next state...");
                _stateTimer?.cancel();
                _stateTimer = null;
                _stateDuration = 0;

                // Remove the confirmed state from the queue
                _expectedStatesQueue.removeAt(0);

                // If all states are completed, capture the image and show success dialog
                if (_expectedStatesQueue.isEmpty) {
                  print("🎉 All states completed!");

                  final image = decodeYUV420SP(inputImage);
                  _showImageDialog(context, image);
                } else {
                  print("➡️ Next expected state: ${_expectedStatesQueue.first}");
                }
              }
            });
          }
        }
      } else {
        _stateTimer?.cancel();
        _stateTimer = null;
        _stateDuration = 0;
        _stateConfirmed = false;
      }
    }

    _text = 'Liveness Status: $livenessStatus\nMessage: ${getLivenessMessage(livenessStatus)}';
    faceText = getLivenessMessage(livenessStatus);

    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }

  String getLivenessMessage(int statusCode) {
    switch (statusCode) {
      case -1:
        return '';
      case 0:
        return 'Look Straight';
      case 1:
        return 'Face not found';
      case 2:
        return 'Look Straight';
      case 3:
        return 'Too dark';
      case 4:
        return 'Too bright';
      case 5:
        return 'Too close';
      case 6:
        return 'Too far';
      case 7:
        return 'No mouth';
      case 8:
        return 'No left eyes';
      case 9:
        return 'No right eyes';
      case 10:
        return 'No eyes';
      case 11:
        return 'Multiple faces';
      case 12:
        return 'Background is bright';
      case 13:
        return 'Turn left';
      case 14:
        return 'Turn right';
      case 15:
        return 'Blink';
      case 16:
        return 'Smile';
      case 17:
        return 'Nod';
      case 18:
        return 'Close mouth';
      case 19:
        return 'Change background';
      case 20:
        return 'Face not center';
      case 21:
        return 'Face is covered';
      default:
        return 'N/A';
    }
  }

  // Convert the YUV data to an image
  // Flutter widget to show image
  void _showImageDialog(BuildContext context, img.Image? image) {
    if (image == null) {
      print('No image to display');
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          child: Container(
            width: 400,
            height: 400,
            child: Center(child: Image.memory(Uint8List.fromList(img.encodeJpg(image)))),
          ),
        );
      },
    );
  }

  bool isFaceCovered(Face face) {
    // ตรวจสอบว่าจำนวน Landmark น้อยเกินไปหรือไม่
    if (face.landmarks.length < 5) {
      print("❗ Face might be covered: Too few landmarks detected.");
      return true;
    }

    // ตรวจสอบว่า Landmark สำคัญหายไปหรือไม่
    bool hasLeftEye = face.landmarks.values.any(
      (landmark) => landmark?.type == FaceLandmarkType.leftEye,
    );
    bool hasRightEye = face.landmarks.values.any(
      (landmark) => landmark?.type == FaceLandmarkType.rightEye,
    );
    bool hasNose = face.landmarks.values.any(
      (landmark) => landmark?.type == FaceLandmarkType.noseBase,
    );
    bool hasMouth = face.landmarks.values.any(
      (landmark) =>
          landmark?.type == FaceLandmarkType.bottomMouth ||
          landmark?.type == FaceLandmarkType.leftMouth ||
          landmark?.type == FaceLandmarkType.rightMouth,
    );

    if (!hasLeftEye || !hasRightEye || !hasNose || !hasMouth) {
      print("❗ Face might be covered: Missing essential landmarks.");
      return true;
    }

    // ตรวจสอบความน่าจะเป็นของดวงตาที่เปิด
    double leftEyeOpenProb = face.leftEyeOpenProbability ?? 0.0;
    double rightEyeOpenProb = face.rightEyeOpenProbability ?? 0.0;

    if (leftEyeOpenProb < 0.2 && rightEyeOpenProb < 0.2) {
      print("❗ Face might be covered: Low eye openness probability.");
      return true;
    }

    // ตรวจสอบขนาด Bounding Box ว่าครอบคลุมตำแหน่ง Landmark หรือไม่
    Rect boundingBox = face.boundingBox;
    for (var entry in face.landmarks.entries) {
      final position = entry.value?.position;
      if (position != null &&
          !boundingBox.contains(Offset(position.x.toDouble(), position.y.toDouble()))) {
        print("❗ Face might be covered: Landmark outside bounding box.");
        return true;
      }
    }

    print("Face is not covered.");
    return false;
  }
}
