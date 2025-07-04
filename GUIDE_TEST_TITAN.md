# Guide de test mopro sur appareil iOS "Titan"

## 🎯 Objectif
Tester les fonctionnalités de preuves zero-knowledge avec mopro sur un vrai appareil iOS.

## 📱 Tests à effectuer

### 1. Test Circom (ZK-SNARKs)
- **Objectif** : Prouver qu'on connaît deux nombres a et b tels que a * b = résultat
- **Inputs par défaut** : a = 5, b = 3
- **Résultat attendu** : Preuve que 5 * 3 = 15 sans révéler b

**Étapes** :
1. Aller dans l'onglet "Circom"
2. Entrer a = 5 (public)
3. Entrer b = 3 (privé)
4. Cliquer "Generate Proof"
5. Vérifier que la preuve est générée
6. Cliquer "Verify Proof"
7. Vérifier que la validation est réussie

### 2. Test Halo2 (PLONK)
- **Objectif** : Prouver la connaissance d'une séquence Fibonacci
- **Inputs par défaut** : Séquence prédéfinie

**Étapes** :
1. Aller dans l'onglet "Halo2"
2. Cliquer "Generate Proof"
3. Vérifier la génération de preuve
4. Cliquer "Verify Proof"
5. Vérifier la validation

### 3. Test Noir
- **Objectif** : Tester les preuves avec le langage Noir
- **Inputs par défaut** : a = 5, b = 3

**Étapes** :
1. Aller dans l'onglet "Noir"
2. Entrer les valeurs
3. Générer et vérifier la preuve

## 🔍 Points d'attention

### Performance
- **Temps de génération** : Les preuves peuvent prendre plusieurs secondes
- **Consommation batterie** : Les calculs ZK sont intensifs
- **Mémoire** : Surveiller l'utilisation mémoire

### Erreurs possibles
- **Timeout** : Les preuves peuvent prendre du temps
- **Erreurs de compilation** : Vérifier les assets
- **Erreurs de validation** : Vérifier la cohérence des inputs

## 📊 Résultats attendus

Si tout fonctionne correctement :
- ✅ Les preuves se génèrent sans erreur
- ✅ Les vérifications retournent `true`
- ✅ L'interface reste responsive
- ✅ Pas de crash de l'application

## 🐛 Debugging

Si des erreurs surviennent :
1. Vérifier les logs Flutter
2. Redémarrer l'application
3. Vérifier les assets ZK
4. Tester avec des valeurs différentes

## 📝 Notes de performance

Exemple de temps de génération (à mesurer) :
- Circom : ~X secondes
- Halo2 : ~X secondes  
- Noir : ~X secondes

Ces temps peuvent varier selon :
- Le modèle d'appareil
- La complexité du circuit
- La température de l'appareil
