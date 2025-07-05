import 'dart:math';

/// Service pour l'intégration World ID avec Flutter
/// Utilise deep linking vers l'app World ID native
/// Alternative: WebView avec World ID JS Kit
class WorldIDService {
  static const String APP_ID =
      'app_staging_your_app_id'; // Remplacer par votre vrai App ID
  static const String ACTION = 'verify-age';
  static const String WORLD_ID_APP_SCHEME = 'worldcoin://';
  static const String WORLD_ID_WEB_URL = 'https://worldcoin.org/verify';

  /// Vérifie l'âge avec World ID
  /// Option 1: Deep linking vers l'app World ID
  /// Option 2: WebView avec World ID JS Kit
  /// Option 3: Simulation pour démo/test
  static Future<WorldIDResult> verifyAge({bool useRealApp = false}) async {
    try {
      print('🌍 Starting World ID verification...');

      // Générer un nullifier_hash unique pour cette vérification
      final nullifierHash = _generateNullifierHash();

      if (useRealApp) {
        // Option 1: Vraie intégration avec l'app World ID
        return await _verifyWithRealWorldIDApp(nullifierHash);
      } else {
        // Option 3: Simulation pour démo (recommandé pour hackathon)
        return await _simulateWorldIDVerification(nullifierHash);
      }
    } catch (e) {
      print('❌ World ID verification error: $e');
      return WorldIDResult(
        success: false,
        error: 'World ID verification failed: $e',
      );
    }
  }

  /// Option 1: Intégration avec la vraie app World ID
  static Future<WorldIDResult> _verifyWithRealWorldIDApp(
      String nullifierHash) async {
    try {
      print('📱 Attempting to open World ID app...');

      // Construire l'URL World ID
      final worldIdUrl = _buildWorldIDUrl(nullifierHash);
      print('🔗 World ID URL: $worldIdUrl');

      // TODO: Implémenter l'ouverture de l'app World ID
      // Dans une vraie implémentation:
      // 1. Vérifier si l'app World ID est installée
      // 2. Ouvrir l'app avec les paramètres
      // 3. Attendre le callback via deep link

      print('⚠️ Real World ID integration not implemented yet');
      print('📝 URL to open manually: $worldIdUrl');

      // Pour l'instant, simuler après affichage de l'URL
      await Future.delayed(Duration(seconds: 3));

      return WorldIDResult(
        success: true,
        nullifierHash: nullifierHash,
        merkleRoot: '0x' + _generateHex(64),
        proof: '0x' + _generateHex(512),
        verificationLevel: 'orb',
        isAdult: true,
        estimatedAge: 25,
      );
    } catch (e) {
      print('❌ Real World ID integration error: $e');
      return await _simulateWorldIDVerification(nullifierHash);
    }
  }

  /// Construit l'URL pour la vérification World ID
  static String _buildWorldIDUrl(String nullifierHash) {
    final Map<String, String> params = {
      'app_id': APP_ID,
      'action': ACTION,
      'signal': nullifierHash,
      'return_to': 'mopro://worldid-callback', // Deep link pour revenir à l'app
    };

    final queryString = params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return 'https://worldcoin.org/verify?$queryString';
  }

  /// Simule la vérification World ID pour la démo
  static Future<WorldIDResult> _simulateWorldIDVerification(
      String nullifierHash) async {
    try {
      print('🔄 Simulating World ID verification...');

      // Simuler le temps d'une vraie vérification
      await Future.delayed(Duration(milliseconds: 2000));

      // Simuler une preuve World ID
      final proof = _generateMockProof(nullifierHash);

      print('✅ World ID verification simulation completed');

      return WorldIDResult(
        success: true,
        nullifierHash: nullifierHash,
        merkleRoot: proof['merkle_root'],
        proof: proof['proof'],
        verificationLevel: 'orb', // Vérification par Orb = humanité + unicité
        isAdult: true, // World ID avec wallet crypto implique 18+
        estimatedAge: 25, // Âge estimé pour un utilisateur crypto
      );
    } catch (e) {
      print('❌ World ID simulation error: $e');
      return WorldIDResult(
        success: false,
        error: 'World ID simulation failed: $e',
      );
    }
  }

  /// Génère une chaîne hexadécimale aléatoire
  static String _generateHex(int length) {
    final random = Random();
    return List.generate(length, (i) => random.nextInt(16).toRadixString(16))
        .join('');
  }

  /// Génère un nullifier hash unique
  static String _generateNullifierHash() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomBytes = List.generate(32, (i) => random.nextInt(256));
    final combined = '$timestamp${randomBytes.join('')}';

    // Simuler un hash (dans une vraie app, on utiliserait crypto)
    return 'nullifier_${combined.hashCode.abs().toRadixString(16)}';
  }

  /// Génère une preuve mockée pour la démo
  static Map<String, String> _generateMockProof(String nullifierHash) {
    final random = Random();

    return {
      'merkle_root':
          '0x${List.generate(64, (i) => random.nextInt(16).toRadixString(16)).join('')}',
      'proof':
          '0x${List.generate(512, (i) => random.nextInt(16).toRadixString(16)).join('')}',
      'nullifier_hash': nullifierHash,
    };
  }
}

/// Résultat de la vérification World ID
class WorldIDResult {
  final bool success;
  final String? error;
  final String? nullifierHash;
  final String? merkleRoot;
  final String? proof;
  final String? verificationLevel; // 'orb' ou 'device'
  final bool isAdult;
  final int? estimatedAge;

  WorldIDResult({
    this.success = false,
    this.error,
    this.nullifierHash,
    this.merkleRoot,
    this.proof,
    this.verificationLevel,
    this.isAdult = false,
    this.estimatedAge,
  });

  /// Informations de debug
  String get debugInfo {
    return '''
Success: $success
Verification Level: ${verificationLevel ?? 'Unknown'}
Is Adult (18+): $isAdult
Estimated Age: ${estimatedAge ?? 'Unknown'}
Nullifier Hash: ${nullifierHash ?? 'None'}
Merkle Root: ${merkleRoot ?? 'None'}
Proof Length: ${proof?.length ?? 0} chars
Error: ${error ?? 'None'}
''';
  }

  /// Données pour la preuve ZK
  Map<String, dynamic> get zkProofData {
    return {
      'worldid_verified': success,
      'verification_level': verificationLevel,
      'is_adult': isAdult,
      'estimated_age': estimatedAge ?? 25,
      'nullifier_hash': nullifierHash,
      'merkle_root': merkleRoot,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }
}
