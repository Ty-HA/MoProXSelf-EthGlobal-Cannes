/// Service de vérification on-chain hybride
/// Supporte les deux modes : READ-ONLY et TRANSACTION

import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

class OnChainVerificationService {
  static const String SEPOLIA_RPC = 'https://ethereum-sepolia.publicnode.com';
  static const String VERIFIER_CONTRACT_ADDRESS = '0x...'; // Votre contrat
  static const String VERIFIER_CONTRACT_ABI = '''[
    {
      "inputs": [
        {"internalType": "uint256[2]", "name": "_pA", "type": "uint256[2]"},
        {"internalType": "uint256[2][2]", "name": "_pB", "type": "uint256[2][2]"},
        {"internalType": "uint256[2]", "name": "_pC", "type": "uint256[2]"},
        {"internalType": "uint256[]", "name": "_pubSignals", "type": "uint256[]"}
      ],
      "name": "verifyProof",
      "outputs": [{"internalType": "bool", "name": "", "type": "bool"}],
      "stateMutability": "view",
      "type": "function"
    }
  ]''';

  late Web3Client _web3Client;
  late DeployedContract _verifierContract;

  /// Initialize service (no wallet required)
  Future<void> initialize() async {
    _web3Client = Web3Client(SEPOLIA_RPC, http.Client());

    final contractAbi =
        ContractAbi.fromJson(VERIFIER_CONTRACT_ABI, 'Groth16Verifier');
    _verifierContract = DeployedContract(
      contractAbi,
      EthereumAddress.fromHex(VERIFIER_CONTRACT_ADDRESS),
    );
  }

  /// Vérification READ-ONLY (pas de wallet requis)
  Future<bool> verifyProofReadOnly(Map<String, dynamic> proofData) async {
    try {
      final verifyFunction = _verifierContract.function('verifyProof');

      // Préparer les paramètres
      final pA = (proofData['pA'] as List<String>)
          .map((e) => BigInt.parse(e))
          .toList();
      final pB = (proofData['pB'] as List<List<String>>)
          .map((row) => row.map((e) => BigInt.parse(e)).toList())
          .toList();
      final pC = (proofData['pC'] as List<String>)
          .map((e) => BigInt.parse(e))
          .toList();
      final pubSignals = (proofData['pubSignals'] as List<String>)
          .map((e) => BigInt.parse(e))
          .toList();

      // Appel READ-ONLY (pas de gas)
      final result = await _web3Client.call(
        contract: _verifierContract,
        function: verifyFunction,
        params: [pA, pB, pC, pubSignals],
      );

      return result.first as bool;
    } catch (e) {
      print('❌ Erreur vérification read-only: $e');
      return false;
    }
  }

  /// Vérification avec transaction (wallet requis)
  Future<bool> verifyProofWithTransaction(
    Map<String, dynamic> proofData,
    EthereumAddress walletAddress,
    String privateKey,
  ) async {
    try {
      final credentials = EthPrivateKey.fromHex(privateKey);
      final verifyFunction = _verifierContract.function('verifyProof');

      // Préparer les paramètres
      final pA = (proofData['pA'] as List<String>)
          .map((e) => BigInt.parse(e))
          .toList();
      final pB = (proofData['pB'] as List<List<String>>)
          .map((row) => row.map((e) => BigInt.parse(e)).toList())
          .toList();
      final pC = (proofData['pC'] as List<String>)
          .map((e) => BigInt.parse(e))
          .toList();
      final pubSignals = (proofData['pubSignals'] as List<String>)
          .map((e) => BigInt.parse(e))
          .toList();

      // Transaction avec gas
      final transaction = Transaction.callContract(
        contract: _verifierContract,
        function: verifyFunction,
        parameters: [pA, pB, pC, pubSignals],
        gasPrice: EtherAmount.inWei(BigInt.from(20000000000)), // 20 gwei
      );

      final txHash = await _web3Client.sendTransaction(
        credentials,
        transaction,
        chainId: 11155111, // Sepolia
      );

      // Attendre la confirmation
      final receipt = await _web3Client.getTransactionReceipt(txHash);
      return receipt != null && receipt.status == true;
    } catch (e) {
      print('❌ Erreur vérification avec transaction: $e');
      return false;
    }
  }

  /// Générer le contrat Solidity verifier
  Future<String> generateSolidityVerifier(String zkeyPath) async {
    // Utiliser snarkjs pour générer le verifier
    // snarkjs zkey export solidityverifier circuit.zkey verifier.sol
    return '''
    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;
    
    contract Groth16Verifier {
        function verifyProof(
            uint[2] memory _pA,
            uint[2][2] memory _pB,
            uint[2] memory _pC,
            uint[2] memory _pubSignals
        ) public view returns (bool) {
            // Code généré par snarkjs
            // ...
        }
    }
    ''';
  }
}
