#!/usr/bin/env bash
# ====================================================================
# Whisper Auto Transcriber - Linux Launcher
# ====================================================================
set -e
cd "$(dirname "$0")"

export HF_HUB_DISABLE_SYMLINKS_WARNING="1"
export HF_HUB_VERBOSITY="error"

if command -v python3 >/dev/null 2>&1; then
    PY_CMD="python3"
elif command -v python >/dev/null 2>&1; then
    PY_CMD="python"
else
    echo "[ERROR] Python 3 is not found in system PATH."
    echo "Please install Python 3.9+ (e.g. 'sudo apt install python3 python3-venv' on Ubuntu/Debian)."
    echo ""
    read -n 1 -s -r -p "Press any key to exit..." || true
    echo ""
    exit 1
fi

VENV_PY="./venv/bin/python"

SETUP_REQ=0
for arg in "$@"; do
    if [[ "$arg" == "--setup" || "$arg" == "--dev" || "$arg" == "--advanced" || "$arg" == "--expert" ]]; then
        SETUP_REQ=1
    fi
done

if [[ "$SETUP_REQ" -eq 1 || ! -f "transcribe.py" ]]; then
    WIZ_PY="./_wizard.py"
    trap 'rm -f "$WIZ_PY"' EXIT INT TERM
    cat > "$WIZ_PY" << '###WIZARD_EOF###'
import os
import sys
import subprocess
import platform
import shutil
from pathlib import Path

os.environ["HF_HUB_DISABLE_SYMLINKS_WARNING"] = "1"
os.environ["HF_HUB_VERBOSITY"] = "error"
import warnings
warnings.filterwarnings("ignore", message=".*unauthenticated requests.*")

if hasattr(sys.stdout, "reconfigure"):
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass
if hasattr(sys.stdin, "reconfigure"):
    try:
        sys.stdin.reconfigure(encoding="utf-8")
    except Exception:
        pass

BASE_DIR = Path(__file__).resolve().parent
RECORDINGS_DIR = BASE_DIR / "recordings"
TRANSCRIBE_PATH = BASE_DIR / "transcribe.py"
VENV_DIR = BASE_DIR / "venv"
VENV_PY = VENV_DIR / ("Scripts/python.exe" if platform.system() == "Windows" else "bin/python")
FLAG_SYSTEM_PY = BASE_DIR / ".use_system_py"

UI_LANG_MAP = {"1": "en", "2": "ja", "3": "zh", "4": "ko"}

