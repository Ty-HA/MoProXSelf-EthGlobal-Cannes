/// Service d'intégration Self Protocol pour Flutter
/// Gère la génération de QR codes et la vérification d'identité via NFC
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

/// Configuration Self Protocol
class SelfProtocolConfig {
  final String appName;
  final String scope;
  final String endpoint;
  final List<SelfDocumentType> allowedDocuments;
  final SelfDisclosures disclosures;

  SelfProtocolConfig({
    required this.appName,
    required this.scope,
    required this.endpoint,
    required this.allowedDocuments,
    required this.disclosures,
  });

  factory SelfProtocolConfig.fromJson(Map<String, dynamic> json) {
    return SelfProtocolConfig(
      appName: json['appName'] ?? 'MoProXSelf',
      scope: json['scope'] ?? 'mopro-self-hackathon',
      endpoint: json['endpoint'] ?? '',
      allowedDocuments: (json['allowedDocuments'] as List<dynamic>?)
              ?.map((doc) => SelfDocumentType.fromJson(doc))
              .toList() ??
          [],
      disclosures: SelfDisclosures.fromJson(json['disclosures'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appName': appName,
      'scope': scope,
      'endpoint': endpoint,
      'allowedDocuments': allowedDocuments.map((doc) => doc.toJson()).toList(),
      'disclosures': disclosures.toJson(),
    };
  }
}

/// Types de documents supportés
class SelfDocumentType {
  final int id;
  final String name;
  final String description;

  SelfDocumentType({
    required this.id,
    required this.name,
    required this.description,
  });

  factory SelfDocumentType.fromJson(Map<String, dynamic> json) {
    return SelfDocumentType(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}

/// Configuration des divulgations
class SelfDisclosures {
  final int minimumAge;
  final List<String> excludedCountries;
  final bool ofac;
  final bool nationality;
  final bool name;
  final bool dateOfBirth;

  SelfDisclosures({
    required this.minimumAge,
    required this.excludedCountries,
    required this.ofac,
    required this.nationality,
    required this.name,
    required this.dateOfBirth,
  });

  factory SelfDisclosures.fromJson(Map<String, dynamic> json) {
    return SelfDisclosures(
      minimumAge: json['minimumAge'] ?? 18,
      excludedCountries: List<String>.from(json['excludedCountries'] ?? []),
      ofac: json['ofac'] ?? true,
      nationality: json['nationality'] ?? true,
      name: json['name'] ?? true,
      dateOfBirth: json['dateOfBirth'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'minimumAge': minimumAge,
      'excludedCountries': excludedCountries,
      'ofac': ofac,
      'nationality': nationality,
      'name': name,
      'dateOfBirth': dateOfBirth,
    };
  }
}

/// QR Code data pour Self Protocol
class SelfQRData {
  final String userId;
  final SelfProtocolConfig config;
  final String qrString;
  final DateTime createdAt;

  SelfQRData({
    required this.userId,
    required this.config,
    required this.qrString,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'config': config.toJson(),
      'qrString': qrString,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// Résultat de vérification Self Protocol
class SelfVerificationResult {
  final bool verified;
  final String? userIdentifier;
  final SelfDisclosureData? disclosures;
  final String? error;
  final DateTime timestamp;

  SelfVerificationResult({
    required this.verified,
    this.userIdentifier,
    this.disclosures,
    this.error,
    required this.timestamp,
  });

  factory SelfVerificationResult.fromJson(Map<String, dynamic> json) {
    return SelfVerificationResult(
      verified: json['verified'] ?? false,
      userIdentifier: json['userIdentifier'],
      disclosures: json['disclosures'] != null
          ? SelfDisclosureData.fromJson(json['disclosures'])
          : null,
      error: json['message'] ?? json['error'],
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}

/// Données divulguées par Self Protocol
class SelfDisclosureData {
  final bool ageVerified;
  final String? nationality;
  final List<String>? name;
  final String? dateOfBirth;
  final bool ofacCheck;

  SelfDisclosureData({
    required this.ageVerified,
    this.nationality,
    this.name,
    this.dateOfBirth,
    required this.ofacCheck,
  });

  factory SelfDisclosureData.fromJson(Map<String, dynamic> json) {
    return SelfDisclosureData(
      ageVerified: json['ageVerified'] ?? false,
      nationality: json['nationality'],
      name: json['name'] is List ? List<String>.from(json['name']) : null,
      dateOfBirth: json['dateOfBirth'],
      ofacCheck: json['ofacCheck'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ageVerified': ageVerified,
      'nationality': nationality,
      'name': name,
      'dateOfBirth': dateOfBirth,
      'ofacCheck': ofacCheck,
    };
  }
}

/// Service principal Self Protocol
class SelfProtocolService {
  static const String _baseUrl = 'http://localhost:3000';
  static const Uuid _uuid = Uuid();

  /// Récupère la configuration depuis le backend
  static Future<SelfProtocolConfig> getConfig() async {
    try {
      print('🔧 Fetching Self Protocol config...');

      final response = await http.get(
        Uri.parse('$_baseUrl/api/config'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final config = SelfProtocolConfig.fromJson(jsonData);

        print('✅ Self Protocol config loaded');
        print('📱 App: ${config.appName}');
        print('🎯 Scope: ${config.scope}');
        print(
            '📄 Documents: ${config.allowedDocuments.map((d) => d.name).join(', ')}');

        return config;
      } else {
        throw Exception('Failed to load config: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error loading Self Protocol config: $e');
      throw Exception('Failed to load Self Protocol config: $e');
    }
  }

  /// Génère un QR code pour Self Protocol
  static Future<SelfQRData> generateQRCode({
    String? userId,
    int? userAge,
  }) async {
    try {
      print('📱 Generating Self Protocol QR code...');

      final finalUserId = userId ?? _uuid.v4();
      print('👤 User ID: $finalUserId');

      final response = await http.post(
        Uri.parse('$_baseUrl/api/generate-qr'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': finalUserId,
          'userAge': userAge,
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final config = SelfProtocolConfig.fromJson(jsonData['qrConfig']);

        // Génération du QR string pour Self Protocol
        final qrString = _generateSelfQRString(config, finalUserId);

        print('✅ QR code generated successfully');
        print('📱 QR String length: ${qrString.length}');

        return SelfQRData(
          userId: finalUserId,
          config: config,
          qrString: qrString,
          createdAt: DateTime.now(),
        );
      } else {
        throw Exception('Failed to generate QR code: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error generating QR code: $e');
      throw Exception('Failed to generate QR code: $e');
    }
  }

  /// Génère le string QR pour Self Protocol
  static String _generateSelfQRString(
      SelfProtocolConfig config, String userId) {
    // Format QR Self Protocol
    final qrData = {
      'appName': config.appName,
      'scope': config.scope,
      'endpoint': config.endpoint,
      'userId': userId,
      'disclosures': config.disclosures.toJson(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    // Encodage en base64 pour le QR code
    final qrString = base64.encode(utf8.encode(json.encode(qrData)));

    return 'self://${qrString}';
  }

  /// Vérifie le statut de vérification
  static Future<SelfVerificationResult> checkVerificationStatus(
      String userId) async {
    try {
      print('🔍 Checking verification status for user: $userId');

      // Simulation d'une vérification en attente
      // Dans la vraie implémentation, on ferait un polling du backend
      await Future.delayed(Duration(seconds: 2));

      // Pour l'instant, on retourne un mock
      return SelfVerificationResult(
        verified: false,
        error: 'Verification pending - please scan QR code with Self app',
        timestamp: DateTime.now(),
      );
    } catch (e) {
      print('❌ Error checking verification status: $e');
      return SelfVerificationResult(
        verified: false,
        error: 'Failed to check verification status: $e',
        timestamp: DateTime.now(),
      );
    }
  }

  /// Simule une vérification réussie (pour les tests)
  static Future<SelfVerificationResult> simulateSuccessfulVerification(
      String userId) async {
    try {
      print('🎭 Simulating successful Self Protocol verification...');

      // Simulation d'une vérification réussie
      await Future.delayed(Duration(seconds: 3));

      return SelfVerificationResult(
        verified: true,
        userIdentifier: userId,
        disclosures: SelfDisclosureData(
          ageVerified: true,
          nationality: 'FR',
          name: ['Test', 'User'],
          dateOfBirth: '1990-01-01',
          ofacCheck: true,
        ),
        timestamp: DateTime.now(),
      );
    } catch (e) {
      print('❌ Error in simulation: $e');
      return SelfVerificationResult(
        verified: false,
        error: 'Simulation failed: $e',
        timestamp: DateTime.now(),
      );
    }
  }

  /// Valide la configuration Self Protocol
  static bool validateConfig(SelfProtocolConfig config) {
    if (config.scope.isEmpty) {
      print('❌ Invalid config: scope is empty');
      return false;
    }

    if (config.endpoint.isEmpty) {
      print('❌ Invalid config: endpoint is empty');
      return false;
    }

    if (config.allowedDocuments.isEmpty) {
      print('❌ Invalid config: no allowed documents');
      return false;
    }

    print('✅ Self Protocol config is valid');
    return true;
  }

  /// Formate les instructions pour l'utilisateur
  static List<String> getInstructions() {
    return [
      '1. Download and install Self app on your phone',
      '2. Create your Self account if needed',
      '3. Scan the QR code with Self app',
      '4. Place your EU ID card or passport on NFC',
      '5. Wait for age verification to complete',
      '6. Return to this app to see results',
    ];
  }
}

/// Modèle pour les résultats combinés
class CombinedVerificationResult {
  final String userId;
  final SelfVerificationResult selfResult;
  final dynamic moproResult; // Sera typé avec le résultat Mopro
  final String combinedProof;
  final DateTime timestamp;

  CombinedVerificationResult({
    required this.userId,
    required this.selfResult,
    required this.moproResult,
    required this.combinedProof,
    required this.timestamp,
  });

  bool get isFullyVerified => selfResult.verified && moproResult != null;

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'selfResult': {
        'verified': selfResult.verified,
        'userIdentifier': selfResult.userIdentifier,
        'disclosures': selfResult.disclosures?.toJson(),
      },
      'moproResult': moproResult,
      'combinedProof': combinedProof,
      'timestamp': timestamp.toIso8601String(),
      'fullyVerified': isFullyVerified,
    };
  }
}
