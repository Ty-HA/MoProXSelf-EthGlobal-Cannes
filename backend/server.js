const express = require('express');
const cors = require('cors');
const { v4: uuidv4 } = require('uuid');
const { 
  SelfBackendVerifier, 
  AllIds,
  DefaultConfigStore,
  ConfigMismatchError 
} = require('@selfxyz/core');
require('dotenv').config();

const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Configuration Storage pour Self Protocol
class MoproSelfConfigStorage {
  async getConfig(configId) {
    console.log(`🔧 Getting config for ID: ${configId}`);
    
    return {
      olderThan: 18,                          // Age minimum requis
      excludedCountries: ['IRN', 'PRK'],      // Pays exclus
      ofac: true,                             // Vérification OFAC
      nationality: true,                      // Demander la nationalité
      name: true,                             // Demander le nom
      dateOfBirth: true                       // Demander la date de naissance
    };
  }
  
  async getActionId(userIdentifier, userDefinedData) {
    console.log(`🔧 Getting action ID for user: ${userIdentifier}`);
    
    // Décoder les données utilisateur
    try {
      const userData = JSON.parse(Buffer.from(userDefinedData, 'hex').toString());
      console.log('📋 User data:', userData);
      
      // Configuration spécifique selon le type de document
      if (userData.attestationId === 1) {
        return 'passport_verification';
      } else if (userData.attestationId === 2) {
        return 'eu_id_verification';
      }
    } catch (error) {
      console.warn('⚠️ Could not parse user data:', error.message);
    }
    
    return 'default_age_verification';
  }
}

// Initialisation du vérificateur Self Protocol
const configStorage = new MoproSelfConfigStorage();

// Types de documents acceptés
const allowedIds = new Map();
allowedIds.set(1, true);  // Passeports
allowedIds.set(2, true);  // Cartes d'identité EU

// Endpoint URL (sera remplacé par ngrok)
const endpointUrl = process.env.SELF_ENDPOINT_URL || 'http://localhost:3000';

console.log(`🚀 Initializing Self Protocol verifier...`);
console.log(`📍 Endpoint URL: ${endpointUrl}`);
console.log(`🎯 App scope: ${process.env.SELF_APP_SCOPE}`);

const selfBackendVerifier = new SelfBackendVerifier(
  process.env.SELF_APP_SCOPE || 'mopro-self-hackathon',
  `${endpointUrl}/api/verify`,
  process.env.USE_MOCK_PASSPORTS === 'true',  // Mode mock pour tests
  allowedIds,
  configStorage,
  'uuid'  // User ID type as string
);

// Routes API

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    service: 'mopro-self-backend'
  });
});

// Configuration endpoint pour Flutter
app.get('/api/config', (req, res) => {
  res.json({
    appName: process.env.SELF_APP_NAME || 'MoProXSelf Age Verification',
    scope: process.env.SELF_APP_SCOPE || 'mopro-self-hackathon',
    endpoint: `${endpointUrl}/api/verify`,
    allowedDocuments: [
      { id: 1, name: 'Passport', description: 'Electronic Passport' },
      { id: 2, name: 'EU ID Card', description: 'European Union ID Card' }
    ],
    disclosures: {
      minimumAge: 18,
      excludedCountries: ['IRN', 'PRK'],
      ofac: true,
      nationality: true,
      name: true,
      dateOfBirth: true
    }
  });
});