I18N = {
    "en": {
        "ui_name": "English",
        "wiz_title": "[Whisper Auto Transcriber - Initial Setup Wizard]",
        "env_step_title": "[Environment] Select Python installation environment:",
        "env_opt_1": "Create and use Virtual Environment (venv) (Recommended)",
        "env_opt_2": "Use System Global Python directly (No venv)",
        "env_prompt": "Select environment [1~2]",
        "venv_creating": "  -> Creating Python virtual environment (venv)... (Please wait 10~30 seconds)",
        "venv_fail": "[Error] Failed to create venv. Proceeding with System Global Python.",
        "py_env_label": "Selected Python Environment",
        "venv_str": "Virtual Environment (venv)",
        "sys_str": "System Global Python",
        "hw_title": "[System Hardware Detection & Recommendations]",
        "hw_cpu": "* CPU Cores   : {cores} cores",
        "hw_ram": "* System RAM  : {ram} GB",
        "hw_gpu": "* GPU / VRAM  : {gpu}",
        "hw_no_gpu": "No dedicated NVIDIA GPU detected (CPU Mode)",
        "hw_rec": "  -> Recommended: Model [{m_key}] | Device [{d_key}]",
        "tag_rec": "(Recommended)",
        "default_word": "Default",
        "invalid_input": "[!] Invalid input. Please choose from {opts}.",
        "step1_title": "[Step 1] Select speech recognition model to download:",
        "step1_prompt": "Select model [1~6] (or 'dev' for PyTorch engines)",
        "dev_mode_banner": "[Developer Mode Enabled - PyTorch engines unlocked]",
        "dev_section_title": "--- Developer Mode / PyTorch Official Engines ---",
        "step1_dev_prompt": "Select model [1~12]",
        "models": {
            "1": "Tiny (75MB / Ultra-low spec, Fast test)",
            "2": "Base (145MB / Standard CPU)",
            "3": "Small (480MB / Balanced & Fast)",
            "4": "Medium (1.5GB / High accuracy)",
            "5": "Turbo (1.6GB / Fast & High quality)",
            "6": "Large-v3 (3.1GB / Maximum quality)",
        },
        "dev_models": {
            "7": "Tiny (75MB / OpenAI Whisper - PyTorch)",
            "8": "Base (145MB / OpenAI Whisper - PyTorch)",
            "9": "Small (480MB / OpenAI Whisper - PyTorch)",
            "10": "Medium (1.5GB / OpenAI Whisper - PyTorch)",
            "11": "Turbo (1.6GB / OpenAI Whisper - PyTorch)",
            "12": "Large-v3 (3.1GB / OpenAI Whisper - PyTorch)",
        },
        "step2_title": "[Step 2] Select compute device (CPU / GPU):",
        "step2_prompt": "Select device [1~2]",
        "devices": {
            "1": "CPU Mode (Low-spec PC / Standard Laptop / Integrated Graphics)",
            "2": "GPU Fast Mode (NVIDIA Graphics Card with CUDA acceleration)",
        },
        "step3_title": "[Step 3] Select default audio language for transcription:",
        "step3_prompt": "Select language [1~5]",
        "target_langs": {
            "1": ("auto", "Multilingual Auto-detect (en/ja/zh/ko/etc.) - Default"),
            "2": ("en", "English only (en)"),
            "3": ("ja", "Japanese only (ja)"),
            "4": ("zh", "Chinese only (zh)"),
            "5": ("ko", "Korean only (ko)"),
        },
        "default_target_lang": "1",
        "step4_title": "[Step 4] Select output file format:",
        "step4_prompt": "Select format [1~3]",
        "formats": {
            "1": ("both", "Both Text & Subtitles (.txt + .srt) (Recommended)"),
            "2": ("txt", "Text only (.txt)"),
            "3": ("srt", "Subtitles only (.srt)"),
        },
        "sum_ui": "UI Language  ",
        "sum_env": "Python Env   ",
        "sum_model": "Model        ",
        "sum_dev": "Device       ",
        "sum_lang": "Audio Lang   ",
        "sum_fmt": "Output Format",
        "prog_1": "[1/3] Installing required libraries...",
        "prog_2": "[2/3] Generating recordings folder, transcribe.py, {guide}...",
        "prog_3": "[3/3] Verifying '{model}' model...",
        "model_check_note": "  -> [Note] Model initial check message: {e}",
        "done_1": "Setup complete! 'recordings' folder, 'transcribe.py', and '{guide}' have been created.",
        "done_2": "Now place your audio files in the 'recordings' folder and run '{run_file}'!",
        "guide_filename": "user_guide.txt",
        "log_filename": "transcription_log.txt",
        "out_suffix": "_transcript",
        "guide_lines": [
            "====================================================================",
            "             [Whisper Auto Transcriber - User Guide]",
            "====================================================================",
            "",
            "* UI Language  : {ui_name}",
            "* Python Env   : {env_str}",
            "* Model        : {m_desc}",
            "* Device       : {d_desc}",
            "* Audio Lang   : {l_desc}",
            "* Output Format: {f_desc}",
            "",
            "[How to Use]",
            "1. Place audio files (.mp3, .m4a, .wav, etc.) into the 'recordings' folder.",
            "2. Run '{run_file}'.",
            "3. When finished, 'filename{suffix}.txt' and/or 'filename{suffix}.srt' will be created in this folder.",
            "4. To reconfigure, delete transcribe.py and run {run_file} again.",
            "====================================================================",
        ],
        "rt_progress": "  -> Progress: {pct:5.1f}% | Segments: {idx} | Elapsed: {el}s | Speed: {spd:.2f}x | ETA: {eta}s   ",
        "rt_start": "Transcription started (OS: {os} | Model: {model} | Device: {dev} | Lang: {lang} | Format: {fmt})",
        "rt_no_files": "[Info] No audio files found in 'recordings' folder. Please add files and run again.",
        "rt_found_files": "Files found: {n}",
        "rt_gpu_fallback": "[Info] GPU init failed ({e}) -> Automatically switching to CPU (int8) mode.",
        "rt_model_loaded": "Model loaded successfully.",
        "rt_file_item": "[{i}/{total}] File: {name}",
        "rt_skip": "  -> [Skipped] Output file already exists ({name})",
        "rt_done": "  -> [Done] {name} (Elapsed: {sec:.1f}s)",
        "rt_fail": "  -> [Failed] Error: {e}",
        "rt_all_done": "All Finished | Success: {ok} | Skipped: {skip} | Failed: {fail}",
    },
    "ja": {
        "ui_name": "日本語 (Japanese)",
        "wiz_title": "[Whisper 自動音声文字起こしシステム - 初期セットアップウィザード]",
        "env_step_title": "[環境設定] Python インストール環境を選択してください:",
        "env_opt_1": "仮想環境 (venv) を作成して使用 (おすすめ)",
        "env_opt_2": "システム標準 Python を直接使用 (venv なし)",
        "env_prompt": "環境番号を選択 [1~2]",
        "venv_creating": "  -> Python 仮想環境 (venv) を作成中... (10〜30秒ほどお待ちください)",
        "venv_fail": "[エラー] 仮想環境の作成に失敗しました。システム標準 Python で続行します。",
        "py_env_label": "選択された Python 環境",
        "venv_str": "仮想環境 (venv)",
        "sys_str": "システム標準 Python",
        "hw_title": "[ハードウェア検出とおすすめ設定]",
        "hw_cpu": "* CPU コア数 : {cores} コア",
        "hw_ram": "* システム RAM: {ram} GB",
        "hw_gpu": "* GPU / VRAM  : {gpu}",
        "hw_no_gpu": "NVIDIA GPU が検出されませんでした (CPU モード)",
        "hw_rec": "  -> おすすめ: モデル [{m_key}] | デバイス [{d_key}]",
        "tag_rec": "(おすすめ)",
        "default_word": "デフォルト",
        "invalid_input": "[!] 無効な入力です。{opts} から選択してください。",
        "step1_title": "[ステップ 1] ダウンロードする音声認識モデルを選択してください:",
        "step1_prompt": "モデル番号を選択 [1~6] (PyTorch版は 'dev' と入力)",
        "dev_mode_banner": "[開発者モード有効 - PyTorch エンジンが利用可能です]",
        "dev_section_title": "--- 開発者用 / PyTorch 公式標準エンジン ---",
        "step1_dev_prompt": "モデル番号を選択 [1~12]",
        "models": {
            "1": "Tiny (75MB / 超低スペック・テスト用)",
            "2": "Base (145MB / 一般CPU用)",
            "3": "Small (480MB / 速度・精度バランス)",
            "4": "Medium (1.5GB / 高精度)",
            "5": "Turbo (1.6GB / 高速・高品質)",
            "6": "Large-v3 (3.1GB / 最高品質)",
        },
        "dev_models": {
            "7": "Tiny (75MB / OpenAI Whisper - PyTorch)",
            "8": "Base (145MB / OpenAI Whisper - PyTorch)",
            "9": "Small (480MB / OpenAI Whisper - PyTorch)",
            "10": "Medium (1.5GB / OpenAI Whisper - PyTorch)",
            "11": "Turbo (1.6GB / OpenAI Whisper - PyTorch)",
            "12": "Large-v3 (3.1GB / OpenAI Whisper - PyTorch)",
        },
        "step2_title": "[ステップ 2] 使用する演算デバイス(CPU / GPU)を選択してください:",
        "step2_prompt": "デバイス番号を選択 [1~2]",
        "devices": {
            "1": "CPU モード (低スペックPC / 一般ノートPC / 内蔵グラフィック用)",
            "2": "GPU 高速モード (NVIDIA グラフィックカード CUDA加速用)",
        },
        "step3_title": "[ステップ 3] 文字起こしする音声の基本言語を選択してください:",
        "step3_prompt": "言語番号を選択 [1~5]",
        "target_langs": {
            "1": ("auto", "多言語自動検出 (Auto-detect: 英語/日本語/中国語/韓国語など) - デフォルト"),
            "2": ("en", "英語専用 (English)"),
            "3": ("ja", "日本語専用 (Japanese)"),
            "4": ("zh", "中国語専用 (Chinese)"),
            "5": ("ko", "韓国語専用 (Korean)"),
        },
        "default_target_lang": "1",
        "step4_title": "[ステップ 4] 出力ファイル形式を選択してください:",
        "step4_prompt": "形式番号を選択 [1~3]",
        "formats": {
            "1": ("both", "テキストと字幕の両方 (.txt + .srt) (おすすめ)"),
            "2": ("txt", "テキストのみ (.txt)"),
            "3": ("srt", "字幕のみ (.srt)"),
        },
        "sum_ui": "UI 言語     ",
        "sum_env": "Python 環境 ",
        "sum_model": "選択モデル  ",
        "sum_dev": "選択デバイス",
        "sum_lang": "音声言語    ",
        "sum_fmt": "出力形式    ",
        "prog_1": "[1/3] 必須ライブラリをインストール中...",
        "prog_2": "[2/3] recordings フォルダ、transcribe.py、{guide} を生成中...",
        "prog_3": "[3/3] '{model}' モデルを確認中...",
        "model_check_note": "  -> [参考] モデル初期確認メッセージ: {e}",
        "done_1": "セットアップ完了！ 'recordings' フォルダ、'transcribe.py'、'{guide}' が生成されました。",
        "done_2": "'recordings' フォルダに音声ファイルを入れて '{run_file}' を実行してください！",
        "guide_filename": "使い方ガイド.txt",
        "log_filename": "文字起こしログ.txt",
        "out_suffix": "_文字起こし",
        "guide_lines": [
            "====================================================================",
            "         [Whisper 自動音声文字起こしシステム 使い方ガイド]",
            "====================================================================",
            "",
            "* UI 言語     : {ui_name}",
            "* Python 環境 : {env_str}",
            "* モデル      : {m_desc}",
            "* 演算デバイス: {d_desc}",
            "* 音声言語    : {l_desc}",
            "* 出力形式    : {f_desc}",
            "",
            "[使い方]",
            "1. 'recordings' フォルダに変換したい音声ファイル(.mp3, .m4a, .wavなど)を入れます。",
            "2. '{run_file}' を実行します。",
            "3. 処理が完了すると、このフォルダに 'ファイル名{suffix}.txt' や 'ファイル名{suffix}.srt' が自動生成されます。",
            "4. 設定を変更するには、transcribe.py を削除して {run_file} を再実行してください。",
            "====================================================================",
        ],
        "rt_progress": "  -> 進捗: {pct:5.1f}% | セグメント: {idx}個 | 経過: {el}秒 | 速度: {spd:.2f}x | 残り時間: {eta}秒   ",
        "rt_start": "文字起こし開始 (OS: {os} | モデル: {model} | デバイス: {dev} | 言語: {lang} | 形式: {fmt})",
        "rt_no_files": "[案内] recordings フォルダに音声ファイルがありません。ファイルを入れて再実行してください。",
        "rt_found_files": "検出されたファイル数: {n}個",
        "rt_gpu_fallback": "[案内] GPU 初期化失敗({e}) -> CPU(int8) モードに自動切り替えします。",
        "rt_model_loaded": "モデル読み込み完了。",
        "rt_file_item": "[{i}/{total}] ファイル: {name}",
        "rt_skip": "  -> [スキップ] 既に結果ファイルが存在します ({name})",
        "rt_done": "  -> [完了] {name} (所要: {sec:.1f}秒)",
        "rt_fail": "  -> [失敗] エラー: {e}",
        "rt_all_done": "全て完了 | 成功: {ok} | スキップ: {skip} | 失敗: {fail}",
    },
    "zh": {
        "ui_name": "中文 (Chinese)",
        "wiz_title": "[Whisper 自动语音转录系统 - 初始安装向导]",
        "env_step_title": "[环境设置] 请选择 Python 安装环境:",
        "env_opt_1": "创建并使用虚拟环境 (venv) (推荐)",
        "env_opt_2": "直接使用系统全局 Python (无 venv)",
        "env_prompt": "选择环境编号 [1~2]",
        "venv_creating": "  -> 正在创建 Python 虚拟环境 (venv)... (请稍候 10~30 秒)",
        "venv_fail": "[错误] 创建虚拟环境失败，将使用系统全局 Python 继续。",
        "py_env_label": "当前选择的 Python 环境",
        "venv_str": "虚拟环境 (venv)",
        "sys_str": "系统全局 Python",
        "hw_title": "[系统硬件检测与推荐配置]",
        "hw_cpu": "* CPU 核心数 : {cores} 核",
        "hw_ram": "* 系统内存    : {ram} GB",
        "hw_gpu": "* 显卡 (GPU)  : {gpu}",
        "hw_no_gpu": "未检测到 NVIDIA 独立显卡 (CPU 模式)",
        "hw_rec": "  -> 推荐: 模型 [{m_key}] | 设备 [{d_key}]",
        "tag_rec": "(推荐)",
        "default_word": "默认",
        "invalid_input": "[!] 输入无效，请从 {opts} 中选择。",
        "step1_title": "[第1步] 请选择要下载的语音识别模型:",
        "step1_prompt": "选择模型编号 [1~6] (输入 'dev' 可查看 PyTorch 引擎)",
        "dev_mode_banner": "[开发者模式已启用 - 已解锁 PyTorch 引擎]",
        "dev_section_title": "--- 开发者专区 / PyTorch 官方标准引擎 ---",
        "step1_dev_prompt": "选择模型编号 [1~12]",
        "models": {
            "1": "Tiny (75MB / 超低配与测试)",
            "2": "Base (145MB / 普通CPU用)",
            "3": "Small (480MB / 速度与准确率均衡)",
            "4": "Medium (1.5GB / 高准确率)",
            "5": "Turbo (1.6GB / 高速高效)",
            "6": "Large-v3 (3.1GB / 最高品质)",
        },
        "dev_models": {
            "7": "Tiny (75MB / OpenAI Whisper - PyTorch)",
            "8": "Base (145MB / OpenAI Whisper - PyTorch)",
            "9": "Small (480MB / OpenAI Whisper - PyTorch)",
            "10": "Medium (1.5GB / OpenAI Whisper - PyTorch)",
            "11": "Turbo (1.6GB / OpenAI Whisper - PyTorch)",
            "12": "Large-v3 (3.1GB / OpenAI Whisper - PyTorch)",
        },
        "step2_title": "[第2步] 请选择计算设备 (CPU / GPU):",
        "step2_prompt": "选择设备编号 [1~2]",
        "devices": {
            "1": "CPU 模式 (低配电脑 / 普通笔记本 / 集成显卡)",
            "2": "GPU 高速模式 (NVIDIA 独立显卡 CUDA 加速)",
        },
        "step3_title": "[第3步] 请选择要转录的默认音频语言:",
        "step3_prompt": "选择语言编号 [1~5]",
        "target_langs": {
            "1": ("auto", "多语言自动检测 (Auto-detect: 英语/日语/中文/韩语等) - 默认"),
            "2": ("en", "仅英语 (English)"),
            "3": ("ja", "仅日语 (Japanese)"),
            "4": ("zh", "仅中文 (Chinese)"),
            "5": ("ko", "仅韩语 (Korean)"),
        },
        "default_target_lang": "1",
        "step4_title": "[第4步] 请选择输出文件格式:",
        "step4_prompt": "选择格式编号 [1~3]",
        "formats": {
            "1": ("both", "文本与字幕同时生成 (.txt + .srt) (推荐)"),
            "2": ("txt", "仅生成文本 (.txt)"),
            "3": ("srt", "仅生成字幕 (.srt)"),
        },
        "sum_ui": "界面语言   ",
        "sum_env": "Python 环境",
        "sum_model": "所选模型   ",
        "sum_dev": "所选设备   ",
        "sum_lang": "转录语言   ",
        "sum_fmt": "输出格式   ",
        "prog_1": "[1/3] 正在安装必需的依赖库...",
        "prog_2": "[2/3] 正在生成 recordings 文件夹、transcribe.py、{guide}...",
        "prog_3": "[3/3] 正在验证 '{model}' 模型...",
        "model_check_note": "  -> [提示] 模型初始检查信息: {e}",
        "done_1": "安装完成！已生成 'recordings' 文件夹、'transcribe.py' 和 '{guide}'。",
        "done_2": "现在请将音频文件放入 'recordings' 文件夹并运行 '{run_file}'！",
        "guide_filename": "使用说明.txt",
        "log_filename": "转录日志.txt",
        "out_suffix": "_转录本",
        "guide_lines": [
            "====================================================================",
            "             [Whisper 自动语音转录系统 - 使用说明]",
            "====================================================================",
            "",
            "* 界面语言   : {ui_name}",
            "* Python 环境: {env_str}",
            "* 已装模型   : {m_desc}",
            "* 计算设备   : {d_desc}",
            "* 转录语言   : {l_desc}",
            "* 输出格式   : {f_desc}",
            "",
            "[使用方法]",
            "1. 将要转换的音频文件(.mp3, .m4a, .wav等)放入 'recordings' 文件夹中。",
            "2. 运行 '{run_file}'。",
            "3. 处理完成后，当前文件夹下会自动生成 '文件名{suffix}.txt' 与 '文件名{suffix}.srt'。",
            "4. 若需更改配置，请删除 transcribe.py 后重新运行 {run_file}。",
            "====================================================================",
        ],
        "rt_progress": "  -> 进度: {pct:5.1f}% | 片段: {idx}个 | 已用: {el}秒 | 速度: {spd:.2f}x | 剩余: {eta}秒   ",
        "rt_start": "转录任务开始 (OS: {os} | 模型: {model} | 设备: {dev} | 语言: {lang} | 格式: {fmt})",
        "rt_no_files": "[提示] recordings 文件夹中没有音频文件。请放入文件后重新运行。",
        "rt_found_files": "检测到的文件数: {n}个",
        "rt_gpu_fallback": "[提示] GPU 初始化失败({e}) -> 自动切换至 CPU(int8) 模式。",
        "rt_model_loaded": "模型加载完成。",
        "rt_file_item": "[{i}/{total}] 文件: {name}",
        "rt_skip": "  -> [跳过] 结果文件已存在 ({name})",
        "rt_done": "  -> [完成] {name} (耗时: {sec:.1f}秒)",
        "rt_fail": "  -> [失败] 错误: {e}",
        "rt_all_done": "全部完成 | 成功: {ok} | 跳过: {skip} | 失败: {fail}",
    },
    "ko": {
        "ui_name": "한국어 (Korean)",
        "wiz_title": "[Whisper 자동 음성 전사 시스템 - 초기 설치 마법사]",
        "env_step_title": "[환경 설정] Python 설치 환경을 선택하세요:",
        "env_opt_1": "가상 환경(venv) 생성 및 사용 (추천)",
        "env_opt_2": "시스템 기본 Python 직접 사용 (venv 없음)",
        "env_prompt": "환경 번호 선택 [1~2]",
        "venv_creating": "  -> Python 가상 환경(venv) 생성 중... (10~30초 정도 소요될 수 있습니다)",
        "venv_fail": "[오류] 가상 환경(venv) 생성에 실패했습니다. 시스템 기본 Python으로 진행합니다.",
        "py_env_label": "현재 선택된 Python 환경",
        "venv_str": "가상 환경 (venv)",
        "sys_str": "시스템 기본 Python",
        "hw_title": "[시스템 사양 감지 및 추천 설정]",
        "hw_cpu": "* CPU 코어 수 : {cores}개",
        "hw_ram": "* 시스템 RAM  : {ram} GB",
        "hw_gpu": "* 그래픽 (GPU): {gpu}",
        "hw_no_gpu": "NVIDIA 그래픽카드 미검출 (CPU 모드 동작)",
        "hw_rec": "  -> 추천: 모델 [{m_key}] | 연산 장치 [{d_key}]",
        "tag_rec": "(추천)",
        "default_word": "기본값",
        "invalid_input": "[!] 잘못된 입력입니다. {opts} 중에서 선택하세요.",
        "step1_title": "[1단계] 다운로드할 음성 인식 모델을 선택하세요:",
        "step1_prompt": "모델 번호 선택 [1~6] (PyTorch 엔진은 'dev' 입력)",
        "dev_mode_banner": "[개발자 모드 활성화 - PyTorch 엔진 잠금 해제]",
        "dev_section_title": "--- 개발자 모드 / PyTorch 공식 원본 엔진 ---",
        "step1_dev_prompt": "모델 번호 선택 [1~12]",
        "models": {
            "1": "Tiny (75MB / 초저사양·테스트용)",
            "2": "Base (145MB / 일반 CPU용)",
            "3": "Small (480MB / 속도·정확도 균형)",
            "4": "Medium (1.5GB / 고정확도)",
            "5": "Turbo (1.6GB / 고속·고품질)",
            "6": "Large-v3 (3.1GB / 최고품질)",
        },
        "dev_models": {
            "7": "Tiny (75MB / OpenAI Whisper - PyTorch)",
            "8": "Base (145MB / OpenAI Whisper - PyTorch)",
            "9": "Small (480MB / OpenAI Whisper - PyTorch)",
            "10": "Medium (1.5GB / OpenAI Whisper - PyTorch)",
            "11": "Turbo (1.6GB / OpenAI Whisper - PyTorch)",
            "12": "Large-v3 (3.1GB / OpenAI Whisper - PyTorch)",
        },
        "step2_title": "[2단계] 사용할 연산 장치(CPU / GPU)를 선택하세요:",
        "step2_prompt": "장치 번호 선택 [1~2]",
        "devices": {
            "1": "CPU 모드 (일반 PC / 노트북)",
            "2": "GPU 고속 모드 (NVIDIA CUDA)",
        },
        "step3_title": "[3단계] 전사할 음성의 기본 언어를 선택하세요:",
        "step3_prompt": "언어 번호 선택 [1~5]",
        "target_langs": {
            "1": ("auto", "다국어 자동 감지 (Auto-detect: 영/일/중/한 등) - 기본값"),
            "2": ("en", "영어 전용 (English)"),
            "3": ("ja", "일본어 전용 (Japanese)"),
            "4": ("zh", "중국어 전용 (Chinese)"),
            "5": ("ko", "한국어 전용 (Korean)"),
        },
        "default_target_lang": "1",
        "step4_title": "[4단계] 결과 파일 저장 형식을 선택하세요:",
        "step4_prompt": "저장 형식 선택 [1~3]",
        "formats": {
            "1": ("both", "텍스트 + 자막 동시 생성 (.txt + .srt) (추천)"),
            "2": ("txt", "텍스트 파일만 생성 (.txt)"),
            "3": ("srt", "자막 파일만 생성 (.srt)"),
        },
        "sum_ui": "UI 언어     ",
        "sum_env": "Python 환경 ",
        "sum_model": "선택 모델   ",
        "sum_dev": "선택 장치   ",
        "sum_lang": "전사 언어   ",
        "sum_fmt": "저장 형식   ",
        "prog_1": "[1/3] 필수 라이브러리 설치 중...",
        "prog_2": "[2/3] recordings 폴더, transcribe.py, {guide} 생성 중...",
        "prog_3": "[3/3] '{model}' 모델 확인 중...",
        "model_check_note": "  -> [참고] 모델 초기 확인 메시지: {e}",
        "done_1": "설치 완료! 'recordings' 폴더, 'transcribe.py', '{guide}'가 생성되었습니다.",
        "done_2": "이제 'recordings' 폴더에 음성 파일을 넣고 '{run_file}'을 실행하세요!",
        "guide_filename": "사용설명서.txt",
        "log_filename": "전사로그.txt",
        "out_suffix": "_전사본",
        "guide_lines": [
            "====================================================================",
            "             [Whisper 자동 음성 전사 시스템 사용 설명서]",
            "====================================================================",
            "",
            "* UI 언어     : {ui_name}",
            "* Python 환경 : {env_str}",
            "* 설치된 모델 : {m_desc}",
            "* 연산 장치   : {d_desc}",
            "* 기본 언어   : {l_desc}",
            "* 저장 형식   : {f_desc}",
            "",
            "[사용 방법]",
            "1. 'recordings' 폴더 안에 변환할 음성 파일(.mp3, .m4a, .wav 등)을 넣습니다.",
            "2. '{run_file}'을 실행합니다.",
            "3. 작업이 끝나면 현재 폴더에 '파일명{suffix}.txt' 및 '파일명{suffix}.srt' 파일이 자동 생성됩니다.",
            "4. 다른 모델이나 언어로 다시 설정하려면 transcribe.py를 지우고 {run_file}을 실행하세요.",
            "====================================================================",
        ],
        "rt_progress": "  -> 진행률: {pct:5.1f}% | 세그먼트: {idx}개 | 경과: {el}초 | 속도: {spd:.2f}x | 남은시간: {eta}초   ",
        "rt_start": "전사 작업 시작 (OS: {os} | 모델: {model} | 장치: {dev} | 언어: {lang} | 형식: {fmt})",
        "rt_no_files": "[안내] recordings 폴더에 음성 파일이 없습니다. 파일을 넣고 다시 실행하세요.",
        "rt_found_files": "탐색된 파일 수: {n}개",
        "rt_gpu_fallback": "[안내] GPU 초기화 실패({e}) -> CPU(int8) 모드로 자동 전환합니다.",
        "rt_model_loaded": "모델 로딩 완료.",
        "rt_file_item": "[{i}/{total}] 파일: {name}",
        "rt_skip": "  -> [건너뜀] 이미 결과 파일 존재 ({name})",
        "rt_done": "  -> [완료] {name} (소요: {sec:.1f}초)",
        "rt_fail": "  -> [실패] 오류: {e}",
        "rt_all_done": "전체 완료 | 성공: {ok} | 건너뜀: {skip} | 실패: {fail}",
    },
}

