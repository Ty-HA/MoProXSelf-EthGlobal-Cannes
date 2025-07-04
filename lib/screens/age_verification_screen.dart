import 'package:flutter/material.dart';
import 'package:mopro_x_self_ethglobal_cannes/services/age_verification_service.dart';
import 'package:mopro_x_self_ethglobal_cannes/screens/qr_code_screen.dart';
import 'package:mopro_x_self_ethglobal_cannes/screens/qr_code_scanner_screen.dart';

class AgeVerificationScreen extends StatefulWidget {
  const AgeVerificationScreen({super.key});

  @override
  State<AgeVerificationScreen> createState() => _AgeVerificationScreenState();
}

class _AgeVerificationScreenState extends State<AgeVerificationScreen>
    with TickerProviderStateMixin {
  final TextEditingController _ageController = TextEditingController();
  final AgeVerificationService _service = AgeVerificationService();

  bool _isVerifying = false;
  AgeVerificationResult? _result;
  String _selectedUseCase = 'civil_majority';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'ZK Age Verification 🔐',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const QRCodeScannerScreen(),
                ),
              );
            },
            tooltip: 'Scan QR Code',
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 30),
                    _buildUseCaseSelector(),
                    const SizedBox(height: 20),
                    _buildAgeInput(),
                    const SizedBox(height: 30),
                    _buildVerifyButton(),
                    const SizedBox(height: 30),
                    if (_result != null) _buildResult(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[100]!, Colors.indigo[100]!],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.verified_user,
              size: 48,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Anonymous Age Verification',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Prove your age without revealing\nyour personal information',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUseCaseSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Use Case',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedUseCase,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.description),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: _getUseCaseOptions(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedUseCase = value;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAgeInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Age',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ageController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => FocusScope.of(context).unfocus(),
            decoration: InputDecoration(
              hintText: 'Enter your age',
              prefixIcon: const Icon(Icons.cake),
              suffixIcon: IconButton(
                icon: const Icon(Icons.keyboard_hide),
                onPressed: () => FocusScope.of(context).unfocus(),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              helperText: '🔒 This information remains private',
              helperStyle: TextStyle(
                color: Colors.green[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyButton() {
    final minAge =
        FrenchLegalConstants.AGE_REQUIREMENTS[_selectedUseCase] ?? 18;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isVerifying ? null : _verifyAge,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        child: _isVerifying
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Generating ZK Proof...',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              )
            : Text(
                'Verify My Age (min. $minAge years)',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Widget _buildResult() {
    final isValid = _result!.isValid;
    final minAge =
        FrenchLegalConstants.AGE_REQUIREMENTS[_selectedUseCase] ?? 18;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isValid ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isValid ? Colors.green[300]! : Colors.red[300]!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isValid ? Colors.green : Colors.red).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isValid ? Colors.green[100] : Colors.red[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isValid ? Icons.check_circle : Icons.error,
                  color: isValid ? Colors.green[700] : Colors.red[700],
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isValid
                          ? 'Verification Successful ✅'
                          : 'Verification Failed ❌',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isValid ? Colors.green[800] : Colors.red[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isValid
                          ? 'You are authorized for: ${_selectedUseCase.replaceAll('_', ' ')}'
                          : _result!.error ??
                              'You must be $minAge years old or older',
                      style: TextStyle(
                        fontSize: 14,
                        color: isValid ? Colors.green[700] : Colors.red[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isValid && _result!.proof != null) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              '🔐 ZK Proof generated successfully',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Protocol: ${_result!.proof!['protocol']?.toUpperCase()}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green[600],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QRCodeScreen(result: _result!),
                    ),
                  );
                },
                icon: const Icon(Icons.qr_code),
                label: const Text('Generate QR Code'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> _getUseCaseOptions() {
    final Map<String, String> useCaseLabels = {
      'civil_majority': 'Civil Majority',
      'alcohol_purchase': 'Alcohol Purchase',
      'driving_license': 'Driving License',
      'voting_rights': 'Voting Rights',
      'bank_account_opening': 'Bank Account Opening',
      'casino_access': 'Casino Access',
      'vehicle_rental': 'Vehicle Rental',
    };

    return FrenchLegalConstants.AGE_REQUIREMENTS.entries.map((entry) {
      final label = useCaseLabels[entry.key] ?? entry.key.replaceAll('_', ' ');
      return DropdownMenuItem(
        value: entry.key,
        child: Text('$label (${entry.value}+ years)'),
      );
    }).toList();
  }

  Future<void> _verifyAge() async {
    final ageText = _ageController.text.trim();
    if (ageText.isEmpty) {
      _showSnackBar('Please enter your age', isError: true);
      return;
    }

    final age = int.tryParse(ageText);
    if (age == null) {
      _showSnackBar('Please enter a valid age', isError: true);
      return;
    }

    setState(() {
      _isVerifying = true;
      _result = null;
    });

    try {
      final minAge =
          FrenchLegalConstants.AGE_REQUIREMENTS[_selectedUseCase] ?? 18;
      final result = await _service.verifyAge(
        age,
        minAge: minAge,
        useCase: _selectedUseCase,
      );

      setState(() {
        _result = result;
      });

      if (result.isValid) {
        _showSnackBar('🎉 Verification successful!', isError: false);
      } else {
        _showSnackBar('❌ Verification failed', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    } finally {
      setState(() {
        _isVerifying = false;
      });
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[600] : Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
