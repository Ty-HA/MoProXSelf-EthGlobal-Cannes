// Script pour tester votre circuit Circom
const snarkjs = require("snarkjs");
const fs = require("fs");

async function testCircuit() {
    console.log("🔍 Testing circuit with inputs: a=18, b=25");
    
    try {
        // Inputs pour le circuit
        const inputs = {
            "a": 18,
            "b": 25
        };
        
        // Vérifier si les fichiers existent
        const zkeyPath = "./assets/multiplier2_final.zkey";
        const wasmPath = "./assets/multiplier2.wasm"; // Vous devriez avoir ce fichier aussi
        
        console.log("📁 Checking files...");
        console.log("- .zkey exists:", fs.existsSync(zkeyPath));
        console.log("- .wasm exists:", fs.existsSync(wasmPath));
        
        if (!fs.existsSync(zkeyPath)) {
            console.log("❌ .zkey file not found at:", zkeyPath);
            return;
        }
        
        // Générer la preuve
        console.log("🔑 Generating proof...");
        const { proof, publicSignals } = await snarkjs.groth16.fullProve(
            inputs,
            wasmPath,
            zkeyPath
        );
        
        console.log("✅ Proof generated successfully!");
        console.log("📊 Public signals:", publicSignals);
        console.log("🧮 Expected: [18, 450] (a, a*b)");
        console.log("🎯 Match:", JSON.stringify(publicSignals) === JSON.stringify(["18", "450"]));
        
    } catch (error) {
        console.error("❌ Error:", error.message);
    }
}

testCircuit();
