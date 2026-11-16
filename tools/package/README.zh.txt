Gesher：Windows 上的 ART（Android 运行时）——试用版
==========================================================

系统要求：Windows 10 或 11，x64。无需安装其他任何东西。

更新 Gesher
---------------
从开始菜单打开「Gesher 控制中心」，或运行：

    gesher-app control-panel

「更新」卡片会检查 GitHub 上的稳定版本。控制中心打开期间会自动检查，也可
以关闭自动检查，或手动检查。确认更新前，请先保存在运行中的 Android 应用里
的工作：安装程序会停止正在运行的 Gesher 设备并升级安装。已安装的应用及其
数据都会保留，更新前无需卸载 Gesher。

运行 Hello
-------------
在命令提示符中：

    gesher

预期输出（前面会有几条关于缺少 boot image 的警告）：

    Hello from ART on Windows

运行你自己的程序
------------------------
1. 编译你的 Java 代码（JDK 17 或 21）并打包成 jar：
       javac -d classes Main.java
       jar cf app.jar -C classes .
2. 用 d8（来自 Android build-tools）转换成 dex，会生成 classes.dex：
       d8 --min-api 36 --output . app.jar
3. 运行：
       gesher classes.dex Main
   或带参数：
       gesher classes.dex com.example.Main arg1 arg2

.dex 文件必须与 Gesher 在同一个盘符（通常是 C:）。

运行 Android 应用（gesher-app）
-----------------------------------
Android 的框架（framework.jar、framework-res.apk）随 Gesher 一起提供。
gesher-app 会安装应用并启动它的启动器 Activity，和在 Android 上一样：
在你自己的「Gesher 设备」上运行一个系统服务（连同 binderd 和
servicemanager），所有启动共用它，并由它为每个应用启动独立进程。Activity
显示在自己的窗口中（由 Android 的渲染器在 CPU 上绘制）；关闭窗口即结束该
Activity，程序随应用进程一起退出。应用的输出显示在控制台中。随附的测试
应用：

    gesher-app "%LOCALAPPDATA%\Programs\Gesher\lifecycle.apk"

首次启动会在后台启动设备（无窗口，且会活得比控制台更久），之后的启动会
复用它。没有应用运行 10 分钟后它会自行停止（GESHER_IDLE_TIMEOUT，单位为
秒），也可以手动停止：

    gesher-app shutdown

已安装的应用会保留（%LOCALAPPDATA%\Gesher\data\app）：

    gesher-app install my.apk
    gesher-app list
    gesher-app uninstall com.example.app
    gesher-app status

每个已安装的应用都会在「Gesher 应用」文件夹中生成一个开始菜单项，带名称和
图标；它以如下方式启动应用：

    gesher-app launch com.example.app

卸载应用会移除该项；卸载 Gesher 会移除整个文件夹。

其他选项：--activity .Other（另一个 Activity）、--ez KEY true|false
（向 intent 添加 extra）、--headless（无窗口：Activity 空闲后启动器就关闭
它；配合 --keep-task 则应用运行到结束；GESHER_APP_WINDOW=headless 使其成为
默认）、--hidden-window（窗口绘制在桌面之外）。
日志位于 %LOCALAPPDATA%\Gesher\logs（某个应用的日志是 <包名>.log）。

不启动设备、让应用单独运行在一个进程中并使用替身服务：

    gesher-app my.apk --single-process

双击 .apk 文件也会用 gesher-app 运行，除非已有其他程序关联了 .apk；那就用
「打开方式」（Gesher 这一项运行 gesher-app.cmd）。

应用中的网页（WebView）
---------------------------
应用的 WebView 使用 Microsoft Edge WebView2 显示网页，这是 Windows 11
（以及当前版本的 Windows 10）内置的浏览器引擎。如果安装程序没有找到它，
会提示安装「Microsoft Edge WebView2 Runtime」；你也可以从
https://go.microsoft.com/fwlink/p/?LinkId=2124703 获取。缺少它时 WebView
会显示空白。每个应用把自己的网页数据（cookie、缓存、存储）保存在各自的
数据文件夹中（app_webview）。

已经能用的，以及还不能用的
--------------------------------
- Windows 会显示应用绘制的内容，但暂时不接受输入（鼠标点击和键盘是下一步）；
  每个窗口都是顶层窗口。
  框架的 native 层覆盖了 Activity 生命周期及其视图所需的接口（资源、
  Looper、Parcel、Binder、android.graphics）；系统服务是 Gesher 自己的，
  部分是替身，所以除随附测试应用之外的应用可能会停在缺少某个 native 方法
  或服务上。
- 仅解释器（无 JIT、无 boot image），因此启动需要几秒钟。
- java.lang、集合、字符串、ICU（文本、区域设置）、基本文件 I/O。
- 尚不支持：启动进程（ProcessBuilder）、WatchService、通过 BoringSSL 的
  BigInteger/加密、完整时区（无 tzdata）。

运行时会把 Android 期望的各个目录保存在 %LOCALAPPDATA%\Gesher 下；
卸载会移除它们。
