#!/usr/bin/env python3
"""
BB84 Quantum Key Distribution - Enhanced Step-by-step Simulation

Course: Advanced Information System Security -- Politecnico di Torino

Features:
 - Correct separation of Alice's 'notebook' vs. physical photon state.
 - ANSI Color output for better readability.
 - Interactive configuration.
 - Detailed QBER and Sifting analysis.
"""

import random
import sys

# ---------------------------------------------------------------------------
# Colors for Terminal Output
# ---------------------------------------------------------------------------
class Colors:
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    GREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    RESET = '\033[0m'
    BOLD = '\033[1m'

# ---------------------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------------------

def random_bits(n):
    return [random.randint(0, 1) for _ in range(n)]

def random_bases(n):
    # "+" = rectilinear (0/90), "x" = diagonal (45/-45)
    return [random.choice(["+", "x"]) for _ in range(n)]

def basis_symbol(basis):
    return "+" if basis == "+" else "×"

def measure_photon(bit_val, prep_basis, meas_basis):
    """
    Simulates the measurement of a photon.
    1. If the measurement basis matches the preparation basis, the bit is preserved.
    2. If bases mismatch, the result is random (50/50).
    """
    if prep_basis == meas_basis:
        return bit_val
    else:
        return random.randint(0, 1)

def get_user_input():
    print(f"{Colors.HEADER}--- Simulation Configuration ---{Colors.RESET}")
    try:
        n_input = input(f"Number of photons [default 15]: ")
        N = int(n_input) if n_input else 15
        
        eve_input = input("Enable Eve (y/n) [default y]: ").lower()
        EVE_ENABLED = False if eve_input == 'n' else True
        
        eve_prob = 0.5
        if EVE_ENABLED:
            prob_input = input("Eve intercept probability (0.0 - 1.0) [default 0.5]: ")
            eve_prob = float(prob_input) if prob_input else 0.5

        decoy_input = input("Enable Decoy States (y/n) [default y]: ").lower()
        DECOY_ENABLED = False if decoy_input == 'n' else True
        
        return N, EVE_ENABLED, eve_prob, DECOY_ENABLED
    except ValueError:
        print(f"{Colors.FAIL}Invalid input. Using defaults.{Colors.RESET}")
        return 15, True, 0.5, True

# ---------------------------------------------------------------------------
# Main BB84 simulation
# ---------------------------------------------------------------------------

