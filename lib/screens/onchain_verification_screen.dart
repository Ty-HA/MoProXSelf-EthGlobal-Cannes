/// Exemple d'utilisation de la vérification on-chain
/// Pour votre projet EthGlobal Cannes

import 'package:flutter/material.dart';
import '../services/onchain_verification_service.dart';

class OnChainVerificationScreen extends StatefulWidget {
  final Map<String, dynamic> proofData;

  const OnChainVerificationScreen({
    super.key,
    required this.proofData,
  });

  @override
  State<OnChainVerificationScreen> createState() =>
      _OnChainVerificationScreenState();
}

class _OnChainVerificationScreenState extends State<OnChainVerificationScreen> {
  final OnChainVerificationService _verificationService =
      OnChainVerificationService();
  bool _isLoading = false;
  String _status = '';
  bool? _verificationResult;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    setState(() {
      _isLoading = true;
      _status = 'Connexion au réseau Ethereum...';
    });

    try {
      await _verificationService.initialize();
      setState(() {
        _status = 'Prêt pour la vérification on-chain';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Erreur de connexion: $e';
        _isLoading = false;
      });
    }
  }

  /// Vérification READ-ONLY (recommandée - pas de wallet)
  Future<void> _verifyReadOnly() async {
    setState(() {
      _isLoading = true;
      _status = 'Vérification on-chain (read-only)...';
      _verificationResult = null;
    });

    try {
      final result =
          await _verificationService.verifyProofReadOnly(widget.proofData);

      setState(() {
        _verificationResult = result;
        _status = result
            ? '✅ Preuve vérifiée on-chain avec succès!'
            : '❌ Preuve rejetée par le contrat smart';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = '❌ Erreur lors de la vérification: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vérification On-Chain'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
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
                    Text(
                      'Status de la vérification',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(_status),
                    if (_isLoading) ...[
                      const SizedBox(height: 8),
                      const LinearProgressIndicator(),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Proof Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informations de la preuve',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('Réseau: Sepolia Testnet'),
                    Text(
                        'Contrat: ${OnChainVerificationService.VERIFIER_CONTRACT_ADDRESS}'),
                    Text('Type: Groth16 ZK-SNARK'),
                    Text('Circuit: multiplier2'),
                    if (_verificationResult != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _verificationResult!
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _verificationResult!
                              ? 'PREUVE VALIDE ✅'
                              : 'PREUVE INVALIDE ❌',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _verificationResult!
                                ? Colors.green.shade800
                                : Colors.red.shade800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Verification Methods
            Text(
              'Méthodes de vérification',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // Read-Only Verification (Recommended)
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _verifyReadOnly,
              icon: const Icon(Icons.search),
              label: const Text('Vérifier (Read-Only)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 8),
            Text(
              'Recommandé: Vérification gratuite sans wallet',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Transaction-based verification (disabled for demo)
            ElevatedButton.icon(
              onPressed: null, // Désactivé pour la démo
              icon: const Icon(Icons.account_balance_wallet),
              label: const Text('Vérifier avec Transaction'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 8),
            Text(
              'Nécessite un wallet et des gas fees (désactivé)',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Info section
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💡 Information',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'La vérification "Read-Only" est gratuite et ne nécessite pas de wallet. '
                      'Elle lit simplement les données du smart contract pour valider votre preuve ZK.',
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
