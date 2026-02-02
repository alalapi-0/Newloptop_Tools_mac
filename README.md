# Newloptop_Tools_mac

面向 macOS 新机到手后的环境配置与常用脚本工具箱。

## 最短开始路径
- 直接按顺序执行完整配置文档：`docs/SETUP_MAC.md`

## 脚本模式（可选）
- 推荐顺序：先阅读 `docs/SETUP_MAC.md`，脚本模式用于自动化与引导。
- 当前已支持自动化步骤：xcode_clt、homebrew、packages_cli。
- 示例命令：
  - `./bin/setup --help`
  - `./bin/setup --dry-run`
  - `./bin/setup --only homebrew`
  - `./bin/setup --skip apps_cask`
  - `./bin/setup --yes`
  - `./bin/setup --profile default --only packages_cli`
- 日志说明：默认在 `logs/` 生成带时间戳的运行日志。

## 文档索引
- `docs/README.md`：文档导航与说明
- `docs/SETUP_MAC.md`：新机完整配置步骤（按顺序复制执行）

## 目录结构（简要）
- `docs/`：文档与使用说明
- `bin/`：未来提供可直接运行的入口脚本
- `scripts/`：按领域拆分的脚本工具箱
- `config/`：配置模板与包清单
- `tests/`：测试与校验脚本

## 约束与原则
- 仅面向 macOS。
- 不提交任何二进制或媒体文件。
- 后续脚本保证幂等，建议先 dry-run。
- 以终端命令为主，文档可直接复制执行。

## Roadmap
- `bin/setup`：一键基础环境配置入口
- `bin/media`：常用音视频处理封装
- `bin/doctor`：环境自检与修复建议
- `scripts/media/`：批量转码、压缩、裁剪
- `scripts/utils/`：文件整理、批量改名、校验
