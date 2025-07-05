# Installation iOS pour iPhone Titan

## Application MoPro x Self - ZK Age Verification

### Fichiers générés
- **App iOS** : `build/ios/iphoneos/Runner.app` (58.4MB)
- **Taille totale** : 58.4MB

### Instructions d'installation

#### Option 1 : Installation via Xcode
1. Connectez votre iPhone Titan à votre Mac
2. Ouvrez Xcode
3. Allez dans `Window > Devices and Simulators`
4. Sélectionnez votre iPhone Titan
5. Faites glisser le fichier `build/ios/iphoneos/Runner.app` vers la section "Installed Apps"
6. L'application sera installée automatiquement

#### Option 2 : Installation via Terminal
```bash
# Connectez votre iPhone Titan et exécutez :
flutter install --device-id [DEVICE_ID]
```

#### Option 3 : Installation directe
```bash
# Depuis le répertoire du projet
flutter run --release --device-id [DEVICE_ID]
```

### Vérification de l'installation

1. **Nom de l'app** : "MoPro x Self - ZK Age Verification"
2. **Bundle ID** : com.ethglobal.moproxselfcannes
3. **Icône** : Icône Flutter par défaut (AppIcon60x60@2x.png)

### Fonctionnalités disponibles

✅ **Génération de QR Code ZK Proof**
- Génère un QR code avec les données de preuve ZK
- Format compatible avec Mopro

✅ **Scan de QR Code**
- Scanner intégré pour lire les QR codes
- Vérification des preuves ZK scannées

✅ **Vérification Blockchain**
- Connexion à Arbitrum Sepolia
- Vérification on-chain via le contrat déployé
- Adresse du contrat : `0xC7e4179bB1a48CDbdcE3e6A5f778CED6d19cd6b8`

✅ **Logs détaillés**
- Affichage des détails de la preuve
- Informations sur la transaction blockchain
- Statut de vérification

### Données de test

L'application utilise des données de test pour la démonstration :
- **Preuve ZK** : Données mockées au format Mopro
- **Âge** : 25 ans (>18, donc valide)
- **Timestamp** : Généré automatiquement

### Réseau blockchain

- **Réseau** : Arbitrum Sepolia Testnet
- **Contrat** : Groth16Verifier
- **Adresse** : 0xC7e4179bB1a48CDbdcE3e6A5f778CED6d19cd6b8
- **Explorateur** : https://sepolia.arbiscan.io/

### Troubleshooting

Si l'installation échoue :
1. Vérifiez que votre iPhone est en mode développeur
2. Assurez-vous que le profil de provisioning est valide
3. Redémarrez Xcode et reconnectez l'iPhone

### Prochaines étapes

1. **Test sur iPhone Titan** : Testez toutes les fonctionnalités
2. **Intégration Mopro réelle** : Remplacez les données mockées par une vraie intégration
3. **UI/UX** : Améliorez l'interface utilisateur pour la démo
4. **Optimisation** : Optimisez les performances pour EthGlobal Cannes

---

**Prêt pour EthGlobal Cannes 2025 ! 🚀**
