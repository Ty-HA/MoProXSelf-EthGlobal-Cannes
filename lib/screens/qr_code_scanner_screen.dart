import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:mopro_x_self_ethglobal_cannes/services/age_verification_service.dart';

class QRCodeScannerScreen extends StatefulWidget {
  const QRCodeScannerScreen({super.key});

  @override
  State<QRCodeScannerScreen> createState() => _QRCodeScannerScreenState();
}

class _QRCodeScannerScreenState extends State<QRCodeScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isScanning = true;
  bool _isVerifying = false;
  String? _result;

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.pauseCamera();
      controller!.resumeCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (_isScanning && scanData.code != null) {
        _handleScannedData(scanData.code!);
      }
    });
  }

  void _handleScannedData(String data) async {
    if (!_isScanning) return;

    setState(() {
      _isScanning = false;
      _isVerifying = true;
    });

    try {
      final isValid = await AgeVerificationService.verifyProofFromQRCode(data);
      setState(() {
        _result = isValid ? 'valid' : 'invalid';
        _isVerifying = false;
      });
    } catch (e) {
      setState(() {
        _result = 'error';
        _isVerifying = false;
      });
      print('Error verifying proof: $e');
    }
  }

  void _resetScanner() {
    setState(() {
      _isScanning = true;
      _isVerifying = false;
      _result = null;
    });
    controller?.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Age Verification Scanner',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => controller?.toggleFlash(),
            tooltip: 'Toggle Flash',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                  overlay: QrScannerOverlayShape(
                    borderColor: Colors.blue,
                    borderRadius: 10,
                    borderLength: 30,
                    borderWidth: 10,
                    cutOutSize: 300,
                  ),
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
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              child: _buildResultPanel(),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code_scanner,
            size: 40,
            color: Colors.blue[600],
          ),
          const SizedBox(height: 10),
          const Text(
            'Point your camera at the QR code',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'The age verification will be processed automatically',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildValidResult() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.verified_user,
                  size: 50,
                  color: Colors.green[600],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Age Verified ✅',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'This person is 18+ years old',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _resetScanner,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan Another'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvalidResult() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red[100],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.cancel,
                  size: 50,
                  color: Colors.red[600],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Verification Failed ❌',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Invalid or expired proof',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _resetScanner,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorResult() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 50,
                  color: Colors.orange[600],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Scan Error ⚠️',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Unable to read QR code',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _resetScanner,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
