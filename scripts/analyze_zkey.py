#!/usr/bin/env python3
"""
Analyseur de fichier .zkey pour comprendre sa structure
"""

import struct
import sys
import os

def read_uint32(f):
    """Lire un entier 32 bits little-endian"""
    return struct.unpack('<I', f.read(4))[0]

def read_uint64(f):
    """Lire un entier 64 bits little-endian"""
    return struct.unpack('<Q', f.read(8))[0]

def read_bytes(f, n):
    """Lire n octets"""
    return f.read(n)

def analyze_zkey(filename):
    """Analyser un fichier .zkey"""
    
    print(f"🔍 Analyse du fichier: {filename}")
    print(f"📊 Taille: {os.path.getsize(filename)} octets")
    print("=" * 50)
    
    with open(filename, 'rb') as f:
        # En-tête
        signature = f.read(4)
        print(f"🏷️  Signature: {signature} ({signature.decode('ascii', errors='ignore')})")
        
        version = read_uint32(f)
        print(f"📝 Version: {version}")
        
        # Nombre de sections
        num_sections = read_uint32(f)
        print(f"📚 Nombre de sections: {num_sections}")
        
        print("\n📋 Sections:")
        
        for i in range(num_sections):
            section_type = read_uint32(f)
            section_size = read_uint64(f)
            
            print(f"  Section {i+1}:")
            print(f"    Type: {section_type}")
            print(f"    Taille: {section_size} octets")
            
            # Lire les premiers octets de la section pour analyse
            current_pos = f.tell()
            preview = f.read(min(32, section_size))
            f.seek(current_pos + section_size)  # Aller à la prochaine section
            
            print(f"    Aperçu: {preview.hex()[:64]}...")
            
            # Interpréter certains types de sections
            if section_type == 1:
                print("    📐 Probablement: Paramètres du circuit")
            elif section_type == 2:
                print("    🔑 Probablement: Clés de preuve")
            elif section_type == 4:
                print("    🧮 Probablement: Coefficients")
            
            print()

if __name__ == "__main__":
    filename = "assets/multiplier2_final.zkey"
    
    if not os.path.exists(filename):
        print(f"❌ Fichier introuvable: {filename}")
        sys.exit(1)
    
    analyze_zkey(filename)
