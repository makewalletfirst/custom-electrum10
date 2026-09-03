# BitEver Electrum Wallet (BEC)

> The official desktop and mobile light wallet client tailored specifically for the **BitEver (BEC)** L1 educational network.

---

## 🌟 What is BitEver?

**BitEver (BEC)** is a Bitcoin L1 hard fork designed for **blockchain education and hands-on learning**. The network launched independently from Bitcoin block **#478,559** (forking at the same point as Bitcoin Cash, #478,558), maintaining the exact consensus logic, halving policy, and 21 Million issuance limit as mainnet Bitcoin, with only network magic bytes customized.

---

## 🔍 Features & Ecosystem Role

**BitEver Electrum** is a highly secure, fast, and feature-rich light client. Unlike full nodes, it does not require downloading or verifying the entire block ledger locally.

- **Instant Synchronization**: Connects to the BitEver peer indexer (`electrs`) servers to query transaction histories and address balances instantly.
- **Satoshi-Era Recovery**: Supports importing, scanning, and resolving historical raw P2PK (Pay-to-PublicKey) keys and legacy addresses for early-generation coins.
- **Private Key Custody**: Private keys are encrypted locally and never leave your machine.
- **Advanced Transactions**: Supports multi-signature configurations, cold storage signing, transaction fee adjustments, and message signing.
- **Branding Customization**: Features specialized brand icons, logos, server discovery configurations, and the official **BEC** ticker integration.

---

## 🛠️ Technology Stack

- **Core**: Python 3.9+
- **GUI Engine**: PyQt5 (for Desktop UI), QML (for Mobile UI)
- **Compilation Engine**: Wine & PyInstaller inside Docker (for compiling Windows binaries)
- **Cryptography**: ECDSA (Secp256k1 curves), SHA256, PBKDF2

---

## 🚀 Installation & Build Instructions

### Method 1: Local Run (Python)

To run the wallet directly from source on Linux/macOS:

1. **Install Dependencies**:
   Ensure you have Python 3.9+ installed with virtualenv tools:
   ```bash
   sudo apt update
   sudo apt install -y python3-pip python3-pyqt5 python3-cryptography libsecp256k1-dev
   ```
2. **Setup Virtual Environment**:
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   ```
3. **Install Requirements**:
   ```bash
   pip install -r requirements.txt
   pip install .
   ```
4. **Execute**:
   ```bash
   ./run_electrum
   ```

---

### Method 2: Compiling Standalone Windows Binaries (EXE)

To package the client into a single `.exe` file without needing an active Windows environment, this repository utilizes **Docker BuildKit with Wine**:

1. **Prerequisites**: Ensure Docker is installed and running:
   ```bash
   sudo systemctl start docker
   ```
2. **Execute Build Script**:
   ```bash
   chmod +x contrib/build-wine/build.sh
   ./contrib/build-wine/build.sh 2>&1 | tee build.log
   ```
   *Note: This downloads Wine, installs Python, installs PyQt5 within the Wine sandbox, compiles the sources via PyInstaller, and saves the final output to `dist/` directory.*

---

### Method 3: Compiling Standalone Android APK

To build the mobile wallet client for Android:

```bash
chmod +x contrib/android/build.sh
./contrib/android/build.sh qml arm64-v8a debug
```
This leverages Android NDK/SDK tools to build and output a debug `.apk` tailored for ARM64 devices under the Android build outputs.

---

## ⚠️ Important Considerations / Caveats

- **Network Boundary Warning**: This wallet is configured specifically for the **BitEver L1 network (BEC)**. It connects only to BitEver electrs servers. **Never attempt to send mainnet Bitcoins (BTC) to this wallet**, or they could be permanently lost.
- **Wallet Recovery Security**: Keep your 12-word seed phrase written down offline in a secure place. If lost, there is no centralized service to recover it.
- **Port requirements**: Make sure outgoing TCP port `50001` or `50002` (SSL) is allowed on your network firewall to let the wallet communicate with external indexing seed nodes.

---

## 🤝 Contribution & License

Derived from the original open-source [spesmilo/electrum](https://github.com/spesmilo/electrum). Customized features and source alterations are licensed under the MIT License.
