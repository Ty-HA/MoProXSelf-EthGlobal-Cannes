import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mopro_x_self_ethglobal_cannes/services/age_verification_service.dart';
import 'package:mopro_x_self_ethglobal_cannes/services/universal_proof_verifier.dart';
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
          // First detect the proof type
          print('🔍 [QR Scanner] Detecting proof type for QR code...');
          final proofType = UniversalProofVerifier.detectProofType(code);
          print('🔍 [QR Scanner] Detected proof type: $proofType');

          bool isValid = false;
          String proofDetails = '';

          if (proofType == ProofType.moproOnly) {
            print('🔍 [QR Scanner] Using Mopro-only verification...');
            // Use original Mopro verification for legacy proofs
            isValid = await AgeVerificationService.verifyProofFromQRCode(code);
            proofDetails = await _formatMoproProofDetails(code, isValid);
            print('🔍 [QR Scanner] Mopro verification result: $isValid');
          } else {
            print('🔍 [QR Scanner] Using universal verifier...');
            // Use universal verifier for hybrid proofs
            final result = await UniversalProofVerifier.verifyProof(code);
            isValid = result.isValid;
            proofDetails = _formatUniversalProofDetails(result);
            print('🔍 [QR Scanner] Universal verification result: $isValid');
          }

          setState(() {
            _result = isValid ? 'valid' : 'invalid';
            _proofDetails = proofDetails;
            _isVerifying = false;
            _cameraActive = false;
          });

          await controller.stop();
        } catch (e) {
          setState(() {
            _result = 'error';
            _proofDetails = 'Error: $e';
            _isVerifying = false;
            _cameraActive = false;
          });
          await controller.stop();
        }
      }
    }
  }

  // Format original Mopro proof details (like before)
  Future<String> _formatMoproProofDetails(
      String qrCodeData, bool isValid) async {
    try {
      final decodedData = utf8.decode(base64Decode(qrCodeData));
      final proofData = jsonDecode(decodedData);

      print(
          '🔍 [QR Scanner] Mopro proof data keys: ${proofData.keys.toList()}');
      print('🔍 [QR Scanner] Mopro proof data: ${proofData.toString()}');

      // Extract age information from public signals
      final publicSignals = proofData['public_signals'] as List<dynamic>?;
      print('🔍 [QR Scanner] Public signals: $publicSignals');

      int userAge = 0;
      int minAge = 18;

      if (publicSignals != null && publicSignals.isNotEmpty) {
        // In the multiplier2 circuit, public_signals[0] is the result (a*b)
        // We need to extract the user age from stored metadata or compute it
        final multiplicationResult =
            int.tryParse(publicSignals[0].toString()) ?? 0;
        print('🔍 [QR Scanner] Multiplication result: $multiplicationResult');

        // Check if we have stored age info in the proof data
        if (proofData.containsKey('user_age')) {
          userAge = proofData['user_age'] ?? 0;
        } else if (proofData.containsKey('metadata')) {
          final metadata = proofData['metadata'] as Map<String, dynamic>?;
          if (metadata != null) {
            userAge = metadata['user_age'] ?? 0;
            minAge = metadata['min_age'] ?? 18;
          }
        }

        // If we still don't have the user age, try to derive it
        if (userAge == 0 && multiplicationResult > 0) {
          // This is a fallback - not ideal but shows the calculation
          if (multiplicationResult % minAge == 0) {
            userAge = multiplicationResult ~/ minAge;
          }
        }
      }

      // Check for explicit age fields in proof data
      if (proofData.containsKey('user_age')) {
        userAge = proofData['user_age'] ?? userAge;
      }
      if (proofData.containsKey('min_age')) {
        minAge = proofData['min_age'] ?? minAge;
      }

      print(
          '🔍 [QR Scanner] Final extracted ages - User: $userAge, Min: $minAge');

      final expectedMultiplication = userAge * minAge;

      return 'Proof is valid: $isValid\n\n'
          'ZK Proof Verification Results:\n\n'
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
          'Proof inputs: ${proofData['public_signals']}\n\n'
          'Proof: ProofCalldata(\n'
          '  ${_formatProofStructure(proofData)}\n'
          ')\n\n'
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
      return 'Proof is valid: $isValid\n\nError parsing proof details: $e';
    }
  }

  String _formatProofStructure(Map<String, dynamic> proofData) {
    try {
      final proof = proofData['proof'];
      if (proof is Map) {
        return 'a: G1Point(\n'
            '    X: ${proof['a']?['x'] ?? 'N/A'},\n'
            '    Y: ${proof['a']?['y'] ?? 'N/A'},\n'
            '    Z: ${proof['a']?['z'] ?? '1'}\n'
            '  ),\n'
            '  b: G2Point(\n'
            '    X: ${proof['b']?['x'] ?? 'N/A'},\n'
            '    Y: ${proof['b']?['y'] ?? 'N/A'},\n'
            '    Z: ${proof['b']?['z'] ?? '[1, 0]'}\n'
            '  ),\n'
            '  c: G1Point(\n'
            '    X: ${proof['c']?['x'] ?? 'N/A'},\n'
            '    Y: ${proof['c']?['y'] ?? 'N/A'},\n'
            '    Z: ${proof['c']?['z'] ?? '1'}\n'
            '  ),\n'
            '  protocol: ${proof['protocol'] ?? proofData['protocol']},\n'
            '  curve: ${proof['curve'] ?? proofData['curve']}';
      } else {
        return 'Proof structure: ${proof.toString()}';
      }
    } catch (e) {
      return 'Error formatting proof structure: $e';
    }
  }

  // Format universal proof details (for hybrid proofs)
  String _formatUniversalProofDetails(UniversalVerificationResult result) {
    print('🔍 [QR Scanner] Formatting universal proof details...');
    print('📋 [QR Scanner] Result isValid: ${result.isValid}');
    print('📋 [QR Scanner] Result title: ${result.title}');
    print('📋 [QR Scanner] Result subtitle: ${result.subtitle}');
    print('📋 [QR Scanner] Result proofType: ${result.proofType}');
    print('📋 [QR Scanner] Result details: ${result.details}');

    final StringBuffer buffer = StringBuffer();

    buffer.writeln('🔍 Universal Proof Verification Results\n');

    // Basic info
    buffer.writeln('STATUS: ${result.isValid ? "✅ VALID" : "❌ INVALID"}');
    buffer.writeln('TYPE: ${result.title}');
    buffer.writeln('DESCRIPTION: ${result.subtitle}\n');

    // Details
    buffer.writeln('📋 Proof Details:');
    result.details.forEach((key, value) {
      print('📋 [QR Scanner] Detail $key: $value');
      buffer.writeln('$key: $value');
    });

    // Instructions
    buffer.writeln('\n📖 About This Proof:');
    final instructions =
        UniversalProofVerifier.getVerificationInstructions(result.proofType);
    for (String instruction in instructions) {
      buffer.writeln(instruction);
    }

    if (result.error != null) {
      buffer.writeln('\n❌ Error: ${result.error}');
    }

    final finalResult = buffer.toString();
    print('📋 [QR Scanner] Final formatted result:\n$finalResult');
    return finalResult;
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
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              _showSupportedFormatsDialog();
            },
            tooltip: 'Supported Formats',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera view
          if (_cameraActive)
            MobileScanner(
              controller: controller,
              onDetect: _handleBarcode,
            ),

          // Overlay
          if (_cameraActive)
            Container(
              decoration: ShapeDecoration(
                shape: QrScannerOverlayShape(
                  borderColor: Colors.blue,
                  borderRadius: 10,
                  borderLength: 30,
                  borderWidth: 10,
                  cutOutSize: 300,
                ),
              ),
            ),

          // Status overlay
          if (_isVerifying)
            const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Verifying proof...',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Result overlay
          if (_result != null && !_isVerifying)
            Center(
              child: Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _result == 'valid'
                            ? Icons.check_circle
                            : _result == 'invalid'
                                ? Icons.error
                                : Icons.warning,
                        size: 64,
                        color: _result == 'valid'
                            ? Colors.green
                            : _result == 'invalid'
                                ? Colors.red
                                : Colors.orange,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _result == 'valid'
                            ? 'Proof is Valid!'
                            : _result == 'invalid'
                                ? 'Proof is Invalid'
                                : 'Verification Error',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _resetScanner,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Scan Again'),
                          ),
                          ElevatedButton.icon(
                            onPressed: _showProofDebugDialog,
                            icon: const Icon(Icons.info),
                            label: const Text('Details'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _goHome,
                        icon: const Icon(Icons.home),
                        label: const Text('Go Home'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Instructions
          if (_cameraActive)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Card(
                color: Colors.black87,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Point your camera at a QR code to verify',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Supports: Mopro ZK Proofs & Hybrid Proofs',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: Icon(
                              controller.torchEnabled
                                  ? Icons.flash_on
                                  : Icons.flash_off,
                              color: Colors.white,
                            ),
                            onPressed: () => controller.toggleTorch(),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.flip_camera_ios,
                              color: Colors.white,
                            ),
                            onPressed: () => controller.switchCamera(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showSupportedFormatsDialog() {
    final supportedFormats = UniversalProofVerifier.getSupportedFormats();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue),
              SizedBox(width: 8),
              Text('Supported Proof Formats'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This scanner supports the following proof formats:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              ...supportedFormats.entries.map((entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.key,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                              Text(
                                entry.value,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
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
}

class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QrScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final cutOutRect = Rect.fromCenter(
      center: rect.center,
      width: cutOutSize,
      height: cutOutSize,
    );

    final outerPath = Path()..addRect(rect);
    final holePath = Path()
      ..addRRect(
          RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)))
      ..close();

    return Path.combine(PathOperation.difference, outerPath, holePath);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final cutOutRect = Rect.fromCenter(
      center: rect.center,
      width: cutOutSize,
      height: cutOutSize,
    );

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    // Draw corner borders
    final cornerLength = borderLength;
    final cornerRadius = borderRadius;

    // Top left corner
    canvas.drawPath(
      Path()
        ..moveTo(
            cutOutRect.left - borderWidth / 2, cutOutRect.top + cornerLength)
        ..lineTo(
            cutOutRect.left - borderWidth / 2, cutOutRect.top + cornerRadius)
        ..quadraticBezierTo(
          cutOutRect.left - borderWidth / 2,
          cutOutRect.top - borderWidth / 2,
          cutOutRect.left + cornerRadius,
          cutOutRect.top - borderWidth / 2,
        )
        ..lineTo(
            cutOutRect.left + cornerLength, cutOutRect.top - borderWidth / 2),
      borderPaint,
    );

    // Top right corner
    canvas.drawPath(
      Path()
        ..moveTo(
            cutOutRect.right - cornerLength, cutOutRect.top - borderWidth / 2)
        ..lineTo(
            cutOutRect.right - cornerRadius, cutOutRect.top - borderWidth / 2)
        ..quadraticBezierTo(
          cutOutRect.right + borderWidth / 2,
          cutOutRect.top - borderWidth / 2,
          cutOutRect.right + borderWidth / 2,
          cutOutRect.top + cornerRadius,
        )
        ..lineTo(
            cutOutRect.right + borderWidth / 2, cutOutRect.top + cornerLength),
      borderPaint,
    );

    // Bottom left corner
    canvas.drawPath(
      Path()
        ..moveTo(
            cutOutRect.left - borderWidth / 2, cutOutRect.bottom - cornerLength)
        ..lineTo(
            cutOutRect.left - borderWidth / 2, cutOutRect.bottom - cornerRadius)
        ..quadraticBezierTo(
          cutOutRect.left - borderWidth / 2,
          cutOutRect.bottom + borderWidth / 2,
          cutOutRect.left + cornerRadius,
          cutOutRect.bottom + borderWidth / 2,
        )
        ..lineTo(cutOutRect.left + cornerLength,
            cutOutRect.bottom + borderWidth / 2),
      borderPaint,
    );

    // Bottom right corner
    canvas.drawPath(
      Path()
        ..moveTo(cutOutRect.right - cornerLength,
            cutOutRect.bottom + borderWidth / 2)
        ..lineTo(cutOutRect.right - cornerRadius,
            cutOutRect.bottom + borderWidth / 2)
        ..quadraticBezierTo(
          cutOutRect.right + borderWidth / 2,
          cutOutRect.bottom + borderWidth / 2,
          cutOutRect.right + borderWidth / 2,
          cutOutRect.bottom - cornerRadius,
        )
        ..lineTo(cutOutRect.right + borderWidth / 2,
            cutOutRect.bottom - cornerLength),
      borderPaint,
    );

    // Draw the overlay
    final overlayPaint = Paint()..color = overlayColor;
    final outerPath = Path()..addRect(rect);
    final holePath = Path()
      ..addRRect(
          RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)))
      ..close();
    final overlayPath =
        Path.combine(PathOperation.difference, outerPath, holePath);
    canvas.drawPath(overlayPath, overlayPaint);
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
      borderRadius: borderRadius,
      borderLength: borderLength,
      cutOutSize: cutOutSize,
    );
  }
}
