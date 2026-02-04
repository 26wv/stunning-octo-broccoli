<p align="center">
  <img src="https://img.shields.io/badge/Assembly-x86__64-blue?style=flat-square&logo=assemblyscript" alt="Assembly">
  <img src="https://img.shields.io/badge/Quantum-Computing-purple?style=flat-square" alt="Quantum">
  <img src="https://img.shields.io/badge/Status-Working-green?style=flat-square" alt="Status">
</p>

<h1 align="center">Quantum Computing Simulation</h1>
<p align="center"><em>A single-qubit quantum computer emulator written in pure x86-64 Assembly</em></p>

---

## Features

- **Quantum State Vector** simulation with complex amplitudes
- **Hadamard Gate** — creates quantum superposition
- **Pauli-X Gate** — quantum NOT operation
- **True Quantum Measurement** — probabilistic collapse using hardware RNG
- **Bloch Sphere Visualization** — real-time coordinate calculation
- **ANSI Terminal Interface** — color-coded state display

## Quick Start

### Build

**Using FASM:**
```bash
fasm quantum.asm
chmod +x quantum
./quantum
