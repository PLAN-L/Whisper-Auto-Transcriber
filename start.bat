@echo off
chcp 65001 > nul
setlocal
cd /d "%~dp0"

set "HF_HUB_DISABLE_SYMLINKS_WARNING=1"
set "HF_HUB_VERBOSITY=error"
set "VENV_PY=%~dp0venv\Scripts\python.exe"

if "%~1"=="--setup" goto SETUP_MODE
if "%~1"=="--dev" goto SETUP_MODE
if "%~1"=="--advanced" goto SETUP_MODE
if "%~1"=="--expert" goto SETUP_MODE
if exist "%~dp0transcribe.py" goto RUN_MODE

:SETUP_MODE
where python >nul 2>nul
if errorlevel 1 goto NO_PYTHON

findstr /B /C:"###PY###" "%~f0" > "%~dp0_raw_wiz.txt"
powershell -NoProfile -Command "(Get-Content '%~dp0_raw_wiz.txt') -replace '^###PY### ?','' | Set-Content '%~dp0_wizard.py' -Encoding UTF8"
if exist "%~dp0_raw_wiz.txt" del /q "%~dp0_raw_wiz.txt"

python "%~dp0_wizard.py" %*
if exist "%~dp0_wizard.py" del /q "%~dp0_wizard.py"

echo.
pause
exit /b 0

:RUN_MODE
if not exist "%~dp0.use_system_py" if exist "%VENV_PY%" goto RUN_WITH_VENV
python "%~dp0transcribe.py" %*
echo.
pause
exit /b 0

:RUN_WITH_VENV
"%VENV_PY%" "%~dp0transcribe.py" %*
echo.
pause
exit /b 0

:NO_PYTHON
echo [ERROR] Python is not found in system PATH.
echo Please install Python 3.9+ and check 'Add Python to PATH'.
echo.
pause
exit /b 1

