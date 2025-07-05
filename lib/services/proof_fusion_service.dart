/// Service de fusion des preuves Mopro + Self Protocol
/// Combine les preuves ZK de Mopro avec les vérifications d'identité Self Protocol
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import '../services/age_verification_service.dart';
import '../services/self_protocol_service.dart';

/// Résultat de la preuve fusionnée
class CombinedProofResult {
  final String proofId;
  final String userId;
  final AgeVerificationResult moproProof;
  final SelfVerificationResult selfVerification;
  final String combinedHash;
  final DateTime timestamp;
  final bool isValid;
  final String proofType;

  CombinedProofResult({
    required this.proofId,
    required this.userId,
    required this.moproProof,
    required this.selfVerification,
    required this.combinedHash,
    required this.timestamp,
    required this.isValid,
    required this.proofType,
  });

  Map<String, dynamic> toJson() {
    return {
      'proofId': proofId,
      'userId': userId,
      'moproProof': {
        'isValid': moproProof.isValid,
        'proof': moproProof.proof,
        'userAge': moproProof.userAge,
        'minAge': moproProof.minAge,
        'timestamp': moproProof.timestamp.toIso8601String(),
        'nullifierHash': moproProof.nullifierHash,
      },
      'selfVerification': {
        'verified': selfVerification.verified,
        'userIdentifier': selfVerification.userIdentifier,
        'disclosures': selfVerification.disclosures?.toJson(),
        'timestamp': selfVerification.timestamp.toIso8601String(),
      },
      'combinedHash': combinedHash,
      'timestamp': timestamp.toIso8601String(),
      'isValid': isValid,
      'proofType': proofType,
    };
  }

  String toQRString() {
    final qrData = {
      'type': 'mopro-self-proof',
      'version': '1.0',
      'proofId': proofId,
      'userId': userId,
      'hash': combinedHash,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'valid': isValid,
      'proofType': proofType,
    };

    return base64.encode(utf8.encode(json.encode(qrData)));
  }
}

/// Étapes de vérification
enum VerificationStep {
  moproProof,
  selfVerification,
  proofFusion,
  qrGeneration,
  completed,
}

/// Statut de la vérification combinée
class CombinedVerificationStatus {
  final VerificationStep currentStep;
  final double progress;
  final String message;
  final bool isComplete;
  final CombinedProofResult? result;
  final String? error;

  CombinedVerificationStatus({
    required this.currentStep,
    required this.progress,
    required this.message,
    required this.isComplete,
    this.result,
    this.error,
  });

  factory CombinedVerificationStatus.step(
    VerificationStep step,
    String message,
  ) {
    final progress = switch (step) {
      VerificationStep.moproProof => 0.2,
      VerificationStep.selfVerification => 0.4,
      VerificationStep.proofFusion => 0.7,
      VerificationStep.qrGeneration => 0.9,
      VerificationStep.completed => 1.0,
    };

    return CombinedVerificationStatus(
      currentStep: step,
      progress: progress,
      message: message,
      isComplete: step == VerificationStep.completed,
    );
  }

  factory CombinedVerificationStatus.completed(CombinedProofResult result) {
    return CombinedVerificationStatus(
      currentStep: VerificationStep.completed,
      progress: 1.0,
      message: 'Verification completed successfully',
      isComplete: true,
      result: result,
    );
  }

  factory CombinedVerificationStatus.error(String error) {
    return CombinedVerificationStatus(
      currentStep: VerificationStep.moproProof,
      progress: 0.0,
      message: 'Verification failed',
      isComplete: false,
      error: error,
    );
  }
}

