import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:math';
import '../core/constants/blockchain_constants.dart';
import '../core/services/blockchain_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BlockchainService _blockchainService = BlockchainService();
  bool _isInitialized = false;
  bool _isGenerating = false;
  bool _isVerifying = false;
  bool _showScanner = false;
  String? _generatedQRData;
  String _statusMessage = 'Ready to generate ZK proof';
  String _detailsLog = '';

  // Mock proof data for demonstration - this would come from Mopro in real implementation
  final Map<String, dynamic> _mockProofData = {
    "proof": {
      "a": [
        "19923060182910226906721600966583312078500667648443339050227909313606466457211",
        "14407272839031589347216548031385245127293064767372124261688524352715379225741"
      ],
      "b": [
        [
          "4883238366009789695331992384951628587386736639951731454264103050234940615318",
          "13794837467771443994011634932013906591194731138607311132947690813749909265311"
        ],
        [
          "9895420863917605766670743315771385403550661381100227123953021876882710833706",
          "4936789948827392647523783493615585043359420880310565993739779319616196207124"
        ]
      ],
      "c": [
        "7720108429977408165089226779484323019898682881191051773022228543201822291289",
        "17229774610108331768514151820056079782339646807062742205515537108161181258410"
      ]
    },
    "publicSignals": ["15", "5"]
  };

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
        _statusMessage = 'Connected to Arbitrum Sepolia ✅';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to connect: $e';
      });
    }
  }

  Future<void> _testProofVerification() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing proof verification...';
    });

    try {
      // Example test proof (you'll replace this with real Mopro proof)
      final testProofA = ['1', '2'];
      final testProofB = [
        ['3', '4'],
        ['5', '6']
      ];
      final testProofC = ['7', '8'];
      final testPublicSignals = ['1', '0']; // Example: age >= 18 = true

      final isValid = await _blockchainService.verifyProof(
        proofA: testProofA,
        proofB: testProofB,
        proofC: testProofC,
        publicSignals: testPublicSignals,
      );

      setState(() {
        _isLoading = false;
        _statusMessage = isValid
            ? 'Proof verification: VALID ✅'
            : 'Proof verification: INVALID ❌';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Verification failed: $e';
      });
    }
  }

  void _copyContractAddress() {
    Clipboard.setData(
        ClipboardData(text: BlockchainConstants.groth16VerifierAddress));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contract address copied to clipboard!')),
    );
  }

  void _openContractOnArbiscan() {
    // You would typically use url_launcher here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Open: ${BlockchainConstants.contractUrl}'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mopro ZK Age Verification'),
            Text(
              '${BlockchainConstants.networkName} • EthGlobal Cannes 2025',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Blockchain Status',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(_statusMessage),
                    const SizedBox(height: 8),
                    if (_isInitialized) ...[
                      Text('Network: ${BlockchainConstants.networkName}'),
                      Text('Chain ID: ${BlockchainConstants.chainId}'),
                      Text(
                          'Contract: ${BlockchainConstants.isVerified ? "Verified ✅" : "Not verified"}'),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Contract Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Smart Contract',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('Groth16Verifier Contract'),
                    const SizedBox(height: 4),
                    Text(
                      BlockchainConstants.groth16VerifierAddress,
                      style: const TextStyle(
                          fontFamily: 'monospace', fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _copyContractAddress,
                          icon: const Icon(Icons.copy, size: 16),
                          label: const Text('Copy Address'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _openContractOnArbiscan,
                          icon: const Icon(Icons.open_in_new, size: 16),
                          label: const Text('View on Arbiscan'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Actions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ZK Proof Actions',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isInitialized && !_isLoading
                            ? _testProofVerification
                            : null,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.verified),
                        label: Text(_isLoading
                            ? 'Verifying...'
                            : 'Test Proof Verification'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Navigate to Mopro proof generation
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Mopro proof generation coming soon!')),
                          );
                        },
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Generate ZK Proof (Mopro)'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),

            // Footer
            Card(
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    const Text(
                      '🏆 EthGlobal Cannes 2025',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ZK Age Verification with Mopro & Hardhat 3.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
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

  @override
  void dispose() {
    _blockchainService.dispose();
    super.dispose();
  }
}