###PY### import os
###PY### import sys
###PY### import subprocess
###PY### import platform
###PY### import shutil
###PY### from pathlib import Path
###PY###
###PY### os.environ["HF_HUB_DISABLE_SYMLINKS_WARNING"] = "1"
###PY### os.environ["HF_HUB_VERBOSITY"] = "error"
###PY### import warnings
###PY### warnings.filterwarnings("ignore", message=".*unauthenticated requests.*")
###PY###
###PY### if hasattr(sys.stdout, "reconfigure"):
###PY###     try:
###PY###         sys.stdout.reconfigure(encoding="utf-8")
###PY###     except Exception:
###PY###         pass
###PY### if hasattr(sys.stdin, "reconfigure"):
###PY###     try:
###PY###         sys.stdin.reconfigure(encoding="utf-8")
###PY###     except Exception:
###PY###         pass
###PY###
###PY### BASE_DIR = Path(__file__).resolve().parent
###PY### RECORDINGS_DIR = BASE_DIR / "recordings"
###PY### TRANSCRIBE_PATH = BASE_DIR / "transcribe.py"
###PY### VENV_DIR = BASE_DIR / "venv"
###PY### VENV_PY = VENV_DIR / ("Scripts/python.exe" if platform.system() == "Windows" else "bin/python")
###PY### FLAG_SYSTEM_PY = BASE_DIR / ".use_system_py"
###PY###
###PY### UI_LANG_MAP = {"1": "en", "2": "ja", "3": "zh", "4": "ko"}
###PY###
###PY### I18N = {
###PY###     "en": {
###PY###         "ui_name": "English",
###PY###         "wiz_title": "[Whisper Auto Transcriber - Initial Setup Wizard]",
###PY###         "env_step_title": "[Environment] Select Python installation environment:",
###PY###         "env_opt_1": "Create and use Virtual Environment (venv) (Recommended)",
###PY###         "env_opt_2": "Use System Global Python directly (No venv)",
###PY###         "env_prompt": "Select environment [1~2]",
###PY###         "venv_creating": "  -> Creating Python virtual environment (venv)... (Please wait 10~30 seconds)",
###PY###         "venv_fail": "[Error] Failed to create venv. Proceeding with System Global Python.",
###PY###         "py_env_label": "Selected Python Environment",
###PY###         "venv_str": "Virtual Environment (venv)",
###PY###         "sys_str": "System Global Python",
###PY###         "hw_title": "[System Hardware Detection & Recommendations]",
###PY###         "hw_cpu": "* CPU Cores   : {cores} cores",
###PY###         "hw_ram": "* System RAM  : {ram} GB",
###PY###         "hw_gpu": "* GPU / VRAM  : {gpu}",
###PY###         "hw_no_gpu": "No dedicated NVIDIA GPU detected (CPU Mode)",
###PY###         "hw_rec": "  -> Recommended: Model [{m_key}] | Device [{d_key}]",
###PY###         "tag_rec": "(Recommended)",
###PY###         "default_word": "Default",
###PY###         "invalid_input": "[!] Invalid input. Please choose from {opts}.",
###PY###         "step1_title": "[Step 1] Select speech recognition model to download:",
###PY###         "step1_prompt": "Select model [1~6] (or 'dev' for PyTorch engines)",
###PY###         "dev_mode_banner": "[Developer Mode Enabled - PyTorch engines unlocked]",
###PY###         "dev_section_title": "--- Developer Mode / PyTorch Official Engines ---",
###PY###         "step1_dev_prompt": "Select model [1~12]",
###PY###         "models": {
###PY###             "1": "Tiny (75MB / Ultra-low spec, Fast test)",
###PY###             "2": "Base (145MB / Standard CPU)",
###PY###             "3": "Small (480MB / Balanced & Fast)",
###PY###             "4": "Medium (1.5GB / High accuracy)",
###PY###             "5": "Turbo (1.6GB / Fast & High quality)",
###PY###             "6": "Large-v3 (3.1GB / Maximum quality)",
###PY###         },
###PY###         "dev_models": {
###PY###             "7": "Tiny (75MB / OpenAI Whisper - PyTorch)",
###PY###             "8": "Base (145MB / OpenAI Whisper - PyTorch)",
###PY###             "9": "Small (480MB / OpenAI Whisper - PyTorch)",
###PY###             "10": "Medium (1.5GB / OpenAI Whisper - PyTorch)",
###PY###             "11": "Turbo (1.6GB / OpenAI Whisper - PyTorch)",
###PY###             "12": "Large-v3 (3.1GB / OpenAI Whisper - PyTorch)",
###PY###         },
###PY###         "step2_title": "[Step 2] Select compute device (CPU / GPU):",
###PY###         "step2_prompt": "Select device [1~2]",
###PY###         "devices": {
###PY###             "1": "CPU Mode (Low-spec PC / Standard Laptop / Integrated Graphics)",
###PY###             "2": "GPU Fast Mode (NVIDIA Graphics Card with CUDA acceleration)",
###PY###         },
###PY###         "step3_title": "[Step 3] Select default audio language for transcription:",
###PY###         "step3_prompt": "Select language [1~5]",
###PY###         "target_langs": {
###PY###             "1": ("auto", "Multilingual Auto-detect (en/ja/zh/ko/etc.) - Default"),
###PY###             "2": ("en", "English only (en)"),
###PY###             "3": ("ja", "Japanese only (ja)"),
###PY###             "4": ("zh", "Chinese only (zh)"),
###PY###             "5": ("ko", "Korean only (ko)"),
###PY###         },
###PY###         "default_target_lang": "1",
###PY###         "step4_title": "[Step 4] Select output file format:",
###PY###         "step4_prompt": "Select format [1~3]",
###PY###         "formats": {
###PY###             "1": ("both", "Both Text & Subtitles (.txt + .srt) (Recommended)"),
###PY###             "2": ("txt", "Text only (.txt)"),
###PY###             "3": ("srt", "Subtitles only (.srt)"),
###PY###         },
###PY###         "sum_ui": "UI Language  ",
###PY###         "sum_env": "Python Env   ",
###PY###         "sum_model": "Model        ",
###PY###         "sum_dev": "Device       ",
###PY###         "sum_lang": "Audio Lang   ",
###PY###         "sum_fmt": "Output Format",
###PY###         "prog_1": "[1/3] Installing required libraries...",
###PY###         "prog_2": "[2/3] Generating recordings folder, transcribe.py, {guide}...",
###PY###         "prog_3": "[3/3] Verifying '{model}' model...",
###PY###         "model_check_note": "  -> [Note] Model initial check message: {e}",
###PY###         "done_1": "Setup complete! 'recordings' folder, 'transcribe.py', and '{guide}' have been created.",
###PY###         "done_2": "Now place your audio files in the 'recordings' folder and run '{run_file}'!",
###PY###         "guide_filename": "user_guide.txt",
###PY###         "log_filename": "transcription_log.txt",
###PY###         "out_suffix": "_transcript",
###PY###         "guide_lines": [
###PY###             "====================================================================",
###PY###             "             [Whisper Auto Transcriber - User Guide]",
###PY###             "====================================================================",
###PY###             "",
###PY###             "* UI Language  : {ui_name}",
###PY###             "* Python Env   : {env_str}",
###PY###             "* Model        : {m_desc}",
###PY###             "* Device       : {d_desc}",
###PY###             "* Audio Lang   : {l_desc}",
###PY###             "* Output Format: {f_desc}",
###PY###             "",
###PY###             "[How to Use]",
###PY###             "1. Place audio files (.mp3, .m4a, .wav, etc.) into the 'recordings' folder.",
###PY###             "2. Run '{run_file}'.",
###PY###             "3. When finished, 'filename{suffix}.txt' and/or 'filename{suffix}.srt' will be created in this folder.",
###PY###             "4. To reconfigure, delete transcribe.py and run {run_file} again.",
###PY###             "====================================================================",
###PY###         ],
###PY###         "rt_progress": "  -> Progress: {pct:5.1f}% | Segments: {idx} | Elapsed: {el}s | Speed: {spd:.2f}x | ETA: {eta}s   ",
###PY###         "rt_start": "Transcription started (OS: {os} | Model: {model} | Device: {dev} | Lang: {lang} | Format: {fmt})",
###PY###         "rt_no_files": "[Info] No audio files found in 'recordings' folder. Please add files and run again.",
###PY###         "rt_found_files": "Files found: {n}",
###PY###         "rt_gpu_fallback": "[Info] GPU init failed ({e}) -> Automatically switching to CPU (int8) mode.",
###PY###         "rt_model_loaded": "Model loaded successfully.",
###PY###         "rt_file_item": "[{i}/{total}] File: {name}",
###PY###         "rt_skip": "  -> [Skipped] Output file already exists ({name})",
###PY###         "rt_done": "  -> [Done] {name} (Elapsed: {sec:.1f}s)",
###PY###         "rt_fail": "  -> [Failed] Error: {e}",
###PY###         "rt_all_done": "All Finished | Success: {ok} | Skipped: {skip} | Failed: {fail}",
###PY###     },
###PY###     "ja": {
###PY###         "ui_name": "\u65e5\u672c\u8a9e (Japanese)",
###PY###         "wiz_title": "[Whisper \u81ea\u52d5\u97f3\u58f0\u6587\u5b57\u8d77\u3053\u3057\u30b7\u30b9\u30c6\u30e0 - \u521d\u671f\u30bb\u30c3\u30c8\u30a2\u30c3\u30d7\u30a6\u30a3\u30b6\u30fc\u30c9]",
###PY###         "env_step_title": "[\u74b0\u5883\u8a2d\u5b9a] Python \u30a4\u30f3\u30b9\u30c8\u30fc\u30eb\u74b0\u5883\u3092\u9078\u629e\u3057\u3066\u304f\u3060\u3055\u3044:",
###PY###         "env_opt_1": "\u4eee\u60f3\u74b0\u5883 (venv) \u3092\u4f5c\u6210\u3057\u3066\u4f7f\u7528 (\u304a\u3059\u3059\u3081)",
###PY###         "env_opt_2": "\u30b7\u30b9\u30c6\u30e0\u6a19\u6e96 Python \u3092\u76f4\u63a5\u4f7f\u7528 (venv \u306a\u3057)",
###PY###         "env_prompt": "\u74b0\u5883\u756a\u53f7\u3092\u9078\u629e [1~2]",
###PY###         "venv_creating": "  -> Python \u4eee\u60f3\u74b0\u5883 (venv) \u3092\u4f5c\u6210\u4e2d... (10\u301c30\u79d2\u307b\u3069\u304a\u5f85\u3061\u304f\u3060\u3055\u3044)",
###PY###         "venv_fail": "[\u30a8\u30e9\u30fc] \u4eee\u60f3\u74b0\u5883\u306e\u4f5c\u6210\u306b\u5931\u6557\u3057\u307e\u3057\u305f\u3002\u30b7\u30b9\u30c6\u30e0\u6a19\u6e96 Python \u3067\u7d9a\u884c\u3057\u307e\u3059\u3002",
###PY###         "py_env_label": "\u9078\u629e\u3055\u308c\u305f Python \u74b0\u5883",
###PY###         "venv_str": "\u4eee\u60f3\u74b0\u5883 (venv)",
###PY###         "sys_str": "\u30b7\u30b9\u30c6\u30e0\u6a19\u6e96 Python",
###PY###         "hw_title": "[\u30cf\u30fc\u30c9\u30a6\u30a7\u30a2\u691c\u51fa\u3068\u304a\u3059\u3059\u3081\u8a2d\u5b9a]",
###PY###         "hw_cpu": "* CPU \u30b3\u30a2\u6570 : {cores} \u30b3\u30a2",
###PY###         "hw_ram": "* \u30b7\u30b9\u30c6\u30e0 RAM: {ram} GB",
###PY###         "hw_gpu": "* GPU / VRAM  : {gpu}",
###PY###         "hw_no_gpu": "NVIDIA GPU \u304c\u691c\u51fa\u3055\u308c\u307e\u305b\u3093\u3067\u3057\u305f (CPU \u30e2\u30fc\u30c9)",
###PY###         "hw_rec": "  -> \u304a\u3059\u3059\u3081: \u30e2\u30c7\u30eb [{m_key}] | \u30c7\u30d0\u30a4\u30b9 [{d_key}]",
###PY###         "tag_rec": "(\u304a\u3059\u3059\u3081)",
###PY###         "default_word": "\u30c7\u30d5\u30a9\u30eb\u30c8",
###PY###         "invalid_input": "[!] \u7121\u52b9\u306a\u5165\u529b\u3067\u3059\u3002{opts} \u304b\u3089\u9078\u629e\u3057\u3066\u304f\u3060\u3055\u3044\u3002",
###PY###         "step1_title": "[\u30b9\u30c6\u30c3\u30d7 1] \u30c0\u30a6\u30f3\u30ed\u30fc\u30c9\u3059\u308b\u97f3\u58f0\u8a8d\u8b58\u30e2\u30c7\u30eb\u3092\u9078\u629e\u3057\u3066\u304f\u3060\u3055\u3044:",
###PY###         "step1_prompt": "\u30e2\u30c7\u30eb\u756a\u53f7\u3092\u9078\u629e [1~6] (PyTorch\u7248\u306f 'dev' \u3068\u5165\u529b)",
###PY###         "dev_mode_banner": "[\u958b\u767a\u8005\u30e2\u30fc\u30c9\u6709\u52b9 - PyTorch \u30a8\u30f3\u30b8\u30f3\u304c\u5229\u7528\u53ef\u80fd\u3067\u3059]",
###PY###         "dev_section_title": "--- \u958b\u767a\u8005\u7528 / PyTorch \u516c\u5f0f\u6a19\u6e96\u30a8\u30f3\u30b8\u30f3 ---",
###PY###         "step1_dev_prompt": "\u30e2\u30c7\u30eb\u756a\u53f7\u3092\u9078\u629e [1~12]",
###PY###         "models": {
###PY###             "1": "Tiny (75MB / \u8d85\u4f4e\u30b9\u30da\u30c3\u30af\u30fb\u30c6\u30b9\u30c8\u7528)",
###PY###             "2": "Base (145MB / \u4e00\u822cCPU\u7528)",
###PY###             "3": "Small (480MB / \u901f\u5ea6\u30fb\u7cbe\u5ea6\u30d0\u30e9\u30f3\u30b9)",
###PY###             "4": "Medium (1.5GB / \u9ad8\u7cbe\u5ea6)",
###PY###             "5": "Turbo (1.6GB / \u9ad8\u901f\u30fb\u9ad8\u54c1\u8cea)",
###PY###             "6": "Large-v3 (3.1GB / \u6700\u9ad8\u54c1\u8cea)",
###PY###         },
###PY###         "dev_models": {
###PY###             "7": "Tiny (75MB / OpenAI Whisper - PyTorch)",
###PY###             "8": "Base (145MB / OpenAI Whisper - PyTorch)",
###PY###             "9": "Small (480MB / OpenAI Whisper - PyTorch)",
###PY###             "10": "Medium (1.5GB / OpenAI Whisper - PyTorch)",
###PY###             "11": "Turbo (1.6GB / OpenAI Whisper - PyTorch)",
###PY###             "12": "Large-v3 (3.1GB / OpenAI Whisper - PyTorch)",
###PY###         },
###PY###         "step2_title": "[\u30b9\u30c6\u30c3\u30d7 2] \u4f7f\u7528\u3059\u308b\u6f14\u7b97\u30c7\u30d0\u30a4\u30b9(CPU / GPU)\u3092\u9078\u629e\u3057\u3066\u304f\u3060\u3055\u3044:",
###PY###         "step2_prompt": "\u30c7\u30d0\u30a4\u30b9\u756a\u53f7\u3092\u9078\u629e [1~2]",
###PY###         "devices": {
###PY###             "1": "CPU \u30e2\u30fc\u30c9 (\u4f4e\u30b9\u30da\u30c3\u30afPC / \u4e00\u822c\u30ce\u30fc\u30c8PC / \u5185\u8535\u30b0\u30e9\u30d5\u30a3\u30c3\u30af\u7528)",
###PY###             "2": "GPU \u9ad8\u901f\u30e2\u30fc\u30c9 (NVIDIA \u30b0\u30e9\u30d5\u30a3\u30c3\u30af\u30ab\u30fc\u30c9 CUDA\u52a0\u901f\u7528)",
###PY###         },
###PY###         "step3_title": "[\u30b9\u30c6\u30c3\u30d7 3] \u6587\u5b57\u8d77\u3053\u3057\u3059\u308b\u97f3\u58f0\u306e\u57fa\u672c\u8a00\u8a9e\u3092\u9078\u629e\u3057\u3066\u304f\u3060\u3055\u3044:",
###PY###         "step3_prompt": "\u8a00\u8a9e\u756a\u53f7\u3092\u9078\u629e [1~5]",
###PY###         "target_langs": {
###PY###             "1": ("auto", "\u591a\u8a00\u8a9e\u81ea\u52d5\u691c\u51fa (Auto-detect: \u82f1\u8a9e/\u65e5\u672c\u8a9e/\u4e2d\u56fd\u8a9e/\u97d3\u56fd\u8a9e\u306a\u3069) - \u30c7\u30d5\u30a9\u30eb\u30c8"),
###PY###             "2": ("en", "\u82f1\u8a9e\u5c02\u7528 (English)"),
###PY###             "3": ("ja", "\u65e5\u672c\u8a9e\u5c02\u7528 (Japanese)"),
###PY###             "4": ("zh", "\u4e2d\u56fd\u8a9e\u5c02\u7528 (Chinese)"),
###PY###             "5": ("ko", "\u97d3\u56fd\u8a9e\u5c02\u7528 (Korean)"),
###PY###         },
###PY###         "default_target_lang": "1",
###PY###         "step4_title": "[\u30b9\u30c6\u30c3\u30d7 4] \u51fa\u529b\u30d5\u30a1\u30a4\u30eb\u5f62\u5f0f\u3092\u9078\u629e\u3057\u3066\u304f\u3060\u3055\u3044:",
###PY###         "step4_prompt": "\u5f62\u5f0f\u756a\u53f7\u3092\u9078\u629e [1~3]",
###PY###         "formats": {
###PY###             "1": ("both", "\u30c6\u30ad\u30b9\u30c8\u3068\u5b57\u5e55\u306e\u4e21\u65b9 (.txt + .srt) (\u304a\u3059\u3059\u3081)"),
###PY###             "2": ("txt", "\u30c6\u30ad\u30b9\u30c8\u306e\u307f (.txt)"),
###PY###             "3": ("srt", "\u5b57\u5e55\u306e\u307f (.srt)"),
###PY###         },
###PY###         "sum_ui": "UI \u8a00\u8a9e     ",
###PY###         "sum_env": "Python \u74b0\u5883 ",
###PY###         "sum_model": "\u9078\u629e\u30e2\u30c7\u30eb  ",
###PY###         "sum_dev": "\u9078\u629e\u30c7\u30d0\u30a4\u30b9",
###PY###         "sum_lang": "\u97f3\u58f0\u8a00\u8a9e    ",
###PY###         "sum_fmt": "\u51fa\u529b\u5f62\u5f0f    ",
###PY###         "prog_1": "[1/3] \u5fc5\u9808\u30e9\u30a4\u30d6\u30e9\u30ea\u3092\u30a4\u30f3\u30b9\u30c8\u30fc\u30eb\u4e2d...",
###PY###         "prog_2": "[2/3] recordings \u30d5\u30a9\u30eb\u30c0\u3001transcribe.py\u3001{guide} \u3092\u751f\u6210\u4e2d...",
###PY###         "prog_3": "[3/3] '{model}' \u30e2\u30c7\u30eb\u3092\u78ba\u8a8d\u4e2d...",
###PY###         "model_check_note": "  -> [\u53c2\u8003] \u30e2\u30c7\u30eb\u521d\u671f\u78ba\u8a8d\u30e1\u30c3\u30bb\u30fc\u30b8: {e}",
###PY###         "done_1": "\u30bb\u30c3\u30c8\u30a2\u30c3\u30d7\u5b8c\u4e86\uff01 'recordings' \u30d5\u30a9\u30eb\u30c0\u3001'transcribe.py'\u3001'{guide}' \u304c\u751f\u6210\u3055\u308c\u307e\u3057\u305f\u3002",
###PY###         "done_2": "'recordings' \u30d5\u30a9\u30eb\u30c0\u306b\u97f3\u58f0\u30d5\u30a1\u30a4\u30eb\u3092\u5165\u308c\u3066 '{run_file}' \u3092\u5b9f\u884c\u3057\u3066\u304f\u3060\u3055\u3044\uff01",
###PY###         "guide_filename": "\u4f7f\u3044\u65b9\u30ac\u30a4\u30c9.txt",
###PY###         "log_filename": "\u6587\u5b57\u8d77\u3053\u3057\u30ed\u30b0.txt",
###PY###         "out_suffix": "_\u6587\u5b57\u8d77\u3053\u3057",
###PY###         "guide_lines": [
###PY###             "====================================================================",
###PY###             "         [Whisper \u81ea\u52d5\u97f3\u58f0\u6587\u5b57\u8d77\u3053\u3057\u30b7\u30b9\u30c6\u30e0 \u4f7f\u3044\u65b9\u30ac\u30a4\u30c9]",
###PY###             "====================================================================",
###PY###             "",
###PY###             "* UI \u8a00\u8a9e     : {ui_name}",
###PY###             "* Python \u74b0\u5883 : {env_str}",
###PY###             "* \u30e2\u30c7\u30eb      : {m_desc}",
###PY###             "* \u6f14\u7b97\u30c7\u30d0\u30a4\u30b9: {d_desc}",
###PY###             "* \u97f3\u58f0\u8a00\u8a9e    : {l_desc}",
###PY###             "* \u51fa\u529b\u5f62\u5f0f    : {f_desc}",
###PY###             "",
###PY###             "[\u4f7f\u3044\u65b9]",
###PY###             "1. 'recordings' \u30d5\u30a9\u30eb\u30c0\u306b\u5909\u63db\u3057\u305f\u3044\u97f3\u58f0\u30d5\u30a1\u30a4\u30eb(.mp3, .m4a, .wav\u306a\u3069)\u3092\u5165\u308c\u307e\u3059\u3002",
###PY###             "2. '{run_file}' \u3092\u5b9f\u884c\u3057\u307e\u3059\u3002",
###PY###             "3. \u51e6\u7406\u304c\u5b8c\u4e86\u3059\u308b\u3068\u3001\u3053\u306e\u30d5\u30a9\u30eb\u30c0\u306b '\u30d5\u30a1\u30a4\u30eb\u540d{suffix}.txt' \u3084 '\u30d5\u30a1\u30a4\u30eb\u540d{suffix}.srt' \u304c\u81ea\u52d5\u751f\u6210\u3055\u308c\u307e\u3059\u3002",
###PY###             "4. \u8a2d\u5b9a\u3092\u5909\u66f4\u3059\u308b\u306b\u306f\u3001transcribe.py \u3092\u524a\u9664\u3057\u3066 {run_file} \u3092\u518d\u5b9f\u884c\u3057\u3066\u304f\u3060\u3055\u3044\u3002",
###PY###             "====================================================================",
###PY###         ],
###PY###         "rt_progress": "  -> \u9032\u6357: {pct:5.1f}% | \u30bb\u30b0\u30e1\u30f3\u30c8: {idx}\u500b | \u7d4c\u904e: {el}\u79d2 | \u901f\u5ea6: {spd:.2f}x | \u6b8b\u308a\u6642\u9593: {eta}\u79d2   ",
###PY###         "rt_start": "\u6587\u5b57\u8d77\u3053\u3057\u958b\u59cb (OS: {os} | \u30e2\u30c7\u30eb: {model} | \u30c7\u30d0\u30a4\u30b9: {dev} | \u8a00\u8a9e: {lang} | \u5f62\u5f0f: {fmt})",
###PY###         "rt_no_files": "[\u6848\u5185] recordings \u30d5\u30a9\u30eb\u30c0\u306b\u97f3\u58f0\u30d5\u30a1\u30a4\u30eb\u304c\u3042\u308a\u307e\u305b\u3093\u3002\u30d5\u30a1\u30a4\u30eb\u3092\u5165\u308c\u3066\u518d\u5b9f\u884c\u3057\u3066\u304f\u3060\u3055\u3044\u3002",
###PY###         "rt_found_files": "\u691c\u51fa\u3055\u308c\u305f\u30d5\u30a1\u30a4\u30eb\u6570: {n}\u500b",
###PY###         "rt_gpu_fallback": "[\u6848\u5185] GPU \u521d\u671f\u5316\u5931\u6557({e}) -> CPU(int8) \u30e2\u30fc\u30c9\u306b\u81ea\u52d5\u5207\u308a\u66ff\u3048\u3057\u307e\u3059\u3002",
###PY###         "rt_model_loaded": "\u30e2\u30c7\u30eb\u8aad\u307f\u8fbc\u307f\u5b8c\u4e86\u3002",
###PY###         "rt_file_item": "[{i}/{total}] \u30d5\u30a1\u30a4\u30eb: {name}",
###PY###         "rt_skip": "  -> [\u30b9\u30ad\u30c3\u30d7] \u65e2\u306b\u7d50\u679c\u30d5\u30a1\u30a4\u30eb\u304c\u5b58\u5728\u3057\u307e\u3059 ({name})",
###PY###         "rt_done": "  -> [\u5b8c\u4e86] {name} (\u6240\u8981: {sec:.1f}\u79d2)",
###PY###         "rt_fail": "  -> [\u5931\u6557] \u30a8\u30e9\u30fc: {e}",
###PY###         "rt_all_done": "\u5168\u3066\u5b8c\u4e86 | \u6210\u529f: {ok} | \u30b9\u30ad\u30c3\u30d7: {skip} | \u5931\u6557: {fail}",
###PY###     },
###PY###     "zh": {
###PY###         "ui_name": "\u4e2d\u6587 (Chinese)",
###PY###         "wiz_title": "[Whisper \u81ea\u52a8\u8bed\u97f3\u8f6c\u5f55\u7cfb\u7edf - \u521d\u59cb\u5b89\u88c5\u5411\u5bfc]",
###PY###         "env_step_title": "[\u73af\u5883\u8bbe\u7f6e] \u8bf7\u9009\u62e9 Python \u5b89\u88c5\u73af\u5883:",
###PY###         "env_opt_1": "\u521b\u5efa\u5e76\u4f7f\u7528\u865a\u62df\u73af\u5883 (venv) (\u63a8\u8350)",
###PY###         "env_opt_2": "\u76f4\u63a5\u4f7f\u7528\u7cfb\u7edf\u5168\u5c40 Python (\u65e0 venv)",
###PY###         "env_prompt": "\u9009\u62e9\u73af\u5883\u7f16\u53f7 [1~2]",
###PY###         "venv_creating": "  -> \u6b63\u5728\u521b\u5efa Python \u865a\u62df\u73af\u5883 (venv)... (\u8bf7\u7a0d\u5019 10~30 \u79d2)",
###PY###         "venv_fail": "[\u9519\u8bef] \u521b\u5efa\u865a\u62df\u73af\u5883\u5931\u8d25\uff0c\u5c06\u4f7f\u7528\u7cfb\u7edf\u5168\u5c40 Python \u7ee7\u7eed\u3002",
###PY###         "py_env_label": "\u5f53\u524d\u9009\u62e9\u7684 Python \u73af\u5883",
###PY###         "venv_str": "\u865a\u62df\u73af\u5883 (venv)",
###PY###         "sys_str": "\u7cfb\u7edf\u5168\u5c40 Python",
###PY###         "hw_title": "[\u7cfb\u7edf\u786c\u4ef6\u68c0\u6d4b\u4e0e\u63a8\u8350\u914d\u7f6e]",
###PY###         "hw_cpu": "* CPU \u6838\u5fc3\u6570 : {cores} \u6838",
###PY###         "hw_ram": "* \u7cfb\u7edf\u5185\u5b58    : {ram} GB",
###PY###         "hw_gpu": "* \u663e\u5361 (GPU)  : {gpu}",
###PY###         "hw_no_gpu": "\u672a\u68c0\u6d4b\u5230 NVIDIA \u72ec\u7acb\u663e\u5361 (CPU \u6a21\u5f0f)",
###PY###         "hw_rec": "  -> \u63a8\u8350: \u6a21\u578b [{m_key}] | \u8bbe\u5907 [{d_key}]",
###PY###         "tag_rec": "(\u63a8\u8350)",
###PY###         "default_word": "\u9ed8\u8ba4",
###PY###         "invalid_input": "[!] \u8f93\u5165\u65e0\u6548\uff0c\u8bf7\u4ece {opts} \u4e2d\u9009\u62e9\u3002",
###PY###         "step1_title": "[\u7b2c1\u6b65] \u8bf7\u9009\u62e9\u8981\u4e0b\u8f7d\u7684\u8bed\u97f3\u8bc6\u522b\u6a21\u578b:",
###PY###         "step1_prompt": "\u9009\u62e9\u6a21\u578b\u7f16\u53f7 [1~6] (\u8f93\u5165 'dev' \u53ef\u67e5\u770b PyTorch \u5f15\u64ce)",
###PY###         "dev_mode_banner": "[\u5f00\u53d1\u8005\u6a21\u5f0f\u5df2\u542f\u7528 - \u5df2\u89e3\u9501 PyTorch \u5f15\u64ce]",
###PY###         "dev_section_title": "--- \u5f00\u53d1\u8005\u4e13\u533a / PyTorch \u5b98\u65b9\u6807\u51c6\u5f15\u64ce ---",
###PY###         "step1_dev_prompt": "\u9009\u62e9\u6a21\u578b\u7f16\u53f7 [1~12]",
###PY###         "models": {
###PY###             "1": "Tiny (75MB / \u8d85\u4f4e\u914d\u4e0e\u6d4b\u8bd5)",
###PY###             "2": "Base (145MB / \u666e\u901aCPU\u7528)",
###PY###             "3": "Small (480MB / \u901f\u5ea6\u4e0e\u51c6\u786e\u7387\u5747\u8861)",
###PY###             "4": "Medium (1.5GB / \u9ad8\u51c6\u786e\u7387)",
###PY###             "5": "Turbo (1.6GB / \u9ad8\u901f\u9ad8\u6548)",
###PY###             "6": "Large-v3 (3.1GB / \u6700\u9ad8\u54c1\u8d28)",
###PY###         },
###PY###         "dev_models": {
###PY###             "7": "Tiny (75MB / OpenAI Whisper - PyTorch)",
###PY###             "8": "Base (145MB / OpenAI Whisper - PyTorch)",
###PY###             "9": "Small (480MB / OpenAI Whisper - PyTorch)",
###PY###             "10": "Medium (1.5GB / OpenAI Whisper - PyTorch)",
###PY###             "11": "Turbo (1.6GB / OpenAI Whisper - PyTorch)",
###PY###             "12": "Large-v3 (3.1GB / OpenAI Whisper - PyTorch)",
###PY###         },
###PY###         "step2_title": "[\u7b2c2\u6b65] \u8bf7\u9009\u62e9\u8ba1\u7b97\u8bbe\u5907 (CPU / GPU):",
###PY###         "step2_prompt": "\u9009\u62e9\u8bbe\u5907\u7f16\u53f7 [1~2]",
###PY###         "devices": {
###PY###             "1": "CPU \u6a21\u5f0f (\u4f4e\u914d\u7535\u8111 / \u666e\u901a\u7b14\u8bb0\u672c / \u96c6\u6210\u663e\u5361)",
###PY###             "2": "GPU \u9ad8\u901f\u6a21\u5f0f (NVIDIA \u72ec\u7acb\u663e\u5361 CUDA \u52a0\u901f)",
###PY###         },
###PY###         "step3_title": "[\u7b2c3\u6b65] \u8bf7\u9009\u62e9\u8981\u8f6c\u5f55\u7684\u9ed8\u8ba4\u97f3\u9891\u8bed\u8a00:",
###PY###         "step3_prompt": "\u9009\u62e9\u8bed\u8a00\u7f16\u53f7 [1~5]",
###PY###         "target_langs": {
###PY###             "1": ("auto", "\u591a\u8bed\u8a00\u81ea\u52a8\u68c0\u6d4b (Auto-detect: \u82f1\u8bed/\u65e5\u8bed/\u4e2d\u6587/\u97e9\u8bed\u7b49) - \u9ed8\u8ba4"),
###PY###             "2": ("en", "\u4ec5\u82f1\u8bed (English)"),
###PY###             "3": ("ja", "\u4ec5\u65e5\u8bed (Japanese)"),
###PY###             "4": ("zh", "\u4ec5\u4e2d\u6587 (Chinese)"),
###PY###             "5": ("ko", "\u4ec5\u97e9\u8bed (Korean)"),
###PY###         },
###PY###         "default_target_lang": "1",
###PY###         "step4_title": "[\u7b2c4\u6b65] \u8bf7\u9009\u62e9\u8f93\u51fa\u6587\u4ef6\u683c\u5f0f:",
###PY###         "step4_prompt": "\u9009\u62e9\u683c\u5f0f\u7f16\u53f7 [1~3]",
###PY###         "formats": {
###PY###             "1": ("both", "\u6587\u672c\u4e0e\u5b57\u5e55\u540c\u65f6\u751f\u6210 (.txt + .srt) (\u63a8\u8350)"),
###PY###             "2": ("txt", "\u4ec5\u751f\u6210\u6587\u672c (.txt)"),
###PY###             "3": ("srt", "\u4ec5\u751f\u6210\u5b57\u5e55 (.srt)"),
###PY###         },
###PY###         "sum_ui": "\u754c\u9762\u8bed\u8a00   ",
###PY###         "sum_env": "Python \u73af\u5883",
###PY###         "sum_model": "\u6240\u9009\u6a21\u578b   ",
###PY###         "sum_dev": "\u6240\u9009\u8bbe\u5907   ",
###PY###         "sum_lang": "\u8f6c\u5f55\u8bed\u8a00   ",
###PY###         "sum_fmt": "\u8f93\u51fa\u683c\u5f0f   ",
###PY###         "prog_1": "[1/3] \u6b63\u5728\u5b89\u88c5\u5fc5\u9700\u7684\u4f9d\u8d56\u5e93...",
###PY###         "prog_2": "[2/3] \u6b63\u5728\u751f\u6210 recordings \u6587\u4ef6\u5939\u3001transcribe.py\u3001{guide}...",
###PY###         "prog_3": "[3/3] \u6b63\u5728\u9a8c\u8bc1 '{model}' \u6a21\u578b...",
###PY###         "model_check_note": "  -> [\u63d0\u793a] \u6a21\u578b\u521d\u59cb\u68c0\u67e5\u4fe1\u606f: {e}",
###PY###         "done_1": "\u5b89\u88c5\u5b8c\u6210\uff01\u5df2\u751f\u6210 'recordings' \u6587\u4ef6\u5939\u3001'transcribe.py' \u548c '{guide}'\u3002",
###PY###         "done_2": "\u73b0\u5728\u8bf7\u5c06\u97f3\u9891\u6587\u4ef6\u653e\u5165 'recordings' \u6587\u4ef6\u5939\u5e76\u8fd0\u884c '{run_file}'\uff01",
###PY###         "guide_filename": "\u4f7f\u7528\u8bf4\u660e.txt",
###PY###         "log_filename": "\u8f6c\u5f55\u65e5\u5fd7.txt",
###PY###         "out_suffix": "_\u8f6c\u5f55\u672c",
###PY###         "guide_lines": [
###PY###             "====================================================================",
###PY###             "             [Whisper \u81ea\u52a8\u8bed\u97f3\u8f6c\u5f55\u7cfb\u7edf - \u4f7f\u7528\u8bf4\u660e]",
###PY###             "====================================================================",
###PY###             "",
###PY###             "* \u754c\u9762\u8bed\u8a00   : {ui_name}",
###PY###             "* Python \u73af\u5883: {env_str}",
###PY###             "* \u5df2\u88c5\u6a21\u578b   : {m_desc}",
###PY###             "* \u8ba1\u7b97\u8bbe\u5907   : {d_desc}",
###PY###             "* \u8f6c\u5f55\u8bed\u8a00   : {l_desc}",
###PY###             "* \u8f93\u51fa\u683c\u5f0f   : {f_desc}",
###PY###             "",
###PY###             "[\u4f7f\u7528\u65b9\u6cd5]",
###PY###             "1. \u5c06\u8981\u8f6c\u6362\u7684\u97f3\u9891\u6587\u4ef6(.mp3, .m4a, .wav\u7b49)\u653e\u5165 'recordings' \u6587\u4ef6\u5939\u4e2d\u3002",
###PY###             "2. \u8fd0\u884c '{run_file}'\u3002",
###PY###             "3. \u5904\u7406\u5b8c\u6210\u540e\uff0c\u5f53\u524d\u6587\u4ef6\u5939\u4e0b\u4f1a\u81ea\u52a8\u751f\u6210 '\u6587\u4ef6\u540d{suffix}.txt' \u4e0e '\u6587\u4ef6\u540d{suffix}.srt'\u3002",
###PY###             "4. \u82e5\u9700\u66f4\u6539\u914d\u7f6e\uff0c\u8bf7\u5220\u9664 transcribe.py \u540e\u91cd\u65b0\u8fd0\u884c {run_file}\u3002",
###PY###             "====================================================================",
###PY###         ],
###PY###         "rt_progress": "  -> \u8fdb\u5ea6: {pct:5.1f}% | \u7247\u6bb5: {idx}\u4e2a | \u5df2\u7528: {el}\u79d2 | \u901f\u5ea6: {spd:.2f}x | \u5269\u4f59: {eta}\u79d2   ",
###PY###         "rt_start": "\u8f6c\u5f55\u4efb\u52a1\u5f00\u59cb (OS: {os} | \u6a21\u578b: {model} | \u8bbe\u5907: {dev} | \u8bed\u8a00: {lang} | \u683c\u5f0f: {fmt})",
###PY###         "rt_no_files": "[\u63d0\u793a] recordings \u6587\u4ef6\u5939\u4e2d\u6ca1\u6709\u97f3\u9891\u6587\u4ef6\u3002\u8bf7\u653e\u5165\u6587\u4ef6\u540e\u91cd\u65b0\u8fd0\u884c\u3002",
###PY###         "rt_found_files": "\u68c0\u6d4b\u5230\u7684\u6587\u4ef6\u6570: {n}\u4e2a",
###PY###         "rt_gpu_fallback": "[\u63d0\u793a] GPU \u521d\u59cb\u5316\u5931\u8d25({e}) -> \u81ea\u52a8\u5207\u6362\u81f3 CPU(int8) \u6a21\u5f0f\u3002",
###PY###         "rt_model_loaded": "\u6a21\u578b\u52a0\u8f7d\u5b8c\u6210\u3002",
###PY###         "rt_file_item": "[{i}/{total}] \u6587\u4ef6: {name}",
###PY###         "rt_skip": "  -> [\u8df3\u8fc7] \u7ed3\u679c\u6587\u4ef6\u5df2\u5b58\u5728 ({name})",
###PY###         "rt_done": "  -> [\u5b8c\u6210] {name} (\u8017\u65f6: {sec:.1f}\u79d2)",
###PY###         "rt_fail": "  -> [\u5931\u8d25] \u9519\u8bef: {e}",
###PY###         "rt_all_done": "\u5168\u90e8\u5b8c\u6210 | \u6210\u529f: {ok} | \u8df3\u8fc7: {skip} | \u5931\u8d25: {fail}",
###PY###     },
###PY###     "ko": {
###PY###         "ui_name": "\ud55c\uad6d\uc5b4 (Korean)",
###PY###         "wiz_title": "[Whisper \uc790\ub3d9 \uc74c\uc131 \uc804\uc0ac \uc2dc\uc2a4\ud15c - \ucd08\uae30 \uc124\uce58 \ub9c8\ubc95\uc0ac]",
###PY###         "env_step_title": "[\ud658\uacbd \uc124\uc815] Python \uc124\uce58 \ud658\uacbd\uc744 \uc120\ud0dd\ud558\uc138\uc694:",
###PY###         "env_opt_1": "\uac00\uc0c1 \ud658\uacbd(venv) \uc0dd\uc131 \ubc0f \uc0ac\uc6a9 (\ucd94\ucc9c)",
###PY###         "env_opt_2": "\uc2dc\uc2a4\ud15c \uae30\ubcf8 Python \uc9c1\uc811 \uc0ac\uc6a9 (venv \uc5c6\uc74c)",
###PY###         "env_prompt": "\ud658\uacbd \ubc88\ud638 \uc120\ud0dd [1~2]",
###PY###         "venv_creating": "  -> Python \uac00\uc0c1 \ud658\uacbd(venv) \uc0dd\uc131 \uc911... (10~30\ucd08 \uc815\ub3c4 \uc18c\uc694\ub420 \uc218 \uc788\uc2b5\ub2c8\ub2e4)",
###PY###         "venv_fail": "[\uc624\ub958] \uac00\uc0c1 \ud658\uacbd(venv) \uc0dd\uc131\uc5d0 \uc2e4\ud328\ud588\uc2b5\ub2c8\ub2e4. \uc2dc\uc2a4\ud15c \uae30\ubcf8 Python\uc73c\ub85c \uc9c4\ud589\ud569\ub2c8\ub2e4.",
###PY###         "py_env_label": "\ud604\uc7ac \uc120\ud0dd\ub41c Python \ud658\uacbd",
###PY###         "venv_str": "\uac00\uc0c1 \ud658\uacbd (venv)",
###PY###         "sys_str": "\uc2dc\uc2a4\ud15c \uae30\ubcf8 Python",
###PY###         "hw_title": "[\uc2dc\uc2a4\ud15c \uc0ac\uc591 \uac10\uc9c0 \ubc0f \ucd94\ucc9c \uc124\uc815]",
###PY###         "hw_cpu": "* CPU \ucf54\uc5b4 \uc218 : {cores}\uac1c",
###PY###         "hw_ram": "* \uc2dc\uc2a4\ud15c RAM  : {ram} GB",
###PY###         "hw_gpu": "* \uadf8\ub798\ud53d (GPU): {gpu}",
###PY###         "hw_no_gpu": "NVIDIA \uadf8\ub798\ud53d\uce74\ub4dc \ubbf8\uac80\ucd9c (CPU \ubaa8\ub4dc \ub3d9\uc791)",
###PY###         "hw_rec": "  -> \ucd94\ucc9c: \ubaa8\ub378 [{m_key}] | \uc5f0\uc0b0 \uc7a5\uce58 [{d_key}]",
###PY###         "tag_rec": "(\ucd94\ucc9c)",
###PY###         "default_word": "\uae30\ubcf8\uac12",
###PY###         "invalid_input": "[!] \uc798\ubabb\ub41c \uc785\ub825\uc785\ub2c8\ub2e4. {opts} \uc911\uc5d0\uc11c \uc120\ud0dd\ud558\uc138\uc694.",
###PY###         "step1_title": "[1\ub2e8\uacc4] \ub2e4\uc6b4\ub85c\ub4dc\ud560 \uc74c\uc131 \uc778\uc2dd \ubaa8\ub378\uc744 \uc120\ud0dd\ud558\uc138\uc694:",
###PY###         "step1_prompt": "\ubaa8\ub378 \ubc88\ud638 \uc120\ud0dd [1~6] (PyTorch \uc5d4\uc9c4\uc740 'dev' \uc785\ub825)",
###PY###         "dev_mode_banner": "[\uac1c\ubc1c\uc790 \ubaa8\ub4dc \ud65c\uc131\ud654 - PyTorch \uc5d4\uc9c4 \uc7a0\uae08 \ud574\uc81c]",
###PY###         "dev_section_title": "--- \uac1c\ubc1c\uc790 \ubaa8\ub4dc / PyTorch \uacf5\uc2dd \uc6d0\ubcf8 \uc5d4\uc9c4 ---",
###PY###         "step1_dev_prompt": "\ubaa8\ub378 \ubc88\ud638 \uc120\ud0dd [1~12]",
###PY###         "models": {
###PY###             "1": "Tiny (75MB / \ucd08\uc800\uc0ac\uc591\u00b7\ud14c\uc2a4\ud2b8\uc6a9)",
###PY###             "2": "Base (145MB / \uc77c\ubc18 CPU\uc6a9)",
###PY###             "3": "Small (480MB / \uc18d\ub3c4\u00b7\uc815\ud655\ub3c4 \uade0\ud615)",
###PY###             "4": "Medium (1.5GB / \uace0\uc815\ud655\ub3c4)",
###PY###             "5": "Turbo (1.6GB / \uace0\uc18d\u00b7\uace0\ud488\uc9c8)",
###PY###             "6": "Large-v3 (3.1GB / \ucd5c\uace0\ud488\uc9c8)",
###PY###         },
###PY###         "dev_models": {
###PY###             "7": "Tiny (75MB / OpenAI Whisper - PyTorch)",
###PY###             "8": "Base (145MB / OpenAI Whisper - PyTorch)",
###PY###             "9": "Small (480MB / OpenAI Whisper - PyTorch)",
###PY###             "10": "Medium (1.5GB / OpenAI Whisper - PyTorch)",
###PY###             "11": "Turbo (1.6GB / OpenAI Whisper - PyTorch)",
###PY###             "12": "Large-v3 (3.1GB / OpenAI Whisper - PyTorch)",
###PY###         },
###PY###         "step2_title": "[2\ub2e8\uacc4] \uc0ac\uc6a9\ud560 \uc5f0\uc0b0 \uc7a5\uce58(CPU / GPU)\ub97c \uc120\ud0dd\ud558\uc138\uc694:",
###PY###         "step2_prompt": "\uc7a5\uce58 \ubc88\ud638 \uc120\ud0dd [1~2]",
###PY###         "devices": {
###PY###             "1": "CPU \ubaa8\ub4dc (\uc77c\ubc18 PC / \ub178\ud2b8\ubd81)",
###PY###             "2": "GPU \uace0\uc18d \ubaa8\ub4dc (NVIDIA CUDA)",
###PY###         },
###PY###         "step3_title": "[3\ub2e8\uacc4] \uc804\uc0ac\ud560 \uc74c\uc131\uc758 \uae30\ubcf8 \uc5b8\uc5b4\ub97c \uc120\ud0dd\ud558\uc138\uc694:",
###PY###         "step3_prompt": "\uc5b8\uc5b4 \ubc88\ud638 \uc120\ud0dd [1~5]",
###PY###         "target_langs": {
###PY###             "1": ("auto", "\ub2e4\uad6d\uc5b4 \uc790\ub3d9 \uac10\uc9c0 (Auto-detect: \uc601/\uc77c/\uc911/\ud55c \ub4f1) - \uae30\ubcf8\uac12"),
###PY###             "2": ("en", "\uc601\uc5b4 \uc804\uc6a9 (English)"),
###PY###             "3": ("ja", "\uc77c\ubcf8\uc5b4 \uc804\uc6a9 (Japanese)"),
###PY###             "4": ("zh", "\uc911\uad6d\uc5b4 \uc804\uc6a9 (Chinese)"),
###PY###             "5": ("ko", "\ud55c\uad6d\uc5b4 \uc804\uc6a9 (Korean)"),
###PY###         },
###PY###         "default_target_lang": "1",
###PY###         "step4_title": "[4\ub2e8\uacc4] \uacb0\uacfc \ud30c\uc77c \uc800\uc7a5 \ud615\uc2dd\uc744 \uc120\ud0dd\ud558\uc138\uc694:",
###PY###         "step4_prompt": "\uc800\uc7a5 \ud615\uc2dd \uc120\ud0dd [1~3]",
###PY###         "formats": {
###PY###             "1": ("both", "\ud14d\uc2a4\ud2b8 + \uc790\ub9c9 \ub3d9\uc2dc \uc0dd\uc131 (.txt + .srt) (\ucd94\ucc9c)"),
###PY###             "2": ("txt", "\ud14d\uc2a4\ud2b8 \ud30c\uc77c\ub9cc \uc0dd\uc131 (.txt)"),
###PY###             "3": ("srt", "\uc790\ub9c9 \ud30c\uc77c\ub9cc \uc0dd\uc131 (.srt)"),
###PY###         },
###PY###         "sum_ui": "UI \uc5b8\uc5b4     ",
###PY###         "sum_env": "Python \ud658\uacbd ",
###PY###         "sum_model": "\uc120\ud0dd \ubaa8\ub378   ",
###PY###         "sum_dev": "\uc120\ud0dd \uc7a5\uce58   ",
###PY###         "sum_lang": "\uc804\uc0ac \uc5b8\uc5b4   ",
###PY###         "sum_fmt": "\uc800\uc7a5 \ud615\uc2dd   ",
###PY###         "prog_1": "[1/3] \ud544\uc218 \ub77c\uc774\ube0c\ub7ec\ub9ac \uc124\uce58 \uc911...",
###PY###         "prog_2": "[2/3] recordings \ud3f4\ub354, transcribe.py, {guide} \uc0dd\uc131 \uc911...",
###PY###         "prog_3": "[3/3] '{model}' \ubaa8\ub378 \ud655\uc778 \uc911...",
###PY###         "model_check_note": "  -> [\ucc38\uace0] \ubaa8\ub378 \ucd08\uae30 \ud655\uc778 \uba54\uc2dc\uc9c0: {e}",
###PY###         "done_1": "\uc124\uce58 \uc644\ub8cc! 'recordings' \ud3f4\ub354, 'transcribe.py', '{guide}'\uac00 \uc0dd\uc131\ub418\uc5c8\uc2b5\ub2c8\ub2e4.",
###PY###         "done_2": "\uc774\uc81c 'recordings' \ud3f4\ub354\uc5d0 \uc74c\uc131 \ud30c\uc77c\uc744 \ub123\uace0 '{run_file}'\uc744 \uc2e4\ud589\ud558\uc138\uc694!",
###PY###         "guide_filename": "\uc0ac\uc6a9\uc124\uba85\uc11c.txt",
###PY###         "log_filename": "\uc804\uc0ac\ub85c\uadf8.txt",
###PY###         "out_suffix": "_\uc804\uc0ac\ubcf8",
###PY###         "guide_lines": [
###PY###             "====================================================================",
###PY###             "             [Whisper \uc790\ub3d9 \uc74c\uc131 \uc804\uc0ac \uc2dc\uc2a4\ud15c \uc0ac\uc6a9 \uc124\uba85\uc11c]",
###PY###             "====================================================================",
###PY###             "",
###PY###             "* UI \uc5b8\uc5b4     : {ui_name}",
###PY###             "* Python \ud658\uacbd : {env_str}",
###PY###             "* \uc124\uce58\ub41c \ubaa8\ub378 : {m_desc}",
###PY###             "* \uc5f0\uc0b0 \uc7a5\uce58   : {d_desc}",
###PY###             "* \uae30\ubcf8 \uc5b8\uc5b4   : {l_desc}",
###PY###             "* \uc800\uc7a5 \ud615\uc2dd   : {f_desc}",
###PY###             "",
###PY###             "[\uc0ac\uc6a9 \ubc29\ubc95]",
###PY###             "1. 'recordings' \ud3f4\ub354 \uc548\uc5d0 \ubcc0\ud658\ud560 \uc74c\uc131 \ud30c\uc77c(.mp3, .m4a, .wav \ub4f1)\uc744 \ub123\uc2b5\ub2c8\ub2e4.",
###PY###             "2. '{run_file}'\uc744 \uc2e4\ud589\ud569\ub2c8\ub2e4.",
###PY###             "3. \uc791\uc5c5\uc774 \ub05d\ub098\uba74 \ud604\uc7ac \ud3f4\ub354\uc5d0 '\ud30c\uc77c\uba85{suffix}.txt' \ubc0f '\ud30c\uc77c\uba85{suffix}.srt' \ud30c\uc77c\uc774 \uc790\ub3d9 \uc0dd\uc131\ub429\ub2c8\ub2e4.",
###PY###             "4. \ub2e4\ub978 \ubaa8\ub378\uc774\ub098 \uc5b8\uc5b4\ub85c \ub2e4\uc2dc \uc124\uc815\ud558\ub824\uba74 transcribe.py\ub97c \uc9c0\uc6b0\uace0 {run_file}\uc744 \uc2e4\ud589\ud558\uc138\uc694.",
###PY###             "====================================================================",
###PY###         ],
###PY###         "rt_progress": "  -> \uc9c4\ud589\ub960: {pct:5.1f}% | \uc138\uadf8\uba3c\ud2b8: {idx}\uac1c | \uacbd\uacfc: {el}\ucd08 | \uc18d\ub3c4: {spd:.2f}x | \ub0a8\uc740\uc2dc\uac04: {eta}\ucd08   ",
###PY###         "rt_start": "\uc804\uc0ac \uc791\uc5c5 \uc2dc\uc791 (OS: {os} | \ubaa8\ub378: {model} | \uc7a5\uce58: {dev} | \uc5b8\uc5b4: {lang} | \ud615\uc2dd: {fmt})",
###PY###         "rt_no_files": "[\uc548\ub0b4] recordings \ud3f4\ub354\uc5d0 \uc74c\uc131 \ud30c\uc77c\uc774 \uc5c6\uc2b5\ub2c8\ub2e4. \ud30c\uc77c\uc744 \ub123\uace0 \ub2e4\uc2dc \uc2e4\ud589\ud558\uc138\uc694.",
###PY###         "rt_found_files": "\ud0d0\uc0c9\ub41c \ud30c\uc77c \uc218: {n}\uac1c",
###PY###         "rt_gpu_fallback": "[\uc548\ub0b4] GPU \ucd08\uae30\ud654 \uc2e4\ud328({e}) -> CPU(int8) \ubaa8\ub4dc\ub85c \uc790\ub3d9 \uc804\ud658\ud569\ub2c8\ub2e4.",
###PY###         "rt_model_loaded": "\ubaa8\ub378 \ub85c\ub529 \uc644\ub8cc.",
###PY###         "rt_file_item": "[{i}/{total}] \ud30c\uc77c: {name}",
###PY###         "rt_skip": "  -> [\uac74\ub108\ub700] \uc774\ubbf8 \uacb0\uacfc \ud30c\uc77c \uc874\uc7ac ({name})",
###PY###         "rt_done": "  -> [\uc644\ub8cc] {name} (\uc18c\uc694: {sec:.1f}\ucd08)",
###PY###         "rt_fail": "  -> [\uc2e4\ud328] \uc624\ub958: {e}",
###PY###         "rt_all_done": "\uc804\uccb4 \uc644\ub8cc | \uc131\uacf5: {ok} | \uac74\ub108\ub700: {skip} | \uc2e4\ud328: {fail}",
###PY###     },
###PY### }
###PY###
###PY### MODEL_DEFS = {
###PY###     "1": ("tiny", "faster-whisper"),
###PY###     "2": ("base", "faster-whisper"),
###PY###     "3": ("small", "faster-whisper"),
###PY###     "4": ("medium", "faster-whisper"),
###PY###     "5": ("large-v3-turbo", "faster-whisper"),
###PY###     "6": ("large-v3", "faster-whisper"),
###PY###     "7": ("tiny", "openai-whisper"),
###PY###     "8": ("base", "openai-whisper"),
###PY###     "9": ("small", "openai-whisper"),
###PY###     "10": ("medium", "openai-whisper"),
###PY###     "11": ("turbo", "openai-whisper"),
###PY###     "12": ("large-v3", "openai-whisper"),
###PY### }
###PY###
###PY### DEVICE_DEFS = {
###PY###     "1": ("cpu", "int8"),
###PY###     "2": ("cuda", "float16"),
###PY### }
###PY###
###PY### FORMAT_DEFS = {
###PY###     "1": "both",
###PY###     "2": "txt",
###PY###     "3": "srt",
###PY### }
###PY###
###PY### def detect_hardware():
###PY###     ram_gb = 8.0
###PY###     sys_name = platform.system()
###PY###     try:
###PY###         if sys_name == "Windows":
###PY###             import ctypes
###PY###             class MEMORYSTATUSEX(ctypes.Structure):
###PY###                 _fields_ = [
###PY###                     ("dwLength", ctypes.c_ulong),
###PY###                     ("dwMemoryLoad", ctypes.c_ulong),
###PY###                     ("ullTotalPhys", ctypes.c_ulonglong),
###PY###                     ("ullAvailPhys", ctypes.c_ulonglong),
###PY###                     ("ullTotalPageFile", ctypes.c_ulonglong),
###PY###                     ("ullAvailPageFile", ctypes.c_ulonglong),
###PY###                     ("ullTotalVirtual", ctypes.c_ulonglong),
###PY###                     ("ullAvailVirtual", ctypes.c_ulonglong),
###PY###                     ("sullAvailExtendedVirtual", ctypes.c_ulonglong),
###PY###                 ]
###PY###             stat = MEMORYSTATUSEX()
###PY###             stat.dwLength = ctypes.sizeof(MEMORYSTATUSEX)
###PY###             if ctypes.windll.kernel32.GlobalMemoryStatusEx(ctypes.byref(stat)):
###PY###                 ram_gb = round(stat.ullTotalPhys / (1024**3), 1)
###PY###         elif sys_name == "Darwin":
###PY###             out = subprocess.check_output(["sysctl", "-n", "hw.memsize"], encoding="utf-8").strip()
###PY###             ram_gb = round(int(out) / (1024**3), 1)
###PY###         else:
###PY###             ram_gb = round(os.sysconf("SC_PAGE_SIZE") * os.sysconf("SC_PHYS_PAGES") / (1024**3), 1)
###PY###     except Exception:
###PY###         pass
###PY###
###PY###     cpu_cores = os.cpu_count() or 4
###PY###     has_gpu = False
###PY###     gpu_name = ""
###PY###     vram_gb = 0.0
###PY###
###PY###     is_mac = (sys_name == "Darwin")
###PY###     is_apple_silicon = is_mac and platform.machine() in ("arm64", "aarch64")
###PY###
###PY###     if is_apple_silicon:
###PY###         gpu_name = f"Apple Silicon ({platform.processor() or 'M-Series'})"
###PY###         rec_dev = "1"
###PY###         if ram_gb >= 15.0:
###PY###             rec_model = "5"
###PY###         elif ram_gb >= 7.5:
###PY###             rec_model = "3"
###PY###         elif ram_gb >= 5.5:
###PY###             rec_model = "2"
###PY###         else:
###PY###             rec_model = "1"
###PY###     else:
###PY###         try:
###PY###             smi = shutil.which("nvidia-smi")
###PY###             if smi:
###PY###                 out = subprocess.check_output(
###PY###                     [smi, "--query-gpu=name,memory.total", "--format=csv,noheader,nounits"],
###PY###                     encoding="utf-8", stderr=subprocess.DEVNULL
###PY###                 ).strip()
###PY###                 if out:
###PY###                     line = out.splitlines()[0]
###PY###                     parts = line.split(",")
###PY###                     gpu_name = parts[0].strip()
###PY###                     if len(parts) > 1:
###PY###                         vram_mb = float(parts[1].strip())
###PY###                         vram_gb = round(vram_mb / 1024.0, 1)
###PY###                     has_gpu = True
###PY###         except Exception:
###PY###             pass
###PY###
###PY###         if has_gpu and vram_gb >= 1.5:
###PY###             rec_dev = "2"
###PY###             if vram_gb >= 11.0:
###PY###                 rec_model = "6"
###PY###             elif vram_gb >= 6.0:
###PY###                 rec_model = "5"
###PY###             elif vram_gb >= 3.5:
###PY###                 rec_model = "4"
###PY###             elif vram_gb >= 2.0:
###PY###                 rec_model = "3"
###PY###             else:
###PY###                 rec_model = "2"
###PY###         else:
###PY###             rec_dev = "1"
###PY###             if cpu_cores >= 6 and ram_gb >= 7.5:
###PY###                 rec_model = "3"
###PY###             elif cpu_cores >= 4 and ram_gb >= 5.5:
###PY###                 rec_model = "2"
###PY###             else:
###PY###                 rec_model = "1"
###PY###
###PY###     return {
###PY###         "ram_gb": ram_gb,
###PY###         "cpu_cores": cpu_cores,
###PY###         "has_gpu": has_gpu,
###PY###         "is_apple_silicon": is_apple_silicon,
###PY###         "gpu_name": gpu_name,
###PY###         "vram_gb": vram_gb,
###PY###         "rec_model": rec_model,
###PY###         "rec_dev": rec_dev,
###PY###     }
###PY###
###PY### def ask(prompt_msg, valid_list, default_val, tr):
###PY###     while True:
###PY###         ans = input(f"{prompt_msg} ({tr['default_word']} {default_val}): ").strip()
###PY###         if not ans:
###PY###             return default_val
###PY###         if ans in valid_list:
###PY###             return ans
###PY###         print("  " + tr["invalid_input"].format(opts=", ".join(valid_list)))
###PY###
###PY### def write_transcribe_script(ui_lang, backend, model_name, device, compute_type, lang, out_format, beam_size, tr):
###PY###     NL = chr(10)
###PY###     lines = [
###PY###         "# -*- coding: utf-8 -*-",
###PY###         "import os, sys, time, platform, argparse, warnings, logging",
###PY###         "from pathlib import Path",
###PY###         "from datetime import datetime",
###PY###         "from difflib import SequenceMatcher",
###PY###         "",
###PY###         'os.environ["HF_HUB_DISABLE_SYMLINKS_WARNING"] = "1"',
###PY###         'os.environ["HF_HUB_VERBOSITY"] = "error"',
###PY###         'warnings.filterwarnings("ignore", message=".*unauthenticated requests.*")',
###PY###         'logging.getLogger("huggingface_hub").setLevel(logging.ERROR)',
###PY###         "",
###PY###         "if hasattr(sys.stdout, 'reconfigure'):",
###PY###         "    try: sys.stdout.reconfigure(encoding='utf-8')",
###PY###         "    except Exception: pass",
###PY###         "",
###PY###         "# PyAV(av.open) metadata_errors compatibility patch",
###PY###         "try:",
###PY###         "    import av",
###PY###         "    _orig_av_open = av.open",
###PY###         "    def _safe_av_open(*args, **kwargs):",
###PY###         "        try:",
###PY###         "            return _orig_av_open(*args, **kwargs)",
###PY###         "        except TypeError as e:",
###PY###         '            if "metadata_errors" in str(e) and "metadata_errors" in kwargs:',
###PY###         '                kwargs.pop("metadata_errors", None)',
###PY###         "                return _orig_av_open(*args, **kwargs)",
###PY###         "            raise",
###PY###         "    av.open = _safe_av_open",
###PY###         "except Exception:",
###PY###         "    pass",
###PY###         "",
###PY###         f"UI_LANG = {repr(ui_lang)}",
###PY###         f"DEFAULT_BACKEND = {repr(backend)}",
###PY###         f"DEFAULT_MODEL = {repr(model_name)}",
###PY###         f"DEFAULT_DEVICE = {repr(device)}",
###PY###         f"DEFAULT_COMPUTE_TYPE = {repr(compute_type)}",
###PY###         f"DEFAULT_LANGUAGE = {repr(lang)}",
###PY###         f"DEFAULT_OUTPUT_FORMAT = {repr(out_format)}",
###PY###         f"DEFAULT_BEAM_SIZE = {beam_size}",
###PY###         "",
###PY###         "SCRIPT_DIR = Path(__file__).resolve().parent",
###PY###         'RECORDINGS_DIR = SCRIPT_DIR / "recordings"',
###PY###         f"LOG_PATH = SCRIPT_DIR / {repr(tr['log_filename'])}",
###PY###         f"OUT_SUFFIX = {repr(tr['out_suffix'])}",
###PY###         'SUPPORTED_EXTENSIONS = {".mp3", ".wav", ".m4a", ".mp4", ".aac", ".flac", ".ogg", ".wma", ".webm"}',
###PY###         "SIMILARITY_THRESHOLD = 0.92",
###PY###         "PARAGRAPH_GAP_SEC = 2.5",
###PY###         "MAX_PARAGRAPH_LEN = 350",
###PY###         'SENTENCE_ENDINGS = (".", "!", "?", "\u3002", "\uff01", "\uff1f", "\ub2e4.", "\uc694.", "\uc8e0.")',
###PY###         "NL = chr(10)",
###PY###         "CR = chr(13)",
###PY###         "",
###PY###         "MSG = {",
###PY###         f'    "progress": {repr(tr["rt_progress"])},',
###PY###         f'    "start": {repr(tr["rt_start"])},',
###PY###         f'    "no_files": {repr(tr["rt_no_files"])},',
###PY###         f'    "found_files": {repr(tr["rt_found_files"])},',
###PY###         f'    "gpu_fallback": {repr(tr["rt_gpu_fallback"])},',
###PY###         f'    "model_loaded": {repr(tr["rt_model_loaded"])},',
###PY###         f'    "file_item": {repr(tr["rt_file_item"])},',
###PY###         f'    "skip": {repr(tr["rt_skip"])},',
###PY###         f'    "done": {repr(tr["rt_done"])},',
###PY###         f'    "fail": {repr(tr["rt_fail"])},',
###PY###         f'    "all_done": {repr(tr["rt_all_done"])},',
###PY###         "}",
###PY###         "",
###PY###         "def write_log(msg, print_console=True):",
###PY###         '    ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")',
###PY###         '    line = f"[{ts}] {msg}"',
###PY###         "    if print_console: print(line)",
###PY###         "    try:",
###PY###         '        with open(LOG_PATH, "a", encoding="utf-8") as f:',
###PY###         "            f.write(line + NL)",
###PY###         "    except Exception: pass",
###PY###         "",
###PY###         "def setup_windows_cuda_dlls():",
###PY###         '    if platform.system() != "Windows": return',
###PY###         "    try:",
###PY###         "        import site",
###PY###         "        sps = site.getsitepackages()",
###PY###         '        if hasattr(site, "getusersitepackages"): sps.append(site.getusersitepackages())',
###PY###         "        for sp in sps:",
###PY###         '            for sub in [Path("nvidia")/"cublas"/"bin", Path("nvidia")/"cudnn"/"bin"]:',
###PY###         "                d = Path(sp) / sub",
###PY###         "                if d.exists():",
###PY###         '                    if hasattr(os, "add_dll_directory"): os.add_dll_directory(str(d))',
###PY###         '                    os.environ["PATH"] = str(d) + os.pathsep + os.environ.get("PATH", "")',
###PY###         "    except Exception: pass",
###PY###         "",
###PY###         "def format_ts(sec):",
###PY###         "    s = max(0, int(sec))",
###PY###         "    h, rem = divmod(s, 3600)",
###PY###         "    m, s = divmod(rem, 60)",
###PY###         '    return f"{h:02d}:{m:02d}:{s:02d}" if h > 0 else f"{m:02d}:{s:02d}"',
###PY###         "",
###PY###         "def format_srt_ts(sec):",
###PY###         "    sec = max(0.0, float(sec))",
###PY###         "    s = int(sec)",
###PY###         "    ms = int(round((sec - s) * 1000))",
###PY###         "    if ms >= 1000:",
###PY###         "        s += 1",
###PY###         "        ms = 0",
###PY###         "    h, rem = divmod(s, 3600)",
###PY###         "    m, s = divmod(rem, 60)",
###PY###         '    return f"{h:02d}:{m:02d}:{s:02d},{ms:03d}"',
###PY###         "",
###PY###         "def generate_srt(filtered):",
###PY###         '    if not filtered: return ""',
###PY###         "    lines = []",
###PY###         "    for idx, seg in enumerate(filtered, 1):",
###PY###         "        st = format_srt_ts(seg['start'])",
###PY###         "        ed = format_srt_ts(seg['end'])",
###PY###         "        tx = seg['text']",
###PY###         '        lines.append(f"{idx}{NL}{st} --> {ed}{NL}{tx}{NL}")',
###PY###         "    return NL.join(lines)",
###PY###         "",
###PY###         "def post_process(raw_segs, duration, t0):",
###PY###         "    filtered, prev = [], ''",
###PY###         "    for idx, seg in enumerate(raw_segs, 1):",
###PY###         '        st = seg.start if hasattr(seg, "start") else seg.get("start", 0.0)',
###PY###         '        ed = seg.end if hasattr(seg, "end") else seg.get("end", 0.0)',
###PY###         '        tx = (seg.text if hasattr(seg, "text") else seg.get("text", "")).strip()',
###PY###         "        if not tx: continue",
###PY###         "        el = max(0.001, time.time() - t0)",
###PY###         "        spd = ed / el if ed > 0 else 0.0",
###PY###         "        if duration > 0 and spd > 0:",
###PY###         "            eta = int(max(0.0, duration - ed) / spd)",
###PY###         "            pct = min(100.0, (ed / duration) * 100)",
###PY###         '            print(CR + MSG["progress"].format(pct=pct, idx=idx, el=int(el), spd=spd, eta=eta), end="", flush=True)',
###PY###         "        if prev and SequenceMatcher(None, prev, tx).ratio() >= SIMILARITY_THRESHOLD: continue",
###PY###         '        filtered.append({"start": st, "end": ed, "text": tx})',
###PY###         "        prev = tx",
###PY###         "    print()",
###PY###         '    if not filtered: return [], ""',
###PY###         "    paras, c_st, c_ed, c_tx = [], filtered[0]['start'], filtered[0]['end'], [filtered[0]['text']]",
###PY###         "    for s in filtered[1:]:",
###PY###         "        joined = ' '.join(c_tx)",
###PY###         "        if (s['start'] - c_ed) >= PARAGRAPH_GAP_SEC or (len(joined) >= MAX_PARAGRAPH_LEN and joined.endswith(SENTENCE_ENDINGS)):",
###PY###         '            paras.append(f"[{format_ts(c_st)} - {format_ts(c_ed)}] {joined}")',
###PY###         "            c_st, c_tx = s['start'], [s['text']]",
###PY###         "        else: c_tx.append(s['text'])",
###PY###         "        c_ed = s['end']",
###PY###         "    if c_tx:",
###PY###         "        joined_last = ' '.join(c_tx)",
###PY###         '        paras.append(f"[{format_ts(c_st)} - {format_ts(c_ed)}] {joined_last}")',
###PY###         "    return filtered, (NL + NL).join(paras)",
###PY###         "",
###PY###         "def main():",
###PY###         "    setup_windows_cuda_dlls()",
###PY###         "    RECORDINGS_DIR.mkdir(parents=True, exist_ok=True)",
###PY###         '    write_log("=" * 60)',
###PY###         '    write_log(MSG["start"].format(os=platform.system(), model=DEFAULT_MODEL, dev=DEFAULT_DEVICE, lang=DEFAULT_LANGUAGE, fmt=DEFAULT_OUTPUT_FORMAT))',
###PY###         "    files = sorted([f for f in RECORDINGS_DIR.iterdir() if f.is_file() and f.suffix.lower() in SUPPORTED_EXTENSIONS])",
###PY###         "    if not files:",
###PY###         '        write_log(MSG["no_files"])',
###PY###         "        return",
###PY###         '    write_log(MSG["found_files"].format(n=len(files)))',
###PY###         "    dev, comp = DEFAULT_DEVICE, DEFAULT_COMPUTE_TYPE",
###PY###         '    if DEFAULT_BACKEND == "faster-whisper":',
###PY###         "        from faster_whisper import WhisperModel",
###PY###         "        try:",
###PY###         "            model = WhisperModel(DEFAULT_MODEL, device=dev, compute_type=comp)",
###PY###         "        except Exception as e1:",
###PY###         '            if dev == "cuda" and comp != "int8":',
###PY###         "                try:",
###PY###         '                    write_log(f"  -> GPU(float16) fallback to GPU(int8)...")',
###PY###         '                    comp = "int8"',
###PY###         '                    model = WhisperModel(DEFAULT_MODEL, device="cuda", compute_type="int8")',
###PY###         "                except Exception as e2:",
###PY###         '                    write_log(MSG["gpu_fallback"].format(e=f"{e1} / {e2}"))',
###PY###         '                    dev, comp = "cpu", "int8"',
###PY###         '                    model = WhisperModel(DEFAULT_MODEL, device="cpu", compute_type="int8")',
###PY###         "            else:",
###PY###         '                write_log(MSG["gpu_fallback"].format(e=e1))',
###PY###         '                dev, comp = "cpu", "int8"',
###PY###         '                model = WhisperModel(DEFAULT_MODEL, device="cpu", compute_type="int8")',
###PY###         "    else:",
###PY###         "        import whisper",
###PY###         '        if dev == "cuda":',
###PY###         "            try:",
###PY###         "                import torch",
###PY###         "                if not torch.cuda.is_available():",
###PY###         '                    write_log(MSG["gpu_fallback"].format(e="CUDA not available"))',
###PY###         '                    dev = "cpu"',
###PY###         "            except Exception:",
###PY###         "                pass",
###PY###         "        try:",
###PY###         "            model = whisper.load_model(DEFAULT_MODEL, device=dev)",
###PY###         "        except Exception as e:",
###PY###         '            write_log(MSG["gpu_fallback"].format(e=e))',
###PY###         '            dev = "cpu"',
###PY###         '            model = whisper.load_model(DEFAULT_MODEL, device="cpu")',
###PY###         '    write_log(MSG["model_loaded"])',
###PY###         "    ok, skip, fail = 0, 0, 0",
###PY###         "    for i, fpath in enumerate(files, 1):",
###PY###         '        txt_out = SCRIPT_DIR / f"{fpath.stem}{OUT_SUFFIX}.txt"',
###PY###         '        srt_out = SCRIPT_DIR / f"{fpath.stem}{OUT_SUFFIX}.srt"',
###PY###         "        needed = []",
###PY###         '        if DEFAULT_OUTPUT_FORMAT in ("both", "txt"): needed.append(txt_out)',
###PY###         '        if DEFAULT_OUTPUT_FORMAT in ("both", "srt"): needed.append(srt_out)',
###PY###         '        write_log(MSG["file_item"].format(i=i, total=len(files), name=fpath.name))',
###PY###         "        if all(p.exists() and p.stat().st_size > 0 for p in needed):",
###PY###         '            write_log(MSG["skip"].format(name=fpath.name))',
###PY###         "            skip += 1; continue",
###PY###         "        t0 = time.time()",
###PY###         "        try:",
###PY###         '            lang_arg = None if DEFAULT_LANGUAGE == "auto" else DEFAULT_LANGUAGE',
###PY###         '            if DEFAULT_BACKEND == "faster-whisper":',
###PY###         "                segs, info = model.transcribe(str(fpath), language=lang_arg, beam_size=DEFAULT_BEAM_SIZE, vad_filter=True, condition_on_previous_text=False)",
###PY###         '                dur = getattr(info, "duration", 0.0)',
###PY###         "            else:",
###PY###         '                res = model.transcribe(str(fpath), language=lang_arg, beam_size=DEFAULT_BEAM_SIZE, fp16=(dev=="cuda"), condition_on_previous_text=False)',
###PY###         '                segs = res.get("segments", [])',
###PY###         '                dur = segs[-1]["end"] if segs else 0.0',
###PY###         "            filtered, txt = post_process(segs, dur, t0)",
###PY###         '            if DEFAULT_OUTPUT_FORMAT in ("both", "txt"):',
###PY###         '                tmp_txt = SCRIPT_DIR / f"{fpath.stem}{OUT_SUFFIX}.txt.tmp"',
###PY###         '                with open(tmp_txt, "w", encoding="utf-8") as out_f:',
###PY###         "                    out_f.write(txt + NL)",
###PY###         "                tmp_txt.replace(txt_out)",
###PY###         '            if DEFAULT_OUTPUT_FORMAT in ("both", "srt"):',
###PY###         "                srt_str = generate_srt(filtered)",
###PY###         '                tmp_srt = SCRIPT_DIR / f"{fpath.stem}{OUT_SUFFIX}.srt.tmp"',
###PY###         '                with open(tmp_srt, "w", encoding="utf-8") as out_f:',
###PY###         "                    out_f.write(srt_str + NL)",
###PY###         "                tmp_srt.replace(srt_out)",
###PY###         '            done_names = ", ".join([p.name for p in needed])',
###PY###         '            write_log(MSG["done"].format(name=done_names, sec=time.time()-t0))',
###PY###         "            ok += 1",
###PY###         "        except Exception as e:",
###PY###         '            write_log(MSG["fail"].format(e=e))',
###PY###         "            fail += 1",
###PY###         '    write_log(MSG["all_done"].format(ok=ok, skip=skip, fail=fail))',
###PY###         "",
###PY###         'if __name__ == "__main__": main()'
###PY###     ]
###PY###     with open(TRANSCRIBE_PATH, "w", encoding="utf-8") as f:
###PY###         f.write(NL.join(lines) + NL)
###PY###
###PY### def main():
###PY###     is_dev = any(arg in sys.argv for arg in ["--dev", "-dev", "--advanced", "--expert"])
###PY###
###PY###     print("=" * 68)
###PY###     print("   [Whisper Auto Transcriber - Initial Setup Wizard]")
###PY###     print("=" * 68)
###PY###     print("\nSelect UI Language / \u8a00\u8a9e\u9078\u629e / \u9009\u62e9\u754c\u9762\u8bed\u8a00 / \uc778\ud130\ud398\uc774\uc2a4 \uc5b8\uc5b4 \uc120\ud0dd:")
###PY###     print("  [1] English (Default)")
###PY###     print("  [2] \u65e5\u672c\u8a9e (Japanese)")
###PY###     print("  [3] \u4e2d\u6587 (Chinese)")
###PY###     print("  [4] \ud55c\uad6d\uc5b4 (Korean)")
###PY###     while True:
###PY###         ans = input("\nSelect [1~4] (Default 1): ").strip()
###PY###         if not ans:
###PY###             ui_choice = "1"
###PY###             break
###PY###         if ans in UI_LANG_MAP:
###PY###             ui_choice = ans
###PY###             break
###PY###         print("  [!] Please select 1, 2, 3, or 4.")
###PY###
###PY###     ui_lang = UI_LANG_MAP[ui_choice]
###PY###     tr = I18N[ui_lang]
###PY###
###PY###     print("\n" + "-" * 68)
###PY###     print(tr["env_step_title"])
###PY###     print(f"  [1] {tr['env_opt_1']}")
###PY###     print(f"  [2] {tr['env_opt_2']}")
###PY###     env_choice = ask("\n" + tr["env_prompt"], ["1", "2"], "1", tr)
###PY###
###PY###     target_py = sys.executable
###PY###     is_venv = False
###PY###     if env_choice == "1":
###PY###         if FLAG_SYSTEM_PY.exists():
###PY###             try: FLAG_SYSTEM_PY.unlink()
###PY###             except Exception: pass
###PY###         if not VENV_PY.exists():
###PY###             print("\n" + tr["venv_creating"])
###PY###             try:
###PY###                 subprocess.check_call([sys.executable, "-m", "venv", str(VENV_DIR)])
###PY###             except Exception:
###PY###                 pass
###PY###         if VENV_PY.exists():
###PY###             target_py = str(VENV_PY)
###PY###             is_venv = True
###PY###         else:
###PY###             print(tr["venv_fail"])
###PY###     else:
###PY###         try:
###PY###             FLAG_SYSTEM_PY.write_text("1", encoding="utf-8")
###PY###         except Exception:
###PY###             pass
###PY###
###PY###     env_str = tr["venv_str"] if is_venv else tr["sys_str"]
###PY###     print("\n" + "=" * 68)
###PY###     print("   " + tr["wiz_title"])
###PY###     print(f"   * {tr['py_env_label']} : {env_str}")
###PY###     print("=" * 68)
###PY###
###PY###     # Hardware Detection & Auto-Recommendation
###PY###     hw = detect_hardware()
###PY###     if hw.get("is_apple_silicon"):
###PY###         gpu_desc = f"{hw['gpu_name']} - Unified Memory {hw['ram_gb']} GB"
###PY###     elif hw["has_gpu"]:
###PY###         gpu_desc = f"{hw['gpu_name']} ({hw['vram_gb']} GB VRAM)"
###PY###     else:
###PY###         gpu_desc = tr["hw_no_gpu"]
###PY###
###PY###     print("\n" + tr["hw_title"])
###PY###     print(tr["hw_cpu"].format(cores=hw["cpu_cores"]))
###PY###     print(tr["hw_ram"].format(ram=hw["ram_gb"]))
###PY###     print(tr["hw_gpu"].format(gpu=gpu_desc))
###PY###     print(tr["hw_rec"].format(m_key=hw["rec_model"], d_key=hw["rec_dev"]))
###PY###     print("-" * 68)
###PY###
###PY###     rec_m = hw["rec_model"]
###PY###     rec_d = hw["rec_dev"]
###PY###
###PY###     while True:
###PY###         print("\n" + tr["step1_title"])
###PY###         for k in ["1", "2", "3", "4", "5", "6"]:
###PY###             mark = f" {tr['tag_rec']}" if k == rec_m else ""
###PY###             print(f"  [{k}] {tr['models'][k]}{mark}")
###PY###         if is_dev:
###PY###             print("\n  " + tr["dev_section_title"])
###PY###             for k in ["7", "8", "9", "10", "11", "12"]:
###PY###                 print(f"  [{k}] {tr['dev_models'][k]}")
###PY###
###PY###         prompt_str = tr["step1_dev_prompt"] if is_dev else tr["step1_prompt"]
###PY###         valid_keys = list(MODEL_DEFS.keys()) if is_dev else ["1", "2", "3", "4", "5", "6"]
###PY###
###PY###         ans = input(f"\n{prompt_str} ({tr['default_word']} {rec_m}): ").strip()
###PY###         if not ans:
###PY###             m_key = rec_m
###PY###             break
###PY###         if ans.lower() in ("dev", "--dev", "expert", "advanced") and not is_dev:
###PY###             is_dev = True
###PY###             print("\n" + tr["dev_mode_banner"])
###PY###             continue
###PY###         if ans in valid_keys:
###PY###             m_key = ans
###PY###             break
###PY###         print("  " + tr["invalid_input"].format(opts=", ".join(valid_keys)))
###PY###
###PY###     m_name, m_backend = MODEL_DEFS[m_key]
###PY###     m_desc = tr["dev_models"][m_key] if int(m_key) >= 7 else tr["models"][m_key]
###PY###
###PY###     print("\n" + "-" * 68)
###PY###     print(tr["step2_title"])
###PY###     for k in DEVICE_DEFS:
###PY###         mark = f" {tr['tag_rec']}" if k == rec_d else ""
###PY###         print(f"  [{k}] {tr['devices'][k]}{mark}")
###PY###
###PY###     d_key = ask("\n" + tr["step2_prompt"], list(DEVICE_DEFS.keys()), rec_d, tr)
###PY###     d_dev, d_comp = DEVICE_DEFS[d_key]
###PY###     d_desc = tr["devices"][d_key]
###PY###
###PY###     print("\n" + "-" * 68)
###PY###     print(tr["step3_title"])
###PY###     for k, v in tr["target_langs"].items():
###PY###         print(f"  [{k}] {v[1]}")
###PY###     l_key = ask("\n" + tr["step3_prompt"], list(tr["target_langs"].keys()), tr["default_target_lang"], tr)
###PY###     l_code, l_desc = tr["target_langs"][l_key]
###PY###
###PY###     print("\n" + "-" * 68)
###PY###     print(tr["step4_title"])
###PY###     for k, v in tr["formats"].items():
###PY###         print(f"  [{k}] {v[1]}")
###PY###     f_key = ask("\n" + tr["step4_prompt"], list(tr["formats"].keys()), "1", tr)
###PY###     f_code, f_desc = tr["formats"][f_key]
###PY###
###PY###     beam = 2 if (m_name in ("tiny", "base") and d_dev == "cpu") else 5
###PY###
###PY###     print("\n" + "=" * 68)
###PY###     print(f" -> {tr['sum_ui']}: {tr['ui_name']}")
###PY###     print(f" -> {tr['sum_env']}: {env_str}")
###PY###     print(f" -> {tr['sum_model']}: {m_desc}")
###PY###     print(f" -> {tr['sum_dev']}: {d_desc}")
###PY###     print(f" -> {tr['sum_lang']}: {l_desc}")
###PY###     print(f" -> {tr['sum_fmt']}: {f_desc}")
###PY###     print("=" * 68)
###PY###
###PY###     print("\n" + tr["prog_1"])
###PY###     subprocess.check_call([target_py, "-m", "pip", "install", "--upgrade", "pip", "-q"])
###PY###     if m_backend == "faster-whisper":
###PY###         pkgs = ["faster-whisper"]
###PY###         if d_dev == "cuda" and platform.system() in ("Windows", "Linux"):
###PY###             pkgs += ["nvidia-cublas-cu12", "nvidia-cudnn-cu12"]
###PY###         subprocess.check_call([target_py, "-m", "pip", "install"] + pkgs)
###PY###     else:
###PY###         subprocess.check_call([target_py, "-m", "pip", "install", "openai-whisper"])
###PY###
###PY###     guide_fname = tr["guide_filename"]
###PY###     guide_path = BASE_DIR / guide_fname
###PY###     print("\n" + tr["prog_2"].format(guide=guide_fname))
###PY###     RECORDINGS_DIR.mkdir(parents=True, exist_ok=True)
###PY###     write_transcribe_script(ui_lang, m_backend, m_name, d_dev, d_comp, l_code, f_code, beam, tr)
###PY###
###PY###     # Clean up old guide files in other languages
###PY###     for old_g in ["\uc0ac\uc6a9\uc124\uba85\uc11c.txt", "user_guide.txt", "\u4f7f\u3044\u65b9\u30ac\u30a4\u30c9.txt", "\u4f7f\u7528\u8bf4\u660e.txt"]:
###PY###         if old_g != guide_fname:
###PY###             old_p = BASE_DIR / old_g
###PY###             if old_p.exists():
###PY###                 try: old_p.unlink()
###PY###                 except Exception: pass
###PY###
###PY###     if platform.system() == "Windows":
###PY###         run_file = "start.bat"
###PY###     elif platform.system() == "Darwin":
###PY###         run_file = "start_mac.command"
###PY###     else:
###PY###         run_file = "./start_linux.sh"
###PY###
###PY###     NL = chr(10)
###PY###     guide_text = NL.join(tr["guide_lines"]).format(
###PY###         ui_name=tr["ui_name"],
###PY###         env_str=env_str,
###PY###         m_desc=m_desc,
###PY###         d_desc=d_desc,
###PY###         l_desc=l_desc,
###PY###         f_desc=f_desc,
###PY###         suffix=tr["out_suffix"],
###PY###         run_file=run_file,
###PY###     ) + NL
###PY###     with open(guide_path, "w", encoding="utf-8") as gf:
###PY###         gf.write(guide_text)
###PY###
###PY###     print("\n" + tr["prog_3"].format(model=m_name))
###PY###     try:
###PY###         if m_backend == "faster-whisper":
###PY###             chk_cmd = f"import os, warnings, logging; os.environ['HF_HUB_DISABLE_SYMLINKS_WARNING']='1'; os.environ['HF_HUB_VERBOSITY']='error'; warnings.filterwarnings('ignore', message='.*unauthenticated requests.*'); logging.getLogger('huggingface_hub').setLevel(logging.ERROR); from faster_whisper import WhisperModel; WhisperModel({repr(m_name)}, device='cpu', compute_type='int8')"
###PY###         else:
###PY###             chk_cmd = f"import whisper; whisper.load_model({repr(m_name)}, device='cpu')"
###PY###         subprocess.check_call([target_py, "-c", chk_cmd])
###PY###     except Exception as e:
###PY###         print(tr["model_check_note"].format(e=e))
###PY###
###PY###     print("\n" + "=" * 68)
###PY###     print(tr["done_1"].format(guide=guide_fname))
###PY###     print(tr["done_2"].format(run_file=run_file))
###PY###     print("=" * 68)
###PY###
###PY### if __name__ == "__main__":
###PY###     main()
