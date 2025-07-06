import { ethers } from 'ethers';

// Configuration
const CONTRACT_ADDRESS = "0x9B14F909E21007f1426dc0AeD5c1A484E624555F";
const RPC_URL = "https://sepolia-rollup.arbitrum.io/rpc";

// ABI minimal pour la fonction verifyProof
const CONTRACT_ABI = [
  {
    "inputs": [
      {"internalType": "uint256[2]", "name": "_pA", "type": "uint256[2]"},
      {"internalType": "uint256[2][2]", "name": "_pB", "type": "uint256[2][2]"},
      {"internalType": "uint256[2]", "name": "_pC", "type": "uint256[2]"},
      {"internalType": "uint256[2]", "name": "_pubSignals", "type": "uint256[2]"}
    ],
    "name": "verifyProof",
    "outputs": [{"internalType": "bool", "name": "", "type": "bool"}],
    "stateMutability": "view",
    "type": "function"
  }
];

async function testProofVerification() {
  console.log("🔍 Testing proof verification with real contract...");
  
  // Provider
  const provider = new ethers.JsonRpcProvider(RPC_URL);
  
  // Contract
  const contract = new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, provider);
  
  // Real proof data from snarkjs
  const pA = [
    "19871734492130223601384149396474860003807184037298404992118567555557339254873",
    "19643855618483189492929249516094088210342707821376323233518586286656112591148"
  ];
  
  const pB = [
    [
      "7194383478967384340722346625573243301340316776350171626420348503805084740526",
      "12371843286090164522356828000192059120268968751899166513339879712471941238980"
    ],
    [
      "18239303357094372975430655516344199379449555177911766724735428335641544326311",
      "4165501871809686142678750165360536378728418367103424103416933556127190282027"
    ]
  ];
  
  const pC = [
    "16659473020686324899568698816336598444113066749653425062764654554095847624698",
    "21693830463071779329962651926134623071893039994067306203157095226398736896766"
  ];
  
  const pubSignals = ["18", "25"];
  
  console.log("📍 Contract:", CONTRACT_ADDRESS);
  console.log("📊 Public signals:", pubSignals);
  
  try {
    const result = await contract.verifyProof(pA, pB, pC, pubSignals);
    console.log("✅ Proof verification result:", result);
    
    if (result) {
      console.log("🎉 SUCCESS! The proof is VALID!");
      console.log("✅ Your circuit and contract are working correctly!");
    } else {
      console.log("❌ FAILED! The proof is invalid!");
    }
  } catch (error) {
    console.log("❌ ERROR calling contract:", error.message);
  }
}

testProofVerification();
