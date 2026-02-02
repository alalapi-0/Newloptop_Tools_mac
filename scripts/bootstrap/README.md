# scripts/bootstrap

用于放置新机初始化、环境引导相关脚本。

## Step 规范
- 每个 step 脚本以两位序号开头，例如 `01_xcode_clt.sh`。
- 文件名与 step 名称对应（去掉序号与扩展名），例如 `xcode_clt`。
- 由 `bin/setup` 统一调度，支持 `--dry-run`、`--only`、`--skip`。
- 每个 step 都应保持幂等与可读性，优先输出操作说明与验证命令。

## 清单文件格式
- 逐行读取包名/应用名。
- 忽略空行。
- 忽略以 `#` 开头的注释行（含行内注释）。

## 当前 step 顺序
1. xcode_clt
2. homebrew
3. packages_cli
4. packages_media
5. apps_cask
6. git
7. python