def bb84_simulation():
    print("====================================================")
    print(f"      {Colors.BOLD}BB84 QKD -- Enhanced Simulation{Colors.RESET}         ")
    print("====================================================\n")

    # 0. Configuration
    N, EVE_ENABLED, EVE_PROB, DECOY_ENABLED = get_user_input()

    print(f"\n{Colors.BLUE}Simulation Parameters:{Colors.RESET}")
    print(f"Photons: {N} | Eve: {EVE_ENABLED} ({EVE_PROB}) | Decoy: {DECOY_ENABLED}\n")

    # -------------------------------------------------------
    # 1. Alice prepares photons
    # -------------------------------------------------------
    alice_bits = random_bits(N)
    alice_bases = random_bases(N)
    
    # Track the PHYSICAL state of the photon as it travels
    # Initially, it matches Alice's preparation
    photon_vals = list(alice_bits)
    photon_bases = list(alice_bases)

    # Decoy State marking
    pulse_type = []
    if DECOY_ENABLED:
        for _ in range(N):
            # 30% Decoy, 70% Signal
            pulse_type.append("D" if random.random() < 0.3 else "S")
    else:
        pulse_type = ["S"] * N

    print(f"{Colors.HEADER}Step 1: Alice prepares photons{Colors.RESET}")
    print("Idx | Type | Bit | Basis")
    print("----+------+-----+------")
    for i in range(N):
        print(f"{i:3d} |  {pulse_type[i]}   |  {alice_bits[i]}  |   {basis_symbol(alice_bases[i])}")
    print()

    # -------------------------------------------------------
    # 2. Eve intercepts (Man-In-The-Middle)
    # -------------------------------------------------------
    if EVE_ENABLED:
        print(f"{Colors.HEADER}Step 2: Eve intercepts (Intercept-Resend){Colors.RESET}")
        intercept_count = 0
        
        for i in range(N):
            if random.random() < EVE_PROB:
                intercept_count += 1
                eve_basis = random.choice(["+", "x"])
                
                # Eve measures the photon coming from Alice
                # NOTE: The photon might have collapsed to a new value if bases mismatch
                eve_result = measure_photon(photon_vals[i], photon_bases[i], eve_basis)
                
                # Eve prepares a NEW photon based on her result to send to Bob
                # The physical photon now has Eve's bit and Eve's basis
                photon_vals[i] = eve_result
                photon_bases[i] = eve_basis
                
                print(f"Photon {i:2d}: {Colors.FAIL}Intercepted{Colors.RESET}. Eve uses {basis_symbol(eve_basis)}, gets {eve_result}. Resends state.")
            else:
                # Photon passes through untouched
                pass
        print(f"Total intercepted: {intercept_count}/{N}\n")
    else:
        print("Step 2: Channel is secure (No Eve).\n")

    # -------------------------------------------------------
    # 3. Bob measures
    # -------------------------------------------------------
    bob_bases = random_bases(N)
    bob_results = []

    print(f"{Colors.HEADER}Step 3: Bob receives and measures{Colors.RESET}")
    print("Idx | Bob Basis | Measurement")
    print("----+-----------+------------")
    for i in range(N):
        # Bob measures the incoming photon (which might have been touched by Eve)
        res = measure_photon(photon_vals[i], photon_bases[i], bob_bases[i])
        bob_results.append(res)
        print(f"{i:3d} |     {basis_symbol(bob_bases[i])}     |      {res}")
    print()

    # -------------------------------------------------------
    # 4. Sifting
    # -------------------------------------------------------
    print(f"{Colors.HEADER}Step 4: Sifting (Alice & Bob compare bases){Colors.RESET}")
    
    sifted_alice_key = []
    sifted_bob_key = []
    sifted_indices = []

    print("Idx | A Basis | B Basis | Match? | A Bit | B Bit | Result")
    print("----+---------+---------+--------+-------+-------+-------")
    
    for i in range(N):
        bases_match = (alice_bases[i] == bob_bases[i])
        match_str = f"{Colors.GREEN}YES{Colors.RESET}" if bases_match else " no"
        
        # Check if bits match (for display purposes only right now)
        bits_match = (alice_bits[i] == bob_results[i])
        
        result_str = ""
        if bases_match:
            if bits_match:
                result_str = f"{Colors.GREEN}SECURE{Colors.RESET}"
            else:
                result_str = f"{Colors.FAIL}ERROR{Colors.RESET}" # This indicates noise or Eve
            
            # Keep bits for the raw key
            sifted_alice_key.append(alice_bits[i])
            sifted_bob_key.append(bob_results[i])
            sifted_indices.append(i)
        
        print(f"{i:3d} |    {basis_symbol(alice_bases[i])}    |    {basis_symbol(bob_bases[i])}    |  {match_str}   |   {alice_bits[i]}   |   {bob_results[i]}   | {result_str}")

    print(f"\nRaw Key Length: {len(sifted_alice_key)} bits")
    print()

    # -------------------------------------------------------
    # 5. QBER Analysis
    # -------------------------------------------------------
    print(f"{Colors.HEADER}Step 5: QBER Analysis (Quantum Bit Error Rate){Colors.RESET}")
    
    if len(sifted_alice_key) == 0:
        print(f"{Colors.WARNING}No bits survived sifting. Increase N.{Colors.RESET}")
        return

    errors = 0
    decoy_errors = 0
    signal_errors = 0
    
    decoy_count = 0
    signal_count = 0

    for idx, raw_idx in enumerate(sifted_indices):
        is_error = (sifted_alice_key[idx] != sifted_bob_key[idx])
        p_type = pulse_type[raw_idx]
        
        if is_error:
            errors += 1
            if p_type == "D": decoy_errors += 1
            else: signal_errors += 1
        
        if p_type == "D": decoy_count += 1
        else: signal_count += 1

    total_sifted = len(sifted_alice_key)
    qber = errors / total_sifted
    
    print(f"Total Sifted Bits: {total_sifted}")
    print(f"Total Errors:      {errors}")
    print(f"Overall QBER:      {qber*100:.2f}%")
    
    # -------------------------------------------------------
    # 6. Decoy Analysis
    # -------------------------------------------------------
    if DECOY_ENABLED:
        print(f"\n{Colors.HEADER}Step 6: Decoy State Check{Colors.RESET}")
        print(f"Signal Pulses: {signal_count} (Errors: {signal_errors})")
        print(f"Decoy Pulses:  {decoy_count} (Errors: {decoy_errors})")
        
        # In a real PNS attack, Decoy stats would differ drastically from Signal stats.
        # In this Intercept-Resend simulation, Eve attacks everything equally,
        # so QBER should be similar for both.
    
    # -------------------------------------------------------
    # 7. Final Verdict
    # -------------------------------------------------------
    print(f"\n{Colors.HEADER}Step 7: Final Verdict{Colors.RESET}")
    print("---------------------")
    
    # Theoretical max QBER for BB84 security is ~11%
    threshold = 0.11
    
    if qber > threshold:
        print(f"{Colors.FAIL}[ALARM] QBER is {qber*100:.2f}% (Threshold 11%).{Colors.RESET}")
        print(f"{Colors.FAIL}High probability of eavesdropping! Communication Aborted.{Colors.RESET}")
    else:
        print(f"{Colors.GREEN}[SUCCESS] QBER is {qber*100:.2f}%. Key exchange successful.{Colors.RESET}")
        
        # Show the final shared key (in reality, this would be Privacy Amplified)
        final_key_str = "".join(str(b) for b in sifted_bob_key)
        print(f"Shared Key: {final_key_str}")

# ---------------------------------------------------------------------------
# Run
# ---------------------------------------------------------------------------
if __name__ == "__main__":
    try:
        bb84_simulation()
    except KeyboardInterrupt:
        print("\nSimulation exited.")
