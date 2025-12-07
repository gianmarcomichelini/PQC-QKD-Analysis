# Quantum Key Distribution (QKD) Simulation

This module is a didactic Python simulation of the **BB84 Protocol**, the first quantum cryptography protocol invented by Charles Bennett and Gilles Brassard in 1984. It demonstrates how two parties (Alice and Bob) can agree on a shared secret key and detect the presence of an eavesdropper (Eve) by measuring the **Quantum Bit Error Rate (QBER)**.

## What is BB84?

BB84 is a quantum key distribution protocol that uses the fundamental principles of quantum mechanics to secure communication:

- **Quantum Superposition**: Photons can exist in multiple states simultaneously
- **Heisenberg Uncertainty Principle**: Measuring a quantum state disturbs it
- **No-Cloning Theorem**: Quantum states cannot be perfectly copied

These properties ensure that any eavesdropping attempt will introduce detectable errors in the transmitted key.

## Features

### Core Functionality

- **Step-by-Step Simulation**: Visualizes the journey of individual photons through the protocol
- **Photon Encoding**: Demonstrates polarization states in rectilinear (+) and diagonal (×) bases
- **Basis Reconciliation**: Shows the public basis comparison (sifting) process
- **Key Generation**: Produces a final shared secret key from successfully matched bits

### Security Features

- **Eavesdropping Detection (Eve)**: Simulates an "Intercept-Resend" attack where Eve collapses the wavefunction, introducing detectable errors
- **QBER Analysis**: Calculates the Quantum Bit Error Rate to determine channel security
- **Decoy States**: Optional simulation of decoy photons to detect Photon Number Splitting (PNS) attacks
- **Security Threshold**: Uses the industry-standard 11% QBER threshold for key acceptance

### Interactive Controls

- **Configurable Parameters**: Adjust photon count, attack probability, and security features
- **Real-time Statistics**: View error rates, success rates, and security verdicts
- **Educational Output**: Color-coded tables showing each protocol step

## Usage

### Prerequisites

Ensure you have Python 3.6 or higher installed:

```bash
python3 --version
```

### 1. Run the Simulation

```bash
python3 qkd_bb84_enhanced.py
```

### 2. Configuration Parameters

The script will prompt for the following parameters (press Enter to use defaults):

| Parameter | Description | Default | Recommended Values |
|-----------|-------------|---------|-------------------|
| **Number of Photons** | How many qubits to transmit | 100 | 15 (quick test), 100 (standard), 1000+ (statistical accuracy) |
| **Enable Eve** | Simulate eavesdropping attack | No | Yes (to see security in action) |
| **Eve Probability** | Likelihood Eve intercepts each photon | 0.5 | 0.3-0.7 (realistic attack scenarios) |
| **Enable Decoy States** | Activate PNS attack detection | No | Yes (advanced security) |

### 3. Example Session

```
=== BB84 Quantum Key Distribution Simulator ===

Enter number of photons to send (default 100): 50
Enable eavesdropping by Eve? (y/n, default n): y
Eve interception probability (0.0-1.0, default 0.5): 0.4
Enable decoy states? (y/n, default n): n

Starting BB84 Protocol...

[Step 1: Alice Prepares Photons]
[Step 2: Eve Intercepts]
[Step 3: Bob Measures]
[Step 4: Basis Sifting]
[Step 5: QBER Calculation]

=== FINAL VERDICT ===
QBER: 8.5%
Status: SECURE ✓
Final Key Length: 23 bits
```

## Understanding the Output

The simulation outputs 7 distinct phases. Here's how to interpret each step:

### Step 1: Alice Prepares Photons

Alice generates the quantum states to send to Bob.

| Column | Description |
|--------|-------------|
| **Bit** | Random bit value (0 or 1) that Alice wants to send |
| **Basis** | Encoding basis chosen randomly by Alice |
| **Polarization** | Actual photon polarization angle |

**Basis Encoding:**
- **+ (Rectilinear)**: 0° for bit 0, 90° for bit 1
- **× (Diagonal)**: 45° for bit 0, 135° for bit 1

**Example:**
```
Bit=1, Basis=+, Polarization=90°
→ Alice encodes bit '1' as vertical polarization
```

### Step 2: Eve Intercepts (If Enabled)

Eve attempts to measure photons before they reach Bob.

| Column | Description |
|--------|-------------|
| **Eve's Basis** | The basis Eve randomly chooses to measure |
| **Measured Bit** | The bit value Eve obtains |
| **State Changed** | Whether Eve's measurement altered the photon state |

