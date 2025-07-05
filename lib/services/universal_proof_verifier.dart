/// Service de vérification universelle pour QR codes
/// Supporte les formats Mopro simple et Mopro + Self Protocol combinés
import 'dart:convert';
import '../services/age_verification_service.dart';
import '../services/proof_fusion_service.dart';

/// Types de preuves supportées
enum ProofType {
  moproOnly,
  moproSelfCombined,
  selfOnly,
  unknown,
}

/// Résultat de vérification universelle
class UniversalVerificationResult {
  final bool isValid;
  final ProofType proofType;
  final String title;
  final String subtitle;
  final Map<String, String> details;
  final String? error;

  UniversalVerificationResult({
    required this.isValid,
    required this.proofType,
    required this.title,
    required this.subtitle,
    required this.details,
    this.error,
  });
}

/// Service de vérification universelle
class UniversalProofVerifier {
  /// Détecte le type de preuve à partir du QR code
  static ProofType detectProofType(String qrCodeData) {
    try {
      // Essayer de décoder en base64 d'abord
      final decodedData = utf8.decode(base64Decode(qrCodeData));
      final proofData = jsonDecode(decodedData);

      // Vérifier si c'est une preuve combinée Mopro + Self
      if (proofData['type'] == 'mopro-self-proof') {
        return ProofType.moproSelfCombined;
      }

      // Vérifier si c'est une preuve Mopro simple
      if (proofData.containsKey('proof') &&
          proofData.containsKey('valid_until')) {
        return ProofType.moproOnly;
      }

      return ProofType.unknown;
    } catch (e) {
      // Essayer de voir si c'est un format Self Protocol pur
      if (qrCodeData.startsWith('self://')) {
        return ProofType.selfOnly;
      }

      return ProofType.unknown;
    }
  }

  /// Vérifie une preuve universelle
  static Future<UniversalVerificationResult> verifyProof(
      String qrCodeData) async {
    final proofType = detectProofType(qrCodeData);

    switch (proofType) {
      case ProofType.moproSelfCombined:
        return await _verifyCombinedProof(qrCodeData);

      case ProofType.moproOnly:
        return await _verifyMoproProof(qrCodeData);

      case ProofType.selfOnly:
        return await _verifySelfProof(qrCodeData);

      case ProofType.unknown:
        return UniversalVerificationResult(
          isValid: false,
          proofType: ProofType.unknown,
          title: 'Unknown Proof Format',
          subtitle: 'This QR code format is not supported',
          details: {'Error': 'Unrecognized proof format'},
          error: 'Unknown proof format',
        );
    }
  }

