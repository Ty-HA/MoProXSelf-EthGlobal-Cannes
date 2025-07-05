#!/bin/bash

# Script pour générer le contrat Solidity verifier
# Nécessite snarkjs installé globalement

echo "🔧 Génération du contrat Solidity verifier..."

# Vérifier que snarkjs est installé
if ! command -v snarkjs &> /dev/null; then
    echo "❌ snarkjs n'est pas installé. Installation..."
    npm install -g snarkjs
fi

# Chemin vers le fichier .zkey
ZKEY_PATH="assets/multiplier2_final.zkey"
OUTPUT_PATH="contracts/Groth16Verifier.sol"

# Créer le dossier contracts s'il n'existe pas
mkdir -p contracts

echo "📋 Génération du verifier à partir de $ZKEY_PATH..."

# Générer le contrat Solidity verifier
snarkjs zkey export solidityverifier "$ZKEY_PATH" "$OUTPUT_PATH"

if [ $? -eq 0 ]; then
    echo "✅ Contrat verifier généré : $OUTPUT_PATH"
    echo ""
    echo "📝 Prochaines étapes :"
    echo "1. Déployer le contrat sur Sepolia testnet"
    echo "2. Mettre à jour l'adresse dans onchain_verification_service.dart"
    echo "3. Tester la vérification on-chain"
    echo ""
    echo "💡 Exemple de déploiement avec Remix :"
    echo "- Aller sur https://remix.ethereum.org"
    echo "- Copier le contenu de $OUTPUT_PATH"
    echo "- Compiler et déployer sur Sepolia"
    echo "- Copier l'adresse du contrat déployé"
else
    echo "❌ Erreur lors de la génération du verifier"
    exit 1
fi
