# Guide d'Utilisation du Scan NFC Réel

## 🚀 Comment utiliser le scan NFC réel avec Self Protocol

### Étape 1: Configurer le backend
1. Allez dans le dossier backend: `cd backend`
2. Configurez votre token ngrok: `ngrok authtoken YOUR_TOKEN`
3. Lancez le script: `./setup_ngrok.sh`
4. Notez l'URL ngrok générée

### Étape 2: Configurer l'application
1. Lancez l'application
2. Appuyez sur "Backend Configuration"
3. Entrez l'URL ngrok
4. Testez la connexion

### Étape 3: Utiliser le scan NFC
1. Appuyez sur "Real NFC Scan" dans le menu principal
2. Un QR code sera généré
3. Ouvrez l'application Self Protocol sur votre téléphone
4. Scannez le QR code
5. Placez votre carte d'identité sur le capteur NFC
6. Attendez le résultat de la vérification

## 🔮 Ce que vous avez dans votre application

Votre application MoProXSelf dispose maintenant des fonctionnalités suivantes:

1. **Vérification avec Mopro (ZK Proofs)**
   - Génération de preuves zéro-knowledge pour l'âge
   - QR codes pour le partage de preuves

2. **Self Protocol (NFC + TEE)**
   - Scan de cartes d'identité via NFC
   - Vérification sécurisée dans un TEE
   - QR codes spécifiques à Self Protocol

3. **Intégration Hybride**
   - Combinaison des preuves Mopro et Self Protocol
   - QR codes universels
   - Format de preuve fusionné

4. **Interface de configuration**
   - Configuration dynamique du backend
   - Tests de connectivité
   - Support pour ngrok

## 📱 Utilisation du scan NFC réel pour les démonstrations

Pour les démonstrations, vous pouvez utiliser:

1. **Mode simulation**: Utilisez "Self Protocol + TEE Test" pour simuler le scan NFC
2. **Mode réel**: Utilisez "Real NFC Scan" avec une vraie carte d'identité
3. **Mode hybride**: Utilisez "Hybrid Verification" pour combiner les deux approches

## 🛡️ Notes importantes sur la sécurité

- Le scan NFC réel nécessite une carte d'identité européenne compatible
- La vérification s'effectue dans un environnement d'exécution sécurisé (TEE)
- Aucune donnée personnelle n'est stockée sur le serveur
- Le QR code généré est unique et temporaire

## 🔧 Dépannage

Si vous rencontrez des problèmes:

1. Vérifiez que le backend est accessible (URL ngrok correcte)
2. Assurez-vous que le scan NFC est activé sur votre téléphone
3. Utilisez une carte d'identité compatible
4. Vérifiez que l'application Self Protocol est installée et à jour

## 🏆 Démonstration pour EthGlobal Cannes

Pour impressionner les juges:

1. Montrez le scan NFC simulé d'abord pour expliquer le concept
2. Ensuite, si possible, faites une démo avec une vraie carte d'identité
3. Expliquez comment Mopro et Self Protocol se complètent pour offrir une vérification complète
4. Mettez en avant le côté innovant de la fusion des deux technologies

N'hésitez pas à personnaliser cette démonstration selon vos besoins!
