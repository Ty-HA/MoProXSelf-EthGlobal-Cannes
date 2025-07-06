// GENERATED FILE - DO NOT EDIT MANUALLY
// Generated on: 2025-07-06T01:00:00.000Z
// Contract deployed and verified on Arbitrum Sepolia
// Contract verified: https://sepolia.arbiscan.io/address/0x9B14F909E21007f1426dc0AeD5c1A484E624555F

/// Blockchain constants for ZK Age Verification
///
/// This class contains all the necessary constants to interact with
/// the deployed AgeVerifier contract on Arbitrum Sepolia.
class BlockchainConstants {
  // Contract Information
  static const String groth16VerifierAddress =
      '0x9B14F909E21007f1426dc0AeD5c1A484E624555F';
  static const String contractName = 'AgeVerifier';
  static const String contractDisplayName = 'ZK Age Verifier';
  static const String contractDescription =
      'Zero-Knowledge Age Verification using Circom and Groth16 proofs';
  static const String verificationStatus = 'Verified ✅';

  // Network Configuration
  static const String network = 'arbitrum-sepolia';
  static const String networkName = 'Arbitrum Sepolia';
  static const int chainId = 421614;
  static const String nativeToken = 'ETH';

  // RPC Endpoints
  static const String rpcUrl = 'https://sepolia-rollup.arbitrum.io/rpc';
  static const String alchemyRpcUrl =
      'https://arb-sepolia.g.alchemy.com/v2/2mDWpv7rxdN7sed4uZbFm7c2VDq1l7PP';

  // Explorer URLs
  static const String explorerBaseUrl = 'https://sepolia.arbiscan.io';
  static const String explorerName = 'Arbiscan';

  // Contract URLs
  static String get contractUrl =>
      '$explorerBaseUrl/address/$groth16VerifierAddress';
  static String get contractCodeUrl =>
      '$explorerBaseUrl/address/$groth16VerifierAddress#code';
  static String get contractReadUrl =>
      '$explorerBaseUrl/address/$groth16VerifierAddress#readContract';

  // Utility Methods
  static String transactionUrl(String txHash) => '$explorerBaseUrl/tx/$txHash';
  static String addressUrl(String address) =>
      '$explorerBaseUrl/address/$address';

  // Contract Deployment Info
  static const String deploymentDate = '2025-07-06';
  static const String deployerAddress =
      '0x742FC65b2D6b24B73e1C2BA5E6E2b51e5e1BfA01'; // Update with actual deployer
  static const bool isVerified = true;
  static const String compilerVersion = '0.8.28+commit.7893614a';
  static const bool optimizationEnabled = true;
  static const int optimizationRuns = 200;
  static const String license = 'GPL-3.0';
  static const String sourceCodeUrl =
      'https://sepolia.arbiscan.io/address/0x9B14F909E21007f1426dc0AeD5c1A484E624555F#code';

  // Gas Configuration
  static const int estimatedGasForVerification = 300000;
  static const String gasTokenSymbol = 'ETH';

  // Contract ABI - Main function signature
  static const String verifyProofFunction =
      'verifyProof(uint256[2],uint256[2][2],uint256[2],uint256[2])';

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
        {"internalType": "uint256[2]", "name": "_pA", "type": "uint256[2]"},
        {
          "internalType": "uint256[2][2]",
          "name": "_pB",
          "type": "uint256[2][2]"
        },
        {"internalType": "uint256[2]", "name": "_pC", "type": "uint256[2]"},
        {
          "internalType": "uint256[2]",
          "name": "_pubSignals",
          "type": "uint256[2]"
        }
      ],
      "name": "verifyProof",
      "outputs": [
        {"internalType": "bool", "name": "", "type": "bool"}
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
