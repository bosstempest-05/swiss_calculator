import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

class VaultCamera extends StatefulWidget {
  const VaultCamera({super.key});

  @override
  State<VaultCamera> createState() => _VaultCameraState();
}

class _VaultCameraState extends State<VaultCamera> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isReady = false;
  int _selectedCameraIndex = 0;

  // ---> NEW: Zoom Control Variables <---
  double _currentZoom = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 1.0;

  // ---> NEW: Aspect Ratio Variables <---
  int _aspectRatioIndex = 0;
  final List<double> _aspectRatios = [3 / 4, 9 / 16, 1.0];
  final List<String> _aspectRatioLabels = ['3:4', '9:16', '1:1'];

  @override
  void initState() {
    super.initState();
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _initCameraController(_cameras![_selectedCameraIndex]);
      }
    } catch (e) {
      debugPrint("Camera error: $e");
    }
  }

  Future<void> _initCameraController(
    CameraDescription cameraDescription,
  ) async {
    if (_controller != null) {
      await _controller!.dispose();
    }

    _controller = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();

      // ---> NEW: Fetch the phone's hardware zoom limits <---
      _minZoom = await _controller!.getMinZoomLevel();
      _maxZoom = await _controller!.getMaxZoomLevel();
      _currentZoom = 1.0; // Reset zoom when switching cameras

      if (mounted) {
        setState(() => _isReady = true);
      }
    } catch (e) {
      debugPrint("Camera init error: $e");
    }
  }

  void _switchCamera() {
    if (_cameras == null || _cameras!.length < 2) return;
    _selectedCameraIndex = _selectedCameraIndex == 0 ? 1 : 0;
    setState(() => _isReady = false);
    _initCameraController(_cameras![_selectedCameraIndex]);
  }

  // ---> NEW: Cycle through aspect ratios <---
  void _toggleAspectRatio() {
    setState(() {
      _aspectRatioIndex = (_aspectRatioIndex + 1) % _aspectRatios.length;
    });
  }

  // ---> NEW: Handle Zoom Slider <---
  void _onZoomChanged(double value) {
    setState(() {
      _currentZoom = value;
      _controller?.setZoomLevel(value);
    });
  }

  Future<void> _takePicture() async {
    if (!_controller!.value.isInitialized ||
        _controller!.value.isTakingPicture) {
      return;
    }

    try {
      final XFile photo = await _controller!.takePicture();

      final directory = await getApplicationDocumentsDirectory();
      final vaultDir = Directory('${directory.path}/vault_images');

      if (!await vaultDir.exists()) {
        await vaultDir.create();
      }

      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File savedImage = File('${vaultDir.path}/$fileName');
      await File(photo.path).copy(savedImage.path);

      await File(photo.path).delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Photo saved to Private Gallery',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.tealAccent,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint("Take picture error: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine light mode to adapt icons, but keep background black for letterboxing!
    bool isLightMode = Theme.of(context).brightness == Brightness.light;
    Color iconColor = isLightMode
        ? Colors.white
        : Colors.white; // Kept white for contrast against the camera feed

    return Theme(
      // We force a black scaffold so the camera letterboxing always looks clean
      data: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: iconColor),
          title: GestureDetector(
            onTap: _toggleAspectRatio,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white30),
              ),
              child: Text(
                _aspectRatioLabels[_aspectRatioIndex],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.flip_camera_ios, color: iconColor, size: 28),
              onPressed: _switchCamera,
            ),
            const SizedBox(width: 8),
          ],
        ),
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            // Camera Viewport wrapped in an AspectRatio and centered!
            if (_isReady && _controller != null)
              Center(
                child: AspectRatio(
                  aspectRatio: _aspectRatios[_aspectRatioIndex],
                  child: ClipRect(child: CameraPreview(_controller!)),
                ),
              )
            else
              const Center(
                child: CircularProgressIndicator(color: Colors.tealAccent),
              ),

            // Bottom Controls Area
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.only(bottom: 40.0, top: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ---> NEW: Zoom Slider <---
                    if (_isReady)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.zoom_out,
                              color: Colors.white,
                              size: 20,
                            ),
                            Expanded(
                              child: Slider(
                                value: _currentZoom,
                                min: _minZoom,
                                max: _maxZoom,
                                activeColor: Colors.tealAccent,
                                inactiveColor: Colors.white30,
                                onChanged: _onZoomChanged,
                              ),
                            ),
                            const Icon(
                              Icons.zoom_in,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),

                    // The Shutter Button
                    GestureDetector(
                      onTap: _takePicture,
                      child: Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          color: Colors.white.withOpacity(0.2),
                        ),
                        child: Center(
                          child: Container(
                            height: 60,
                            width: 60,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