MODEL_DEFS = {
    "1": ("tiny", "faster-whisper"),
    "2": ("base", "faster-whisper"),
    "3": ("small", "faster-whisper"),
    "4": ("medium", "faster-whisper"),
    "5": ("large-v3-turbo", "faster-whisper"),
    "6": ("large-v3", "faster-whisper"),
    "7": ("tiny", "openai-whisper"),
    "8": ("base", "openai-whisper"),
    "9": ("small", "openai-whisper"),
    "10": ("medium", "openai-whisper"),
    "11": ("turbo", "openai-whisper"),
    "12": ("large-v3", "openai-whisper"),
}

DEVICE_DEFS = {
    "1": ("cpu", "int8"),
    "2": ("cuda", "float16"),
}

FORMAT_DEFS = {
    "1": "both",
    "2": "txt",
    "3": "srt",
}

def detect_hardware():
    ram_gb = 8.0
    sys_name = platform.system()
    try:
        if sys_name == "Windows":
            import ctypes
            class MEMORYSTATUSEX(ctypes.Structure):
                _fields_ = [
                    ("dwLength", ctypes.c_ulong),
                    ("dwMemoryLoad", ctypes.c_ulong),
                    ("ullTotalPhys", ctypes.c_ulonglong),
                    ("ullAvailPhys", ctypes.c_ulonglong),
                    ("ullTotalPageFile", ctypes.c_ulonglong),
                    ("ullAvailPageFile", ctypes.c_ulonglong),
                    ("ullTotalVirtual", ctypes.c_ulonglong),
                    ("ullAvailVirtual", ctypes.c_ulonglong),
                    ("sullAvailExtendedVirtual", ctypes.c_ulonglong),
                ]
            stat = MEMORYSTATUSEX()
            stat.dwLength = ctypes.sizeof(MEMORYSTATUSEX)
            if ctypes.windll.kernel32.GlobalMemoryStatusEx(ctypes.byref(stat)):
                ram_gb = round(stat.ullTotalPhys / (1024**3), 1)
        elif sys_name == "Darwin":
            out = subprocess.check_output(["sysctl", "-n", "hw.memsize"], encoding="utf-8").strip()
            ram_gb = round(int(out) / (1024**3), 1)
        else:
            ram_gb = round(os.sysconf("SC_PAGE_SIZE") * os.sysconf("SC_PHYS_PAGES") / (1024**3), 1)
    except Exception:
        pass

    cpu_cores = os.cpu_count() or 4
    has_gpu = False
    gpu_name = ""
    vram_gb = 0.0

    is_mac = (sys_name == "Darwin")
    is_apple_silicon = is_mac and platform.machine() in ("arm64", "aarch64")

    if is_apple_silicon:
        gpu_name = f"Apple Silicon ({platform.processor() or 'M-Series'})"
        rec_dev = "1"
        if ram_gb >= 15.0:
            rec_model = "5"
        elif ram_gb >= 7.5:
            rec_model = "3"
        elif ram_gb >= 5.5:
            rec_model = "2"
        else:
            rec_model = "1"
    else:
        try:
            smi = shutil.which("nvidia-smi")
            if smi:
                out = subprocess.check_output(
                    [smi, "--query-gpu=name,memory.total", "--format=csv,noheader,nounits"],
                    encoding="utf-8", stderr=subprocess.DEVNULL
                ).strip()
                if out:
                    line = out.splitlines()[0]
                    parts = line.split(",")
                    gpu_name = parts[0].strip()
                    if len(parts) > 1:
                        vram_mb = float(parts[1].strip())
                        vram_gb = round(vram_mb / 1024.0, 1)
                    has_gpu = True
        except Exception:
            pass

        if has_gpu and vram_gb >= 1.5:
            rec_dev = "2"
            if vram_gb >= 11.0:
                rec_model = "6"
            elif vram_gb >= 6.0:
                rec_model = "5"
            elif vram_gb >= 3.5:
                rec_model = "4"
            elif vram_gb >= 2.0:
                rec_model = "3"
            else:
                rec_model = "2"
        else:
            rec_dev = "1"
            if cpu_cores >= 6 and ram_gb >= 7.5:
                rec_model = "3"
            elif cpu_cores >= 4 and ram_gb >= 5.5:
                rec_model = "2"
            else:
                rec_model = "1"

    return {
        "ram_gb": ram_gb,
        "cpu_cores": cpu_cores,
        "has_gpu": has_gpu,
        "is_apple_silicon": is_apple_silicon,
        "gpu_name": gpu_name,
        "vram_gb": vram_gb,
        "rec_model": rec_model,
        "rec_dev": rec_dev,
    }

