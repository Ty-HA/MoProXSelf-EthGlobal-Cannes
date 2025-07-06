const { ethers } = require("hardhat");

async function main() {
  // Contract address
  const contractAddress = "0x9B14F909E21007f1426dc0AeD5c1A484E624555F";
  
  // Real proof data from snarkjs
  const proof = {
    "pi_a": [
      "19871734492130223601384149396474860003807184037298404992118567555557339254873",
      "19643855618483189492929249516094088210342707821376323233518586286656112591148",
      "1"
    ],
    "pi_b": [
      [
        "12371843286090164522356828000192059120268968751899166513339879712471941238980",
        "7194383478967384340722346625573243301340316776350171626420348503805084740526"
      ],
      [
        "4165501871809686142678750165360536378728418367103424103416933556127190282027",
        "18239303357094372975430655516344199379449555177911766724735428335641544326311"
      ],
      [
        "1",
        "0"
      ]
    ],
    "pi_c": [
      "16659473020686324899568698816336598444113066749653425062764654554095847624698",
      "21693830463071779329962651926134623071893039994067306203157095226398736896766",
      "1"
    ]
  };
  
  const publicSignals = ["18", "25"];
  
  // Connect to the contract
  const contract = await ethers.getContractAt("AgeVerifier", contractAddress);
  
  // Format proof for Solidity
  const pA = [proof.pi_a[0], proof.pi_a[1]];
  const pB = [[proof.pi_b[0][1], proof.pi_b[0][0]], [proof.pi_b[1][1], proof.pi_b[1][0]]];
  const pC = [proof.pi_c[0], proof.pi_c[1]];
  const pubSignals = publicSignals;
  
  console.log("🔍 Testing proof verification...");
  console.log("📍 Contract:", contractAddress);
  console.log("📊 Public signals:", pubSignals);
  
  try {
    const result = await contract.verifyProof(pA, pB, pC, pubSignals);
    console.log("✅ Proof verification result:", result);
    
    if (result) {
      console.log("🎉 SUCCESS! The proof is valid!");
    } else {
      console.log("❌ FAILED! The proof is invalid!");
    }
  } catch (error) {
    console.log("❌ ERROR calling contract:", error.message);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
