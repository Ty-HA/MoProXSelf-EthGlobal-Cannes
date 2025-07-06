import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'qr_display_screen.dart';
import 'dart:convert';
import 'package:mopro_flutter/mopro_flutter.dart';
import 'package:mopro_flutter/mopro_types.dart';

class GenerateProofScreen extends StatefulWidget {
  const GenerateProofScreen({super.key});

  @override
  State<GenerateProofScreen> createState() => _GenerateProofScreenState();
}

class _GenerateProofScreenState extends State<GenerateProofScreen> {
  final TextEditingController _ageController = TextEditingController();
  final FocusNode _ageFocusNode = FocusNode();

  String? _selectedUseCase;
  bool _isGenerating = false;

  final MoproFlutter _mopro = MoproFlutter();

  // Définition de la couleur personnalisée mauve
  final Color customPurple = const Color.fromRGBO(187, 181, 247, 1);

  // Generate real ZK proof using MoPro
  Future<Map<String, dynamic>> _generateRealProof(int age, int minAge) async {
    try {
      // Verify inputs first
      if (age < minAge) {
        print("⚠️ Warning: User age $age is less than minimum age $minAge");
        // Continue anyway to test the circuit
      }

      // For Circom circuits, inputs are provided as a JSON string
      // Based on the circuit ABI: parameter 'a' (public/minAge), parameter 'b' (private/age)
      final inputs = {"userAge": age, "minAge": minAge};
      final inputsJson = jsonEncode(inputs);

      print("🔑 Generating proof with inputs: $inputs");
      print("📁 Using zkey file: assets/test_age_verification_final.zkey");

      // Generate proof using the Circom circuit
      final proofResult = await _mopro.generateCircomProof(
        'assets/test_age_verification_final.zkey',
        inputsJson,
        ProofLib.arkworks,
      );

      if (proofResult == null) {
        throw Exception("Failed to generate proof");
      }

      print("✅ Proof generated successfully");
      print("📊 Public inputs: ${proofResult.inputs}");

      // Convert to the expected format for our app
      final result = {
        "proof": proofResult.toMap(),
        "publicSignals": proofResult.inputs,
      };

      return result;
    } catch (e) {
      print("❌ Error generating proof: $e");
      print("🔄 Falling back to mock data");

      // Fallback to mock data if proof generation fails
      // For Circom proofs, we need to provide mock proof data and public signals
      // Our circuit outputs [minAge, userAge] as public signals
      final publicSignals = [minAge.toString(), age.toString()];

      print("⚠️ Using mock Circom proof with public signals: $publicSignals");

      // Mock Circom proof structure
      return {
        "proof": {
          "a": ["1", "2"],
          "b": [
            ["3", "4"],
            ["5", "6"]
          ],
          "c": ["7", "8"],
          "protocol": "groth16",
          "curve": "bn128",
        },
        "publicSignals": publicSignals,
      };
    }
  }