**Key Insight:**
- If Eve uses the **wrong basis** (probability 50%), she collapses the quantum state into a new state
- This disturbance will cause Bob to potentially measure a different value than Alice sent
- This is how eavesdropping becomes detectable!

**Example:**
```
Alice sent: Bit=0, Basis=+, Polarization=0°
Eve measures: Basis=×
→ Eve gets random result (50/50 chance)
→ Photon is now in a new state (45° or 135°)
→ Bob may receive wrong bit even if he uses correct basis!
```

### Step 3: Bob Measures

Bob receives the photon and measures it in a randomly chosen basis.

| Column | Description |
|--------|-------------|
| **Bob's Basis** | The basis Bob randomly chooses |
| **Measured Bit** | The bit value Bob obtains |

**Measurement Rules:**
- **Same basis as Alice**: Bob gets the correct bit (unless Eve interfered)
- **Different basis**: Bob gets random result (50/50)

### Step 4: Basis Sifting

Alice and Bob publicly compare their **basis choices** (not the bit values) over a classical channel.

| Column | Description |
|--------|-------------|
| **Basis Match** | Whether Alice and Bob used the same basis |
| **Keep Bit?** | YES = bit is kept for the key, no = bit is discarded |
| **Outcome** | SECURE (bits match) or ERROR (bits differ despite same basis) |

**Critical Understanding:**
- **YES + SECURE**: Normal operation, no eavesdropping detected
- **YES + ERROR**: Bases matched but bits differ → Eve caused an error!
- **no**: Bases didn't match, bit is discarded (expected in 50% of cases)

**Example:**
```
Alice: Bit=1, Basis=+
Bob:   Bit=1, Basis=+
→ Match: YES, Outcome: SECURE ✓

Alice: Bit=0, Basis=+
Bob:   Bit=1, Basis=+
→ Match: YES, Outcome: ERROR ⚠ (Eve likely present!)

Alice: Bit=1, Basis=+
Bob:   Bit=0, Basis=×
→ Match: no (discarded, this is normal)
```

### Step 5: QBER Calculation and Security Verdict

The **Quantum Bit Error Rate** determines if the channel is secure.

**Formula:**

```
QBER = (Number of Errors) / (Total Sifted Bits) × 100%
```

**Interpretation:**

| QBER Range | Verdict | Meaning |
|------------|---------|---------|
| **0% - 11%** | SECURE | Channel is safe, proceed with key |
| **> 11%** | UNSAFE | Eavesdropping detected, discard key |

**Why 11%?**
- In perfect conditions: QBER ≈ 0%
- With noise/imperfections: QBER ≈ 1-3%
- With 50% eavesdropping: QBER ≈ 25%
- 11% threshold provides security margin while allowing for real-world noise

### Step 6: Error Correction (Simulated)

In real implementations, Alice and Bob would perform:
- **Information Reconciliation**: Correct remaining errors using error-correcting codes
- **Privacy Amplification**: Shorten the key to remove any information Eve might have gained

The simulation acknowledges these steps but doesn't implement them in detail.

### Step 7: Final Shared Key

The resulting secret key that Alice and Bob now share.

**Key Statistics:**
- **Original Photons**: Number sent by Alice
- **After Sifting**: ~50% remain (due to random basis choices)
- **After QBER Check**: Bits with errors are identified
- **Final Key**: Secure shared secret ready for encryption

## Advanced Features

### Decoy States

When enabled, decoy states help detect **Photon Number Splitting (PNS)** attacks:

**The Problem:**
- Real quantum systems sometimes emit multiple photons instead of one
- Eve can split off extra photons without disturbing the signal

**The Solution:**
- Alice randomly varies photon intensity (signal vs decoy states)
- Statistical analysis of decoy states reveals if photons are being split
- This simulation marks decoy photons with a special flag

### Attack Scenarios to Try

**Scenario 1: No Attack (Baseline)**
```
Enable Eve: n
Expected QBER: 0-2% (just measurement noise)
```

**Scenario 2: Moderate Attack**
```
Enable Eve: y
Eve Probability: 0.3
Expected QBER: 7-8%
Verdict: Likely SECURE (below threshold)
```

**Scenario 3: Heavy Attack**
```
Enable Eve: y
Eve Probability: 0.7
Expected QBER: 15-20%
Verdict: UNSAFE (eavesdropper detected!)
```

**Scenario 4: Complete Interception**
```
Enable Eve: y
Eve Probability: 1.0
Expected QBER: ~25%
Verdict: UNSAFE (maximum detectable interference)
```