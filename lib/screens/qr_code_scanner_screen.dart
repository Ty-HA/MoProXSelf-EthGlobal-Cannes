import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mopro_x_self_ethglobal_cannes/services/age_verification_service.dart';
import 'dart:convert';

class QRCodeScannerScreen extends StatefulWidget {
  const QRCodeScannerScreen({super.key});

  @override
  State<QRCodeScannerScreen> createState() => _QRCodeScannerScreenState();
}

class _QRCodeScannerScreenState extends State<QRCodeScannerScreen> {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isVerifying = false;
  String? _result;
  String? _proofDetails;
  bool _cameraActive = true;

  @override
  void initState() {
    super.initState();
    controller.start();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) async {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && !_isVerifying && _cameraActive) {
      final String? code = barcodes.first.rawValue;
      if (code != null) {
        setState(() {
          _isVerifying = true;
        });

        try {
          final isValid =
              await AgeVerificationService.verifyProofFromQRCode(code);

          // Extract proof details for debugging
          String proofDetails = '';
          try {
            final decodedData = utf8.decode(base64Decode(code));
            final proofData = jsonDecode(decodedData);

            // Calculate expected multiplication result for circuit explanation
            final userAge = proofData['user_age'] ?? 0;
            final minAge = proofData['min_age'] ?? 18;
            final expectedMultiplication = userAge * minAge;

            proofDetails = 'ZK Proof Verification Results:\n\n'
                'VERIFICATION STATUS: ${isValid ? "✅ VALID" : "❌ INVALID"}\n\n'
                'Age Verification Details:\n'
                'User Age: ${userAge > 0 ? userAge : 'N/A'}\n'
                'Min Age Required: $minAge\n'
                'Age Requirement Met: ${userAge >= minAge ? "✅ YES" : "❌ NO"}\n\n'
                'Circuit Details (multiplier2):\n'
                'Public Input (a): $minAge\n'
                'Private Input (b): $userAge\n'
                'Expected Result (a*b): $expectedMultiplication\n'
                'Actual Public Signals: ${proofData['public_signals']}\n\n'
                'ZK Proof Metadata:\n'
                'Protocol: ${proofData['protocol']}\n'
                'Curve: ${proofData['curve']}\n'
                'Is Simulated: ${proofData['simulated'] ?? false}\n'
                'Generated At: ${proofData['generated_at'] != null ? DateTime.fromMillisecondsSinceEpoch(proofData['generated_at']) : "N/A"}\n'
                'Timestamp: ${DateTime.fromMillisecondsSinceEpoch(proofData['timestamp'])}\n'
                'Valid until: ${DateTime.fromMillisecondsSinceEpoch(proofData['valid_until'])}\n'
                'Nullifier: ${proofData['nullifier']}\n\n'
                'Note: This uses a multiplier circuit where the minimum age is public\n'
                'and the user\'s age is private. The multiplication result proves\n'
                'the user knows their age without revealing it directly.';
          } catch (e) {
            proofDetails = 'Error parsing proof details: $e';
          }

          setState(() {
            _result = isValid ? 'valid' : 'invalid';
            _proofDetails = proofDetails;
            _isVerifying = false;
            _cameraActive = false; // Stop camera after verification
          });

          // Stop the camera
          await controller.stop();
        } catch (e) {
          setState(() {
            _result = 'error';
            _proofDetails = 'Error: $e';
            _isVerifying = false;
          });
          print('Error verifying proof: $e');
        }
      }
    }
  }

  void _resetScanner() async {
    setState(() {
      _result = null;
      _proofDetails = null;
      _isVerifying = false;
      _cameraActive = true;
    });
    await controller.start();
  }

  void _goHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _showProofDebugDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.bug_report, color: Colors.orange),
              SizedBox(width: 8),
              Text('ZK Proof Debug'),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'For hackathon demonstration purposes only',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _proofDetails ?? 'No proof details available',
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Age Verification Scanner',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goHome,
          tooltip: 'Return Home',
        ),
        actions: [
          if (_cameraActive)
            IconButton(
              icon: ValueListenableBuilder<TorchState>(
                valueListenable: controller.torchState,
                builder: (context, state, child) {
                  return Icon(
                    state == TorchState.on ? Icons.flash_on : Icons.flash_off,
                    color: Colors.white,
                  );
                },
              ),
              onPressed: () => controller.toggleTorch(),
              tooltip: 'Toggle Flash',
            ),
        ],
      ),
      body: Column(
        children: [
          // Camera section - only shown when active
          if (_cameraActive)
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  MobileScanner(
                    controller: controller,
                    onDetect: _handleBarcode,
                    errorBuilder: (context, error, child) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error,
                              color: Colors.red,
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Camera Error',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              error.toString(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  if (_isVerifying)
                    Container(
                      color: Colors.black.withOpacity(0.7),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Verifying proof...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Scanner overlay
                  CustomPaint(
                    size: Size.infinite,
                    painter: ScannerOverlay(
                      borderColor: Colors.blue,
                      borderRadius: 10,
                      borderLength: 30,
                      borderWidth: 10,
                      cutOutSize: 250,
                    ),
                  ),
                ],
              ),
            ),

          // Result section - expands when camera is not active
          Expanded(
            flex: _cameraActive ? 3 : 8,
            child: Container(
              color: Colors.white,
              child: SingleChildScrollView(
                child: _buildResultPanel(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultPanel() {
    if (_result == null) {
      return _buildScanningPanel();
    }

    switch (_result!) {
      case 'valid':
        return _buildValidResult();
      case 'invalid':
        return _buildInvalidResult();
      case 'error':
        return _buildErrorResult();
      default:
        return _buildScanningPanel();
    }
  }

  Widget _buildScanningPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code_scanner,
            size: 48,
            color: Colors.blue[600],
          ),
          const SizedBox(height: 16),
          const Text(
            'Point your camera at a QR code',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Make sure the QR code is well-lit and clear',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildValidResult() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle,
            size: 80,
            color: Colors.green,
          ),
          const SizedBox(height: 24),
          const Text(
            'Age Verified Successfully!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'This person meets the age requirement',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _goHome,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Return Home'),
              ),
              ElevatedButton(
                onPressed: _resetScanner,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Scan Another'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_proofDetails != null)
            TextButton.icon(
              onPressed: () => _showProofDebugDialog(),
              icon: const Icon(Icons.bug_report, color: Colors.orange),
              label: const Text('Show Proof Debug'),
              style: TextButton.styleFrom(foregroundColor: Colors.orange),
            ),
        ],
      ),
    );
  }

  Widget _buildInvalidResult() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.cancel,
            size: 80,
            color: Colors.red,
          ),
          const SizedBox(height: 24),
          const Text(
            'Age Verification Failed',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'This person does not meet the age requirement',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _goHome,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Return Home'),
              ),
              ElevatedButton(
                onPressed: _resetScanner,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_proofDetails != null)
            TextButton.icon(
              onPressed: () => _showProofDebugDialog(),
              icon: const Icon(Icons.bug_report, color: Colors.orange),
              label: const Text('Show Proof Debug'),
              style: TextButton.styleFrom(foregroundColor: Colors.orange),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorResult() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error,
            size: 80,
            color: Colors.orange,
          ),
          const SizedBox(height: 24),
          const Text(
            'Verification Error',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Unable to verify the QR code. Please try again.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _goHome,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Return Home'),
              ),
              ElevatedButton(
                onPressed: _resetScanner,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_proofDetails != null)
            TextButton.icon(
              onPressed: () => _showProofDebugDialog(),
              icon: const Icon(Icons.bug_report, color: Colors.orange),
              label: const Text('Show Proof Debug'),
              style: TextButton.styleFrom(foregroundColor: Colors.orange),
            ),
        ],
      ),
    );
  }
}

