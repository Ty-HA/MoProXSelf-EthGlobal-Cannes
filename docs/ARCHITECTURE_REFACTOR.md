## 🏗️ **Architecture Refactorisée - Focus Mopro + Blockchain**

```
📱 Flutter App
├── 🔐 Mopro ZK Core               # Génération/vérification preuves
├── 📱 QR Code Features            # Scanner/génération QR universels  
├── ⛓️ On-Chain Verification       # Smart contract integration
└── 🎨 Modern UI                   # Interface utilisateur élégante
```

### **📁 Nouvelle structure des dossiers :**

```
MoProXSelf-EthGlobal-Cannes/
├── 📱 lib/
│   ├── core/
│   │   ├── services/
│   │   │   ├── mopro_service.dart          # Mopro ZK integration
│   │   │   ├── qr_service.dart             # QR code management  
│   │   │   └── onchain_service.dart        # Blockchain verification
│   │   ├── models/
│   │   │   ├── zk_proof.dart               # ZK proof models
│   │   │   └── verification_result.dart    # Verification results
│   │   └── utils/
│   │       └── crypto_utils.dart           # Crypto utilities
│   ├── features/
│   │   ├── proof_generation/               # ZK proof generation
│   │   ├── qr_scanner/                     # QR code scanning
│   │   └── onchain_verification/           # Blockchain verification
│   └── shared/
│       ├── widgets/                        # Shared UI components
│       └── constants/                      # App constants
├── ⛓️ blockchain/                           # Hardhat 3.0 setup
│   ├── contracts/
│   │   └── Groth16Verifier.sol            # ZK verifier contract
│   ├── scripts/
│   │   ├── deploy.js                      # Deployment script
│   │   └── verify.js                      # Contract verification
│   └── hardhat.config.js                 # Hardhat 3.0 config
├── 🎨 assets/
│   └── multiplier2_final.zkey             # ZK circuit
├── 📄 docs/                               # Documentation
└── 📜 scripts/                            # Utility scripts
```

### **🔥 Points forts de cette architecture :**

1. **Focus sur Mopro** - Votre vraie valeur ajoutée
2. **On-chain verification** - Pour impressionner les juges
3. **Architecture clean** - Code maintenable et professionnel
4. **Hardhat 3.0** - Respecte les requirements du hackathon

### **📈 Démonstration finale :**

```
1. 📱 Utilisateur génère une preuve ZK (âge ≥ 18) avec Mopro
2. 📱 App créé un QR code avec la preuve  
3. 📱 Scanner lit le QR code
4. ✅ Vérification locale (Mopro)
5. ⛓️ Vérification on-chain (Smart contract)
6. 🔗 Lien Etherscan pour transparence
```

### **🎯 Valeur pour les juges :**

- **Technique** : Mopro + Blockchain + Hardhat 3.0
- **Innovation** : ZK mobile-first approach  
- **Utilité** : Vérification d'âge sans révéler l'âge
- **Transparence** : Vérification publique on-chain
