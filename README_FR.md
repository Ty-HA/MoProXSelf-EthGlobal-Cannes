# Mopro Flutter Test App

Ce projet est un exemple d'utilisation de mopro avec Flutter pour générer et vérifier des preuves zero-knowledge.

## Qu'est-ce que mopro ?

Mopro est une bibliothèque qui permet de générer et vérifier des preuves zero-knowledge (ZK) sur mobile. Elle supporte :
- **Circom** avec arkworks
- **Halo2** pour les preuves PLONK
- **Noir** pour les preuves zero-knowledge

## Comment utiliser cette app

### 1. Lancer l'application

```bash
# Sur macOS
flutter run -d macos

# Sur le web
flutter run -d chrome
```

### 2. Tester les preuves

L'app contient 3 onglets :

#### Onglet Circom
- **Input public `a`** : Un nombre public (ex: 5)
- **Input privé `b`** : Un nombre privé (ex: 3)
- **Generate Proof** : Génère une preuve que `a * b = résultat`
- **Verify Proof** : Vérifie que la preuve est valide

#### Onglet Halo2
- Teste des preuves PLONK avec la suite Fibonacci

#### Onglet Noir
- Teste des preuves avec le langage Noir

### 3. Exemple d'utilisation

```dart
// Générer une preuve Circom
var inputs = '{"a":["5"],"b":["3"]}';
CircomProofResult? proofResult = await _moproFlutterPlugin.generateCircomProof(
    "assets/multiplier2_final.zkey", 
    inputs, 
    ProofLib.arkworks
);

// Vérifier la preuve
bool? valid = await _moproFlutterPlugin.verifyCircomProof(
    "assets/multiplier2_final.zkey", 
    proofResult!, 
    ProofLib.arkworks
);
```

## Assets ZK inclus

- `multiplier2_final.zkey` : Circuit Circom pour multiplication
- `noir_multiplier2.json` : Circuit Noir pour multiplication
- `plonk_fibonacci_*.bin` : Circuit Halo2 pour Fibonacci

## Développement

Pour modifier les circuits ZK ou ajouter de nouveaux circuits, consultez la documentation officielle de mopro : https://zkmopro.org/docs/
