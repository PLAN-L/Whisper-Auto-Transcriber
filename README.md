# 🎙️ Whisper Auto Transcriber

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.9+](https://img.shields.io/badge/python-3.9+-blue.svg)](https://www.python.org/downloads/)
[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey.svg)]()
[![Powered by faster-whisper](https://img.shields.io/badge/engine-faster--whisper-orange.svg)](https://github.com/SYSTRAN/faster-whisper)

A lightweight, zero-configuration local voice transcription and subtitle generator powered by **faster-whisper** (CTranslate2) & **OpenAI Whisper**. Runs 100% locally on your computer with complete privacy, unlimited length, and automated hardware optimization.

---

## ✨ Features

- **🚀 1-Click Launchers**:
  - **Windows**: Double-click `start.bat`
  - **macOS**: Double-click `start_mac.command` (Finder native)
  - **Linux / Unix**: Run `./start_linux.sh` or `./start.sh`
- **🧠 Intelligent Hardware Auto-Tuning**: Automatically detects CPU cores, RAM, and GPU VRAM (NVIDIA CUDA & Apple Silicon Unified Memory) to recommend and configure the optimal model and device.
- **⚡ Latest High-Efficiency Models**:
  - Standard options: `tiny`, `base`, `small`, `medium`, `large-v3-turbo`, `large-v3`.
  - Built-in `dev` mode to test official OpenAI PyTorch Whisper models.
- **📝 Multi-Format Output**: Choose between synchronized subtitles (`.srt`), clean timestamped text (`.txt`), or both.
- **🌐 4-Language Setup Wizard**: Available in English, 日本語 (Japanese), 中文 (Chinese), and 한국어 (Korean).
- **🛡️ 100% Offline & Private**: Audio files never leave your machine. No API keys required.

---

## 🚀 Quick Start

### 1. Requirements
- Python 3.9 or higher installed and added to system PATH.
  - Windows: [python.org](https://www.python.org/) (check **"Add Python to PATH"**)
  - macOS: `brew install python`
  - Ubuntu/Debian: `sudo apt install python3 python3-venv`

### 2. How to Run

1. **Clone or Download this repository**:
   ```bash
   git clone https://github.com/PLAN-L/Whisper-Auto-Transcriber.git
   cd Whisper-Auto-Transcriber
   ```

2. **Run the launcher for your OS**:
   - **Windows**: Double-click `start.bat`.
   - **macOS**: Double-click `start_mac.command` *(or run `./start.sh` in Terminal)*.
   - **Linux**: Run `./start_linux.sh` in Terminal.

3. **Follow the Setup Wizard**:
   - Choose your preferred language.
   - The wizard detects your hardware and highlights **`(Recommended)`** options.
   - Press **Enter** to accept recommendations and let it automatically install dependencies and download the model.

4. **Transcribe**:
   - Put your audio/video files (`.mp3`, `.m4a`, `.wav`, `.mp4`, `.flac`, etc.) into the created `recordings/` folder.
   - Run the launcher again! Your transcripts (`.txt`) and subtitles (`.srt`) will be generated automatically.

---

## 💻 Hardware-Based Model Recommendations

| Environment | Detected Specs | Recommended Device | Recommended Model | Best Suited For |
| :--- | :--- | :--- | :--- | :--- |
| **NVIDIA GPU** | VRAM **11 GB+** | `GPU Fast Mode` | **`[6] Large-v3`** | RTX 4090, 4080, 4070, 3060 12GB |
| **NVIDIA GPU** | VRAM **6 GB ~ 10 GB** | `GPU Fast Mode` | **`[5] Turbo`** | RTX 5050 (8GB), RTX 4060, RTX 3060 |
| **NVIDIA GPU** | VRAM **3.5 GB ~ 5 GB** | `GPU Fast Mode` | **`[4] Medium`** | GTX 1650 (4GB), RTX 3050 (4GB) |
| **NVIDIA GPU** | VRAM **2 GB ~ 3 GB** | `GPU Fast Mode` | **`[3] Small`** | GTX 1060 (3GB), MX450 |
| **Apple Silicon** | RAM **16 GB+** | `CPU Mode` | **`[5] Turbo`** | Mac M1/M2/M3/M4 (16GB+ Unified Memory) |
| **Apple Silicon** | RAM **8 GB** | `CPU Mode` | **`[3] Small`** | Mac M1/M2/M3/M4 (8GB Unified Memory) |
| **CPU Only** | Cores 6+ & RAM 8 GB+ | `CPU Mode` | **`[3] Small`** | Modern Intel Core i5/i7, AMD Ryzen |
| **CPU Only** | Cores 4 & RAM 6 GB+ | `CPU Mode` | **`[2] Base`** | Standard office quad-core laptops |
| **CPU Only** | Cores 2 or RAM < 6 GB | `CPU Mode` | **`[1] Tiny`** | Low-spec dual-core PCs |
