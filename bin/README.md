# bin 目录

此目录用于放置可直接执行的入口脚本。

## setup

统一入口脚本，用于引导 macOS 新机环境配置。当前阶段以“引导与框架”为主，不会强制自动化安装。

**使用示例：**
```bash
./bin/setup --help
./bin/setup --dry-run
./bin/setup --only homebrew
./bin/setup --skip apps_cask
./bin/setup --yes
```

**日志：**
- 默认写入仓库根目录的 `logs/`，文件名格式为 `setup_YYYYmmdd_HHMMSS.log`。
- 可用 `--log-dir` 指定其他目录。
