# Groth16Verifier.sol - Smart Contract Documentation

## 📋 Vue d'ensemble

Le contrat `Groth16Verifier.sol` est un vérificateur de preuves zero-knowledge Groth16 généré automatiquement à partir du circuit `multiplier2`. Il permet de vérifier on-chain les preuves ZK générées par votre application Flutter.

## 🔍 Fonction principale

```solidity
function verifyProof(
    uint[2] calldata _pA,           // Point A de la preuve
    uint[2][2] calldata _pB,        // Point B de la preuve
    uint[2] calldata _pC,           // Point C de la preuve
    uint[2] calldata _pubSignals    // Signaux publics [minAge, userAge * minAge]
) public view returns (bool)
```

### Paramètres d'entrée

1. **`_pA`** : Point A de la preuve Groth16 (coordonnées G1)
2. **`_pB`** : Point B de la preuve Groth16 (coordonnées G2) 
3. **`_pC`** : Point C de la preuve Groth16 (coordonnées G1)
4. **`_pubSignals`** : Tableau des signaux publics du circuit

### Signaux publics pour la vérification d'âge

Pour le circuit `multiplier2` adapté à la vérification d'âge :

```solidity
_pubSignals[0] = minAge          // Âge minimum requis (ex: 18)
_pubSignals[1] = userAge * minAge // Résultat de la multiplication (ex: 21 * 18 = 378)
```

## 🔧 Déploiement

### 1. Via Remix IDE

1. Ouvrir [Remix](https://remix.ethereum.org)
2. Créer un nouveau fichier `Groth16Verifier.sol`
3. Copier le contenu du contrat généré
4. Compiler avec Solidity 0.8.x
5. Déployer sur Sepolia testnet

### 2. Estimation des coûts

- **Déploiement** : ~800,000 gas (~$2-5 sur Sepolia)
- **Vérification read-only** : GRATUIT (fonction `view`)
- **Vérification avec transaction** : ~200,000 gas (~$1-3)

### 3. Configuration réseau

**Sepolia Testnet** (recommandé pour tests)
- RPC : `https://ethereum-sepolia.publicnode.com`
- Chain ID : 11155111
- Faucet : [Sepolia Faucet](https://sepoliafaucet.com/)

## 📱 Intégration Flutter

### Configuration du service

```dart
// lib/services/onchain_verification_service.dart
static const String VERIFIER_CONTRACT_ADDRESS = '0xVOTRE_ADRESSE_DEPLOYEE';
static const String SEPOLIA_RPC = 'https://ethereum-sepolia.publicnode.com';
```

### Vérification read-only (recommandée)

```dart
Future<bool> verifyProofReadOnly(Map<String, dynamic> proofData) async {
  final result = await _web3Client.call(
    contract: _verifierContract,
    function: verifyFunction,
    params: [pA, pB, pC, pubSignals],
  );
  
  return result.first as bool;
}
```

### Format des données de preuve

```dart
Map<String, dynamic> proofData = {
  'pA': ['0x...', '0x...'],           // Point A (2 éléments)
  'pB': [['0x...', '0x...'], 
         ['0x...', '0x...']],         // Point B (2x2 éléments)
  'pC': ['0x...', '0x...'],           // Point C (2 éléments)
  'pubSignals': ['18', '378'],        // [minAge, userAge * minAge]
};
```

## 🔐 Clés de vérification

Le contrat contient les clés de vérification hardcodées du circuit :

```solidity
// Clés alpha, beta, gamma, delta (points elliptiques)
uint256 constant alphax = 20491192805390485299153009773594534940189261866228447918068658471970481763042;
uint256 constant alphay = 9383485363053290200918347156157836566562967994039712273449902621266178545958;

// Points IC pour les inputs publics
uint256 constant IC0x = 6819801395408938350212900248749732364821477541620635511814266536599629892365;
uint256 constant IC1x = 17882351432929302592725330552407222299541667716607588771282887857165175611387;
uint256 constant IC2x = 15838138634521468894153380932528531886891906022296654376137218419558038465083;
```

Ces clés sont **spécifiques** à votre circuit `multiplier2` et ne peuvent vérifier que les preuves générées avec le fichier `.zkey` correspondant.

## ⚡ Optimisations

### Gas efficiency

Le contrat utilise des optimisations assembly pour réduire les coûts :

1. **Opérations elliptiques** : Utilise les precompiles Ethereum
2. **Validation des champs** : Vérifie que tous les éléments sont dans le bon champ fini
3. **Pairing check** : Utilise le precompile pairing d'Ethereum (adresse 0x08)

### Sécurité

- **Validation des inputs** : Tous les éléments sont vérifiés avant utilisation
- **Protection overflow** : Utilise l'arithmétique modulaire sécurisée
- **Read-only** : La fonction de vérification est `view` (pas d'état modifié)

## 🧪 Tests et validation

### Test avec des données réelles

```javascript
// Exemple de test avec des vraies preuves
const proof = {
  a: ["0x...", "0x..."],
  b: [["0x...", "0x..."], ["0x...", "0x..."]],
  c: ["0x...", "0x..."]
};

const publicSignals = ["18", "378"]; // minAge=18, userAge=21

const isValid = await verifier.verifyProof(
  proof.a,
  proof.b, 
  proof.c,
  publicSignals
);
```

### Debugging

Si la vérification échoue :

1. **Vérifier les signaux publics** : Ordre et format corrects
2. **Valider la preuve** : Générée avec le bon circuit
3. **Contrôler les types** : uint256 en hexadécimal
4. **Tester localement** : Avec Ganache avant déploiement

## 📊 Monitoring

### Events (optionnel)

Vous pouvez ajouter des événements pour tracker les vérifications :

```solidity
event ProofVerified(
    address indexed verifier,
    uint256 minAge,
    uint256 timestamp,
    bool success
);

function verifyProofWithEvent(/* params */) public returns (bool) {
    bool result = verifyProof(_pA, _pB, _pC, _pubSignals);
    
    emit ProofVerified(
        msg.sender,
        _pubSignals[0], // minAge
        block.timestamp,
        result
    );
    
    return result;
}
```

### Intégration avec explorateurs

Une fois déployé, le contrat sera visible sur :
- **Sepolia Etherscan** : `https://sepolia.etherscan.io/address/0xVOTRE_ADRESSE`
- **Transactions** : Toutes les vérifications seront publiques
- **ABI** : Interface pour interagir avec le contrat

## 🚀 Prochaines étapes

1. **Déployer** le contrat sur Sepolia
2. **Mettre à jour** l'adresse dans Flutter
3. **Tester** la vérification read-only
4. **Intégrer** dans l'UI principale
5. **Documenter** pour les juges EthGlobal

## 💡 Pour EthGlobal Cannes

Ce contrat démontre :
- **Intégration Web3** : Smart contract déployé
- **Zero-Knowledge** : Vérification ZK on-chain
- **Mobile-first** : Preuves générées sur mobile
- **Interopérabilité** : Mopro + Ethereum + Flutter

Parfait pour impressionner les juges avec une démo complète !
