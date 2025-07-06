import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("AgeVerifierModule", (m) => {
  const ageVerifier = m.contract("contracts/AgeVerifier.sol:AgeVerifier");  // Correct name!

  return { ageVerifier };
});
