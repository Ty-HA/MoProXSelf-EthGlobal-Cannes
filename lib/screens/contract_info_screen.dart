import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants/blockchain_constants.dart';
import '../core/services/blockchain_service.dart';

class ContractInfoScreen extends StatefulWidget {
  const ContractInfoScreen({super.key});

  @override
  State<ContractInfoScreen> createState() => _ContractInfoScreenState();
}

class _ContractInfoScreenState extends State<ContractInfoScreen> {
  final BlockchainService _blockchainService = BlockchainService();
  bool _isLoading = true;
  bool _isContractValid = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _checkContractStatus();
  }

  Future<void> _checkContractStatus() async {
    try {
      await _blockchainService.initialize();

      // Check if the contract has the verifyProof function
      final isValid = await _blockchainService.isContractValid();

      setState(() {
        _isLoading = false;
        _isContractValid = isValid;
        _statusMessage = isValid
            ? 'Contract is valid and deployed'
            : 'Contract might need to be redeployed';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error checking contract: $e';
      });
    }
  }

  Future<void> _openContractOnExplorer() async {
    final Uri url = Uri.parse(BlockchainConstants.contractUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Could not open ${BlockchainConstants.contractUrl}')),
        );
      }
    }
  }

  void _copyContractAddress() {
    Clipboard.setData(
        ClipboardData(text: BlockchainConstants.groth16VerifierAddress));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contract address copied to clipboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contract Information'),
        backgroundColor: Colors.blue.shade50,
        foregroundColor: Colors.blue.shade800,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contract Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _isLoading
                    ? Colors.grey.shade50
                    : _isContractValid
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isLoading
                      ? Colors.grey.shade300
                      : _isContractValid
                          ? Colors.green.shade300
                          : Colors.red.shade300,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _isLoading
                        ? Icons.hourglass_empty
                        : _isContractValid
                            ? Icons.check_circle
                            : Icons.error,
                    size: 48,
                    color: _isLoading
                        ? Colors.grey
                        : _isContractValid
                            ? Colors.green
                            : Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isLoading ? 'Checking contract status...' : _statusMessage,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Contract Details
            const Text(
              'Contract Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              'Contract Address',
              BlockchainConstants.groth16VerifierAddress,
              Icons.account_balance_wallet,
              Colors.blue,
              onCopy: _copyContractAddress,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              'Network',
              '${BlockchainConstants.networkName} (Chain ID: ${BlockchainConstants.chainId})',
              Icons.lan,
              Colors.purple,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              'Contract Type',
              'Groth16 ZK Proof Verifier',
              Icons.verified_user,
              Colors.green,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              'Deployed On',
              BlockchainConstants.deploymentDate,
              Icons.calendar_today,
              Colors.amber,
            ),
            const SizedBox(height: 32),

            // View on Explorer Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openContractOnExplorer,
                icon: const Icon(Icons.open_in_new),
                label: Text('View on ${BlockchainConstants.explorerName}'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Redeployment Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      const Text(
                        'About Contract Redeployment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• You only need to redeploy the contract if you change the circuit\n'
                    '• Each ZK circuit has its own specific verification contract\n'
                    '• The same contract can verify multiple proofs from the same circuit\n'
                    '• If verification fails, the issue might be with the proof or inputs',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),

                  // Contract redeployment button
                  _isContractValid
                      ? Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle,
                                  color: Colors.green.shade700, size: 20),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Contract is deployed and working correctly',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: _openRedeploymentGuide,
                          icon: const Icon(Icons.upload),
                          label: const Text('Redeploy Contract'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            minimumSize: const Size(double.infinity, 0),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    VoidCallback? onCopy,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            if (onCopy != null)
              IconButton(
                icon: const Icon(Icons.copy, size: 20),
                onPressed: onCopy,
                color: Colors.grey,
              ),
          ],
        ),
      ),
    );
  }

  /// Open a dialog with redeployment instructions
  Future<void> _openRedeploymentGuide() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.settings_suggest, color: Colors.orange),
            SizedBox(width: 8),
            Text('Contract Redeployment Guide'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Follow these steps to redeploy the verification contract:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                  '1. Generate the verifier contract from your circuit:'),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'snarkjs zkey export solidityverifier multiplier2_final.zkey verifier.sol',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
              const Text('2. Deploy the contract to Arbitrum Sepolia'),
              const SizedBox(height: 8),
              const Text('3. Update the contract address in:'),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'lib/core/constants/blockchain_constants.dart',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
              const Text(
                'Note: The circuit and verifier contract must match. If you modify the circuit, you must redeploy the contract.',
                style: TextStyle(fontStyle: FontStyle.italic),
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
  void dispose() {
    // Removed _blockchainService.dispose() as it doesn't exist
    super.dispose();
  }
}
