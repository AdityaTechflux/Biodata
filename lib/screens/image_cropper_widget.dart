import 'dart:io';
import 'dart:typed_data';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ImageCropperScreen extends StatefulWidget {
  final File imageFile;

  const ImageCropperScreen({
    Key? key,
    required this.imageFile,
  }) : super(key: key);

  @override
  State<ImageCropperScreen> createState() => _ImageCropperScreenState();
}

class _ImageCropperScreenState extends State<ImageCropperScreen> {
  final _cropController = CropController();
  bool _isCircleUi = false;
  bool _isCropping = false;

  // Transform values for zoom and pan
  double _scale = 1.0;
  double _previousScale = 1.0;
  Offset _position = Offset.zero;
  Offset _previousPosition = Offset.zero;

  // Transformation matrix
  Matrix4 _transform = Matrix4.identity();

  void _handleScaleStart(ScaleStartDetails details) {
    _previousScale = _scale;
    _previousPosition = details.focalPoint;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      // Handle scale
      _scale = (_previousScale * details.scale).clamp(0.8, 4.0);

      // Handle position
      final Offset delta = details.focalPoint - _previousPosition;
      _position += delta;
      _previousPosition = details.focalPoint;

      // Update transform matrix
      _transform = Matrix4.identity()
        ..translate(_position.dx, _position.dy)
        ..scale(_scale);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Edit Photo',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: _isCropping
                ? null
                : () {
                    setState(() => _isCropping = true);
                    if (_isCircleUi) {
                      _cropController.cropCircle();
                    } else {
                      _cropController.crop();
                    }
                  },
          ),
        ],
      ),
      body: FutureBuilder<Uint8List>(
        future: widget.imageFile.readAsBytes(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              Column(
                children: [
                  // Crop Area
                  Expanded(
                    child: Container(
                      color: Colors.black,
                      child: GestureDetector(
                        onScaleStart: _handleScaleStart,
                        onScaleUpdate: _handleScaleUpdate,
                        child: Transform(
                          transform: _transform,
                          child: InteractiveViewer(
                            minScale: 0.8,
                            maxScale: 4.0,
                            child: Crop(
                              controller: _cropController,
                              image: snapshot.data!,
                              onCropped: (result) async {
                                switch (result) {
                                  case CropSuccess(:final croppedImage):
                                    try {
                                      final tempDir =
                                          await getTemporaryDirectory();
                                      final tempFile = File(
                                        '${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg',
                                      );
                                      await tempFile.writeAsBytes(croppedImage);
                                      if (mounted) {
                                        Navigator.of(context).pop(tempFile);
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Failed to save cropped image: $e'),
                                          ),
                                        );
                                      }
                                    }
                                  case CropFailure(:final cause):
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text('Failed to crop: $cause'),
                                        ),
                                      );
                                    }
                                }
                                if (mounted) {
                                  setState(() => _isCropping = false);
                                }
                              },
                              interactive: true,
                              fixCropRect: false,
                              radius: 8,
                              withCircleUi: _isCircleUi,
                              overlayBuilder: (context, rect) {
                                return _isCircleUi
                                    ? ClipOval(
                                        child:
                                            CustomPaint(painter: GridPainter()))
                                    : CustomPaint(painter: GridPainter());
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Controls
                  Container(
                    color: Colors.black,
                    padding: const EdgeInsets.all(16),
                    child: SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Aspect Ratio Controls
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildAspectButton(
                                Icons.crop_16_9,
                                () {
                                  setState(() {
                                    _isCircleUi = false;
                                    _cropController.aspectRatio = 16 / 9;
                                  });
                                },
                              ),
                              _buildAspectButton(
                                Icons.crop_5_4,
                                () {
                                  setState(() {
                                    _isCircleUi = false;
                                    _cropController.aspectRatio = 4 / 3;
                                  });
                                },
                              ),
                              _buildAspectButton(
                                Icons.crop_square,
                                () {
                                  setState(() {
                                    _isCircleUi = false;
                                    _cropController.aspectRatio = 1;
                                  });
                                },
                              ),
                              _buildAspectButton(
                                Icons.circle,
                                () {
                                  setState(() {
                                    _isCircleUi = true;
                                    _cropController.aspectRatio = 1;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (_isCropping)
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAspectButton(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(
        icon,
        color: Colors.white,
        size: 28,
      ),
      onPressed: _isCropping ? null : onPressed,
      padding: const EdgeInsets.all(16),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 1;

    // Draw vertical lines
    for (int i = 1; i < 3; i++) {
      final x = size.width * i / 3;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (int i = 1; i < 3; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
