#!/bin/bash

# Script de déploiement automatique du contrat Groth16Verifier
# Utilise Foundry pour le déploiement sur Sepolia

echo "🚀 Déploiement du contrat Groth16Verifier sur Sepolia..."

# Vérifications préalables
if [ ! -f "contracts/Groth16Verifier.sol" ]; then
    echo "❌ Contrat non trouvé. Exécutez d'abord: ./generate_verifier.sh"
    exit 1
fi

# Configuration
SEPOLIA_RPC="https://ethereum-sepolia.publicnode.com"
PRIVATE_KEY="YOUR_PRIVATE_KEY"  # À remplacer par votre clé privée
CONTRACT_PATH="contracts/Groth16Verifier.sol"

echo "📋 Configuration:"
echo "  - Réseau: Sepolia Testnet"
echo "  - RPC: $SEPOLIA_RPC"
echo "  - Contrat: $CONTRACT_PATH"
echo ""

# Vérifier que Foundry est installé
if ! command -v forge &> /dev/null; then
    echo "❌ Foundry n'est pas installé. Installation..."
    curl -L https://foundry.paradigm.xyz | bash
    source ~/.bashrc
    foundryup
fi

# Créer la structure Foundry
if [ ! -f "foundry.toml" ]; then
    echo "🔧 Initialisation du projet Foundry..."
    forge init --force --no-git .
fi

# Copier le contrat vers src/
mkdir -p src
cp contracts/Groth16Verifier.sol src/

# Compiler le contrat
echo "🔨 Compilation du contrat..."
forge build

if [ $? -ne 0 ]; then
    echo "❌ Erreur de compilation"
    exit 1
fi

# Instructions pour le déploiement manuel
echo ""
echo "✅ Contrat compilé avec succès!"
echo ""
echo "📝 Instructions de déploiement:"
echo ""
echo "1. Exportez votre clé privée:"
echo "   export PRIVATE_KEY=your_private_key_here"
echo ""
echo "2. Déployez sur Sepolia:"
echo "   forge create --rpc-url $SEPOLIA_RPC \\"
echo "     --private-key \$PRIVATE_KEY \\"
echo "     --etherscan-api-key YOUR_ETHERSCAN_API_KEY \\"
echo "     --verify \\"
echo "     src/Groth16Verifier.sol:Groth16Verifier"
echo ""
echo "3. Copiez l'adresse du contrat déployé"
echo ""
echo "4. Mettez à jour onchain_verification_service.dart:"
echo "   static const String VERIFIER_CONTRACT_ADDRESS = '0xADRESSE_DEPLOYEE';"
echo ""

# Alternative via Remix
echo "💡 Alternative: Déploiement via Remix IDE"
echo ""
echo "1. Ouvrez https://remix.ethereum.org"
echo "2. Créez un nouveau fichier Groth16Verifier.sol"
echo "3. Copiez le contenu de: contracts/Groth16Verifier.sol"
echo "4. Compilez avec Solidity 0.8.x"
echo "5. Connectez MetaMask sur Sepolia"
echo "6. Déployez le contrat"
echo "7. Copiez l'adresse déployée"
echo ""

# Informations sur les coûts
echo "💰 Estimation des coûts (Sepolia):"
echo "  - Déploiement: ~800,000 gas (~$2-5)"
echo "  - Vérification: GRATUIT (fonction view)"
echo ""

# Génération du script de mise à jour
cat > update_contract_address.sh << 'EOF'
#!/bin/bash
# Script pour mettre à jour l'adresse du contrat

if [ $# -eq 0 ]; then
    echo "Usage: $0 <contract_address>"
    echo "Exemple: $0 0x1234567890abcdef..."
    exit 1
fi

CONTRACT_ADDRESS=$1
SERVICE_FILE="lib/services/onchain_verification_service.dart"

echo "🔄 Mise à jour de l'adresse du contrat..."
echo "  Nouvelle adresse: $CONTRACT_ADDRESS"

# Backup du fichier
cp $SERVICE_FILE ${SERVICE_FILE}.backup

# Remplacer l'adresse
sed -i.tmp "s/static const String VERIFIER_CONTRACT_ADDRESS = '.*';/static const String VERIFIER_CONTRACT_ADDRESS = '$CONTRACT_ADDRESS';/" $SERVICE_FILE

rm ${SERVICE_FILE}.tmp

echo "✅ Adresse mise à jour dans $SERVICE_FILE"
echo "📦 Backup sauvegardé: ${SERVICE_FILE}.backup"
EOF

chmod +x update_contract_address.sh

echo "📦 Script de mise à jour créé: update_contract_address.sh"
echo ""
echo "🎯 Une fois déployé, exécutez:"
echo "   ./update_contract_address.sh 0xVOTRE_ADRESSE_DEPLOYEE"
