<div align="center">

<h1>📦 百度网盘绿色清洁版</h1>

<p><strong>Baidu Netdisk Portable Launcher for Windows</strong></p>

<p>少一些更新打扰，多一些目录自主。</p>

<p>
  <img src="https://img.shields.io/badge/Windows-11_x64-0078D4?style=flat-square" alt="已验证系统：Windows 11 x64" />
  <img src="https://img.shields.io/badge/Client-7.36.0.3_x86-2563EB?style=flat-square" alt="已验证客户端：7.36.0.3，32 位" />
  <img src="https://img.shields.io/badge/Status-Experimental-F59E0B?style=flat-square" alt="状态：实验版" />
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-16A34A?style=flat-square" alt="自编组件许可证：MIT" /></a>
</p>

<p>
  <a href="https://github.com/HAN-Programming/BaiduNetdisk-portable/releases"><img src="https://img.shields.io/badge/Download-Releases-2563EB?style=for-the-badge&amp;logo=github&amp;logoColor=white" alt="前往 Releases 下载启动器与保护组件" /></a>
</p>

<p>
  <a href="#quick-start">🚀 开始使用</a> ·
  <a href="docs/PORTABILITY.md">📖 使用条件</a> ·
  <a href="https://github.com/HAN-Programming/BaiduNetdisk-portable/issues">💬 问题反馈</a>
</p>

</div>

**百度网盘（Baidu Netdisk / BaiduYun）Windows 便携版本**，用于搭建免安装的客户端运行目录。通过进程内保护组件限制当前版本的自动更新，并将常见的配置、缓存和临时文件重定向到便携目录。

网盘承载了许多学习资料与日常文件。这个项目希望让使用过程更可控：减少自动更新干扰，把运行数据集中保存，让客户端专注于文件管理与下载。

## ✨ 你能获得什么

| 能力 | 实际作用 |
| --- | --- |
| 📦 便携启动 | 准备好匹配的客户端文件后，双击图形启动器运行，无需安装启动器、Python 或管理员权限 |
| 🛑 限制自动更新 | 针对已验证版本，从更新接口、子进程启动和程序文件保护三个环节进行限制 |
| 🗂️ 集中运行数据 | 重定向常见用户目录；对允许目录之外的其他写入返回拒绝访问 |
| 🔎 源码可查看 | 公开启动器、保护组件、依赖源码与说明，便于了解实现和复现构建 |

<a name="quick-start"></a>

## ⬇️ 下载与使用

**公开发布范围：自编启动器、保护组件、依赖源码和说明，不包含百度网盘完整客户端。** 首次使用需要自行准备 **百度网盘 7.36.0.3 的 32 位原始客户端文件**。