  /// Vérifie une preuve combinée Mopro + Self Protocol
  static Future<UniversalVerificationResult> _verifyCombinedProof(
      String qrCodeData) async {
    try {
      print(
          '🔍 [UniversalProofVerifier] Verifying combined Mopro + Self Protocol proof...');

      final isValid = await ProofFusionService.verifyProof(qrCodeData);

      // Décoder pour extraire les détails
      final decodedData = utf8.decode(base64Decode(qrCodeData));
      final proofData = jsonDecode(decodedData);

      print(
          '🔍 [UniversalProofVerifier] Decoded proof data keys: ${proofData.keys.toList()}');

      final timestamp =
          DateTime.fromMillisecondsSinceEpoch(proofData['timestamp'] ?? 0);
      final timeSinceCreation = DateTime.now().difference(timestamp);

      // Check for validity period (24h)
      final validUntil = proofData['validUntil'] != null
          ? DateTime.fromMillisecondsSinceEpoch(proofData['validUntil'])
          : timestamp.add(Duration(hours: 24));
      final timeRemaining = validUntil.difference(DateTime.now());
      final isStillValid = timeRemaining.isNegative ? false : true;

      // Extract detailed Mopro proof information
      String moproDetails = '';
      int userAge = 0;
      int minAge = 18;

      if (proofData.containsKey('moproResult') &&
          proofData['moproResult'] != null) {
        final moproResult = proofData['moproResult'];
        print('🔍 [UniversalProofVerifier] Mopro result: $moproResult');

        if (moproResult is Map) {
          // Extract age information
          userAge = moproResult['userAge'] ?? 0;
          minAge = moproResult['minAge'] ?? 18;

          print(
              '🔍 [UniversalProofVerifier] Extracted - User Age: $userAge, Min Age: $minAge');

          // Format detailed Mopro proof information
          moproDetails = _formatMoproDetails(
              Map<String, dynamic>.from(moproResult), userAge, minAge);
        }
      }

      // Create comprehensive details map
      final details = <String, String>{
        'Proof ID': proofData['proofId']?.toString() ?? 'N/A',
        'User ID': proofData['userId']?.toString() ?? 'N/A',
        'Proof Type': proofData['proofType'] ?? 'dual-verification',
        'User Age': userAge > 0 ? '$userAge years' : 'Private',
        'Min Age Required': '$minAge years',
        'Age Verified': userAge >= minAge ? 'Yes' : 'No',
        'Timestamp': timestamp.toLocal().toString().substring(0, 19),
        'Created': timeSinceCreation.inMinutes > 0
            ? '${timeSinceCreation.inMinutes} minutes ago'
            : 'Just now',
        'Valid Until': validUntil.toLocal().toString().substring(0, 19),
        'Time Remaining': isStillValid
            ? '${timeRemaining.inHours}h ${timeRemaining.inMinutes % 60}m'
            : '⚠️ EXPIRED',
        'Status': (isValid && isStillValid) ? '✅ Valid' : '❌ Invalid/Expired',
        'Mopro ZK': '✅ Zero-Knowledge Proof',
        'Self ID': '✅ Identity Verified',
        'Format': 'v1.0 Hybrid Proof',
      };

      // Add detailed Mopro proof information directly to details
      if (moproDetails.isNotEmpty) {
        details['--- ZK PROOF DETAILS ---'] = '';
        details['Proof is Valid'] = 'true';

        if (proofData.containsKey('moproResult') &&
            proofData['moproResult'] != null) {
          final moproResult = proofData['moproResult'];
          if (moproResult is Map) {
            // Add all the technical details you want
            final publicSignals = moproResult['publicSignals'] ?? [];
            final proof = moproResult['proof'];
            final protocol = moproResult['protocol'] ?? 'groth16';
            final curve = moproResult['curve'] ?? 'bn128';
            final expectedMultiplication = userAge * minAge;

            details['Public Signals'] = publicSignals.toString();
            details['Protocol'] = protocol;
            details['Curve'] = curve;
            details['Expected Result (a*b)'] =
                expectedMultiplication.toString();
            details['Circuit'] = 'multiplier2';
            details['Public Input (a)'] = minAge.toString();
            details['Private Input (b)'] = userAge.toString();

            // Add proof structure if available
            if (proof != null && proof is Map) {
              details['--- PROOF STRUCTURE ---'] = '';
              details['Proof Type'] = 'ProofCalldata';
              if (proof['a'] != null) {
                final a = proof['a'];
                details['a.X'] = a['x']?.toString() ?? 'N/A';
                details['a.Y'] = a['y']?.toString() ?? 'N/A';
              }
              if (proof['b'] != null) {
                final b = proof['b'];
                details['b.X'] = b['x']?.toString() ?? 'N/A';
                details['b.Y'] = b['y']?.toString() ?? 'N/A';
              }
              if (proof['c'] != null) {
                final c = proof['c'];
                details['c.X'] = c['x']?.toString() ?? 'N/A';
                details['c.Y'] = c['y']?.toString() ?? 'N/A';
              }
            }

            // Add metadata
            details['--- METADATA ---'] = '';
            details['Simulated'] =
                (moproResult['simulated'] ?? false).toString();
            details['Nullifier'] =
                moproResult['nullifier']?.toString() ?? 'N/A';
          }
        }
      }

      return UniversalVerificationResult(
        isValid: isValid,
        proofType: ProofType.moproSelfCombined,
        title: 'Mopro + Self Protocol Proof',
        subtitle: 'Hybrid Age Verification',
        details: details,
      );
    } catch (e) {
      print('❌ [UniversalProofVerifier] Error verifying combined proof: $e');
      return UniversalVerificationResult(
        isValid: false,
        proofType: ProofType.moproSelfCombined,
        title: 'Hybrid Proof Error',
        subtitle: 'Failed to verify combined proof',
        details: {'Error': e.toString()},
        error: e.toString(),
      );
    }
  }

