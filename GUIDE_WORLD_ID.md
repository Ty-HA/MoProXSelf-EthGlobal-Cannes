# World ID Integration Guide

## Vue d'ensemble

Cette app utilise maintenant **World ID** pour la vérification d'âge au lieu du NFC. C'est une approche plus élégante et sécurisée pour plusieurs raisons :

### Pourquoi World ID ?

1. **Humanité vérifiée** : World ID avec Orb prouve que vous êtes humain et unique
2. **Majorité implicite** : L'utilisation de crypto wallets implique 18+ ans
3. **Privacy-first** : Pas de données personnelles stockées, juste une preuve ZK
4. **Global** : Fonctionne partout dans le monde, pas seulement en France

## Comment ça marche

### 1. Vérification World ID
- L'utilisateur clique sur "Verify with World ID"
- L'app simule une vérification World ID (avec Orb)
- Retourne : humanité prouvée + adulte (18+)

### 2. Génération ZK Proof
- L'âge est automatiquement rempli (25 ans par défaut)
- La preuve ZK est générée avec Mopro
- Le QR code contient la preuve + métadonnées World ID

### 3. Vérification
- Le scanner lit le QR code
- Vérifie la preuve ZK + World ID data
- Confirme l'âge sans révéler l'identité

## Architecture technique

```
[World ID] → [Age Verification] → [ZK Proof] → [QR Code]
    ↓              ↓                 ↓            ↓
Humanité +    Âge rempli      Preuve Mopro   Partage
Adulte        automatiquement                 sécurisé
```

## Tests

### 1. Test de base
1. Ouvrez l'app sur iPhone
2. Allez dans "Age Verification"
3. Cliquez sur "Verify with World ID" (bouton violet)
4. L'app simule la vérification World ID
5. L'âge (25 ans) est automatiquement rempli
6. Générez la preuve ZK normalement

### 2. Données simulées
Pour la démo, l'app simule :
- **Verification Level** : "orb" (la plus sécurisée)
- **Is Adult** : true (18+)
- **Estimated Age** : 25 ans
- **Nullifier Hash** : Hash unique pour cette vérification
- **Merkle Root** : Preuve d'inclusion dans l'arbre World ID

## Intégration réelle World ID

Pour une vraie app, vous devrez :

### 1. Créer une App World ID
```bash
# Sur https://developer.worldcoin.org
1. Créer un nouveau projet
2. Obtenir votre APP_ID
3. Configurer l'action "verify-age"
```

### 2. Intégrer le SDK
```dart
// Remplacer dans world_id_service.dart
static const String APP_ID = 'app_your_real_app_id';

// Utiliser le vrai SDK World ID au lieu de la simulation
```

### 3. Deep Links
```dart
// Dans ios/Runner/Info.plist
<key>CFBundleURLSchemes</key>
<array>
    <string>mopro</string>
</array>

// Pour recevoir le callback World ID
```

## Avantages vs NFC

| Aspect | NFC | World ID |
|--------|-----|----------|
| **Hardware** | Nécessite puce NFC | Smartphone standard |
| **Portée** | France uniquement | Global |
| **Sécurité** | Carte physique | Preuve biométrique |
| **Privacy** | Données sur carte | Zero-knowledge |
| **UX** | Placement physique | Simple tap |

## Cas d'usage

1. **Bars/Clubs** : Vérifier l'âge à l'entrée
2. **E-commerce** : Achats soumis à restriction d'âge
3. **Events** : Accès à des événements 18+
4. **Services** : Accès à des plateformes réglementées

## Développement futur

- [ ] Intégration SDK World ID réel
- [ ] Deep links pour retour d'app
- [ ] Cache des vérifications
- [ ] Support multi-age (pas juste 18+)
- [ ] Intégration wallet pour paiements

## Démo EthGlobal

Cette implémentation est parfaite pour le hackathon car :
- ✅ Démontre l'intégration World ID
- ✅ Montre les preuves ZK avec Mopro  
- ✅ Interface utilisateur moderne
- ✅ Scénario réaliste et utile
