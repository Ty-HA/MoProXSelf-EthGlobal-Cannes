# Guide de test NFC - Carte d'identité française

## Problèmes corrigés

### 1. Gestion des erreurs améliorée
- **Avant** : Exceptions non gérées causaient des "unknown error"
- **Maintenant** : Gestion complète des erreurs avec messages explicites

### 2. Vérification NFC robuste
- **Avant** : Vérification basique de disponibilité
- **Maintenant** : Vérification avec logs détaillés et gestion d'erreurs

### 3. Session NFC améliorée
- **Avant** : Session pouvait se terminer sans résultat
- **Maintenant** : Attente et vérification du résultat de session

## Comment tester

### 1. Test de base
1. Ouvrez l'app sur iPhone
2. Allez dans "Age Verification" 
3. Cliquez sur "Read with NFC" 
4. Cliquez sur "Start NFC Reading"
5. **Attendez les logs** dans la console pour voir les détails

### 2. Test avec carte d'identité française
1. Placez votre carte d'identité française près de l'iPhone
2. L'app devrait détecter la carte et afficher :
   - Type de carte détecté
   - Technologies NFC disponibles
   - Âge simulé (25 ans pour la démo)
   - Numéro de carte généré

### 3. Test sans carte
1. Cliquez sur "Start NFC Reading" sans carte
2. L'app devrait afficher un message d'attente
3. Après timeout, elle devrait retourner une erreur explicite

## Logs à surveiller

### Logs de succès
```
🔍 Starting NFC session...
📡 NFC availability check: true
🔍 NFC Tag discovered: {...}
📡 Available technologies: [isodep, nfca, ndef]
🔄 Simulating French ID card reading...
✅ Card reading simulation completed successfully
✅ NFC reading completed successfully
```

### Logs d'erreur
```
❌ Error checking NFC availability: ...
❌ NFC service error: ...
❌ NFC tag reading error: ...
```

## Technologies NFC supportées

L'app détecte automatiquement les technologies disponibles :
- **isodep** : ISO14443-4 (cartes à puce)
- **nfca** : NFC Type A  
- **nfcb** : NFC Type B
- **ndef** : NFC Data Exchange Format

## Simulation pour la démo

Pour le hackathon, l'app simule :
- **Âge** : 25 ans (calculé pour être majeur)
- **Numéro de carte** : FR + timestamp
- **Type de carte** : Carte d'identité française
- **Lecture réussie** : Toujours (sauf erreur technique)

## Commandes APDU implémentées

Les commandes APDU réelles sont préparées mais pas utilisées dans la simulation :
- `SELECT` : Sélectionner l'application carte d'identité
- `READ BINARY` : Lire les données personnelles
- `GET CHALLENGE` : Tester la communication

## Prochaines étapes

1. **Test avec vraie carte** : Tester avec une carte d'identité française réelle
2. **Parsing des données** : Implémenter le parsing réel des données de la carte
3. **Sécurité** : Ajouter la vérification cryptographique des données
4. **Gestion d'erreurs** : Affiner selon les tests réels

## Dépannage

### "NFC not available"
- Vérifiez que l'iPhone supporte NFC
- Vérifiez les permissions dans Settings > Privacy > NFC

### "Session timeout"
- Rapprochez la carte de l'iPhone
- Essayez de maintenir la carte stable

### "Unknown error"
- Consultez les logs de la console
- Redémarrez l'app si nécessaire