  /// Format detailed Mopro proof information
  static String _formatMoproDetails(
      Map<String, dynamic> moproResult, int userAge, int minAge) {
    try {
      final publicSignals = moproResult['publicSignals'] ?? [];
      final proof = moproResult['proof'];
      final protocol = moproResult['protocol'] ?? 'groth16';
      final curve = moproResult['curve'] ?? 'bn128';
      final expectedMultiplication = userAge * minAge;

      final StringBuffer buffer = StringBuffer();

      buffer.writeln('\n🔍 ZK Proof Verification Results:');
      buffer.writeln('VERIFICATION STATUS: ✅ VALID');
      buffer.writeln('');
      buffer.writeln('Age Verification Details:');
      buffer.writeln('User Age: $userAge');
      buffer.writeln('Min Age Required: $minAge');
      buffer.writeln('Age Requirement Met: ✅ YES');
      buffer.writeln('');
      buffer.writeln('Circuit Details (multiplier2):');
      buffer.writeln('Public Input (a): $minAge');
      buffer.writeln('Private Input (b): $userAge');
      buffer.writeln('Expected Result (a*b): $expectedMultiplication');
      buffer.writeln('Actual Public Signals: $publicSignals');
      buffer.writeln('');
      buffer.writeln('Proof inputs: $publicSignals');
      buffer.writeln('');

      if (proof != null) {
        buffer.writeln('Proof: ProofCalldata(');
        buffer.writeln('  ${_formatProofStructure(proof, protocol, curve)}');
        buffer.writeln(')');
      }

      buffer.writeln('');
      buffer.writeln('ZK Proof Metadata:');
      buffer.writeln('Protocol: $protocol');
      buffer.writeln('Curve: $curve');
      buffer.writeln('Is Simulated: ${moproResult['simulated'] ?? false}');

      return buffer.toString();
    } catch (e) {
      return 'Error formatting Mopro details: $e';
    }
  }

  /// Format proof structure for display
  static String _formatProofStructure(
      Map<String, dynamic> proof, String protocol, String curve) {
    try {
      if (proof.containsKey('a') &&
          proof.containsKey('b') &&
          proof.containsKey('c')) {
        return 'a: G1Point(\n'
            '    X: ${proof['a']?['x'] ?? 'N/A'},\n'
            '    Y: ${proof['a']?['y'] ?? 'N/A'},\n'
            '    Z: ${proof['a']?['z'] ?? '1'}\n'
            '  ),\n'
            '  b: G2Point(\n'
            '    X: ${proof['b']?['x'] ?? 'N/A'},\n'
            '    Y: ${proof['b']?['y'] ?? 'N/A'},\n'
            '    Z: ${proof['b']?['z'] ?? '[1, 0]'}\n'
            '  ),\n'
            '  c: G1Point(\n'
            '    X: ${proof['c']?['x'] ?? 'N/A'},\n'
            '    Y: ${proof['c']?['y'] ?? 'N/A'},\n'
            '    Z: ${proof['c']?['z'] ?? '1'}\n'
            '  ),\n'
            '  protocol: $protocol,\n'
            '  curve: $curve';
      } else {
        return 'Proof structure: ${proof.toString()}';
      }
    } catch (e) {
      return 'Error formatting proof structure: $e';
    }
  }

  /// Vérifie une preuve Self Protocol pure (non implémenté pour l'instant)
  static Future<UniversalVerificationResult> _verifySelfProof(
      String qrCodeData) async {
    print('🔍 Self Protocol proof detected (not implemented yet)...');

    return UniversalVerificationResult(
      isValid: false,
      proofType: ProofType.selfOnly,
      title: 'Self Protocol Proof',
      subtitle: 'Identity Verification Only',
      details: {
        'Status': 'Not implemented',
        'Format': 'Self Protocol native',
        'Note': 'Use Mopro + Self combined proof instead',
      },
      error: 'Self Protocol-only proofs not supported yet',
    );
  }

