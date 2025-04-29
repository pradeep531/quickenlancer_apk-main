import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:async';

class KYCVerificationPage extends StatefulWidget {
  const KYCVerificationPage({super.key});

  @override
  _KYCVerificationPageState createState() => _KYCVerificationPageState();
}

class _KYCVerificationPageState extends State<KYCVerificationPage> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  String? _firstName,
      _lastName,
      _email,
      _gender,
      _mobileNumber,
      _country,
      _state,
      _city,
      _address,
      _idProofName,
      _idProofNumber;
  File? _idProofFile; // Changed from String? to File?
  String? _idProofFileError; // To store file-related errors
  CameraController? _cameraController;
  VideoPlayerController? _videoPlayerController;
  bool _isRecording = false;
  XFile? _recordedVideo;
  Timer? _timer;
  int _recordingSeconds = 0;
  String? _cameraError;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      CameraDescription? frontCamera;
      try {
        frontCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
        );
      } catch (_) {
        setState(() => _cameraError = 'No front camera available');
        return;
      }

      if (frontCamera != null) {
        _cameraController =
            CameraController(frontCamera, ResolutionPreset.medium);
        await _cameraController!.initialize();
        if (mounted) setState(() {});
      }
    } catch (e) {
      setState(() => _cameraError = 'Camera initialization error: $e');
    }
  }

  void _startRecording() async {
    if (_cameraController?.value.isInitialized ?? false) {
      try {
        await _cameraController!.startVideoRecording();
        setState(() {
          _isRecording = true;
          _recordingSeconds = 0;
        });
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() => _recordingSeconds++);
        });
      } catch (e) {
        print('Error starting recording: $e');
      }
    }
  }

  void _stopRecording() async {
    if (_cameraController?.value.isRecordingVideo ?? false) {
      try {
        _recordedVideo = await _cameraController!.stopVideoRecording();
        _timer?.cancel();
        await _cameraController!.dispose();
        _cameraController = null;
        await _initializeVideoPlayer();
        setState(() => _isRecording = false);
      } catch (e) {
        print('Error stopping recording: $e');
      }
    }
  }

  Future<void> _initializeVideoPlayer() async {
    if (_recordedVideo != null) {
      try {
        _videoPlayerController =
            VideoPlayerController.file(File(_recordedVideo!.path));
        await _videoPlayerController!.initialize();
        setState(() {});
      } catch (e) {
        setState(() {
          _cameraError = 'Error loading video: $e';
        });
      }
    }
  }

  void _reRecord() async {
    await _videoPlayerController?.dispose();
    _videoPlayerController = null;
    _recordedVideo = null;
    _cameraError = null;
    await _initializeCamera();
    setState(() {});
  }

  Future<void> _pickIdProofFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        // Validate file size (< 100KB)
        final fileSize = await file.length();
        if (fileSize > 100 * 1024) {
          setState(() {
            _idProofFileError = 'File size exceeds 100KB';
            _idProofFile = null;
          });
          return;
        }
        setState(() {
          _idProofFile = file;
          _idProofFileError = null;
        });
      } else {
        setState(() {
          _idProofFileError = 'No file selected';
          _idProofFile = null;
        });
      }
    } catch (e) {
      setState(() {
        _idProofFileError = 'Error selecting file: $e';
        _idProofFile = null;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cameraController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      if (_currentStep == 0 && _formKey.currentState!.validate()) {
        _formKey.currentState!.save();
      }
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primaryColor: Colors.blue,
        colorScheme: const ColorScheme.light(
            primary: Colors.blue, secondary: Colors.teal),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('KYC Verification',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                [
                  'Personal Information',
                  'ID Proof Details',
                  'Video Verification',
                  'Payment Confirmation'
                ][_currentStep],
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Stepper(
                  type: StepperType.horizontal,
                  currentStep: _currentStep,
                  onStepContinue: _nextStep,
                  onStepCancel: _previousStep,
                  physics: const ClampingScrollPhysics(),
                  controlsBuilder: (context, details) => Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_currentStep > 0)
                          TextButton(
                            onPressed: details.onStepCancel,
                            child: const Text('Back',
                                style: TextStyle(color: Colors.blue)),
                          )
                        else
                          const SizedBox(),
                        ElevatedButton(
                          onPressed: details.onStepContinue,
                          child: Text(_currentStep < 3 ? 'Next' : 'Submit'),
                        ),
                      ],
                    ),
                  ),
                  steps: [
                    Step(
                      title: const Text(''),
                      isActive: _currentStep >= 0,
                      state: _currentStep > 0
                          ? StepState.complete
                          : StepState.indexed,
                      content: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            ...[
                              'First Name',
                              'Last Name',
                              'Email',
                              'Gender',
                              'Mobile Number',
                              'Country',
                              'State',
                              'City',
                              'Address'
                            ].map(
                              (label) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildTextField(
                                  label: label,
                                  onSaved: (value) {
                                    if (label == 'First Name')
                                      _firstName = value;
                                    else if (label == 'Last Name')
                                      _lastName = value;
                                    else if (label == 'Email')
                                      _email = value;
                                    else if (label == 'Gender')
                                      _gender = value;
                                    else if (label == 'Mobile Number')
                                      _mobileNumber = value;
                                    else if (label == 'Country')
                                      _country = value;
                                    else if (label == 'State')
                                      _state = value;
                                    else if (label == 'City')
                                      _city = value;
                                    else if (label == 'Address')
                                      _address = value;
                                  },
                                  validator: (value) =>
                                      value!.isEmpty ? 'Required' : null,
                                  keyboardType: label == 'Email'
                                      ? TextInputType.emailAddress
                                      : label == 'Mobile Number'
                                          ? TextInputType.phone
                                          : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Step(
                      title: const Text(''),
                      isActive: _currentStep >= 1,
                      state: _currentStep > 1
                          ? StepState.complete
                          : StepState.indexed,
                      content: Column(
                        children: [
                          _buildTextField(
                            label: 'ID Proof Name',
                            onChanged: (value) => _idProofName = value,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            label: 'ID Proof Number',
                            onChanged: (value) => _idProofNumber = value,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: _idProofFileError != null
                                      ? Text(
                                          _idProofFileError!,
                                          style: const TextStyle(
                                              color: Colors.red),
                                        )
                                      : _idProofFile != null
                                          ? Text(
                                              _idProofFile!.path
                                                  .split('/')
                                                  .last,
                                              style: const TextStyle(
                                                  color: Colors.black),
                                            )
                                          : const Text(
                                              'No file chosen',
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: _pickIdProofFile,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal),
                                child: const Text('Upload'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Image size < 100KB (JPG, JPEG, PNG)',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          if (_idProofFile != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Container(
                                height: 100,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _idProofFile!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Text(
                                          'Invalid image data',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Step(
                      title: const Text(''),
                      isActive: _currentStep >= 2,
                      state: _currentStep > 2
                          ? StepState.complete
                          : StepState.indexed,
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Record Verification',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 12),
                          if (_cameraError != null)
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  _cameraError!,
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          else if (_recordedVideo != null &&
                              _videoPlayerController != null)
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: VideoPlayer(_videoPlayerController!),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    _videoPlayerController!.value.isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 48,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _videoPlayerController!.value.isPlaying
                                          ? _videoPlayerController!.pause()
                                          : _videoPlayerController!.play();
                                    });
                                  },
                                ),
                              ],
                            )
                          else if (_cameraController?.value.isInitialized ??
                              false)
                            Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CameraPreview(_cameraController!),
                                  ),
                                ),
                                if (_isRecording)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        _formatDuration(_recordingSeconds),
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          const SizedBox(height: 12),
                          Center(
                            child: _recordedVideo != null
                                ? ElevatedButton(
                                    onPressed: _reRecord,
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue),
                                    child: const Text('Re-Record'),
                                  )
                                : ElevatedButton.icon(
                                    onPressed: _cameraError != null
                                        ? null
                                        : (_isRecording
                                            ? _stopRecording
                                            : _startRecording),
                                    icon: Icon(
                                        _isRecording
                                            ? Icons.stop
                                            : Icons.videocam,
                                        size: 20),
                                    label:
                                        Text(_isRecording ? 'Stop' : 'Record'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _isRecording
                                          ? Colors.red
                                          : Colors.blue,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    Step(
                      title: const Text(''),
                      isActive: _currentStep >= 3,
                      state: StepState.indexed,
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('₹1',
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue)),
                          const SizedBox(height: 12),
                          const Text('Confirm Payment',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          const Text(
                              'Complete KYC with a nominal payment for secure verification.',
                              style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 16),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green),
                              child: const Text('Pay Now'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    Function(String?)? onChanged,
    Function(String?)? onSaved,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      decoration: InputDecoration(
          labelText: label, labelStyle: const TextStyle(fontSize: 14)),
      onChanged: onChanged,
      onSaved: onSaved,
      validator: validator,
      keyboardType: keyboardType,
    );
  }
}
