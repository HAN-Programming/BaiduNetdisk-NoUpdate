# Baidu Netdisk Portable Launcher（实验版）

用于百度网盘 Windows 客户端的便携启动与进程内目录重定向实验。双击图形启动器运行，原始客户端 EXE/DLL 不打补丁；自编组件尝试把客户端配置、缓存、临时文件与 HKCU 配置保存在客户端目录，并限制自动更新与目录外写入。

**本项目开源的是启动器和重定向组件。百度网盘本体不是本项目的开源软件，仓库不包含官方客户端或账号数据。**

当前为实验状态：已在 Windows 11 x64、百度网盘 7.36.0.3 的 32 位客户端上验证登录界面、实际下载和若干写入拦截。不能保证任意电脑即开即用，也不能保证系统绝对没有目录外写入。[详细限制](docs/PORTABILITY.md)是使用条件的一部分。

## 使用

1. 个人完整包已经包含客户端。解压后只需双击根目录的 `百度网盘便携启动.exe`，无需安装、拼装 DLL、运行脚本或准备 Python。
2. 根目录只有该 EXE 和 `App`、`Downloads`、`markdownlog` 文件夹。官方主程序、DLL、资源与便携组件完整放在 `App` 内，下载放在根目录 `Downloads`。
3. 启动器为 GUI 程序，不弹命令行窗口，也不请求管理员权限。首次使用正常登录网盘即可。
4. 仅从源码构建时，自行把对应版本原始客户端文件放入 `dist/App`，保留构建产生的 `.portable/runtime` 和配置文件。源码仓库不附官方客户端。
5. 开发者如需外部下载目录：在 `App/portable.ini` 配置一个已存在的绝对路径，重启并在客户端选择同一目录。普通使用不需要修改配置。

正常启动会在 `App` 内生成 `.portable/data`、`.portable/logs`、客户端的 `users`、`Data`、日志和配置等。这些运行数据不应提交到仓库。直接运行 `App/BaiduNetdisk.exe` 会绕过启动器限制。

## 工作方式

启动器暂停创建原始进程，在内存中加入重定向组件导入项；组件加载后恢复内存头部。使用 MinHook 拦截部分文件、注册表、子进程与系统操作 API。子进程按路径白名单放行并加载同一组件；配置使用私有应用配置单元，目录环境变量只在网盘进程及其子进程内改变。该环境变量 API 的作用域见[微软说明](https://learn.microsoft.com/en-us/windows/win32/api/processenv/nf-processenv-setenvironmentvariablew)。

原 `updateagent.dll` 文件保留，在加载阶段禁用其更新接口；拦截不在白名单内的更新进程及客户端可执行文件覆盖。另将首次初始化可能使用的盘符根目录 `BaiduYunKernel` 专用路径重定向到 `App/.portable/data/BaiduYunKernel`。未来客户端的更新机制可能变化，需要重新验证。

为减少入站授权提示，在网盘进程内拒绝对外 TCP 监听和非回环固定 UDP 端口绑定，保留本机回环、临时 UDP 客户端端口与主动连接。P2P 入站或部分局域网功能可能不可用。不添加或删除 Windows 防火墙规则，也不修改 VPN、代理或网络适配器设置。拒绝 Windows 自身的防火墙提示可能由 Windows 创建阻止规则，见[微软说明](https://learn.microsoft.com/en-us/windows/security/operating-system-security/network-security/windows-firewall/rules)。

启动器会跟踪客户端是否已显示主界面，不再把成功打开后的普通退出码一律显示成“启动失败”；已知崩溃状态仍报告运行异常。另对这个客户端版本的窗口资源释放函数做内存保护：全局状态已销毁时跳过再次释放，避免退出时的空对象访问。修复函数的地址和指令特征仅适用于已验证版本，原始 EXE 文件不改。真实客户端自动退出的原始退出码已从 `0xC0000005` 变为 `0`。[本地集成测试说明](develop/tests/README.md)记录对应探针。

## 源码目录

| 目录 | 用途 |
| --- | --- |
| `src` | 启动器、内存导入和文件/注册表保护层源码 |
| `third_party` | MinHook 源码与原许可证 |
| `docs` | 项目简述及便携限制说明 |
| `develop/tests` | 可公开的网络与退出集成探针源码和使用说明 |
| `develop/markdownlog` | 后续开发注意事项 |

根层保留 GitHub 首页和构建所需的 README、许可证、Git 配置及构建入口。这里不包含本机的调试输出、编译器、账号、客户端或完整包。

## 构建

源码为 C，目标 x86，使用 MinHook 1.3.4。构建不需要 Python。编译器手动解压在项目 `tools` 内，不安装、不加入 PATH。

本次私有运行组件原构建工具为 [llvm-mingw 20261006 UCRT x86_64](https://github.com/mstorsjo/llvm-mingw/releases/tag/20261006)，压缩包 SHA-256：

```text
317492c456aa27ee607a5919f1d2d38dcdc1112516a24d0bf4b00d078f52d17a
```

在本项目目录打开 PowerShell，运行：

```powershell
& .\build.ps1 -CompilerRoot .\tools\llvm-mingw-20261006-ucrt-x86_64
```

脚本把产物写入本项目 `build`、`dist`，只临时改变构建进程的 TEMP/TMP，结束后恢复；不设置全局环境变量或执行策略。若机器禁止执行脚本，可在允许脚本的现有开发环境中构建，无须为使用已编译启动器修改系统策略。

仓库源码保留最初开发用 `--probe` 分支，但不附带其测试 EXE；普通使用不传该参数。不要用探针分支绕过客户端单实例检查。仓库构建只嵌入权限清单，不包含百度图标。本次个人包使用该源码重新构建，并进行空白启动验证；重新构建后的其他版本仍需重新测试。

## 许可证

自编部分为 [MIT](LICENSE)，MinHook 和其反汇编引擎保留[原许可证](third_party/minhook/LICENSE.txt)。见 [THIRD-PARTY-NOTICES.txt](THIRD-PARTY-NOTICES.txt)。本项目与百度无隶属关系，不为百度客户端授予再分发许可。