def ask(prompt_msg, valid_list, default_val, tr):
    while True:
        ans = input(f"{prompt_msg} ({tr['default_word']} {default_val}): ").strip()
        if not ans:
            return default_val
        if ans in valid_list:
            return ans
        print("  " + tr["invalid_input"].format(opts=", ".join(valid_list)))

def write_transcribe_script(ui_lang, backend, model_name, device, compute_type, lang, out_format, beam_size, tr):
    NL = chr(10)
    lines = [
        "# -*- coding: utf-8 -*-",
        "import os, sys, time, platform, argparse, warnings, logging",
        "from pathlib import Path",
        "from datetime import datetime",
        "from difflib import SequenceMatcher",
        "",
        'os.environ["HF_HUB_DISABLE_SYMLINKS_WARNING"] = "1"',
        'os.environ["HF_HUB_VERBOSITY"] = "error"',
        'warnings.filterwarnings("ignore", message=".*unauthenticated requests.*")',
        'logging.getLogger("huggingface_hub").setLevel(logging.ERROR)',
        "",
        "if hasattr(sys.stdout, 'reconfigure'):",
        "    try: sys.stdout.reconfigure(encoding='utf-8')",
        "    except Exception: pass",
        "",
        "# PyAV(av.open) metadata_errors compatibility patch",
        "try:",
        "    import av",
        "    _orig_av_open = av.open",
        "    def _safe_av_open(*args, **kwargs):",
        "        try:",
        "            return _orig_av_open(*args, **kwargs)",
        "        except TypeError as e:",
        '            if "metadata_errors" in str(e) and "metadata_errors" in kwargs:',
        '                kwargs.pop("metadata_errors", None)',
        "                return _orig_av_open(*args, **kwargs)",
        "            raise",
        "    av.open = _safe_av_open",
        "except Exception:",
        "    pass",
        "",
        f"UI_LANG = {repr(ui_lang)}",
        f"DEFAULT_BACKEND = {repr(backend)}",
        f"DEFAULT_MODEL = {repr(model_name)}",
        f"DEFAULT_DEVICE = {repr(device)}",
        f"DEFAULT_COMPUTE_TYPE = {repr(compute_type)}",
        f"DEFAULT_LANGUAGE = {repr(lang)}",
        f"DEFAULT_OUTPUT_FORMAT = {repr(out_format)}",
        f"DEFAULT_BEAM_SIZE = {beam_size}",
        "",
        "SCRIPT_DIR = Path(__file__).resolve().parent",
        'RECORDINGS_DIR = SCRIPT_DIR / "recordings"',
        f"LOG_PATH = SCRIPT_DIR / {repr(tr['log_filename'])}",
        f"OUT_SUFFIX = {repr(tr['out_suffix'])}",
        'SUPPORTED_EXTENSIONS = {".mp3", ".wav", ".m4a", ".mp4", ".aac", ".flac", ".ogg", ".wma", ".webm"}',
        "SIMILARITY_THRESHOLD = 0.92",
        "PARAGRAPH_GAP_SEC = 2.5",
        "MAX_PARAGRAPH_LEN = 350",
        'SENTENCE_ENDINGS = (".", "!", "?", "。", "！", "？", "다.", "요.", "죠.")',
        "NL = chr(10)",
        "CR = chr(13)",
        "",
        "MSG = {",
        f'    "progress": {repr(tr["rt_progress"])},',
        f'    "start": {repr(tr["rt_start"])},',
        f'    "no_files": {repr(tr["rt_no_files"])},',
        f'    "found_files": {repr(tr["rt_found_files"])},',
        f'    "gpu_fallback": {repr(tr["rt_gpu_fallback"])},',
        f'    "model_loaded": {repr(tr["rt_model_loaded"])},',
        f'    "file_item": {repr(tr["rt_file_item"])},',
        f'    "skip": {repr(tr["rt_skip"])},',
        f'    "done": {repr(tr["rt_done"])},',
        f'    "fail": {repr(tr["rt_fail"])},',
        f'    "all_done": {repr(tr["rt_all_done"])},',
        "}",
        "",
        "def write_log(msg, print_console=True):",
        '    ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")',
        '    line = f"[{ts}] {msg}"',
        "    if print_console: print(line)",
        "    try:",
        '        with open(LOG_PATH, "a", encoding="utf-8") as f:',
        "            f.write(line + NL)",
        "    except Exception: pass",
        "",
        "def setup_windows_cuda_dlls():",
        '    if platform.system() != "Windows": return',
        "    try:",
        "        import site",
        "        sps = site.getsitepackages()",
        '        if hasattr(site, "getusersitepackages"): sps.append(site.getusersitepackages())',
        "        for sp in sps:",
        '            for sub in [Path("nvidia")/"cublas"/"bin", Path("nvidia")/"cudnn"/"bin"]:',
        "                d = Path(sp) / sub",
        "                if d.exists():",
        '                    if hasattr(os, "add_dll_directory"): os.add_dll_directory(str(d))',
        '                    os.environ["PATH"] = str(d) + os.pathsep + os.environ.get("PATH", "")',
        "    except Exception: pass",
        "",
        "def format_ts(sec):",
        "    s = max(0, int(sec))",
        "    h, rem = divmod(s, 3600)",
        "    m, s = divmod(rem, 60)",
        '    return f"{h:02d}:{m:02d}:{s:02d}" if h > 0 else f"{m:02d}:{s:02d}"',
        "",
        "def format_srt_ts(sec):",
        "    sec = max(0.0, float(sec))",
        "    s = int(sec)",
        "    ms = int(round((sec - s) * 1000))",
        "    if ms >= 1000:",
        "        s += 1",
        "        ms = 0",
        "    h, rem = divmod(s, 3600)",
        "    m, s = divmod(rem, 60)",
        '    return f"{h:02d}:{m:02d}:{s:02d},{ms:03d}"',
        "",
        "def generate_srt(filtered):",
        '    if not filtered: return ""',
        "    lines = []",
        "    for idx, seg in enumerate(filtered, 1):",
        "        st = format_srt_ts(seg['start'])",
        "        ed = format_srt_ts(seg['end'])",
        "        tx = seg['text']",
        '        lines.append(f"{idx}{NL}{st} --> {ed}{NL}{tx}{NL}")',
        "    return NL.join(lines)",
        "",
        "def post_process(raw_segs, duration, t0):",
        "    filtered, prev = [], ''",
        "    for idx, seg in enumerate(raw_segs, 1):",
        '        st = seg.start if hasattr(seg, "start") else seg.get("start", 0.0)',
        '        ed = seg.end if hasattr(seg, "end") else seg.get("end", 0.0)',
        '        tx = (seg.text if hasattr(seg, "text") else seg.get("text", "")).strip()',
        "        if not tx: continue",
        "        el = max(0.001, time.time() - t0)",
        "        spd = ed / el if ed > 0 else 0.0",
        "        if duration > 0 and spd > 0:",
        "            eta = int(max(0.0, duration - ed) / spd)",
        "            pct = min(100.0, (ed / duration) * 100)",
        '            print(CR + MSG["progress"].format(pct=pct, idx=idx, el=int(el), spd=spd, eta=eta), end="", flush=True)',
        "        if prev and SequenceMatcher(None, prev, tx).ratio() >= SIMILARITY_THRESHOLD: continue",
        '        filtered.append({"start": st, "end": ed, "text": tx})',
        "        prev = tx",
        "    print()",
        '    if not filtered: return [], ""',
        "    paras, c_st, c_ed, c_tx = [], filtered[0]['start'], filtered[0]['end'], [filtered[0]['text']]",
        "    for s in filtered[1:]:",
        "        joined = ' '.join(c_tx)",
        "        if (s['start'] - c_ed) >= PARAGRAPH_GAP_SEC or (len(joined) >= MAX_PARAGRAPH_LEN and joined.endswith(SENTENCE_ENDINGS)):",
        '            paras.append(f"[{format_ts(c_st)} - {format_ts(c_ed)}] {joined}")',
        "            c_st, c_tx = s['start'], [s['text']]",
        "        else: c_tx.append(s['text'])",
        "        c_ed = s['end']",
        "    if c_tx:",
        "        joined_last = ' '.join(c_tx)",
        '        paras.append(f"[{format_ts(c_st)} - {format_ts(c_ed)}] {joined_last}")',
        "    return filtered, (NL + NL).join(paras)",
        "",
        "def main():",
        "    setup_windows_cuda_dlls()",
        "    RECORDINGS_DIR.mkdir(parents=True, exist_ok=True)",
        '    write_log("=" * 60)',
        '    write_log(MSG["start"].format(os=platform.system(), model=DEFAULT_MODEL, dev=DEFAULT_DEVICE, lang=DEFAULT_LANGUAGE, fmt=DEFAULT_OUTPUT_FORMAT))',
        "    files = sorted([f for f in RECORDINGS_DIR.iterdir() if f.is_file() and f.suffix.lower() in SUPPORTED_EXTENSIONS])",
        "    if not files:",
        '        write_log(MSG["no_files"])',
        "        return",
        '    write_log(MSG["found_files"].format(n=len(files)))',
        "    dev, comp = DEFAULT_DEVICE, DEFAULT_COMPUTE_TYPE",
        '    if DEFAULT_BACKEND == "faster-whisper":',
        "        from faster_whisper import WhisperModel",
        "        try:",
        "            model = WhisperModel(DEFAULT_MODEL, device=dev, compute_type=comp)",
        "        except Exception as e1:",
        '            if dev == "cuda" and comp != "int8":',
        "                try:",
        '                    write_log(f"  -> GPU(float16) fallback to GPU(int8)...")',
        '                    comp = "int8"',
        '                    model = WhisperModel(DEFAULT_MODEL, device="cuda", compute_type="int8")',
        "                except Exception as e2:",
        '                    write_log(MSG["gpu_fallback"].format(e=f"{e1} / {e2}"))',
        '                    dev, comp = "cpu", "int8"',
        '                    model = WhisperModel(DEFAULT_MODEL, device="cpu", compute_type="int8")',
        "            else:",
        '                write_log(MSG["gpu_fallback"].format(e=e1))',
        '                dev, comp = "cpu", "int8"',
        '                model = WhisperModel(DEFAULT_MODEL, device="cpu", compute_type="int8")',
        "    else:",
        "        import whisper",
        '        if dev == "cuda":',
        "            try:",
        "                import torch",
        "                if not torch.cuda.is_available():",
        '                    write_log(MSG["gpu_fallback"].format(e="CUDA not available"))',
        '                    dev = "cpu"',
        "            except Exception:",
        "                pass",
        "        try:",
        "            model = whisper.load_model(DEFAULT_MODEL, device=dev)",
        "        except Exception as e:",
        '            write_log(MSG["gpu_fallback"].format(e=e))',
        '            dev = "cpu"',
        '            model = whisper.load_model(DEFAULT_MODEL, device="cpu")',
        '    write_log(MSG["model_loaded"])',
        "    ok, skip, fail = 0, 0, 0",
        "    for i, fpath in enumerate(files, 1):",
        '        txt_out = SCRIPT_DIR / f"{fpath.stem}{OUT_SUFFIX}.txt"',
        '        srt_out = SCRIPT_DIR / f"{fpath.stem}{OUT_SUFFIX}.srt"',
        "        needed = []",
        '        if DEFAULT_OUTPUT_FORMAT in ("both", "txt"): needed.append(txt_out)',
        '        if DEFAULT_OUTPUT_FORMAT in ("both", "srt"): needed.append(srt_out)',
        '        write_log(MSG["file_item"].format(i=i, total=len(files), name=fpath.name))',
        "        if all(p.exists() and p.stat().st_size > 0 for p in needed):",
        '            write_log(MSG["skip"].format(name=fpath.name))',
        "            skip += 1; continue",
        "        t0 = time.time()",
        "        try:",
        '            lang_arg = None if DEFAULT_LANGUAGE == "auto" else DEFAULT_LANGUAGE',
        '            if DEFAULT_BACKEND == "faster-whisper":',
        "                segs, info = model.transcribe(str(fpath), language=lang_arg, beam_size=DEFAULT_BEAM_SIZE, vad_filter=True, condition_on_previous_text=False)",
        '                dur = getattr(info, "duration", 0.0)',
        "            else:",
        '                res = model.transcribe(str(fpath), language=lang_arg, beam_size=DEFAULT_BEAM_SIZE, fp16=(dev=="cuda"), condition_on_previous_text=False)',
        '                segs = res.get("segments", [])',
        '                dur = segs[-1]["end"] if segs else 0.0',
        "            filtered, txt = post_process(segs, dur, t0)",
        '            if DEFAULT_OUTPUT_FORMAT in ("both", "txt"):',
        '                tmp_txt = SCRIPT_DIR / f"{fpath.stem}{OUT_SUFFIX}.txt.tmp"',
        '                with open(tmp_txt, "w", encoding="utf-8") as out_f:',
        "                    out_f.write(txt + NL)",
        "                tmp_txt.replace(txt_out)",
        '            if DEFAULT_OUTPUT_FORMAT in ("both", "srt"):',
        "                srt_str = generate_srt(filtered)",
        '                tmp_srt = SCRIPT_DIR / f"{fpath.stem}{OUT_SUFFIX}.srt.tmp"',
        '                with open(tmp_srt, "w", encoding="utf-8") as out_f:',
        "                    out_f.write(srt_str + NL)",
        "                tmp_srt.replace(srt_out)",
        '            done_names = ", ".join([p.name for p in needed])',
        '            write_log(MSG["done"].format(name=done_names, sec=time.time()-t0))',
        "            ok += 1",
        "        except Exception as e:",
        '            write_log(MSG["fail"].format(e=e))',
        "            fail += 1",
        '    write_log(MSG["all_done"].format(ok=ok, skip=skip, fail=fail))',
        "",
        'if __name__ == "__main__": main()'
    ]
    with open(TRANSCRIBE_PATH, "w", encoding="utf-8") as f:
        f.write(NL.join(lines) + NL)

