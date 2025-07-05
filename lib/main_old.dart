import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mopro_x_self_ethglobal_cannes/screens/age_verification_screen.dart';
import 'package:mopro_x_self_ethglobal_cannes/screens/qr_code_scanner_screen.dart';
import 'package:mopro_x_self_ethglobal_cannes/screens/integrated_verification_screen.dart';
import 'package:mopro_x_self_ethglobal_cannes/services/age_verification_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZK Age Verification',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'System',
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _lastQRCode;

  @override
  void initState() {
    super.initState();
    _loadLastQRCode();
    // Also check for hybrid proofs on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {}); // Refresh after first frame
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh when returning to this screen
    setState(() {});
  }

  Future<void> _loadLastQRCode() async {
    final qrCode = await AgeVerificationService.getLastQRCode();
    if (mounted) {
      setState(() {
        _lastQRCode = qrCode;
      });
    }
  }

  Future<void> _clearQRCode() async {
    await AgeVerificationService.clearLastQRCode();
    setState(() {
      _lastQRCode = null;
    });
  }

  void _showStoredQRCode() {
    if (_lastQRCode == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your Age Verification QR Code'),
        content: Container(
          width: 250,
          height: 300,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: QrImageView(
                  data: _lastQRCode!['qr_data'],
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Age: ${_lastQRCode!['user_age']} | Min: ${_lastQRCode!['min_age']}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showStoredHybridQRCode() {
    final lastCombinedProof = ProofFusionService.getLastCombinedProof();
    final lastQRCode = ProofFusionService.getLastQRCode();

    if (lastCombinedProof == null || lastQRCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No valid hybrid proof found or proof has expired'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.qr_code, color: Colors.blue),
            SizedBox(width: 8),
            Text('Hybrid Age Verification QR'),
          ],
        ),
        content: Container(
          width: 280,
          height: 380,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: QrImageView(
                  data: lastQRCode,
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🔐 Hybrid Proof Details',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'User Age: ${lastCombinedProof.moproProof.userAge} years',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      'Min Age: ${lastCombinedProof.moproProof.minAge} years',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      'Type: ${lastCombinedProof.proofType}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Valid until: ${lastCombinedProof.validUntil.toLocal().toString().substring(0, 19)}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Text(
                      'Time left: ${lastCombinedProof.timeRemaining.inHours}h ${lastCombinedProof.timeRemaining.inMinutes % 60}m',
                      style: TextStyle(
                          fontSize: 11,
                          color: lastCombinedProof.timeRemaining.inHours < 2
                              ? Colors.orange
                              : Colors.green),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Debug: Check if hybrid proof is available
    final hasHybridProof = ProofFusionService.hasValidStoredProof();
    print('🔍 [Debug] hasValidStoredProof: $hasHybridProof');

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'ZK Age Verification',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildOptionCards(context),
              if (_lastQRCode != null) ...[
                const SizedBox(height: 20),
                _buildLastQRCodeCard(),
              ],
              // Show last hybrid QR code if available
              if (ProofFusionService.hasValidStoredProof()) ...[
                const SizedBox(height: 16),
                _buildLastHybridQRCodeCard(),
              ],
              const SizedBox(height: 20),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[100]!, Colors.indigo[100]!],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.verified_user,
            size: 50,
            color: Colors.blue,
          ),
          const SizedBox(height: 12),
          const Text(
            'Zero-Knowledge Age Verification',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Prove your age without revealing personal information',
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

  Widget _buildOptionCards(BuildContext context) {
    return Column(
      children: [
        _buildOptionCard(
          context,
          'Generate Age Proof',
          'Create a ZK proof of your age',
          Icons.person_add,
          Colors.green,
          () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AgeVerificationScreen(),
              ),
            );
            // Refresh QR code if user returned
            _loadLastQRCode();
          },
        ),
        const SizedBox(height: 16),
        _buildOptionCard(
          context,
          'Verify Age Proof',
          'Scan and verify someone\'s age proof',
          Icons.qr_code_scanner,
          Colors.orange,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const QRCodeScannerScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        _buildOptionCard(
          context,
          'Mopro + Self Protocol',
          'Hybrid verification with real ID + ZK proof',
          Icons.security,
          Colors.purple,
          () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const IntegratedVerificationScreen(),
              ),
            );
            // Refresh the UI when returning from hybrid verification
            setState(() {});
          },
        ),
        const SizedBox(height: 16),
        _buildOptionCard(
          context,
          'Self Protocol + TEE Test',
          'Test TEE-secured identity verification',
          Icons.verified_user,
          Colors.deepPurple,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SelfProtocolTestScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        _buildOptionCard(
          context,
          'Real NFC Scan',
          'Scan real EU ID card with NFC',
          Icons.contactless,
          Colors.amber,
          () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RealNfcScanScreen(minAge: 18),
              ),
            );
            // Refresh UI
            setState(() {});
          },
        ),
        const SizedBox(height: 16),
        _buildOptionCard(
          context,
          'Backend Configuration',
          'Configure backend URL for real NFC scan',
          Icons.settings,
          Colors.teal,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BackendConfigScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        _buildOptionCard(
          context,
          'Backend Debugger',
          'Advanced backend testing and diagnostics',
          Icons.bug_report,
          Colors.grey[800]!,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BackendDebugScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildOptionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Text(
          'Powered by',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Mopro SDK • Self Protocol',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.security,
                size: 16,
                color: Colors.blue,
              ),
              SizedBox(width: 8),
              Text(
                'Privacy First • No Personal Data Stored',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLastQRCodeCard() {
    final qrData = _lastQRCode!;
    final expiry = qrData['expiry'] as DateTime;
    final timeLeft = expiry.difference(DateTime.now());

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.withOpacity(0.1),
              Colors.green.withOpacity(0.05)
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.qr_code,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Last Generated QR Code',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Age: ${qrData['user_age']} | Min: ${qrData['min_age']}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _clearQRCode,
                  icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                  tooltip: 'Remove QR Code',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.timer, size: 14, color: Colors.orange[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Expires in ${timeLeft.inHours}h ${timeLeft.inMinutes % 60}m',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.orange[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _showStoredQRCode,
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: const Size(0, 32),
                  ),
                  child: const Text(
                    'Show QR',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastHybridQRCodeCard() {
    final lastCombinedProof = ProofFusionService.getLastCombinedProof();
    if (lastCombinedProof == null) return Container();

    final timeLeft = lastCombinedProof.timeRemaining;
    final isExpiringSoon = timeLeft.inHours < 2;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.withOpacity(0.1),
              Colors.purple.withOpacity(0.05)
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.security,
                    color: Colors.purple,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Last Hybrid Proof (Mopro + Self)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Age: ${lastCombinedProof.moproProof.userAge} | Type: ${lastCombinedProof.proofType}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    ProofFusionService.clearStoredProof();
                    setState(() {});
                  },
                  icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                  tooltip: 'Remove Hybrid Proof',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.timer,
                    size: 14,
                    color: isExpiringSoon
                        ? Colors.orange[600]
                        : Colors.green[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Expires in ${timeLeft.inHours}h ${timeLeft.inMinutes % 60}m',
                    style: TextStyle(
                      fontSize: 11,
                      color: isExpiringSoon
                          ? Colors.orange[600]
                          : Colors.green[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _showStoredHybridQRCode,
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: const Size(0, 32),
                  ),
                  child: const Text(
                    'Show QR',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