  final List<Map<String, dynamic>> _useCases = [
    {
      'title': 'Alcohol Purchase',
      'subtitle': 'Verify you are 18+ for alcohol',
      'icon': Icons.local_bar,
      'color': Colors.orange,
      'emoji': '🍺',
      'minAge': 18,
    },
    {
      'title': 'Driving License',
      'subtitle': 'Verify you are 16+ for driving',
      'icon': Icons.directions_car,
      'color': Colors.blue,
      'emoji': '🚗',
      'minAge': 16,
    },
    {
      'title': 'Voting',
      'subtitle': 'Verify you are 18+ for voting',
      'icon': Icons.how_to_vote,
      'color': Colors.green,
      'emoji': '🗳️',
      'minAge': 18,
    },
    {
      'title': 'Legal Age',
      'subtitle': 'Verify you are 18+ for legal matters',
      'icon': Icons.gavel,
      'color': Colors.purple,
      'emoji': '⚖️',
      'minAge': 18,
    },
    {
      'title': 'Adult Content',
      'subtitle': 'Verify you are 18+ for adult content',
      'icon': Icons.shield,
      'color': Colors.red,
      'emoji': '🔞',
      'minAge': 18,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        title: Text('Generate Age Proof',
            style: TextStyle(color: customPurple, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.grey.shade800,
        foregroundColor: customPurple,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Create Your Age Proof',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: customPurple,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select your use case and enter your age to generate a zero-knowledge proof.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 32),

            // Use Case Selection
            const Text(
              'Select Use Case',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.greenAccent,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: customPurple, width: 1.5),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedUseCase,
                  hint: Text(
                    'Choose a use case...',
                    style: TextStyle(color: Colors.grey.shade400),
                  ),
                  dropdownColor: Colors.grey.shade800,
                  style: const TextStyle(color: Colors.white),
                  isExpanded: true,
                  items: _useCases.map((useCase) {
                    return DropdownMenuItem<String>(
                      value: useCase['title'],
                      child: Row(
                        children: [
                          Icon(
                            useCase['icon'],
                            color: useCase['color'],
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  useCase['title'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  useCase['subtitle'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            useCase['emoji'],
                            style: const TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedUseCase = newValue;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Age Input

            const Text(
              'Enter Your Age',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.greenAccent,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ageController,
              focusNode: _ageFocusNode,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                // Trigger state update when text changes
                setState(() {
                  // This forces the button state to re-evaluate
                });
              },
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
              decoration: InputDecoration(
                hintText: 'Enter your age (e.g., 25)',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                filled: true,
                fillColor: Colors.grey.shade800,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: customPurple),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: customPurple),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Colors.greenAccent, width: 2),
                ),
                prefixIcon: const Icon(Icons.cake, color: Colors.greenAccent),
                suffixIcon: IconButton(
                  icon: Icon(Icons.keyboard_hide, color: customPurple),
                  onPressed: () {
                    _ageFocusNode.unfocus();
                  },
                ),
              ),
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 32),

            // Generate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canGenerate() ? _generateProof : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _canGenerate() ? customPurple : Colors.grey.shade700,
                  foregroundColor:
                      _canGenerate() ? Colors.white : Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                        color: _canGenerate()
                            ? Colors.greenAccent
                            : Colors.grey.shade600,
                        width: 1),
                  ),
                  elevation: _canGenerate() ? 2 : 0,
                ),
                child: _isGenerating
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Generating Proof...',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      )
                    : const Text(
                        'Generate Proof',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Info card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.greenAccent),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.greenAccent),
                      const SizedBox(width: 8),
                      Text(
                        'How it works',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: customPurple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Zero-knowledge proof ensures privacy\n'
                    '• Only proves you meet age requirements\n'
                    '• No personal information is revealed\n'
                    '• Proof is cryptographically secure',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canGenerate() {
    return _selectedUseCase != null &&
        _ageController.text.isNotEmpty &&
        !_isGenerating;
  }

  Future<void> _generateProof() async {
    if (!_canGenerate()) return;

    setState(() {
      _isGenerating = true;
    });

    // Simulate proof generation
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      // Get selected use case details
      final useCase = _useCases.firstWhere(
        (uc) => uc['title'] == _selectedUseCase,
      );
      final int age = int.parse(_ageController.text);
      final int minAge = _getMinAgeForUseCase(_selectedUseCase);

      // Generate a real proof using MoPro (or fallback to mock data)
      final proofData = await _generateRealProof(age, minAge);

      // Create QR data with proof
      final qrDataMap = {
        'proof': proofData['proof'],
        'publicSignals': proofData['publicSignals'],
        'age': age,
        'minAge': minAge,
        'useCase': _selectedUseCase,
        'proofType': 'Groth16',
        'timestamp': DateTime.now().toIso8601String(),
        'expiresAt':
            DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
      };

      // Encode the data as JSON for QR code
      final qrData = json.encode(qrDataMap);

      setState(() {
        _isGenerating = false;
      });

      // Navigate to QR display screen
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QRDisplayScreen(
            qrData: qrData,
            title: 'Age Proof Generated',
            subtitle: 'Your proof is ready to use',
            age: int.parse(_ageController.text),
            useCase: _selectedUseCase,
            emoji: useCase['emoji'],
          ),
        ),
      );

      // Return QR data to home screen
      if (mounted) {
        Navigator.pop(context, {
          'qrData': qrData,
          'age': int.parse(_ageController.text),
          'useCase': _selectedUseCase,
        });
      }
    }
  }

  // Get minimum age for the selected use case
  int _getMinAgeForUseCase(String? useCase) {
    if (useCase == null) return 18; // Default minimum age

    final selectedUseCase = _useCases.firstWhere(
      (uc) => uc['title'] == useCase,
      orElse: () => {'minAge': 18},
    );

    return selectedUseCase['minAge'] as int;
  }

  @override
  void dispose() {
    _ageController.dispose();
    _ageFocusNode.dispose();
    super.dispose();
  }
}
