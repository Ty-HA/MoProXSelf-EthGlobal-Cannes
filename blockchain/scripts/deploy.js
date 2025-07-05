const { ethers } = require("hardhat");
const fs = require("fs");
const path = require("path");

async function main() {
  console.log("🚀 Deploying Groth16Verifier contract...");
  
  // Get the deployer account
  const [deployer] = await ethers.getSigners();
  console.log("📝 Deploying with account:", deployer.address);
  
  // Get account balance
  const balance = await deployer.provider.getBalance(deployer.address);
  console.log("💰 Account balance:", ethers.formatEther(balance), "ETH");
  
  if (balance < ethers.parseEther("0.01")) {
    console.warn("⚠️  Warning: Account balance is low. You may need more ETH for deployment.");
  }
  
  // Get the contract factory
  const Groth16Verifier = await ethers.getContractFactory("Groth16Verifier");
  
  // Deploy the contract
  console.log("⏳ Deploying contract...");
  const verifier = await Groth16Verifier.deploy();
  
  // Wait for deployment
  await verifier.waitForDeployment();
  const contractAddress = await verifier.getAddress();
  
  console.log("✅ Groth16Verifier deployed successfully!");
  console.log("📍 Contract address:", contractAddress);
  console.log("🔗 Transaction hash:", verifier.deploymentTransaction().hash);
  
  // Save deployment info
  const deploymentInfo = {
    contractAddress: contractAddress,
    transactionHash: verifier.deploymentTransaction().hash,
    network: hre.network.name,
    deployer: deployer.address,
    timestamp: new Date().toISOString(),
    blockNumber: verifier.deploymentTransaction().blockNumber
  };
  
  // Save to file
  const deploymentsDir = path.join(__dirname, "../deployments");
  if (!fs.existsSync(deploymentsDir)) {
    fs.mkdirSync(deploymentsDir, { recursive: true });
  }
  
  const deploymentFile = path.join(deploymentsDir, `${hre.network.name}.json`);
  fs.writeFileSync(deploymentFile, JSON.stringify(deploymentInfo, null, 2));
  
  console.log("\n📋 Deployment Summary:");
  console.log("Contract Address:", deploymentInfo.contractAddress);
  console.log("Network:", deploymentInfo.network);
  console.log("Deployer:", deploymentInfo.deployer);
  console.log("Timestamp:", deploymentInfo.timestamp);
  console.log("📁 Deployment info saved to:", deploymentFile);
  
  // Wait for confirmations on live networks
  if (hre.network.name !== "hardhat" && hre.network.name !== "localhost") {
    console.log("\n⏳ Waiting for confirmations...");
    await verifier.deploymentTransaction().wait(5);
    console.log("✅ Contract confirmed with 5 blocks!");
    
    // Verify on Etherscan if API key is provided
    if (process.env.ETHERSCAN_API_KEY) {
      console.log("\n🔍 Verifying contract on Etherscan...");
      try {
        await hre.run("verify:verify", {
          address: contractAddress,
          constructorArguments: [],
        });
        console.log("✅ Contract verified on Etherscan!");
      } catch (error) {
        console.log("❌ Etherscan verification failed:", error.message);
      }
    }
  }
  
  // Generate Flutter constants
  const flutterConstantsContent = `
// GENERATED FILE - DO NOT EDIT MANUALLY
// Generated on: ${new Date().toISOString()}

class BlockchainConstants {
  static const String groth16VerifierAddress = '${contractAddress}';
  static const String network = '${hre.network.name}';
  static const int chainId = ${hre.network.config.chainId || 'null'};
  static const String deployer = '${deployer.address}';
  static const String deploymentTimestamp = '${deploymentInfo.timestamp}';
  
  // Etherscan URLs
  static const String etherscanBaseUrl = ${hre.network.name === 'sepolia' ? "'https://sepolia.etherscan.io'" : "'https://etherscan.io'"};
  static String get contractUrl => '\$etherscanBaseUrl/address/\$groth16VerifierAddress';
  static String transactionUrl(String txHash) => '\$etherscanBaseUrl/tx/\$txHash';
}
`;

  const flutterConstantsPath = path.join(__dirname, "../../lib/core/constants/blockchain_constants.dart");
  const flutterConstantsDir = path.dirname(flutterConstantsPath);
  
  if (!fs.existsSync(flutterConstantsDir)) {
    fs.mkdirSync(flutterConstantsDir, { recursive: true });
  }
  
  fs.writeFileSync(flutterConstantsPath, flutterConstantsContent.trim());
  console.log("📱 Flutter constants generated:", flutterConstantsPath);
  
  return deploymentInfo;
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("❌ Deployment failed:", error);
    process.exit(1);
  });
