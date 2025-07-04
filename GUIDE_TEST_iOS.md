# Guide de test mopro sur appareil iOS (Titan)

## 🎯 Objectif
Tester les preuves zero-knowledge avec mopro sur un vrai appareil iOS.

## 📱 Fonctionnalités à tester sur Titan

### 1. Onglet Circom (Multiplication ZK)
- **Input `a`** : 5 (nombre public)
- **Input `b`** : 3 (nombre privé)
- **Résultat attendu** : Preuve que 5 × 3 = 15 sans révéler `b`

**Test à faire :**
1. Cliquer sur "Generate Proof" → Vérifier qu'une preuve est générée
2. Cliquer sur "Verify Proof" → Vérifier que la preuve est valide

### 2. Onglet Halo2 (Fibonacci)
- **Test** : Génération de preuve PLONK pour la suite Fibonacci
- **Vérification** : Que les calculs Fibonacci sont corrects

### 3. Onglet Noir (ZK général)
- **Test** : Preuves avec le langage Noir
- **Vérification** : Génération et vérification de preuves

## 🔍 Points d'attention

### Performance
- **Temps de génération** : Les preuves ZK peuvent prendre plusieurs secondes
- **Utilisation CPU** : L'appareil peut chauffer légèrement
- **Mémoire** : Surveiller l'utilisation mémoire

### Erreurs possibles
- **Timeout** : Si la génération prend trop de temps
- **Erreur de format** : Si les inputs ne sont pas valides
- **Erreur de vérification** : Si la preuve est corrompue

## 📊 Résultats attendus

### Circom
```
Inputs: {"a":["5"],"b":["3"]}
Proof: Chaîne hexadécimale longue
Valid: true
```

### Halo2
```
Proof: Données binaires
Valid: true
```

### Noir
```
Proof: Format JSON
Valid: true
```

## 🚀 Après les tests

Si tout fonctionne bien, tu pourras :
1. **Intégrer mopro** dans tes propres projets Flutter
2. **Créer des circuits** ZK personnalisés
3. **Déployer** des applications avec preuves zero-knowledge

## 📝 Notes de développement

- **Circuit files** : Stockés dans `assets/`
- **Plugin principal** : `mopro_flutter`
- **Méthodes clés** : `generateCircomProof()`, `verifyCircomProof()`

---

**Bon test ! 🎉** L'application devrait se lancer sur ton Titan dans quelques instants.