def main():
    is_dev = any(arg in sys.argv for arg in ["--dev", "-dev", "--advanced", "--expert"])

    print("=" * 68)
    print("   [Whisper Auto Transcriber - Initial Setup Wizard]")
    print("=" * 68)
    print("\nSelect UI Language / 言語選択 / 选择界面语言 / 인터페이스 언어 선택:")
    print("  [1] English (Default)")
    print("  [2] 日本語 (Japanese)")
    print("  [3] 中文 (Chinese)")
    print("  [4] 한국어 (Korean)")
    while True:
        ans = input("\nSelect [1~4] (Default 1): ").strip()
        if not ans:
            ui_choice = "1"
            break
        if ans in UI_LANG_MAP:
            ui_choice = ans
            break
        print("  [!] Please select 1, 2, 3, or 4.")

    ui_lang = UI_LANG_MAP[ui_choice]
    tr = I18N[ui_lang]

    print("\n" + "-" * 68)
    print(tr["env_step_title"])
    print(f"  [1] {tr['env_opt_1']}")
    print(f"  [2] {tr['env_opt_2']}")
    env_choice = ask("\n" + tr["env_prompt"], ["1", "2"], "1", tr)

    target_py = sys.executable
    is_venv = False
    if env_choice == "1":
        if FLAG_SYSTEM_PY.exists():
            try: FLAG_SYSTEM_PY.unlink()
            except Exception: pass
        if not VENV_PY.exists():
            print("\n" + tr["venv_creating"])
            try:
                subprocess.check_call([sys.executable, "-m", "venv", str(VENV_DIR)])
            except Exception:
                pass
        if VENV_PY.exists():
            target_py = str(VENV_PY)
            is_venv = True
        else:
            print(tr["venv_fail"])
    else:
        try:
            FLAG_SYSTEM_PY.write_text("1", encoding="utf-8")
        except Exception:
            pass

    env_str = tr["venv_str"] if is_venv else tr["sys_str"]
    print("\n" + "=" * 68)
    print("   " + tr["wiz_title"])
    print(f"   * {tr['py_env_label']} : {env_str}")
    print("=" * 68)

    # Hardware Detection & Auto-Recommendation
    hw = detect_hardware()
    if hw.get("is_apple_silicon"):
        gpu_desc = f"{hw['gpu_name']} - Unified Memory {hw['ram_gb']} GB"
    elif hw["has_gpu"]:
        gpu_desc = f"{hw['gpu_name']} ({hw['vram_gb']} GB VRAM)"
    else:
        gpu_desc = tr["hw_no_gpu"]

    print("\n" + tr["hw_title"])
    print(tr["hw_cpu"].format(cores=hw["cpu_cores"]))
    print(tr["hw_ram"].format(ram=hw["ram_gb"]))
    print(tr["hw_gpu"].format(gpu=gpu_desc))
    print(tr["hw_rec"].format(m_key=hw["rec_model"], d_key=hw["rec_dev"]))
    print("-" * 68)

    rec_m = hw["rec_model"]
    rec_d = hw["rec_dev"]

    while True:
        print("\n" + tr["step1_title"])
        for k in ["1", "2", "3", "4", "5", "6"]:
            mark = f" {tr['tag_rec']}" if k == rec_m else ""
            print(f"  [{k}] {tr['models'][k]}{mark}")
        if is_dev:
            print("\n  " + tr["dev_section_title"])
            for k in ["7", "8", "9", "10", "11", "12"]:
                print(f"  [{k}] {tr['dev_models'][k]}")

        prompt_str = tr["step1_dev_prompt"] if is_dev else tr["step1_prompt"]
        valid_keys = list(MODEL_DEFS.keys()) if is_dev else ["1", "2", "3", "4", "5", "6"]

        ans = input(f"\n{prompt_str} ({tr['default_word']} {rec_m}): ").strip()
        if not ans:
            m_key = rec_m
            break
        if ans.lower() in ("dev", "--dev", "expert", "advanced") and not is_dev:
            is_dev = True
            print("\n" + tr["dev_mode_banner"])
            continue
        if ans in valid_keys:
            m_key = ans
            break
        print("  " + tr["invalid_input"].format(opts=", ".join(valid_keys)))

    m_name, m_backend = MODEL_DEFS[m_key]
    m_desc = tr["dev_models"][m_key] if int(m_key) >= 7 else tr["models"][m_key]

    print("\n" + "-" * 68)
    print(tr["step2_title"])
    for k in DEVICE_DEFS:
        mark = f" {tr['tag_rec']}" if k == rec_d else ""
        print(f"  [{k}] {tr['devices'][k]}{mark}")

    d_key = ask("\n" + tr["step2_prompt"], list(DEVICE_DEFS.keys()), rec_d, tr)
    d_dev, d_comp = DEVICE_DEFS[d_key]
    d_desc = tr["devices"][d_key]

    print("\n" + "-" * 68)
    print(tr["step3_title"])
    for k, v in tr["target_langs"].items():
        print(f"  [{k}] {v[1]}")
    l_key = ask("\n" + tr["step3_prompt"], list(tr["target_langs"].keys()), tr["default_target_lang"], tr)
    l_code, l_desc = tr["target_langs"][l_key]

    print("\n" + "-" * 68)
    print(tr["step4_title"])
    for k, v in tr["formats"].items():
        print(f"  [{k}] {v[1]}")
    f_key = ask("\n" + tr["step4_prompt"], list(tr["formats"].keys()), "1", tr)
    f_code, f_desc = tr["formats"][f_key]

    beam = 2 if (m_name in ("tiny", "base") and d_dev == "cpu") else 5

    print("\n" + "=" * 68)
    print(f" -> {tr['sum_ui']}: {tr['ui_name']}")
    print(f" -> {tr['sum_env']}: {env_str}")
    print(f" -> {tr['sum_model']}: {m_desc}")
    print(f" -> {tr['sum_dev']}: {d_desc}")
    print(f" -> {tr['sum_lang']}: {l_desc}")
    print(f" -> {tr['sum_fmt']}: {f_desc}")
    print("=" * 68)

    print("\n" + tr["prog_1"])
    subprocess.check_call([target_py, "-m", "pip", "install", "--upgrade", "pip", "-q"])
    if m_backend == "faster-whisper":
        pkgs = ["faster-whisper"]
        if d_dev == "cuda" and platform.system() in ("Windows", "Linux"):
            pkgs += ["nvidia-cublas-cu12", "nvidia-cudnn-cu12"]
        subprocess.check_call([target_py, "-m", "pip", "install"] + pkgs)
    else:
        subprocess.check_call([target_py, "-m", "pip", "install", "openai-whisper"])

    guide_fname = tr["guide_filename"]
    guide_path = BASE_DIR / guide_fname
    print("\n" + tr["prog_2"].format(guide=guide_fname))
    RECORDINGS_DIR.mkdir(parents=True, exist_ok=True)
    write_transcribe_script(ui_lang, m_backend, m_name, d_dev, d_comp, l_code, f_code, beam, tr)

    # Clean up old guide files in other languages
    for old_g in ["사용설명서.txt", "user_guide.txt", "使い方ガイド.txt", "使用说明.txt"]:
        if old_g != guide_fname:
            old_p = BASE_DIR / old_g
            if old_p.exists():
                try: old_p.unlink()
                except Exception: pass

    if platform.system() == "Windows":
        run_file = "start.bat"
    elif platform.system() == "Darwin":
        run_file = "start_mac.command"
    else:
        run_file = "./start_linux.sh"

    NL = chr(10)
    guide_text = NL.join(tr["guide_lines"]).format(
        ui_name=tr["ui_name"],
        env_str=env_str,
        m_desc=m_desc,
        d_desc=d_desc,
        l_desc=l_desc,
        f_desc=f_desc,
        suffix=tr["out_suffix"],
        run_file=run_file,
    ) + NL
    with open(guide_path, "w", encoding="utf-8") as gf:
        gf.write(guide_text)

    print("\n" + tr["prog_3"].format(model=m_name))
    try:
        if m_backend == "faster-whisper":
            chk_cmd = f"import os, warnings, logging; os.environ['HF_HUB_DISABLE_SYMLINKS_WARNING']='1'; os.environ['HF_HUB_VERBOSITY']='error'; warnings.filterwarnings('ignore', message='.*unauthenticated requests.*'); logging.getLogger('huggingface_hub').setLevel(logging.ERROR); from faster_whisper import WhisperModel; WhisperModel({repr(m_name)}, device='cpu', compute_type='int8')"
        else:
            chk_cmd = f"import whisper; whisper.load_model({repr(m_name)}, device='cpu')"
        subprocess.check_call([target_py, "-c", chk_cmd])
    except Exception as e:
        print(tr["model_check_note"].format(e=e))

    print("\n" + "=" * 68)
    print(tr["done_1"].format(guide=guide_fname))
    print(tr["done_2"].format(run_file=run_file))
    print("=" * 68)

if __name__ == "__main__":
    main()

###WIZARD_EOF###

    "$PY_CMD" "$WIZ_PY" "$@"
    rm -f "$WIZ_PY"
    trap - EXIT INT TERM
    echo ""
    read -n 1 -s -r -p "Press any key to exit..." || true
    echo ""
    exit 0
fi

# Run Mode
if [[ ! -f ".use_system_py" && -f "$VENV_PY" ]]; then
    "$VENV_PY" transcribe.py "$@"
else
    "$PY_CMD" transcribe.py "$@"
fi

echo ""
read -n 1 -s -r -p "Press any key to exit..." || true
echo ""
exit 0
