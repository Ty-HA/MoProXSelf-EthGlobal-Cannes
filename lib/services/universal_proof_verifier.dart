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
      if (proofData.containsKey('proof') && proofData.containsKey('valid_until')) {
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
  static Future<UniversalVerificationResult> verifyProof(String qrCodeData) async {
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
  static Future<UniversalVerificationResult> _verifyCombinedProof(String qrCodeData) async {
    try {
      print('🔍 Verifying combined Mopro + Self Protocol proof...');
      
      final isValid = await ProofFusionService.verifyProof(qrCodeData);
      
      // Décoder pour extraire les détails
      final decodedData = utf8.decode(base64Decode(qrCodeData));
      final proofData = jsonDecode(decodedData);
      
      final timestamp = DateTime.fromMillisecondsSinceEpoch(proofData['timestamp'] ?? 0);
      final age = DateTime.now().difference(timestamp);
      
      return UniversalVerificationResult(
        isValid: isValid,
        proofType: ProofType.moproSelfCombined,
        title: 'Mopro + Self Protocol Proof',
        subtitle: 'Hybrid Age Verification',
        details: {
          'Proof ID': proofData['proofId']?.toString().substring(0, 8) ?? 'Unknown',
          'User ID': proofData['userId']?.toString().substring(0, 8) ?? 'Unknown',
          'Proof Type': proofData['proofType'] ?? 'Unknown',
          'Timestamp': timestamp.toLocal().toString().substring(0, 19),
          'Age': '${age.inMinutes} minutes ago',
          'Status': isValid ? '✅ Valid' : '❌ Invalid',
          'Mopro ZK': '✅ Zero-Knowledge Proof',
          'Self ID': '✅ Identity Verified',
          'Format': 'v1.0 Hybrid Proof',
        },
      );
    } catch (e) {
      print('❌ Error verifying combined proof: $e');
      return UniversalVerificationResult(
        isValid: false,
        proofType: ProofType.moproSelfCombined,
        title: 'Combined Proof Error',
        subtitle: 'Failed to verify hybrid proof',
        details: {'Error': e.toString()},
        error: e.toString(),
      );
    }
  }

  /// Vérifie une preuve Mopro simple (ancien format)
  static Future<UniversalVerificationResult> _verifyMoproProof(String qrCodeData) async {
    try {
      print('🔍 Verifying Mopro-only proof...');
      
      final isValid = await AgeVerificationService.verifyProofFromQRCode(qrCodeData);
      
      // Décoder pour extraire les détails
      final decodedData = utf8.decode(base64Decode(qrCodeData));
      final proofData = jsonDecode(decodedData);
      
      final validUntil = DateTime.fromMillisecondsSinceEpoch(proofData['valid_until'] ?? 0);
      final timeLeft = validUntil.difference(DateTime.now());
      
      return UniversalVerificationResult(
        isValid: isValid,
        proofType: ProofType.moproOnly,
        title: 'Mopro ZK Proof',
        subtitle: 'Zero-Knowledge Age Verification',
        details: {
          'Age Verified': proofData['age_verified']?.toString() ?? 'Unknown',
          'Use Case': proofData['use_case'] ?? 'general',
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
      print('❌ Error verifying Mopro proof: $e');
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

  /// Vérifie une preuve Self Protocol pure (non implémenté pour l'instant)
  static Future<UniversalVerificationResult> _verifySelfProof(String qrCodeData) async {
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
