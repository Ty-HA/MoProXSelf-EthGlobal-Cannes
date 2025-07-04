# 🏆 MoProXSelf - EthGlobal Cannes Hackathon

## 🎯 Projet
**ZK Authentication avec Self Protocol** - Authentification privée sans révéler les données personnelles

## 🔧 Stack Technique
- **Frontend** : Flutter (iOS/Android natif)
- **ZK Proofs** : Circom + Groth16 via Mopro SDK
- **Platform** : Client-side uniquement (aucun serveur)
- **Intégration** : Self Protocol circuits

## 🚀 Installation

```bash
# Installer les dépendances
flutter pub get

# Lancer sur iOS
flutter run -d ios

# Lancer sur Android  
flutter run -d android

# Lancer sur macOS (pour debug)
flutter run -d macos
```

## 🎯 Use Cases Implémentés

### 1. 🔐 Age Verification
- Prouver +18, +21, +25 ans sans révéler l'âge exact
- Integration Touch ID/Face ID
- Stockage sécurisé des preuves

### 2. 💰 Balance Proof (Ledger integration)
- Prouver possession d'assets sans révéler les montants
- Support BTC, ETH, USDC
- Signatures cryptographiques

### 3. 📍 Location Proof  
- Prouver présence dans une zone sans GPS exact
- Check-in privé pour événements
- Anti-tracking

## 🏆 Critères Hackathon

✅ **ZK Proofs client-side** : Toutes les preuves générées sur l'appareil  
✅ **Code mobile natif** : Flutter avec bindings Swift/Kotlin  
✅ **Self Protocol integration** : Réutilise leurs circuits ZK  
✅ **Pas de webview** : 100% natif mobile  
✅ **Nouveaux features** : Touch ID, stockage sécurisé, interface mobile  

## 📱 Demo

### Scénario 1 : Bar/Club
1. Scanner QR code du bar
2. Générer preuve +21 ans avec Touch ID
3. Montrer "✅ Client majeur" sans révéler l'âge

### Scénario 2 : DeFi Access
1. Connecter portefeuille  
2. Prouver > 1 ETH sans révéler balance exacte
3. Accéder au pool VIP

### Scénario 3 : Événement privé
1. Prouver géolocalisation dans la zone
2. Check-in anonyme
3. Recevoir badge NFT

---

**Équipe** : 1 développeur  
**Durée** : 48h hackathon  
**Objectif** : 🥇 Best use of ZK on Mopro ($5,000)