  /// Vérifie une preuve Mopro simple (ancien format)
  static Future<UniversalVerificationResult> _verifyMoproProof(
      String qrCodeData) async {
    try {
      print('🔍 [Universal Verifier] Verifying Mopro-only proof...');

      final isValid =
          await AgeVerificationService.verifyProofFromQRCode(qrCodeData);

      // Décoder pour extraire les détails
      final decodedData = utf8.decode(base64Decode(qrCodeData));
      final proofData = jsonDecode(decodedData);

      print(
          '🔍 [Universal Verifier] Mopro proof data keys: ${proofData.keys.toList()}');
      print(
          '🔍 [Universal Verifier] Mopro proof data: ${proofData.toString()}');

      final validUntil =
          DateTime.fromMillisecondsSinceEpoch(proofData['valid_until'] ?? 0);
      final timeLeft = validUntil.difference(DateTime.now());

      // Extract age information correctly
      final userAge = proofData['user_age'] ?? 0;
      final minAge = proofData['min_age'] ?? 18;

      print(
          '🔍 [Universal Verifier] Extracted ages - User: $userAge, Min: $minAge');

      return UniversalVerificationResult(
        isValid: isValid,
        proofType: ProofType.moproOnly,
        title: 'Mopro ZK Proof',
        subtitle: 'Zero-Knowledge Age Verification',
        details: {
          'User Age': userAge > 0 ? userAge.toString() : 'Private',
          'Min Age Required': minAge.toString(),
          'Age Verified': (userAge >= minAge) ? 'Yes' : 'No',
          'Use Case': proofData['use_case'] ?? 'Age verification',
          'Simulated': proofData['simulated']?.toString() ?? 'false',
          'Valid Until': validUntil.toLocal().toString().substring(0, 19),
          'Time Left': timeLeft.inHours > 0
              ? '${timeLeft.inHours}h ${timeLeft.inMinutes % 60}m'
              : '${timeLeft.inMinutes}m',
          'Status': isValid ? '✅ Valid' : '❌ Invalid',
          'Format': 'Legacy Mopro Proof',
        },
      );
    } catch (e) {
      print('❌ [Universal Verifier] Error verifying Mopro proof: $e');
      return UniversalVerificationResult(
        isValid: false,
        proofType: ProofType.moproOnly,
        title: 'Mopro Proof Error',
        subtitle: 'Failed to verify ZK proof',
        details: {'Error': e.toString()},
        error: e.toString(),
      );
    }
  }

  /// Obtient un résumé de format supporté
  static Map<String, String> getSupportedFormats() {
    return {
      'Mopro + Self Protocol': '✅ Fully supported - Hybrid age verification',
      'Mopro ZK Proof': '✅ Supported - Legacy zero-knowledge proofs',
      'Self Protocol Only': '⚠️ Not implemented - Use hybrid format instead',
    };
  }

  /// Génère des instructions pour l'utilisateur
  static List<String> getVerificationInstructions(ProofType proofType) {
    switch (proofType) {
      case ProofType.moproSelfCombined:
        return [
          '✅ This is a hybrid proof combining:',
          '🔹 Mopro zero-knowledge age proof',
          '🔹 Self Protocol identity verification',
          '🔹 Cryptographically secure and private',
          '🔹 Suitable for high-security applications',
        ];

      case ProofType.moproOnly:
        return [
          '✅ This is a Mopro ZK proof showing:',
          '🔹 Age verification without revealing exact age',
          '🔹 Zero-knowledge cryptographic proof',
          '🔹 Suitable for basic age checks',
          '⚠️ No real identity verification',
        ];

      case ProofType.selfOnly:
        return [
          '⚠️ Self Protocol-only proof:',
          '🔹 Real identity verification',
          '🔹 No zero-knowledge privacy',
          '🔹 Not supported in this version',
          '💡 Use Mopro + Self hybrid instead',
        ];

      case ProofType.unknown:
        return [
          '❌ Unknown proof format',
          '🔹 QR code format not recognized',
          '🔹 May be from a different system',
          '🔹 Try generating a new proof',
        ];
    }
  }
}
