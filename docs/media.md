# 音视频工具箱（bin/media）

> 仅面向 macOS。依赖：`ffmpeg`、`ffprobe`、`mediainfo`。
> 建议先执行：`./bin/setup --only packages_media` 或参考 `docs/SETUP_MAC.md` 手动安装。

## 总览

- 统一入口：`./bin/media <command> [options]`
- 默认输出目录：仓库根目录 `out/`（不存在会自动创建）。
- 默认日志目录：`logs/`，日志文件名：`media_YYYYmmdd_HHMMSS.log`。
- 输出文件若已存在会自动改名（例如 `name.mp4` -> `name_2.mp4`）。
- 所有子命令支持 `--help`、`--dry-run`、`--out`/`--out-dir`。

## 命令：probe

查看媒体信息，支持 `json` 与 `txt`。

- `txt`：使用 `mediainfo`
- `json`：使用 `ffprobe`

### 示例

```bash
./bin/media probe --in demo.mp4
./bin/media probe --in demo.mp4 --format json
./bin/media probe --in demo.mp4 --format txt --out out/demo_info.txt
```

### 输出规则

- 未指定 `--out` 时，自动生成：`out/<basename>_probe.<ext>`。
- `--format json` 输出 `.json`，`--format txt` 输出 `.txt`。

## 命令：cut

按时间戳切片，支持单文件与批处理任务文件。

### 时间戳格式

- `HH:MM:SS`
- `HH:MM:SS.mmm`
- `MM:SS`（视为 `00:MM:SS`）

### 注意事项

- 默认 `-c copy` 尽量无损，但受关键帧影响可能存在起止偏移。
- 如需更精确切片，请使用 `--reencode 1`（h264+aac）。

### 示例（单文件）

```bash
./bin/media cut --in demo.mp4 --start 00:01:10 --end 00:02:00
./bin/media cut --in demo.mp4 --start 01:10 --end 02:00 --reencode 1
./bin/media cut --in demo.mp4 --start 00:00:05 --end 00:00:15 --out out/intro.mp4
```

### 示例（批处理 tasks.txt）

```bash
./bin/media cut --tasks tasks.txt
./bin/media cut --tasks tasks.txt --out-dir out/cuts
./bin/media cut --tasks tasks.txt --reencode 1 --dry-run
```

### tasks.txt 格式

- 每行一条任务，字段用 **TAB** 分隔（推荐）或 `|` 分隔。
- 允许空行与以 `#` 开头的注释行。
- 字段：`input_path<TAB>start<TAB>end<TAB>output_name(optional)`

示例：

```text
# input_path<TAB>start<TAB>end<TAB>output_name(optional)
./videos/demo.mp4	00:00:05	00:00:15	intro
./videos/demo.mp4	00:01:10	00:02:00	
./videos/other.mov	01:10	02:00	clip_b
```

### 输出规则

- 未指定 `--out` 时，自动生成：`out/<basename>_cut_<start>-<end>.mp4`。
- 批处理时，若提供 `output_name`，将输出为：`out/<output_name>.mp4`（自动补 `.mp4`）。

## 命令：extract-audio

从视频抽取音频（默认尽量不重编码）。

- `m4a`：优先 `-c:a copy`
- `wav`：`pcm_s16le`
- `mp3`：`libmp3lame`（默认 `192k`）

### 示例

```bash
./bin/media extract-audio --in demo.mp4
./bin/media extract-audio --in demo.mp4 --format wav
./bin/media extract-audio --in demo.mp4 --format mp3 --out out/demo.mp3
```

### 输出规则

- 未指定 `--out` 时，自动生成：`out/<basename>_audio.<ext>`。

## 命令：transcode

统一转码为 mp4（h264 + aac），适配常见播放器与剪辑软件。

### 示例

```bash
./bin/media transcode --in demo.mov
./bin/media transcode --in demo.mov --preset fast --crf 20
./bin/media transcode --in demo.mov --audio-bitrate 256k --out out/demo_h264.mp4
```

### 输出规则

- 未指定 `--out` 时，自动生成：`out/<basename>_h264.mp4`。

## 命令：concat（可选）

将多个片段拼接为一个视频，使用 ffmpeg concat demuxer（默认 `-c copy`）。

### 示例

```bash
./bin/media concat --list list.txt
./bin/media concat --list list.txt --out out/merged.mp4
./bin/media concat --list list.txt --dry-run
```

### list.txt 格式

- 每行一个文件路径（可相对路径）。
- 允许空行与以 `#` 开头的注释行。

示例：

```text
# 每行一个文件路径
./out/part1.mp4
./out/part2.mp4
./out/part3.mp4
```

## 常见报错与解决

1. **`ffmpeg not found` / `mediainfo not found`**
   - 先执行：`./bin/setup --only packages_media` 或参考 `docs/SETUP_MAC.md` 手动安装。
2. **`Input not found` / `No such file`**
   - 检查 `--in` 或任务文件路径是否正确，建议用绝对路径或确认当前目录。
3. **`Invalid --format` / `Invalid --preset`**
   - 使用 `--help` 查看可选值，确保参数拼写正确。
4. **输出文件已存在**
   - 工具会自动改名（例如 `_2`、`_3`），不会覆盖原文件。
5. **concat 失败（编码不一致）**
   - `concat` 需要输入文件编码参数一致，先用 `transcode` 统一为 h264+aac。
