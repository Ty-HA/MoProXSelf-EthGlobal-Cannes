# Guide pour Scanner NFC Réel avec Self Protocol

## 📱 Étapes pour utiliser le scan NFC réel

### 1. Prérequis
- Carte d'identité européenne compatible NFC
- Application Self Protocol installée sur votre téléphone
- Backend exposé publiquement (ngrok ou autre)

### 2. Configuration
1. **Installer ngrok** (si pas encore fait) :
   ```bash
   brew install ngrok
   ```

2. **Configurer le token ngrok** :
   - Allez sur https://dashboard.ngrok.com/get-started/your-authtoken
   - Copiez votre token
   - Exécutez : `ngrok authtoken YOUR_TOKEN_HERE`

3. **Exposer le backend** :
   ```bash
   cd backend
   ./setup_ngrok.sh
   ```

### 3. Utilisation
1. **Démarrer le backend exposé** avec ngrok
2. **Mettre à jour l'URL** dans l'app Flutter avec l'URL ngrok
3. **Ouvrir l'app Self Protocol** sur votre téléphone
4. **Scanner votre carte d'identité** via NFC
5. **Retourner à l'app Flutter** et utiliser "Real NFC Verification"

### 4. Dépannage
- **NFC ne fonctionne pas** : Vérifiez que NFC est activé sur votre téléphone
- **Carte non reconnue** : Assurez-vous que c'est une carte d'identité européenne récente
- **Backend inaccessible** : Vérifiez que l'URL ngrok est correcte dans l'app

### 5. Test avec Self Protocol
- L'app Self Protocol doit être configurée avec l'URL du backend
- La carte d'identité doit être compatible NFC
- La vérification se fait dans le TEE (Trusted Execution Environment)

## 🔧 Configuration Flutter pour URL dynamique

Vous devez mettre à jour l'URL du backend dans `self_protocol_service.dart` :

```dart
static const String baseUrl = 'VOTRE_URL_NGROK_ICI';
```

## 🚀 Commandes rapides

```bash
# Exposer le backend
cd backend && ./setup_ngrok.sh

# Obtenir l'URL ngrok
cat backend/.ngrok_url

# Tester le backend
curl "$(cat backend/.ngrok_url)/health"
```
