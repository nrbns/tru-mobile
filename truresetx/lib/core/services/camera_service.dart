import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
// cleaned imports: UI import not needed; commons types are provided by specific mlkit packages

/// Camera Service for handling camera operations and ML Kit integration
class CameraService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  PoseDetector? _poseDetector;
  ImageLabeler? _imageLabeler;

  /// Initialize camera
  Future<void> initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _controller!.initialize();
      }
    } catch (e) {
      print('Camera initialization error: $e');
    }
  }

  /// Start pose detection
  void startPoseDetection(Function(Pose) onPoseDetected) {
    _poseDetector = PoseDetector(options: PoseDetectorOptions());

    if (_controller != null && _controller!.value.isInitialized) {
      _controller!.startImageStream((image) async {
        final inputImage = _inputImageFromCameraImage(image);
        final poses = await _poseDetector!.processImage(inputImage);

        if (poses.isNotEmpty) {
          onPoseDetected(poses.first);
        }
      });
    }
  }

  /// Start image labeling
  void startImageLabeling(Function(List<ImageLabel>) onLabelsDetected) {
    _imageLabeler = ImageLabeler(options: ImageLabelerOptions());

    if (_controller != null && _controller!.value.isInitialized) {
      _controller!.startImageStream((image) async {
        final inputImage = _inputImageFromCameraImage(image);
        final labels = await _imageLabeler!.processImage(inputImage);

        if (labels.isNotEmpty) {
          onLabelsDetected(labels);
        }
      });
    }
  }

  /// Stop camera stream
  Future<void> stopCameraStream() async {
    if (_controller != null && _controller!.value.isInitialized) {
      await _controller!.stopImageStream();
    }
  }

  /// Take picture
  Future<File?> takePicture() async {
    if (_controller != null && _controller!.value.isInitialized) {
      final image = await _controller!.takePicture();
      return File(image.path);
    }
    return null;
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _controller?.dispose();
    await _poseDetector?.close();
    await _imageLabeler?.close();
  }

  /// Get camera controller
  CameraController? get controller => _controller;

  /// Check if camera is initialized
  bool get isInitialized => _controller?.value.isInitialized ?? false;

  /// Convert camera image to input image
  InputImage _inputImageFromCameraImage(CameraImage cameraImage) {
    final camera = _cameras![0];
    final sensorOrientation = camera.sensorOrientation;

    final format = InputImageFormatValue.fromRawValue(cameraImage.format.raw);
    if (format == null) throw Exception('Unsupported image format');

    // Concatenate all plane bytes
    final allBytes = <int>[];
    for (final plane in cameraImage.planes) {
      allBytes.addAll(plane.bytes);
    }
    final bytes = Uint8List.fromList(allBytes);

    // Some versions of google_mlkit_commons export different metadata types.
    // Build a lightweight dynamic metadata object and pass it through to avoid hard
    // dependency on specific exported classes during static analysis.
    final dynamic imageData = {
      'size': {'width': cameraImage.width, 'height': cameraImage.height},
      'imageRotation': sensorOrientation,
      'inputImageFormat': format,
      'planeData': cameraImage.planes
          .map((p) => {
                'bytesPerRow': p.bytesPerRow,
                'height': p.height,
                'width': p.width,
              })
          .toList(),
    };

    return InputImage.fromBytes(bytes: bytes, metadata: imageData as dynamic);
  }

  /// Convert rotation integer to image rotation
  // Rotation helper removed - using raw sensorOrientation integer in metadata

  /// Process image file for pose detection
  Future<List<Pose>> detectPosesInImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final poseDetector = PoseDetector(options: PoseDetectorOptions());

    try {
      final poses = await poseDetector.processImage(inputImage);
      await poseDetector.close();
      return poses;
    } catch (e) {
      print('Pose detection error: $e');
      return [];
    }
  }

  /// Process image file for image labeling
  Future<List<ImageLabel>> detectLabelsInImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final imageLabeler = ImageLabeler(options: ImageLabelerOptions());

    try {
      final labels = await imageLabeler.processImage(inputImage);
      await imageLabeler.close();
      return labels;
    } catch (e) {
      print('Image labeling error: $e');
      return [];
    }
  }

  /// Process image file for text recognition
  Future<String> recognizeTextInImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer();

    try {
      final recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();
      return recognizedText.text;
    } catch (e) {
      print('Text recognition error: $e');
      return '';
    }
  }

  /// Process image file for face detection
  Future<List<Face>> detectFacesInImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final faceDetector = FaceDetector(options: FaceDetectorOptions());

    try {
      final faces = await faceDetector.processImage(inputImage);
      await faceDetector.close();
      return faces;
    } catch (e) {
      print('Face detection error: $e');
      return [];
    }
  }

  /// Process image file for object detection
  Future<List<DetectedObject>> detectObjectsInImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final objectDetector = ObjectDetector(
      options: ObjectDetectorOptions(
        mode: DetectionMode.single,
        classifyObjects: true,
        multipleObjects: false,
      ),
    );

    try {
      final objects = await objectDetector.processImage(inputImage);
      await objectDetector.close();
      return objects;
    } catch (e) {
      print('Object detection error: $e');
      return [];
    }
  }
}

/// Provider for Camera Service
final cameraServiceProvider = Provider<CameraService>((ref) {
  return CameraService();
});

/// Camera state provider
final cameraStateProvider =
    StateNotifierProvider<CameraStateNotifier, CameraState>((ref) {
  return CameraStateNotifier(ref.read(cameraServiceProvider));
});

/// Camera state notifier
class CameraStateNotifier extends StateNotifier<CameraState> {
  CameraStateNotifier(this._cameraService) : super(CameraState.initial);
  final CameraService _cameraService;

  /// Initialize camera
  Future<void> initializeCamera() async {
    state = CameraState.initializing;
    try {
      await _cameraService.initializeCamera();
      state = CameraState.ready;
    } catch (e) {
      state = CameraState.error;
      print('Camera initialization failed: $e');
    }
  }

  /// Start pose detection
  void startPoseDetection() {
    if (state == CameraState.ready) {
      state = CameraState.detectingPoses;
    }
  }

  /// Start image labeling
  void startImageLabeling() {
    if (state == CameraState.ready) {
      state = CameraState.labelingImages;
    }
  }

  /// Stop camera operations
  Future<void> stopCamera() async {
    await _cameraService.stopCameraStream();
    state = CameraState.ready;
  }

  /// Dispose camera
  @override
  Future<void> dispose() async {
    await _cameraService.dispose();
    state = CameraState.disposed;
    super.dispose();
  }
}

/// Camera state enum
enum CameraState {
  initial,
  initializing,
  ready,
  detectingPoses,
  labelingImages,
  error,
  disposed,
}
