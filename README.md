# ZK-Age Verify Mobile 🔐📱

> **MoProXSelf-EthGlobal-Cannes** - Une application mobile native de vérification d'âge utilisant les preuves zero-knowledge

## 🎯 Aperçu du Projet

**ZK-Age Verify Mobile** est une application Flutter qui démontre la vérification d'âge transparente en utilisant les preuves zero-knowledge. Les utilisateurs peuvent prouver qu'ils respectent les exigences d'âge sans révéler leur âge réel, combinant la puissance des **capacités ZK natives mobiles de Mopro** avec la **vérification d'identité de Self Protocol**.

### 🏆 Objectifs Hackathon
- **Ethereum Foundation - Prix Mopro** : $5,000 (Meilleure utilisation de ZK sur Mopro)
- **Prix Self Protocol** : $10,000 (Meilleure intégration Self onchain SDK)

## ✨ Fonctionnalités Clés

### 🔒 Vérification d'Âge Zero-Knowledge
- **Génération de preuves ZK côté client** utilisant Mopro + Circom
- Prouver `age >= 18` sans révéler l'âge exact (majorité française)
- **Aucun calcul côté serveur** - toutes les preuves générées sur l'appareil mobile

### 🌐 Intégration Self Protocol
- **Vérification onchain** sur le réseau Celo
- Vérifications de conformité OFAC
- Vérification de pays
- **Attestation d'identité préservant la confidentialité**

### 📱 Expérience Mobile Native
- **Interface Flutter** avec animations fluides
- **Authentification biométrique** pour une sécurité renforcée
- **Génération de preuves ZK hors ligne**
- **Validation de preuves en temps réel**

## 🛠️ Architecture Technique

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   App Flutter   │    │   SDK Mopro     │    │ Self Protocol   │
│                 │    │                 │    │                 │
│ • Saisie âge    │───▶│ • Circuit Circom│───▶│ • Vérif onchain │
│ • UI/UX         │    │ • Génér. preuve │    │ • Réseau Celo   │
│ • Biométrie     │    │ • Mobile natif  │    │ • Vérif OFAC    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🇫🇷 Spécificités Françaises

- **Majorité civile** : 18 ans
- **Achat d'alcool** : 18 ans
- **Permis de conduire** : 18 ans
- **Droit de vote** : 18 ans

## 🚀 Installation

```bash
# Cloner le dépôt
git clone https://github.com/Ty-HA/MoProXSelf-EthGlobal-Cannes.git

# Installer les dépendances
flutter pub get

# Lancer sur iOS
flutter run -d ios

# Lancer sur Android
flutter run -d android

# Lancer sur macOS (pour debug)
flutter run -d macos
```

## 🎯 Critères Hackathon

### ✅ Exigences Mopro Respectées
- ✅ **Liaisons ZK natives mobiles** via le SDK Mopro
- ✅ **Génération de preuves côté client** (pas de relais serveur)
- ✅ **Nouveau code natif mobile** en Flutter
- ✅ **Pas de webview/navigateur** - implémentation purement native
- ✅ **Fonctionne sur appareil physique** (iPhone/Android)

### ✅ Exigences Self Protocol Respectées
- ✅ **Intégration SDK Self onchain**
- ✅ **Vérification preuves réseau Celo**
- ✅ **Système de preuves fonctionnel**
- ✅ **Vérifications conformité OFAC**  
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
