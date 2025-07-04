import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mopro_x_self_ethglobal_cannes/services/age_verification_service.dart';

class QRCodeScreen extends StatefulWidget {
  final AgeVerificationResult result;

  const QRCodeScreen({
    super.key,
    required this.result,
  });

  @override
  State<QRCodeScreen> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  String? _qrData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _generateQRCode();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _generateQRCode() async {
    try {
      final qrData = widget.result.toQRCodeData();
      setState(() {
        _qrData = qrData;
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Failed to generate QR code: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _shareQRCode() {
    if (_qrData != null) {
      Share.share(
        'My Age Verification Proof:\n\n$_qrData\n\nScan this QR code to verify that I am 18+ years old.',
        subject: 'Age Verification Proof',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Age Verification QR Code',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_qrData != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareQRCode,
              tooltip: 'Share QR Code',
            ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text(
                      'Generating QR Code...',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              )
            : _qrData != null
                ? FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: _buildQRCodeView(),
                    ),
                  )
                : _buildErrorView(),
      ),
    );
  }

  Widget _buildQRCodeView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 30),
          _buildQRCode(),
          const SizedBox(height: 30),
          _buildInfoCards(),
          const SizedBox(height: 30),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[100]!, Colors.green[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
            'Age Verification Successful! 🎉',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          const Text(
            'Your proof is ready to share',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQRCode() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Scan to Verify Age',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          QrImageView(
            data: _qrData!,
            version: QrVersions.auto,
            size: 250.0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            errorCorrectionLevel: QrErrorCorrectLevel.M,
            embeddedImage: null,
            embeddedImageStyle: const QrEmbeddedImageStyle(
              size: Size(50, 50),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'This QR code proves you are 18+ years old\nwithout revealing your exact age',
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

  Widget _buildInfoCards() {
    return Column(
      children: [
        _buildInfoCard(
          'Valid Until',
          _formatExpirationTime(),
          Icons.access_time,
          Colors.orange,
        ),
        const SizedBox(height: 10),
        _buildInfoCard(
          'Verification Method',
          'Zero-Knowledge Proof',
          Icons.security,
          Colors.blue,
        ),
        const SizedBox(height: 10),
        _buildInfoCard(
          'Privacy Level',
          'Complete Privacy',
          Icons.privacy_tip,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildInfoCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _shareQRCode,
            icon: const Icon(Icons.share),
            label: const Text('Share QR Code'),
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
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Generate New Proof'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green[600],
              side: BorderSide(color: Colors.green[600]!),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[300],
          ),
          const SizedBox(height: 20),
          const Text(
            'Failed to Generate QR Code',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Please try again or contact support',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Go Back'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _formatExpirationTime() {
    final expirationTime =
        widget.result.timestamp.add(const Duration(hours: 24));
    final now = DateTime.now();
    final difference = expirationTime.difference(now);

    if (difference.inHours >= 1) {
      return '${difference.inHours} hours';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} minutes';
    } else {
      return 'Soon';
    }
  }
}