// Custom painter for scanner overlay
class ScannerOverlay extends CustomPainter {
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  ScannerOverlay({
    required this.borderColor,
    required this.borderWidth,
    required this.borderRadius,
    required this.borderLength,
    required this.cutOutSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final cutOutCenterX = width / 2;
    final cutOutCenterY = height / 2;
    final cutOutLeft = cutOutCenterX - cutOutSize / 2;
    final cutOutTop = cutOutCenterY - cutOutSize / 2;
    final cutOutRight = cutOutCenterX + cutOutSize / 2;
    final cutOutBottom = cutOutCenterY + cutOutSize / 2;

    // Draw semi-transparent background
    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, width, height))
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            cutOutLeft,
            cutOutTop,
            cutOutSize,
            cutOutSize,
          ),
          Radius.circular(borderRadius),
        ),
      )
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(backgroundPath, backgroundPaint);

    final cornerPaint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Top left corner
    canvas.drawPath(
      Path()
        ..moveTo(cutOutLeft, cutOutTop + borderLength)
        ..lineTo(cutOutLeft, cutOutTop + borderRadius)
        ..arcToPoint(
          Offset(cutOutLeft + borderRadius, cutOutTop),
          radius: Radius.circular(borderRadius),
        )
        ..lineTo(cutOutLeft + borderLength, cutOutTop),
      cornerPaint,
    );

    // Top right corner
    canvas.drawPath(
      Path()
        ..moveTo(cutOutRight - borderLength, cutOutTop)
        ..lineTo(cutOutRight - borderRadius, cutOutTop)
        ..arcToPoint(
          Offset(cutOutRight, cutOutTop + borderRadius),
          radius: Radius.circular(borderRadius),
        )
        ..lineTo(cutOutRight, cutOutTop + borderLength),
      cornerPaint,
    );

    // Bottom left corner
    canvas.drawPath(
      Path()
        ..moveTo(cutOutLeft, cutOutBottom - borderLength)
        ..lineTo(cutOutLeft, cutOutBottom - borderRadius)
        ..arcToPoint(
          Offset(cutOutLeft + borderRadius, cutOutBottom),
          radius: Radius.circular(borderRadius),
        )
        ..lineTo(cutOutLeft + borderLength, cutOutBottom),
      cornerPaint,
    );

    // Bottom right corner
    canvas.drawPath(
      Path()
        ..moveTo(cutOutRight - borderLength, cutOutBottom)
        ..lineTo(cutOutRight - borderRadius, cutOutBottom)
        ..arcToPoint(
          Offset(cutOutRight, cutOutBottom - borderRadius),
          radius: Radius.circular(borderRadius),
        )
        ..lineTo(cutOutRight, cutOutBottom - borderLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
