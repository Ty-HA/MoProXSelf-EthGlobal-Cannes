import 'package:flutter_test/flutter_test.dart';
import 'package:mopro_x_self_ethglobal_cannes/services/age_verification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('AgeVerificationService Tests', () {
    late AgeVerificationService service;

    setUp(() {
      service = AgeVerificationService();
    });

    test('Valid age verification (18 years)', () async {
      final result = await service.verifyAge(18);

      expect(result.isValid, true);
      expect(result.error, null);
      expect(result.proof, isNotNull);
      print('✅ Test 18 years: ${result.toString()}');
    });

    test('Valid age verification (25 years)', () async {
      final result = await service.verifyAge(25);

      expect(result.isValid, true);
      expect(result.error, null);
      expect(result.proof, isNotNull);
      print('✅ Test 25 years: ${result.toString()}');
    });

    test('Insufficient age verification (17 years)', () async {
      final result = await service.verifyAge(17);

      expect(result.isValid, false);
      expect(result.error, contains('Age requirement not met'));
      expect(result.proof, null);
      print('❌ Test 17 years: ${result.toString()}');
    });

    test('Age verification with specific use case', () async {
      final result = await service.verifyAge(
        20,
        minAge: 21,
        useCase: 'vehicle_rental',
      );

      expect(result.isValid, false);
      expect(result.error, contains('Age requirement not met'));
      print('🚗 Vehicle rental test: ${result.toString()}');
    });

    test('French legal constants', () {
      expect(FrenchLegalConstants.MAJORITE_CIVILE, 18);
      expect(FrenchLegalConstants.AGE_ALCOOL, 18);
      expect(FrenchLegalConstants.AGE_CONDUITE, 18);
      expect(FrenchLegalConstants.AGE_VOTE, 18);

      expect(AgeVerificationService.getMinimumAge('civil_majority'), 18);
      expect(AgeVerificationService.getMinimumAge('vehicle_rental'), 21);

      final useCases = AgeVerificationService.getAvailableUseCases();
      expect(useCases.contains('civil_majority'), true);
      expect(useCases.contains('alcohol_purchase'), true);

      print('🇫🇷 French legal constants validated');
      print('📋 Use cases: $useCases');
    });

    test('Input validation', () async {
      // Negative age
      final result1 = await service.verifyAge(-5);
      expect(result1.isValid, false);
      expect(result1.error, contains('Invalid age'));

      // Age too high
      final result2 = await service.verifyAge(150);
      expect(result2.isValid, false);
      expect(result2.error, contains('Invalid age'));

      print('⚠️ Input validation tested');
    });

    test('ZK proof structure', () async {
      final result = await service.verifyAge(20);

      expect(result.isValid, true);
      expect(result.proof, isNotNull);

      final proof = result.proof!;
      expect(proof['protocol'], anyOf('groth16', 'simulated'));
      expect(proof['curve'], anyOf('bn128', 'simulated'));
      expect(proof['public_inputs'], isNotNull);
      expect(proof['generated_at'], isNotNull);

      print('🔐 ZK proof structure: ${proof.keys.toList()}');
      print('📊 Public inputs: ${proof['public_inputs']}');
    });

    test('QR code generation', () async {
      final result = await service.verifyAge(20);
      
      expect(result.isValid, true);
      expect(result.proof, isNotNull);

      final qrData = result.toQRCodeData();
      expect(qrData, isNotNull);
      expect(qrData.length, greaterThan(0));

      print('📱 QR code data generated: ${qrData.substring(0, 50)}...');
    });
  });
}
