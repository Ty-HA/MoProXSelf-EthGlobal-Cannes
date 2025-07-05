// GENERATED FILE - DO NOT EDIT MANUALLY
// Generated on: 2025-07-05T19:30:00.000Z
// Contract deployed and verified on Arbitrum Sepolia

/// Blockchain constants for ZK Age Verification
/// 
/// This class contains all the necessary constants to interact with
/// the deployed Groth16Verifier contract on Arbitrum Sepolia.
class BlockchainConstants {
  // Contract Information
  static const String groth16VerifierAddress = '0xC7e4179bB1a48CDbdcE3e6A5f778CED6d19cd6b8';
  static const String contractName = 'Groth16Verifier';
  
  // Network Configuration
  static const String network = 'arbitrum-sepolia';
  static const String networkName = 'Arbitrum Sepolia';
  static const int chainId = 421614;
  static const String nativeToken = 'ETH';
  
  // RPC Endpoints
  static const String rpcUrl = 'https://sepolia-rollup.arbitrum.io/rpc';
  static const String alchemyRpcUrl = 'https://arb-sepolia.g.alchemy.com/v2/2mDWpv7rxdN7sed4uZbFm7c2VDq1l7PP';
  
  // Explorer URLs
  static const String explorerBaseUrl = 'https://sepolia.arbiscan.io';
  static const String explorerName = 'Arbiscan';
  
  // Contract URLs
  static String get contractUrl => '$explorerBaseUrl/address/$groth16VerifierAddress';
  static String get contractCodeUrl => '$explorerBaseUrl/address/$groth16VerifierAddress#code';
  static String get contractReadUrl => '$explorerBaseUrl/address/$groth16VerifierAddress#readContract';
  
  // Utility Methods
  static String transactionUrl(String txHash) => '$explorerBaseUrl/tx/$txHash';
  static String addressUrl(String address) => '$explorerBaseUrl/address/$address';
  
  // Contract Deployment Info
  static const String deploymentDate = '2025-07-05';
  static const String deployerAddress = '0x742FC65b2D6b24B73e1C2BA5E6E2b51e5e1BfA01'; // Update with actual deployer
  static const bool isVerified = true;
  static const String compilerVersion = '0.8.28';
  static const bool optimizationEnabled = true;
  static const int optimizationRuns = 200;
  
  // Gas Configuration
  static const int estimatedGasForVerification = 300000;
  static const String gasTokenSymbol = 'ETH';
  
  // Contract ABI - Main function signature
  static const String verifyProofFunction = 'verifyProof(uint256[2],uint256[2][2],uint256[2],uint256[2])';
  
  // Network Configuration for Web3
  static Map<String, dynamic> get networkConfig => {
    'chainId': '0x${chainId.toRadixString(16)}', // 0x66eee
    'chainName': networkName,
    'nativeCurrency': {
      'name': 'Ethereum',
      'symbol': nativeToken,
      'decimals': 18,
    },
    'rpcUrls': [rpcUrl],
    'blockExplorerUrls': [explorerBaseUrl],
  };
  
  // Contract ABI for the verifyProof function
  static const List<Map<String, dynamic>> contractAbi = [
    {
      "inputs": [
        {
          "internalType": "uint256[2]",
          "name": "_pA",
          "type": "uint256[2]"
        },
        {
          "internalType": "uint256[2][2]",
          "name": "_pB",
          "type": "uint256[2][2]"
        },
        {
          "internalType": "uint256[2]",
          "name": "_pC",
          "type": "uint256[2]"
        },
        {
          "internalType": "uint256[2]",
          "name": "_pubSignals",
          "type": "uint256[2]"
        }
      ],
      "name": "verifyProof",
      "outputs": [
        {
          "internalType": "bool",
          "name": "",
          "type": "bool"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    }
  ];
  
  // Development flags
  static const bool isDevelopment = true;
  static const bool enableLogging = true;
  static const bool useTestnet = true;
  
  // Validation helpers
  static bool isValidAddress(String address) {
    return address.toLowerCase().startsWith('0x') && address.length == 42;
  }
  
  static bool isValidTxHash(String txHash) {
    return txHash.toLowerCase().startsWith('0x') && txHash.length == 66;
  }
}
