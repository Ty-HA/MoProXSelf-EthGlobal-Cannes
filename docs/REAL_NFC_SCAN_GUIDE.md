# Guide de Scan NFC Réel avec Self Protocol

## 📱 Introduction

Ce guide vous explique comment configurer et utiliser le scan NFC réel avec Self Protocol pour vérifier l'âge et l'identité à partir d'une carte d'identité européenne ou d'un passeport.

## 🔧 Configuration du backend

### 1. Prérequis

- Node.js installé
- ngrok installé (`brew install ngrok`)
- Une carte d'identité européenne compatible NFC
- L'application Self Protocol installée sur votre téléphone

### 2. Configurer ngrok

1. Créez un compte sur [ngrok.com](https://dashboard.ngrok.com/signup)
2. Obtenez votre token d'authentification depuis [dashboard.ngrok.com/get-started/your-authtoken](https://dashboard.ngrok.com/get-started/your-authtoken)
3. Configurez votre token:
   ```bash
   ngrok authtoken YOUR_TOKEN_HERE
   ```

### 3. Démarrer le backend

1. Accédez au dossier backend:
   ```bash
   cd backend
   ```

2. Installez les dépendances (si ce n'est pas déjà fait):
   ```bash
   npm install
   ```

3. Exécutez le script ngrok:
   ```bash
   ./setup_ngrok.sh
   ```

4. Notez l'URL ngrok qui s'affiche (par exemple: `https://abc123.ngrok.io`)

## 📱 Configuration de l'application Flutter

### 1. Ouvrir l'application

Lancez l'application MoProXSelf sur votre appareil.

### 2. Configurer l'URL du backend

1. Appuyez sur "Backend Configuration" dans le menu principal
2. Entrez l'URL ngrok que vous avez notée précédemment
3. Appuyez sur "Tester la connexion" pour vérifier que tout fonctionne
4. Si le test réussit (✅), vous êtes prêt!

## 🔍 Utilisation du scan NFC réel

### 1. Lancer le scan

1. Dans le menu principal, appuyez sur "Real NFC Scan"
2. Un QR code sera généré

### 2. Scanner avec l'application Self Protocol

1. Ouvrez l'application Self Protocol sur votre téléphone
2. Scannez le QR code affiché
3. Suivez les instructions pour placer votre carte d'identité sur le capteur NFC
4. Attendez que la vérification soit terminée

### 3. Vérification des résultats

1. L'application Flutter affichera automatiquement les résultats de la vérification
2. Vous verrez si l'âge a été vérifié avec succès
3. Des informations supplémentaires peuvent être affichées (nationalité, nom, etc.)

## ❓ Dépannage

### Le QR code ne se génère pas
- Vérifiez que l'URL du backend est correcte
- Assurez-vous que le backend est en cours d'exécution
- Vérifiez votre connexion internet

### La vérification échoue
- Assurez-vous que votre carte d'identité est compatible NFC
- Placez la carte correctement sur le capteur NFC
- Vérifiez que l'application Self Protocol est à jour

### L'application Self Protocol ne reconnaît pas le QR code
- Assurez-vous que le QR code est bien éclairé
- Nettoyez l'objectif de votre appareil photo
- Essayez de générer un nouveau QR code

## 🛡️ Sécurité et confidentialité

- Toutes les vérifications sont effectuées dans un environnement sécurisé (TEE)
- Aucune donnée personnelle n'est stockée sur le serveur
- L'âge est vérifié sans révéler la date de naissance complète

## 🔄 Compatibilité

- **Appareils supportés**: Tout téléphone avec NFC
- **Cartes supportées**: Cartes d'identité européennes (eID) et passeports biométriques
- **Pays supportés**: Union Européenne, Royaume-Uni, Suisse, et plus

## 📝 Notes techniques

- Le backend utilise Self Protocol avec support TEE
- Le QR code contient une référence temporaire unique
- La validation est effectuée avec des preuves à divulgation nulle
- Les résultats sont cryptographiquement signés et vérifiables