/// Service principal de fusion des preuves
class ProofFusionService {
  /// Génère un ID unique pour la preuve
  static String _generateProofId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (i) => random.nextInt(256));
    return base64.encode(bytes).replaceAll('/', '_').replaceAll('+', '-');
  }

  /// Génère un hash combiné des deux preuves
  static String _generateCombinedHash(
    AgeVerificationResult moproProof,
    SelfVerificationResult selfVerification,
  ) {
    final moproHash = sha256
        .convert(utf8.encode(moproProof.proof?.toString() ?? ''))
        .toString();
    final selfHash = sha256
        .convert(utf8.encode(selfVerification.userIdentifier ?? ''))
        .toString();
    final timestampHash = sha256
        .convert(utf8.encode(DateTime.now().millisecondsSinceEpoch.toString()))
        .toString();

    final combinedString = '$moproHash$selfHash$timestampHash';
    return sha256.convert(utf8.encode(combinedString)).toString();
  }

  /// Valide la cohérence des preuves
  static bool _validateProofConsistency(
    AgeVerificationResult moproProof,
    SelfVerificationResult selfVerification,
  ) {
    // Vérifier que les deux preuves confirment l'âge majeur
    if (!moproProof.isValid || !selfVerification.verified) {
      print('❌ Basic validation failed');
      return false;
    }

    // Vérifier que l'âge est cohérent
    if (selfVerification.disclosures?.ageVerified != true) {
      print('❌ Age verification inconsistent');
      return false;
    }

    // Vérifier les timestamps (pas trop anciens)
    final now = DateTime.now();
    final moproAge = now.difference(moproProof.timestamp);
    if (moproAge.inMinutes > 15) {
      print('❌ Mopro proof too old: ${moproAge.inMinutes} minutes');
      return false;
    }

    final selfAge = now.difference(selfVerification.timestamp);
    if (selfAge.inMinutes > 15) {
      print('❌ Self verification too old: ${selfAge.inMinutes} minutes');
      return false;
    }

    print('✅ Proof consistency validated');
    return true;
  }

  /// Fusionne les preuves Mopro et Self Protocol
  static Future<CombinedProofResult> combineProofs({
    required AgeVerificationResult moproProof,
    required SelfVerificationResult selfVerification,
    required String userId,
  }) async {
    print('🔄 Combining Mopro and Self Protocol proofs...');

    try {
      // Validation de la cohérence
      final isValid = _validateProofConsistency(moproProof, selfVerification);

      // Génération des identifiants
      final proofId = _generateProofId();
      final combinedHash = _generateCombinedHash(moproProof, selfVerification);

      // Détermination du type de preuve
      String proofType = 'unknown';
      if (moproProof.isValid && selfVerification.verified) {
        proofType = 'dual-verification';
      } else if (moproProof.isValid) {
        proofType = 'mopro-only';
      } else if (selfVerification.verified) {
        proofType = 'self-only';
      }

      final result = CombinedProofResult(
        proofId: proofId,
        userId: userId,
        moproProof: moproProof,
        selfVerification: selfVerification,
        combinedHash: combinedHash,
        timestamp: DateTime.now(),
        isValid: isValid,
        proofType: proofType,
      );

      print('✅ Combined proof created successfully');
      print('🆔 Proof ID: $proofId');
      print('🔐 Combined hash: ${combinedHash.substring(0, 12)}...');
      print('📋 Proof type: $proofType');
      print('✅ Valid: $isValid');

      return result;
    } catch (e) {
      print('❌ Error combining proofs: $e');
      rethrow;
    }
  }

  /// Processus complet de vérification combinée
  static Stream<CombinedVerificationStatus> performCombinedVerification({
    required int userAge,
    required String userId,
    bool useSimulation = false,
  }) async* {
    try {
      print('🚀 Starting combined verification process...');

      // Étape 1 : Génération de la preuve Mopro ZK
      yield CombinedVerificationStatus.step(
        VerificationStep.moproProof,
        'Generating zero-knowledge proof with Mopro...',
      );

      await Future.delayed(Duration(seconds: 1));

      final ageService = AgeVerificationService();
      final moproResult = await ageService.verifyAge(userAge);

      if (!moproResult.isValid) {
        yield CombinedVerificationStatus.error(
          'Mopro verification failed: ${moproResult.error}',
        );
        return;
      }

      print('✅ Mopro proof generated successfully');

      // Étape 2 : Vérification Self Protocol
      yield CombinedVerificationStatus.step(
        VerificationStep.selfVerification,
        'Verifying identity with Self Protocol...',
      );

      await Future.delayed(Duration(seconds: 1));

      final selfResult = useSimulation
          ? await SelfProtocolService.simulateSuccessfulVerification(userId)
          : await SelfProtocolService.checkVerificationStatus(userId);

      if (!selfResult.verified && !useSimulation) {
        yield CombinedVerificationStatus.error(
          'Self Protocol verification failed: ${selfResult.error}',
        );
        return;
      }

      print('✅ Self Protocol verification completed');

      // Étape 3 : Fusion des preuves
      yield CombinedVerificationStatus.step(
        VerificationStep.proofFusion,
        'Combining proofs and generating attestation...',
      );

      await Future.delayed(Duration(seconds: 1));

      final combinedResult = await combineProofs(
        moproProof: moproResult,
        selfVerification: selfResult,
        userId: userId,
      );

      print('✅ Proofs combined successfully');

      // Étape 4 : Génération du QR code final
      yield CombinedVerificationStatus.step(
        VerificationStep.qrGeneration,
        'Generating final QR code...',
      );

      await Future.delayed(Duration(seconds: 1));

      print('✅ QR code generated');

      // Étape 5 : Terminé
      yield CombinedVerificationStatus.completed(combinedResult);
    } catch (e) {
      print('❌ Combined verification error: $e');
      yield CombinedVerificationStatus.error(e.toString());
    }
  }

  /// Vérifie une preuve combinée
  static Future<bool> verifyProof(String proofData) async {
    try {
      print('🔍 Verifying combined proof...');

      final decodedData = base64.decode(proofData);
      final jsonData = json.decode(utf8.decode(decodedData));

      // Vérifications basiques
      if (jsonData['type'] != 'mopro-self-proof') {
        print('❌ Invalid proof type');
        return false;
      }

      if (jsonData['version'] != '1.0') {
        print('❌ Unsupported proof version');
        return false;
      }

      // Vérification du timestamp (pas trop ancien)
      final timestamp =
          DateTime.fromMillisecondsSinceEpoch(jsonData['timestamp']);
      final age = DateTime.now().difference(timestamp);

      if (age.inHours > 24) {
        print('❌ Proof expired (${age.inHours} hours old)');
        return false;
      }

      // Vérification de la validité
      if (jsonData['valid'] != true) {
        print('❌ Proof marked as invalid');
        return false;
      }

      print('✅ Proof verification successful');
      return true;
    } catch (e) {
      print('❌ Error verifying proof: $e');
      return false;
    }
  }

  /// Génère un résumé de la preuve pour affichage
  static Map<String, dynamic> generateProofSummary(CombinedProofResult result) {
    return {
      'title': 'Age Verification Proof',
      'subtitle': 'Mopro ZK + Self Protocol',
      'details': [
        'Proof ID: ${result.proofId.substring(0, 8)}...',
        'User ID: ${result.userId.substring(0, 8)}...',
        'Verification Type: ${result.proofType}',
        'Timestamp: ${result.timestamp.toLocal().toString().substring(0, 19)}',
        'Status: ${result.isValid ? "Valid" : "Invalid"}',
        'Mopro ZK Proof: ${result.moproProof.isValid ? "✅" : "❌"}',
        'Self Identity: ${result.selfVerification.verified ? "✅" : "❌"}',
        'Age Verified: ${result.selfVerification.disclosures?.ageVerified == true ? "✅" : "❌"}',
        'OFAC Check: ${result.selfVerification.disclosures?.ofacCheck == true ? "✅" : "❌"}',
        'Nationality: ${result.selfVerification.disclosures?.nationality ?? "Unknown"}',
      ],
      'qrString': result.toQRString(),
      'isValid': result.isValid,
    };
  }
}

/// Extension pour faciliter l'utilisation
extension CombinedProofResultExtension on CombinedProofResult {
  /// Convertit en format lisible
  String get readableFormat {
    return '''
🆔 Proof ID: $proofId
👤 User ID: $userId
🔐 Hash: ${combinedHash.substring(0, 12)}...
⏰ Created: ${timestamp.toLocal().toString().substring(0, 19)}
📋 Type: $proofType
✅ Valid: $isValid

🔹 Mopro ZK Proof:
   Valid: ${moproProof.isValid}
   User Age: ${moproProof.userAge}
   Min Age: ${moproProof.minAge}
   
🔹 Self Protocol:
   Verified: ${selfVerification.verified}
   Age OK: ${selfVerification.disclosures?.ageVerified}
   Nationality: ${selfVerification.disclosures?.nationality}
   OFAC: ${selfVerification.disclosures?.ofacCheck}
    ''';
  }
}
