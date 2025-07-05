/// Écran de vérification d'âge intégré Mopro + Self Protocol
/// Interface utilisateur complète pour la vérification hybride
import 'package:flutter/material.dart';
import '../services/proof_fusion_service.dart';
import '../widgets/debug_popup.dart';
import 'qr_display_screen.dart';

class IntegratedVerificationScreen extends StatefulWidget {
  const IntegratedVerificationScreen({Key? key}) : super(key: key);

  @override
  State<IntegratedVerificationScreen> createState() =>
      _IntegratedVerificationScreenState();
}

class _IntegratedVerificationScreenState
    extends State<IntegratedVerificationScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  int _userAge = 25;
  bool _isVerifying = false;
  CombinedVerificationStatus? _currentStatus;
  CombinedProofResult? _finalResult;

  // Contrôleurs pour les étapes
  late AnimationController _stepController;
  late Animation<double> _stepAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _stepController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _stepAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _stepController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _stepController.dispose();
    super.dispose();
  }

  void _startVerification() async {
    if (_isVerifying) return;

    setState(() {
      _isVerifying = true;
      _currentStatus = null;
      _finalResult = null;
    });

    _stepController.forward();

    // Écouter le stream de vérification
    await for (final status in ProofFusionService.performCombinedVerification(
      userAge: _userAge,
      userId: 'user-${DateTime.now().millisecondsSinceEpoch}',
      useSimulation: true, // Pour les tests
    )) {
      setState(() {
        _currentStatus = status;

        if (status.isComplete && status.result != null) {
          _finalResult = status.result;
          _isVerifying = false;
        }

        if (status.error != null) {
          _isVerifying = false;
        }
      });
    }
  }

  void _showQRCode() {
    if (_finalResult == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QRDisplayScreen(
          qrData: _finalResult!.toQRString(),
          title: 'Combined Age Verification Proof',
          subtitle: 'Mopro ZK + Self Protocol',
          metadata: {
            'Proof ID': _finalResult!.proofId,
            'User ID': _finalResult!.userId,
            'Timestamp': _finalResult!.timestamp.toLocal().toString(),
            'Valid': _finalResult!.isValid ? 'Yes' : 'No',
            'Type': _finalResult!.proofType,
          },
        ),
      ),
    );
  }

  void _showDebugInfo() {
    if (_finalResult == null) return;

    showDialog(
      context: context,
      builder: (context) => DebugPopup(
        title: 'Combined Verification Debug',
        data: _finalResult!.toJson(),
      ),
    );
  }

  Widget _buildAgeSelector() {
    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Age',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _userAge.toDouble(),
                    min: 16,
                    max: 99,
                    divisions: 83,
                    label: '$_userAge years old',
                    onChanged: _isVerifying
                        ? null
                        : (value) {
                            setState(() {
                              _userAge = value.round();
                            });
                          },
                  ),
                ),
                Container(
                  width: 60,
                  alignment: Alignment.center,
                  child: Text(
                    '$_userAge',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _userAge >= 18 ? Colors.green : Colors.orange,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _userAge >= 18
                  ? '✅ Eligible for age verification'
                  : '⚠️ Must be 18 or older',
              style: TextStyle(
                color: _userAge >= 18 ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationSteps() {
    if (_currentStatus == null) return const SizedBox.shrink();

    final steps = [
      ('Mopro ZK Proof', VerificationStep.moproProof, Icons.security),
      (
        'Self Protocol ID',
        VerificationStep.selfVerification,
        Icons.credit_card
      ),
      ('Proof Fusion', VerificationStep.proofFusion, Icons.merge_type),
      ('QR Generation', VerificationStep.qrGeneration, Icons.qr_code),
      ('Complete', VerificationStep.completed, Icons.check_circle),
    ];

    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Verification Progress',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Barre de progression globale
            LinearProgressIndicator(
              value: _currentStatus!.progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _currentStatus!.error != null ? Colors.red : Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(_currentStatus!.progress * 100).round()}% Complete',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),

            // Étapes détaillées
            ...steps.map((step) {
              final (name, stepEnum, icon) = step;
              final isActive = _currentStatus!.currentStep == stepEnum;
              final isCompleted = steps.indexOf(step) <
                  steps.indexWhere((s) => s.$2 == _currentStatus!.currentStep);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      isCompleted
                          ? Icons.check_circle
                          : isActive
                              ? icon
                              : Icons.radio_button_unchecked,
                      color: isCompleted
                          ? Colors.green
                          : isActive
                              ? Colors.blue
                              : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        name,
                        style: TextStyle(
                          fontWeight:
                              isActive ? FontWeight.bold : FontWeight.normal,
                          color: isCompleted
                              ? Colors.green
                              : isActive
                                  ? Colors.blue
                                  : Colors.grey[600],
                        ),
                      ),
                    ),
                    if (isActive)
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 16),
            Text(
              _currentStatus!.message,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: _currentStatus!.error != null ? Colors.red : Colors.blue,
              ),
            ),

            if (_currentStatus!.error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _currentStatus!.error!,
                        style: TextStyle(color: Colors.red[800]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    if (_finalResult == null) return const SizedBox.shrink();

    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _finalResult!.isValid ? Icons.verified : Icons.error,
                  color: _finalResult!.isValid ? Colors.green : Colors.red,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _finalResult!.isValid
                        ? 'Verification Successful!'
                        : 'Verification Failed',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              _finalResult!.isValid ? Colors.green : Colors.red,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Résumé des vérifications
            _buildVerificationSummary(),

            const SizedBox(height: 20),

            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showQRCode,
                    icon: const Icon(Icons.qr_code),
                    label: const Text('Show QR Code'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showDebugInfo,
                    icon: const Icon(Icons.bug_report),
                    label: const Text('Debug Info'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationSummary() {
    if (_finalResult == null) return const SizedBox.shrink();

    final mopro = _finalResult!.moproProof;
    final self = _finalResult!.selfVerification;

    return Column(
      children: [
        _buildSummaryRow(
          'Mopro ZK Proof',
          mopro.isValid ? 'Valid' : 'Invalid',
          mopro.isValid ? Colors.green : Colors.red,
          Icons.security,
        ),
        _buildSummaryRow(
          'Self Protocol ID',
          self.verified ? 'Verified' : 'Failed',
          self.verified ? Colors.green : Colors.red,
          Icons.credit_card,
        ),
        _buildSummaryRow(
          'Age Verification',
          self.disclosures?.ageVerified == true ? 'Age >= 18' : 'Not verified',
          self.disclosures?.ageVerified == true ? Colors.green : Colors.red,
          Icons.cake,
        ),
        _buildSummaryRow(
          'OFAC Check',
          self.disclosures?.ofacCheck == true ? 'Passed' : 'Not checked',
          self.disclosures?.ofacCheck == true ? Colors.green : Colors.orange,
          Icons.gavel,
        ),
        if (self.disclosures?.nationality != null)
          _buildSummaryRow(
            'Nationality',
            self.disclosures!.nationality!,
            Colors.blue,
            Icons.flag,
          ),
      ],
    );
  }

  Widget _buildSummaryRow(
      String label, String value, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mopro + Self Protocol'),
            Text(
              'Hybrid Age Verification',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('How it works'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                          'This app combines two powerful technologies:'),
                      const SizedBox(height: 12),
                      const Text(
                          '🔹 Mopro SDK: Generates zero-knowledge proofs'),
                      const Text('🔹 Self Protocol: Verifies real identity'),
                      const SizedBox(height: 12),
                      const Text(
                          'Together, they create a secure, private, and verifiable age proof.'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Sélecteur d'âge
              _buildAgeSelector(),
              const SizedBox(height: 16),

              // Bouton de démarrage de la vérification
              if (!_isVerifying && _finalResult == null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _userAge >= 18 ? _startVerification : null,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Verification'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

              // Bouton de redémarrage
              if (!_isVerifying && _finalResult != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _finalResult = null;
                        _currentStatus = null;
                      });
                      _stepController.reset();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Start New Verification'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Étapes de vérification
              if (_currentStatus != null)
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: const Offset(0, 0),
                  ).animate(_stepAnimation),
                  child: _buildVerificationSteps(),
                ),

              // Résultat final
              if (_finalResult != null) ...[
                const SizedBox(height: 16),
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: const Offset(0, 0),
                  ).animate(_stepAnimation),
                  child: _buildResultCard(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
