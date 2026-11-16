<p align="center">
  <img src="assets/gesher.png" alt="Gesher Logo" width="160"/>
</p>

# Gesher（简体中文版）

**在 Windows 上以原生进程运行 Android 应用——不用模拟器，不用虚拟机。**

Gesher（希伯来语，意为“桥”）之于 Android，正如 Wine 之于 Windows：它是一层
兼容层。双击一个 `.apk`，应用就在一个普通窗口里以原生速度运行，没有隐藏的
虚拟机，也不需要启动 Android 镜像。

> **本仓库是 [gesher-runtime/gesher](https://github.com/gesher-runtime/gesher)
> 的简体中文本地化分支。** 在上游代码的基础上增加了中文界面（安装向导、
> 控制中心、应用对话框、命令行提示、开始菜单），并附带中文安装包与中文说明。
> 代码逻辑与上游一致，差别只在界面文案与文档。
>
> **版本：v0.1.3（中文界面）**——在 Windows 上原生执行 Android 应用，包含
> ART JIT、HWUI/Direct3D 硬件加速、WASAPI 音频、摄像头/定位子系统、
> microG GMS 替身、ARM64→x64 二进制翻译，以及与 Windows 桌面的深度集成。
> 设计细节见[架构概览](docs/architecture.md)（英文）。

## 下载与安装

从 [Releases](../../releases) 下载 `gesher-setup-0.1.3.exe`，右键选择
**以管理员身份运行**。

安装后界面语言自动跟随 Windows 语言：中文系统即为中文，无需任何设置。
安装包同时包含英文与希伯来文界面。若需强制指定语言，可设置环境变量：

```
GESHER_PANEL_UI_LANGUAGE=zh    # 或 en / he
```

## 工作原理

Gesher 不重写 Android，而是把 Android 开源项目（AOSP）自己的运行时与框架
编译到 Windows 上，只替换那些与 Linux 内核打交道的层：

```
 .apk ─► APK 加载器       清单、资源、dex、原生库
         ART（含 JIT）     Android 自己的 Java 运行时，移植到 Windows
         framework.jar    真正的 Android 框架
           └ 系统服务在进程内重新实现
         HWUI + Skia      → OpenGL ES → ANGLE → Direct3D 11
         原生 .so         ELF 加载器 + Win32 上的 bionic（+ arm64 翻译）
         集成层           窗口、输入、输入法、剪贴板、文件、通知
```

完整设计见 [docs/architecture.md](docs/architecture.md)。

## 兼容性

**Android 兼容性是部分的。** 应用仍可能因为缺少模块 API、缺少原生导入或
后端行为不符而失败；构建成功或符号查找成功，都不代表任意 APK 都能正确运行。

上游仓库有一系列审计文档记录了当前的契约修复、回归覆盖与剩余缺口（均为英文）：

- [2026-11-16 运行时性能审计](docs/research/runtime-performance-audit-2026-11-16.md)
- [2026-11-14 Android/Windows 契约审计](docs/research/android-windows-compatibility-2026-11-14.md)
- [2026-11-14 Android 契约审计](docs/research/android-contract-audit-2026-11-14.md)
- [2026-11-13 生命周期契约审计](docs/research/android-lifecycle-contracts-2026-11-13.md)

已知限制（源自上游说明）：

- 窗口能显示应用绘制的内容，但**暂不接受鼠标与键盘输入**；每个窗口都是顶层窗口。
- 系统服务部分是 Gesher 自己的替身实现。
- 尚未支持：启动进程（ProcessBuilder）、WatchService、经 BoringSSL 的
  BigInteger/加密、完整时区数据（无 tzdata）。

## 设计原则

- **不用虚拟机，不用模拟器。** 每个应用就是一个 Windows 进程。
- **轻量。** 没有应用运行时，什么都不跑。
- **不做商店。** Gesher 只打开用户已有的 `.apk` 文件。
- **尊重宿主环境。** 网络与 TLS 使用 Windows 自己的证书存储，内容过滤与
  企业代理无需改动即可生效。
- **重活交给 CI。** 所有构建与测试都在 GitHub Actions 上运行，贡献者不需要
  一台性能强劲的机器。

## 从源码构建

依赖：CMake 3.24+、Ninja、Python 3、git，以及
[llvm-mingw](https://github.com/mstorsjo/llvm-mingw)（Linux 与 Windows 主机均可）。

```sh
tools/fetch-aosp.sh                       # 拉取锁定版本的 AOSP 源码并打补丁
cmake -S . -B out -G Ninja \
  -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain-llvm-mingw.cmake \
  -DLLVM_MINGW=/path/to/llvm-mingw
ninja -C out
```

主要产物：

- `dalvikvm.exe`：移植后的 ART 运行时（含 JIT 编译器）。
- `gesher-exec.exe`：应用进程宿主与启动器。
- `installer/gesher-setup-*.exe`：完整的 Windows 安装包与 Shell 集成。

测试：先 `tests/build-test-apps.sh out/test-apps`（需要 JDK），然后在 Windows 上
运行 `tests/windows/run-tests.ps1`。

## 关于更新

控制中心的「更新」卡片会检查 **GitHub Releases**。请注意：本分支的更新检查
仍然指向上游仓库 `gesher-runtime/gesher`，因此**不会**看到本仓库发布的版本，
需要更新时请手动下载本仓库 Releases 中的安装包覆盖安装（已安装的应用及其
数据会保留）。

## 许可证

[Apache License 2.0](LICENSE)，与 AOSP 相同。参见
[决策 0001](docs/decisions/0001-license.md)。

## 相关链接

- 上游项目：[gesher-runtime/gesher](https://github.com/gesher-runtime/gesher)
- 本仓库英文原版 README：[README.en.md](README.en.md)
- 界面语言说明：[docs/ui-language.md](docs/ui-language.md)