// Endpoint principal de vérification
app.post('/api/verify', async (req, res) => {
  console.log('📥 Received verification request');
  console.log('📋 Request body:', JSON.stringify(req.body, null, 2));
  
  try {
    const { attestationId, proof, pubSignals, userContextData } = req.body;

    // Validation des données reçues
    if (!attestationId || !proof || !pubSignals || !userContextData) {
      console.error('❌ Missing required fields');
      return res.status(400).json({ 
        status: 'error',
        message: 'Missing required fields: attestationId, proof, pubSignals, userContextData'
      });
    }

    console.log(`🔍 Verifying attestation ID: ${attestationId}`);
    console.log(`📊 Proof length: ${JSON.stringify(proof).length} chars`);
    console.log(`📊 PubSignals length: ${pubSignals.length} elements`);

    // Vérification avec Self Protocol
    const result = await selfBackendVerifier.verify(
      attestationId,
      proof,
      pubSignals,
      userContextData
    );

    console.log('✅ Verification result:', result);

    if (result.isValidDetails.isValid) {
      // Vérification réussie
      console.log('🎉 Age verification successful!');
      console.log('👤 User age verified:', result.discloseOutput.olderThan);
      console.log('🌍 Nationality:', result.discloseOutput.nationality);
      
      return res.status(200).json({
        status: 'success',
        verified: true,
        attestationId: result.attestationId,
        userIdentifier: result.userData.userIdentifier,
        disclosures: {
          ageVerified: result.isValidDetails.isOlderThanValid,
          nationality: result.discloseOutput.nationality,
          name: result.discloseOutput.name,
          dateOfBirth: result.discloseOutput.dateOfBirth,
          ofacCheck: result.isValidDetails.isOfacValid
        },
        timestamp: new Date().toISOString()
      });
    } else {
      // Vérification échouée
      console.log('❌ Age verification failed');
      console.log('📋 Validation details:', result.isValidDetails);
      
      return res.status(400).json({
        status: 'error',
        verified: false,
        message: 'Age verification failed',
        details: result.isValidDetails,
        timestamp: new Date().toISOString()
      });
    }
  } catch (error) {
    console.error('💥 Error during verification:', error);
    
    if (error instanceof ConfigMismatchError) {
      console.error('⚙️ Configuration mismatch:', error.issues);
      return res.status(400).json({
        status: 'error',
        verified: false,
        message: 'Configuration mismatch between frontend and backend',
        issues: error.issues,
        timestamp: new Date().toISOString()
      });
    }
    
    return res.status(500).json({
      status: 'error',
      verified: false,
      message: error.message || 'Internal server error',
      timestamp: new Date().toISOString()
    });
  }
});

// Endpoint pour générer QR code Self Protocol
app.post('/api/generate-qr', async (req, res) => {
  console.log('📱 Generating QR code for Self Protocol');
  
  try {
    const { userId, userAge } = req.body;
    const finalUserId = userId || uuidv4();
    
    console.log(`👤 User ID: ${finalUserId}`);
    console.log(`🎂 User age: ${userAge}`);
    
    // Configuration QR code
    const qrConfig = {
      appName: process.env.SELF_APP_NAME || 'MoProXSelf Age Verification',
      scope: process.env.SELF_APP_SCOPE || 'mopro-self-hackathon',
      endpoint: `${endpointUrl}/api/verify`,
      userId: finalUserId,
      disclosures: {
        minimumAge: 18,
        excludedCountries: ['IRN', 'PRK'],
        ofac: true,
        nationality: true,
        name: true,
        dateOfBirth: true
      }
    };
    
    console.log('📋 QR Config:', JSON.stringify(qrConfig, null, 2));
    
    res.json({
      status: 'success',
      userId: finalUserId,
      qrConfig: qrConfig,
      instructions: [
        '1. Open Self app on your phone',
        '2. Scan the QR code generated with this config',
        '3. Place your EU ID card or passport on your phone\'s NFC',
        '4. Wait for verification to complete'
      ],
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('💥 Error generating QR code:', error);
    
    res.status(500).json({
      status: 'error',
      message: error.message || 'Failed to generate QR code',
      timestamp: new Date().toISOString()
    });
  }
});

// Démarrage du serveur
app.listen(port, () => {
  console.log(`🚀 Mopro + Self Protocol backend running on port ${port}`);
  console.log(`🌍 Health check: http://localhost:${port}/health`);
  console.log(`⚙️ Config endpoint: http://localhost:${port}/api/config`);
  console.log(`🔍 Verify endpoint: http://localhost:${port}/api/verify`);
  console.log(`📱 QR generation: http://localhost:${port}/api/generate-qr`);
  console.log(`\n🎯 Next steps:`);
  console.log(`   1. Install dependencies: npm install`);
  console.log(`   2. Setup ngrok: ngrok http ${port}`);
  console.log(`   3. Update .env with ngrok URL`);
  console.log(`   4. Test with Flutter app`);
});

module.exports = app;
