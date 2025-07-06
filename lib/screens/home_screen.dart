import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import '../core/constants/blockchain_constants.dart';
import '../core/services/blockchain_service.dart';
import 'generate_proof_screen.dart';
import 'contract_info_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BlockchainService _blockchainService = BlockchainService();
  final MobileScannerController _scannerController = MobileScannerController();

  bool _isInitialized = false;
  bool _isVerifying = false;
  bool _showScanner = false;
  String? _lastGeneratedQR;
  DateTime? _lastQRTime;
  String _statusMessage = 'Connecting to blockchain...';
  String _verificationResult = '';

  @override
  void initState() {
    super.initState();
    _initializeBlockchain();
  }

  Future<void> _initializeBlockchain() async {
    try {
      await _blockchainService.initialize();
      setState(() {
        _isInitialized = true;
        _statusMessage = 'Ready for age verification';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to connect: $e';
      });
    }
  }

  void _navigateToGenerateProof() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GenerateProofScreen(),
      ),
    );

    // If a QR was generated, save it
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _lastGeneratedQR = result['qrData'];
        _lastQRTime = DateTime.now();
      });
    }
  }

  Future<void> _verifyScannedProof(String qrData) async {
    setState(() {
      _isVerifying = true;
      _statusMessage = 'Verifying scanned proof...';
    });

    try {
      final proofData = jsonDecode(qrData);

      // === LOCAL VERIFICATION ===
      bool localVerified = false;
      // Simple local check: userAge >= minAge
      if (proofData['age'] != null && proofData['minAge'] != null) {
        final int userAge = int.tryParse(proofData['age'].toString()) ?? 0;
        final int minAge = int.tryParse(proofData['minAge'].toString()) ?? 0;
        localVerified = userAge >= minAge;
      }

      // Check if proof is expired
      if (proofData['expiresAt'] != null) {
        // Handle both string and int timestamp formats
        DateTime expiresAt;
        if (proofData['expiresAt'] is int) {
          expiresAt =
              DateTime.fromMillisecondsSinceEpoch(proofData['expiresAt']);
        } else {
          expiresAt = DateTime.parse(proofData['expiresAt'].toString());
        }

        if (DateTime.now().isAfter(expiresAt)) {
          setState(() {
            _isVerifying = false;
            _statusMessage = 'Proof has expired ❌';
            _verificationResult = 'EXPIRED: Proof was valid for 24 hours only';
          });
          return;
        }
      }

      // Extract proof components
      final proof = proofData['proof'];
      final proofA = List<String>.from(proof['a']);
      final proofB =
          List<List<String>>.from(proof['b'].map((b) => List<String>.from(b)));
      final proofC = List<String>.from(proof['c']);
      final publicSignals = List<String>.from(proofData['publicSignals']);

      // === ON-CHAIN VERIFICATION ===
      final isValid = await _blockchainService.verifyProof(
        proofA: proofA,
        proofB: proofB,
        proofC: proofC,
        publicSignals: publicSignals,
      );

      setState(() {
        _isVerifying = false;
        _statusMessage = isValid
            ? 'Proof verification: VALID ✅'
            : 'Proof verification: INVALID ❌';

        _verificationResult = '''
=== LOCAL VERIFICATION ===
Local check: ${localVerified ? 'VERIFIED ✅' : 'FAILED ❌'}

=== BLOCKCHAIN VERIFICATION ===
Contract: ${BlockchainConstants.groth16VerifierAddress}
Network: ${BlockchainConstants.networkName}
Chain ID: ${BlockchainConstants.chainId}
Verification Result: ${isValid ? 'VALID' : 'INVALID'}

=== PROOF DETAILS ===
Age: ${proofData['age']} years old
Min Age Required: ${proofData['minAge']}
Proof Type: ${proofData['proofType']}
Generated: ${proofData['timestamp']}
Expires: ${proofData['expiresAt']}

=== TECHNICAL DATA ===
Proof A: [${proofA.join(', ')}]
Proof B: [${proofB.map((b) => '[${b.join(', ')}]').join(', ')}]
Proof C: [${proofC.join(', ')}]
Public Signals: [${publicSignals.join(', ')}]

Verified on: ${DateTime.now().toIso8601String()}
        ''';
      });

      // Show verification result in a dialog
      _showVerificationDialog(isValid, proofData, localVerified);
    } catch (e) {
      setState(() {
        _isVerifying = false;
        _statusMessage = 'Verification failed: $e';
        _verificationResult = 'Error: $e';
      });
    }
  }

  // Update dialog to show local verification result
  void _showVerificationDialog(bool isValid, Map<String, dynamic> proofData,
      [bool? localVerified]) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                isValid ? Icons.check_circle : Icons.error,
                color: isValid ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(isValid ? 'Verification Successful' : 'Verification Failed'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (localVerified != null) ...[
                  Text(
                    localVerified
                        ? 'Local verification: VERIFIED ✅'
                        : 'Local verification: FAILED ❌',
                    style: TextStyle(
                      color: localVerified ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                if (isValid) ...[
                  const Text(
                    '✅ Age verification confirmed on blockchain',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Age: ${proofData['age']} years old'),
                  Text('Minimum required: ${proofData['minAge']}'),
                  Text(
                      'Valid until: ${proofData['expiresAt']?.substring(0, 19)}'),
                ] else ...[
                  const Text(
                    '❌ Age verification failed',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                const Text(
                  'Blockchain Details:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text('Network: ${BlockchainConstants.networkName}'),
                Text(
                    'Contract: ${BlockchainConstants.groth16VerifierAddress.substring(0, 10)}...'),
                Text('Verification: ${isValid ? 'VALID' : 'INVALID'}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            if (isValid)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _openContractOnArbiscan();
                },
                child: const Text('View on Arbiscan'),
              ),
          ],
        );
      },
    );
  }

  void _startScanning() {
    setState(() {
      _showScanner = true;
      _statusMessage = 'Scanning for QR code...';
    });
  }

  void _stopScanning() {
    setState(() {
      _showScanner = false;
      _statusMessage = 'Scan cancelled';
    });
  }

  void _onQRCodeDetected(BarcodeCapture capture) {
    final String? qrData = capture.barcodes.first.rawValue;
    if (qrData != null && qrData.isNotEmpty) {
      _stopScanning();
      _verifyScannedProof(qrData);
    }
  }

  void _copyContractAddress() {
    Clipboard.setData(
        ClipboardData(text: BlockchainConstants.groth16VerifierAddress));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contract address copied to clipboard!')),
    );
  }

  Future<void> _openContractOnArbiscan() async {
    final Uri url = Uri.parse(BlockchainConstants.contractUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Could not open ${BlockchainConstants.contractUrl}')),
      );
    }
  }

  // Définition de la couleur personnalisée mauve
  final Color customPurple = const Color.fromRGBO(187, 181, 247, 1);

  @override
  Widget build(BuildContext context) {
    if (_showScanner) {
      return _buildScannerScreen();
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'ZKAge Proof',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: customPurple),
            ),
            Text(
              'Prove your age without revealing personal information',
              style:
                  TextStyle(fontSize: 14, color: customPurple.withOpacity(0.7)),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.grey.shade800,
        foregroundColor: customPurple,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _isInitialized
                    ? Colors.grey.shade800
                    : Colors.grey.shade700,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      _isInitialized ? Colors.greenAccent : Colors.orangeAccent,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _isInitialized ? Icons.check_circle : Icons.hourglass_empty,
                    size: 48,
                    color: _isInitialized
                        ? Colors.greenAccent
                        : Colors.orangeAccent,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _statusMessage,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_isInitialized) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${BlockchainConstants.networkName} • Contract Verified ✅',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.greenAccent,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Main Action Buttons - Now stacked vertically to prevent overflow
            Column(
              children: [
                _buildMainActionCard(
                  title: 'Generate Age Proof',
                  subtitle: 'Create your ZK proof',
                  icon: Icons.qr_code,
                  color: Colors.blue,
                  onPressed: _isInitialized ? _navigateToGenerateProof : null,
                ),
                const SizedBox(height: 16),
                _buildMainActionCard(
                  title: 'Verify Proof',
                  subtitle: 'Scan QR to verify',
                  icon: Icons.qr_code_scanner,
                  color: Colors.green,
                  onPressed:
                      _isInitialized && !_isVerifying ? _startScanning : null,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Recent Activity Section
            if (_lastGeneratedQR != null || _verificationResult.isNotEmpty) ...[
              Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: customPurple,
                ),
              ),
              const SizedBox(height: 16),
              if (_lastGeneratedQR != null) ...[
                Card(
                  elevation: 3,
                  color: Colors.grey.shade800,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.qr_code, color: customPurple),
                            const SizedBox(width: 8),
                            const Text(
                              'Last Generated QR Code',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: GestureDetector(
                            onTap:
                                _showQRFullScreenWallet, // Show wallet-style full screen on tap
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // QR Code
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: QrImageView(
                                    data: _lastGeneratedQR!,
                                    version: QrVersions.auto,
                                    size: 150,
                                    backgroundColor: Colors.white,
                                  ),
                                ),

                                // Bouton "View" au centre
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: customPurple, width: 1.5),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.fullscreen,
                                        color: customPurple,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'View',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade700,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.greenAccent.withOpacity(0.5)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: Colors.greenAccent,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Valid for 24 hours',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.greenAccent,
                                    ),
                                  ),
                                ],
                              ),
                              if (_lastQRTime != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Generated: ${_formatTime(_lastQRTime!)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: customPurple.withOpacity(0.8),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (_verificationResult.isNotEmpty) ...[
                Card(
                  elevation: 3,
                  color: Colors.grey.shade800,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.verified, color: Colors.green.shade700),
                            const SizedBox(width: 8),
                            const Text(
                              'Last Verification',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: SelectableText(
                            _verificationResult,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ],

            // Contract Info
            Card(
              elevation: 2,
              color: Colors.grey.shade800,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Smart Contract Info',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: customPurple,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Network', BlockchainConstants.networkName),
                    _buildInfoRow('Contract',
                        '${BlockchainConstants.groth16VerifierAddress.substring(0, 10)}...'),
                    _buildInfoRow('Status', 'Verified ✅'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _copyContractAddress,
                            icon: const Icon(Icons.copy, size: 16),
                            label: const Text('Copy Address'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: customPurple,
                              side: BorderSide(color: customPurple),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _openContractOnArbiscan,
                            icon: const Icon(Icons.open_in_new, size: 16),
                            label: const Text('View on Arbiscan'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.greenAccent,
                              side: const BorderSide(color: Colors.greenAccent),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ContractInfoScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.info_outline, size: 16),
                        label: const Text('Contract Details & Redeployment'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: customPurple,
                          side: BorderSide(color: customPurple),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: customPurple.withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  const Text(
                    'Build for EthGlobal Cannes 2025',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Zero Knowledge Age Verification\nwith Mopro & Hardhat 3.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: customPurple.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    final Color activeColor =
        color == Colors.blue ? customPurple : Colors.greenAccent;
    return Card(
      elevation: 4,
      color: Colors.grey.shade800,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16), // Reduced padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Use min size vertically
            children: [
              Container(
                padding: const EdgeInsets.all(12), // Reduced padding
                decoration: BoxDecoration(
                  color: Colors.grey.shade700,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color:
                        onPressed != null ? activeColor : Colors.grey.shade600,
                    width: 2,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 28, // Slightly smaller icon
                  color: onPressed != null ? activeColor : Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 12), // Reduced spacing
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: onPressed != null ? activeColor : Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1, // Limit to one line
                overflow: TextOverflow.ellipsis, // Handle text overflow
              ),
              const SizedBox(height: 4), // Reduced spacing
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                ),
                textAlign: TextAlign.center,
                maxLines: 1, // Limit to one line
                overflow: TextOverflow.ellipsis, // Handle text overflow
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScannerScreen() {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _stopScanning,
        ),
        backgroundColor: Colors.grey.shade800,
        foregroundColor: Colors.greenAccent,
      ),
      body: Column(
        children: [
          // Scanner qui occupe seulement la moitié supérieure de l'écran
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Stack(
              children: [
                // Cadre du scanner
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.greenAccent, width: 2),
                    color: Colors.black,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: MobileScanner(
                      controller: _scannerController,
                      onDetect: _onQRCodeDetected,
                    ),
                  ),
                ),
                // Guide visuel pour le scan
                Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: customPurple, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Panneau d'information
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.qr_code_scanner,
                    color: Colors.greenAccent,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _statusMessage,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Position the QR code within the purple frame above',
                    style: TextStyle(
                      color: customPurple,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _stopScanning,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: customPurple),
                      ),
                    ),
                    child: const Text('Cancel Scanning'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                color: customPurple.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // Ancienne méthode remplacée par _showQRFullScreenWallet

  void _showQRFullScreenWallet() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "QR Code Wallet View",
      barrierColor: Colors.black.withOpacity(0.7),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => Container(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutQuad,
        );

        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: customPurple, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.shield_outlined,
                            color: Colors.greenAccent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ZKAge Proof',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: customPurple,
                                ),
                              ),
                              const Text(
                                'Private Age Verification',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white60),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // QR Code with shiny border
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.greenAccent,
                            customPurple,
                            Colors.greenAccent,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: QrImageView(
                          data: _lastGeneratedQR!,
                          version: QrVersions.auto,
                          size: 250,
                          backgroundColor: Colors.white,
                          errorCorrectionLevel: QrErrorCorrectLevel.H,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Status info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: customPurple.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Status',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.greenAccent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  const Text(
                                    'Active',
                                    style: TextStyle(
                                      color: Colors.greenAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Divider(color: Colors.white10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Valid for',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const Text(
                                '24 hours',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action button
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.greenAccent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }
}
