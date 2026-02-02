# macOS 新机完整配置步骤（按顺序执行）

## 开始前说明
- 适用系统：macOS（Apple Silicon 或 Intel）。
- 需要权限：部分命令会提示输入密码，输入时终端不会显示任何字符，这是正常现象。
- 过程中如果出现错误，请先停止并解决，再继续下一步。
- 建议在稳定网络环境下执行。

## 脚本模式说明（可选）
- 当前脚本模式已支持自动执行以下步骤：xcode_clt、homebrew、packages_cli。
- 其他步骤仍以本手册中的手动命令为准。
- 从桌面执行的推荐方式：
  1. 在终端进入仓库目录（例如 `cd ~/Desktop/Newloptop_Tools_mac`）。
  2. 如有需要，赋予可执行权限：`chmod +x ./bin/setup`。
  3. 先进行 dry-run：`./bin/setup --dry-run`。
  4. 示例：指定 profile 安装 CLI 包 `./bin/setup --profile default --only packages_cli`。

---

## 1. 安装 Xcode Command Line Tools

**本步骤做什么：** 安装编译工具与基础命令行组件，后续 Homebrew 与编译依赖均需要。

**需要执行的命令：**
```bash
xcode-select --install
```

**验证命令：**
```bash
xcode-select -p
clang --version
```

**常见错误/注意事项：**
- 弹窗安装完成后才算成功，若提示已安装可直接进入下一步。

---

## 2. 安装 Homebrew

**本步骤做什么：** 安装 macOS 常用包管理器，并配置 shell 环境。

**需要执行的命令：**
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**然后配置 shellenv（按 CPU 类型选择一条执行）：**
- Apple Silicon：
```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```
- Intel：
```bash
echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/usr/local/bin/brew shellenv)"
```

**验证命令：**
```bash
brew --version
brew doctor
brew update
```

**常见错误/注意事项：**
- 若 `brew doctor` 给出建议，请先修复再继续。

---

## 3. 安装 Git 并完成基础配置

**本步骤做什么：** 安装 Git 并设置全局用户信息。

**需要执行的命令：**
```bash
brew install git
git config --global user.name "你的名字"
git config --global user.email "you@example.com"
```

**验证命令：**
```bash
git --version
git config --global -l
```

**常见错误/注意事项：**
- 请将示例姓名与邮箱替换为你的真实信息。

---

## 4. 安装常用命令行工具

**本步骤做什么：** 一次性安装常用 CLI 工具与 GNU 版本增强命令。

**需要执行的命令：**
```bash
brew install wget curl aria2 jq ripgrep fd bat tree htop tmux watch \
  coreutils gnu-sed gawk findutils p7zip unar zstd
```

**验证命令：**
```bash
rg --version
fd --version
bat --version
```

**常见错误/注意事项：**
- 若某个包安装失败，先单独重试该包再继续。

---

## 5. 安装视频/文件处理工具

**本步骤做什么：** 安装音视频处理与文件元信息工具。

**需要执行的命令：**
```bash
brew install ffmpeg mediainfo imagemagick exiftool
```

**（可选）安装下载工具：**
```bash
brew install yt-dlp
```

**验证命令：**
```bash
ffmpeg -version
mediainfo --Version
magick -version
exiftool -ver
```

**常见错误/注意事项：**
- `magick` 命令来自 ImageMagick，若提示不存在请重新安装。

---

## 6. 安装常用 GUI 软件

**本步骤做什么：** 安装常用桌面应用。

**需要执行的命令：**
```bash
brew install --cask iina google-chrome wechat dingtalk pycharm visual-studio-code iterm2 keka
```

**验证命令：**
```bash
brew list --cask
```

**常见错误/注意事项：**
- 若 cask 安装被系统拦截，请在“系统设置 -> 隐私与安全”中允许。

---

## 7. Python 开发环境（推荐 pyenv）

**本步骤做什么：** 安装 pyenv 并配置默认 Python 版本。

**需要执行的命令：**
```bash
brew install pyenv
cat >> ~/.zshrc <<'PYENV'
# pyenv 初始化
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi
PYENV
source ~/.zshrc
pyenv install 3.12.8
pyenv global 3.12.8
python -m pip install --upgrade pip
```

**验证命令：**
```bash
pyenv --version
python --version
which python
pip --version
```

**常见错误/注意事项：**
- `pyenv install` 可能耗时较久，请耐心等待完成。

---

## 8. （可选）导出 Brewfile 方便下次复现

**本步骤做什么：** 将当前 Homebrew 包清单导出并验证可复现。

**需要执行的命令：**
```bash
brew bundle dump --file=~/Brewfile --force
brew bundle --file=~/Brewfile
```

**验证命令：**
```bash
ls -l ~/Brewfile
```

**常见错误/注意事项：**
- 若提示缺少包，请先完成前面步骤再导出。

---

## 快速自检清单（全部通过即可）
```bash
xcode-select -p
brew --version
git --version
rg --version
ffmpeg -version
mediainfo --Version
magick -version
exiftool -ver
pyenv --version
python --version
```