1. **获取组件**：打开 [Releases 发布页](https://github.com/HAN-Programming/BaiduNetdisk-portable/releases)，阅读版本说明并选择对应组件附件。GitHub 自动生成的 `Source code` 是源码；如尚无组件附件，可按下文从源码构建。
2. **准备目录**：按照发行说明，将匹配版本的原始客户端程序、DLL 和资源文件放入 `App`，保留组件的 `App/.portable/runtime` 与 `App/portable.ini` 等相对位置。
3. **双击启动**：运行根目录的 **`百度网盘便携启动.exe`**。启动器使用图形界面，不弹命令行窗口，不请求管理员权限。
4. **登录并下载**：正常登录网盘，默认将下载文件保存到根目录的 `Downloads`。

完成首次准备后，日常使用只需双击启动器。个人完整客户端包仅供个人使用，不作为本项目的公开下载内容。

> [!IMPORTANT]
> 必须通过根目录的 `百度网盘便携启动.exe` 启动。直接运行 `App/BaiduNetdisk.exe` 会绕过保护。当前验证范围为 **Windows 11 x64 + 百度网盘 7.36.0.3（x86）**；其他环境与客户端版本需重新验证。

## 🗂️ 数据保存到哪里

常见目录会重定向到便携包内；下载文件默认保存在包根目录的 `Downloads`。

| 客户端使用的位置 | 便携包中的实际位置 |
| --- | --- |
| `AppData/Roaming` | `App/.portable/data/AppData/Roaming` |
| `AppData/Local` | `App/.portable/data/AppData/Local` |
| `AppData/LocalLow` | `App/.portable/data/AppData/LocalLow` |
| `ProgramData` | `App/.portable/data/ProgramData` |
| `TEMP` / `TMP` | `App/.portable/data/Temp` |
| 用户配置目录 | `App/.portable/data/Profile` |
| 默认下载目录 | `Downloads` |
| 客户端的 `HKEY_CURRENT_USER` 配置 | `App/.portable/data/registry.dat` |

客户端自身的 `users`、`Data`、日志等还可能保存在 `App` 内；保护层日志位于 `App/.portable/logs`。这些运行数据不属于公开源码。

需要外部下载目录时，在 `App/portable.ini` 中配置一个已存在的绝对路径，重启后在客户端中选择同一目录。普通使用无需修改配置。

## 🔍 工作原理

启动器以暂停状态创建客户端进程，在内存中加载 `bdpguard32.dll`，再恢复运行。保护组件使用 MinHook 拦截相关接口，限制更新操作与文件写入；官方程序文件始终保留。

<details>
<summary><strong>🛑 三层更新限制</strong></summary>

1. **更新接口拦截**：在内存中拦截 `updateagent.dll` 的 9 个更新接口，包括初始化、添加更新任务、设置更新参数等，使其直接返回，不执行原有更新逻辑。原 DLL 文件仍然保留。
2. **子进程白名单**：只允许指定位置的主程序、渲染进程等必要组件启动；安装器、更新器等不在白名单内的程序会被拒绝。允许启动的子进程也必须先加载保护组件。
3. **程序文件保护**：阻止修改、删除或替换程序目录中的受保护 EXE、DLL 等文件。下载目录仍允许保存这些格式的普通下载文件。

这些限制针对当前客户端的更新机制，未通过修改 hosts 或系统防火墙规则屏蔽更新服务器。未来版本需要重新分析和验证。

实现见 [`src/guard.c`](src/guard.c)。

</details>

<details>
<summary><strong>🗂️ 路径重定向、越界写入与私有注册表</strong></summary>

- **只改变进程内部环境**：使用 `SetEnvironmentVariableW` 设置客户端及其子进程看到的目录，不使用 `setx`，不修改系统或用户的持久环境变量，其他应用不受此设置影响。参见 [Microsoft API 说明](https://learn.microsoft.com/en-us/windows/win32/api/processenv/nf-processenv-setenvironmentvariablew)。
- **继续检查文件接口**：拦截 `NtCreateFile`、`NtWriteFile`、`NtSetInformationFile` 等接口，把原 AppData、ProgramData 等常见绝对路径改写为便携路径；对其他允许范围外的写入返回“拒绝访问”。配置的下载目录属于允许范围。
- **检查更多路径入口**：检查已打开的文件句柄、重命名目标和目录链接，降低绕过路径限制的可能。首次初始化可能使用的盘符根目录 `BaiduYunKernel` 专用路径，也会重定向到 `App/.portable/data/BaiduYunKernel`。
- **独立保存 HKCU 配置**：将网盘进程内的 `HKEY_CURRENT_USER` 映射到 `App/.portable/data/registry.dat` 私有配置单元，另外限制其他注册表写入；不会重定向整个系统的用户注册表。

实现见 [`src/launcher.c`](src/launcher.c)、[`src/memory_import.h`](src/memory_import.h) 与 [`src/guard.c`](src/guard.c)。

</details>

<details>
<summary><strong>🌐 网络行为与退出兼容处理</strong></summary>

为减少入站授权提示，保护组件在网盘进程内拒绝对外 TCP 监听和非回环固定 UDP 端口绑定，保留本机回环、临时 UDP 客户端端口与主动连接。**P2P 入站或部分局域网功能可能不可用。** 本项目不添加或删除 Windows 防火墙规则，也不修改 VPN、代理或网络适配器设置。Windows 自身可能因用户拒绝防火墙提示而创建阻止规则，参见 [Microsoft 说明](https://learn.microsoft.com/en-us/windows/security/operating-system-security/network-security/windows-firewall/rules)。

启动器会区分主界面成功显示后的普通退出与已知崩溃状态。针对已验证版本，还在内存中保护窗口资源释放逻辑，避免全局状态销毁后的重复释放；原始 EXE 文件不改。本地测试中，对应客户端自动退出的原始退出码由 `0xC0000005` 变为 `0`。相关地址与指令特征仅适用于已验证版本。

探针与验证方法见 [`develop/tests/README.md`](develop/tests/README.md)。

</details>

## 🧪 验证范围与使用边界

已在 **Windows 11 x64、百度网盘 7.36.0.3（32 位客户端）** 上进行启动、登录界面、实际下载、退出及部分写入拦截测试。

- **用户态保护层**：不是内核级沙箱，不能据此承诺任意电脑、所有功能或未来版本都适用。
- **系统记录仍有边界**：Windows 自身产生的日志等记录，不在“客户端常见路径重定向”的保证范围内，不承诺系统绝对零写入。
- **下载速度仍取决于官方服务与网络条件**：项目关注便携运行、更新限制与数据保存位置。

使用前请阅读 [完整使用条件与便携边界](docs/PORTABILITY.md)。遇到问题可 [提交 Issue](https://github.com/HAN-Programming/BaiduNetdisk-portable/issues)，附上系统版本、客户端版本、复现步骤与脱敏日志。

## 🛠️ 源码与构建

| 文件或目录 | 用途 |
| --- | --- |
| [`src/launcher.c`](src/launcher.c) | 图形启动器与客户端启动流程 |
| [`src/guard.c`](src/guard.c) | 更新限制、文件与注册表保护等实现 |
| [`third_party/minhook`](third_party/minhook) | MinHook 源码与原许可证 |
| [`docs/PROJECT-SUMMARY.md`](docs/PROJECT-SUMMARY.md) | 项目概述 |
| [`docs/PORTABILITY.md`](docs/PORTABILITY.md) | 适用条件与限制 |
| [`develop/tests`](develop/tests) | 可公开的网络与退出集成探针 |
| [`develop/markdownlog/开发说明.md`](develop/markdownlog/开发说明.md) | 开发注意事项 |
| [`PACKAGE-MANIFEST.sha256`](PACKAGE-MANIFEST.sha256) | 随附文件的 SHA-256 校验清单 |

<details>
<summary><strong>展开源码构建步骤</strong></summary>

源码为 **C**，目标为 **x86**，使用 **MinHook 1.3.4**。构建不需要 Python。

1. 下载并手动解压 [llvm-mingw 20261006 UCRT x86_64](https://github.com/mstorsjo/llvm-mingw/releases/tag/20261006) 到项目的 `tools` 目录，无需安装或加入 PATH。原构建工具压缩包的 SHA-256 为：

   ```text
   317492c456aa27ee607a5919f1d2d38dcdc1112516a24d0bf4b00d078f52d17a
   ```

2. 在项目根目录打开 PowerShell，执行：

   ```powershell
   & .\build.ps1 -CompilerRoot .\tools\llvm-mingw-20261006-ucrt-x86_64
   ```

3. 构建产物位于项目内的 `build`、`dist`。自行将匹配版本的原始客户端文件放入 `dist/App`，保留构建产生的 `.portable/runtime` 和配置文件。

脚本只临时改变构建进程的 TEMP/TMP，结束后恢复；不设置全局环境变量或执行策略。若当前环境禁止执行脚本，请使用已有的、允许脚本执行的开发环境。使用已编译启动器无需运行构建脚本。

源码保留开发用的 `--probe` 分支，普通使用不传该参数，也不要用它绕过客户端单实例检查。仓库不附探针 EXE；构建只嵌入权限清单，不包含百度图标。重新构建后的其他版本仍需重新测试。

</details>

## 📄 许可证与项目关系

自编启动器与保护组件采用 [MIT License](LICENSE)。MinHook 及其反汇编引擎保留 [原许可证](third_party/minhook/LICENSE.txt)，详见 [第三方声明](THIRD-PARTY-NOTICES.txt)。

本项目为独立的开源实验，与百度无隶属关系。百度网盘客户端不属于本项目的开源范围，本项目不为其授予再分发许可。

---

**English:** An experimental open-source launcher for Baidu Netdisk on Windows, featuring portable configuration storage, in-process path redirection, a private registry hive, and version-specific automatic-update restrictions. Original client EXE/DLL files remain unchanged on disk. The Baidu Netdisk client is not included.
