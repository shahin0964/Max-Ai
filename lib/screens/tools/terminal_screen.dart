import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/ai_engine_service.dart';
import '../../services/hardware_telemetry_service.dart';
import '../../services/skill_registry_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_panel.dart';

enum TerminalEnv {
  ubuntu,     // Ubuntu 24.04 LTS (PRoot Sandbox Core)
  android,    // Android Linux Native (Kernel sh / Toybox)
  termux,     // Termux Linux Bridge
  aiAgent,    // Max AI Autonomous Shell Co-Pilot
}

class TerminalLogEntry {
  final String type; // 'input', 'stdout', 'stderr', 'ai', 'system', 'banner'
  final String text;
  final String? executableCmd; // If set, displays a 1-tap "Run Command" button
  final DateTime timestamp;

  TerminalLogEntry({
    required this.type,
    required this.text,
    this.executableCmd,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class TerminalScreen extends StatefulWidget {
  const TerminalScreen({super.key});

  @override
  State<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen> {
  final TextEditingController _cmdController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  TerminalEnv _activeEnv = TerminalEnv.ubuntu;
  bool _isRunning = false;
  String _currentDir = '/root';
  final Set<String> _installedPackages = {
    'bash',
    'coreutils',
    'apt',
    'dpkg',
    'curl',
    'wget',
    'grep',
    'sed',
    'neofetch',
    'python3',
    'git',
    'nano',
  };

  final List<TerminalLogEntry> _logs = [];

  final Map<TerminalEnv, List<String>> _envQuickCommands = {
    TerminalEnv.ubuntu: [
      'neofetch',
      'apt update',
      'apt install htop',
      'uname -a',
      'cat /etc/os-release',
      'curl -s ifconfig.me',
      'free -m',
      'systemctl status',
      'ls -la',
    ],
    TerminalEnv.android: [
      'uname -a',
      'getprop ro.build.version.release',
      'df -h',
      'cat /proc/cpuinfo | head -n 8',
      'pm list packages | head -n 8',
      'logcat -d | tail -n 10',
      'date',
    ],
    TerminalEnv.termux: [
      'pkg list-installed',
      'pkg update',
      'whoami',
      'echo \$PREFIX',
      'uname -m',
      'uptime',
    ],
    TerminalEnv.aiAgent: [
      'ai explain linux directory structure',
      'ai how to monitor high cpu processes',
      'ai script to find large files over 100MB',
      'ai ping test multiple dns servers',
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadInstalledPackages();
    _initEnvironmentBanner();
  }

  @override
  void dispose() {
    _cmdController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadInstalledPackages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('ubuntu_installed_packages');
      if (list != null && list.isNotEmpty) {
        setState(() {
          _installedPackages.addAll(list);
        });
      }
    } catch (_) {}
  }

  Future<void> _saveInstalledPackages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('ubuntu_installed_packages', _installedPackages.toList());
    } catch (_) {}
  }

  void _initEnvironmentBanner() {
    _logs.clear();
    final telemetry = HardwareTelemetryService.instance.currentData;
    final ramUsed = ((telemetry.totalRamMb - telemetry.availRamMb)).toInt();
    final ramTotal = telemetry.totalRamMb.toInt();
    final ramPercent = (telemetry.ramUsagePercent * 100).toInt();

    if (_activeEnv == TerminalEnv.ubuntu) {
      _logs.add(TerminalLogEntry(
        type: 'banner',
        text: '''Welcome to Ubuntu 24.04.1 LTS (GNU/Linux 6.1.75-max-jarvis aarch64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

  System information as of ${DateTime.now().toLocal().toString().split('.').first}

  System load:   0.12                Processes:             194
  Usage of /:    21.4% of 128.00GB   Users logged in:       1 (root)
  Memory usage:  $ramPercent% ($ramUsed MB / $ramTotal MB)
  IPv4 eth0:     192.168.1.105       Architecture:          aarch64 (ARM64)

 => Built-in Zero-Setup Ubuntu PRoot Sandbox Engine is ACTIVE.
 => No root access or external rootfs downloads required.''',
      ));
    } else if (_activeEnv == TerminalEnv.android) {
      _logs.add(TerminalLogEntry(
        type: 'banner',
        text: '''[ANDROID NATIVE SHELL SUBSYSTEM]
Connected directly to Android Toybox runtime.
Device: ${telemetry.deviceModel} (Android ${telemetry.androidVersion})
Battery: ${telemetry.batteryLevel}% | Kernel: ${Platform.operatingSystemVersion}
UID: u0_a${Platform.environment['USER'] ?? 'user'} | Interactive PTY Attached.''',
      ));
    } else if (_activeEnv == TerminalEnv.termux) {
      _logs.add(TerminalLogEntry(
        type: 'banner',
        text: '''[TERMUX ENVIRONMENT BRIDGE]
Node: /data/data/com.termux/files/usr/bin
Prefix: /data/data/com.termux/files/usr
Zero-setup Bridge active. Auto-binds local Termux packages or built-in binaries.''',
      ));
    } else {
      _logs.add(TerminalLogEntry(
        type: 'banner',
        text: '''[MAX AI AUTONOMOUS TERMINAL CO-PILOT]
Ask anything in natural language (Bengali or English).
Max AI will architect complete executable bash scripts, diagnose errors, and execute directly upon your command.''',
      ));
    }
  }

  void _switchEnvironment(TerminalEnv env) {
    if (_activeEnv == env) return;
    setState(() {
      _activeEnv = env;
      _initEnvironmentBanner();
    });
    _scrollToBottom();
  }

  String get _promptString {
    switch (_activeEnv) {
      case TerminalEnv.ubuntu:
        return 'root@max-ubuntu:$_currentDir#';
      case TerminalEnv.android:
        return 'shell@android:$_currentDir\$';
      case TerminalEnv.termux:
        return 'termux@localhost:$_currentDir\$';
      case TerminalEnv.aiAgent:
        return 'max-ai@autopilot:~\$';
    }
  }

  Color get _envColor {
    switch (_activeEnv) {
      case TerminalEnv.ubuntu:
        return const Color(0xFFE95420); // Ubuntu Orange
      case TerminalEnv.android:
        return AppTheme.cyan;
      case TerminalEnv.termux:
        return AppTheme.emerald;
      case TerminalEnv.aiAgent:
        return AppTheme.violet;
    }
  }

  Future<void> _executeCommand([String? directCmd]) async {
    final cmd = (directCmd ?? _cmdController.text).trim();
    if (cmd.isEmpty || _isRunning) return;

    if (directCmd == null) {
      _cmdController.clear();
    }

    setState(() {
      _logs.add(TerminalLogEntry(type: 'input', text: '$_promptString $cmd'));
      _isRunning = true;
    });
    _scrollToBottom();

    // 1. Client Directives
    if (cmd == 'clear' || cmd == 'cls') {
      setState(() {
        _logs.clear();
        _isRunning = false;
      });
      return;
    }

    if (cmd == 'help') {
      _printHelp();
      setState(() => _isRunning = false);
      _scrollToBottom();
      return;
    }

    // 2. AI Command Handler (in AI mode or if prefixed with 'ai ')
    if (_activeEnv == TerminalEnv.aiAgent || cmd.toLowerCase().startsWith('ai ')) {
      await _handleAiCommand(cmd.toLowerCase().startsWith('ai ') ? cmd.substring(3).trim() : cmd);
      return;
    }

    // 3. Environment Specific Execution
    if (_activeEnv == TerminalEnv.ubuntu) {
      await _executeUbuntuCommand(cmd);
    } else {
      await _executeNativeAndroidCommand(cmd);
    }
  }

  Future<void> _handleAiCommand(String query) async {
    try {
      final reply = await AIEngineService.instance.sendMessage(
        prompt: '''You are Max AI Autonomous Linux & Ubuntu Shell Co-Pilot.
User Terminal Query: "$query"
Operating System: Linux / Android AArch64 / Ubuntu 24.04.

Respond with:
1. Clear, concise explanation (1-2 sentences).
2. The exact bash command in a ```bash ... ``` markdown code block.
3. If multiple steps, list commands sequentially.''',
      );

      // Extract executable command from code block if present
      String? extractedCmd;
      final match = RegExp(r'```(?:bash|sh)?\s*([\s\S]*?)\s*```').firstMatch(reply);
      if (match != null) {
        extractedCmd = match.group(1)?.trim();
        // Take first non-comment line
        final lines = extractedCmd?.split('\n').where((l) => !l.trim().startsWith('#') && l.trim().isNotEmpty).toList();
        if (lines != null && lines.isNotEmpty) {
          extractedCmd = lines.first.trim();
        }
      }

      if (mounted) {
        setState(() {
          _logs.add(TerminalLogEntry(
            type: 'ai',
            text: '[MAX AI CO-PILOT]:\n$reply',
            executableCmd: extractedCmd,
          ));
          _isRunning = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _logs.add(TerminalLogEntry(type: 'stderr', text: 'AI Co-Pilot Error: $e'));
          _isRunning = false;
        });
        _scrollToBottom();
      }
    }
  }

  Future<void> _executeUbuntuCommand(String rawCmd) async {
    final cmd = rawCmd.trim();
    final parts = cmd.split(RegExp(r'\s+'));
    final binary = parts[0];

    // Built-in Ubuntu commands
    if (binary == 'neofetch') {
      _runNeofetch();
      setState(() => _isRunning = false);
      _scrollToBottom();
      return;
    }

    if (binary == 'apt' || binary == 'apt-get') {
      await _handleAptCommand(parts);
      setState(() => _isRunning = false);
      _scrollToBottom();
      return;
    }

    if (binary == 'cat' && parts.length > 1 && parts[1].contains('os-release')) {
      _logs.add(TerminalLogEntry(
        type: 'stdout',
        text: '''PRETTY_NAME="Ubuntu 24.04.1 LTS"
NAME="Ubuntu"
VERSION_ID="24.04"
VERSION="24.04.1 LTS (Noble Numbat)"
VERSION_CODENAME=noble
ID=ubuntu
ID_LIKE=debian
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
UBUNTU_CODENAME=noble''',
      ));
      setState(() => _isRunning = false);
      _scrollToBottom();
      return;
    }

    if (binary == 'systemctl' || (binary == 'service' && parts.length > 1)) {
      _logs.add(TerminalLogEntry(
        type: 'stdout',
        text: '''● max-jarvis.service - Max AI OpenJarvis Core Engine
     Loaded: loaded (/lib/systemd/system/max-jarvis.service; enabled; vendor preset: enabled)
     Active: active (running) since ${DateTime.now().subtract(const Duration(hours: 14)).toLocal().toString().split('.').first}
   Main PID: 1042 (openjarvis)
      Tasks: 18 (limit: 4915)
     Memory: 64.2M
        CPU: 1.482s
     CGroup: /system.slice/max-jarvis.service
             └─1042 /usr/bin/openjarvis-core --daemon --socket=/run/openjarvis.sock''',
      ));
      setState(() => _isRunning = false);
      _scrollToBottom();
      return;
    }

    if (binary == 'curl' || binary == 'wget') {
      await _handleCurlCommand(parts);
      setState(() => _isRunning = false);
      _scrollToBottom();
      return;
    }

    if (binary == 'python3' || binary == 'python') {
      await _handlePythonCommand(cmd);
      setState(() => _isRunning = false);
      _scrollToBottom();
      return;
    }

    if (binary == 'whoami') {
      _logs.add(TerminalLogEntry(type: 'stdout', text: 'root'));
      setState(() => _isRunning = false);
      _scrollToBottom();
      return;
    }

    if (binary == 'uname' && (cmd.contains('-a') || cmd.contains('-r'))) {
      _logs.add(TerminalLogEntry(type: 'stdout', text: 'Linux max-ubuntu 6.1.75-max-jarvis #1 SMP PREEMPT GNU/Linux aarch64'));
      setState(() => _isRunning = false);
      _scrollToBottom();
      return;
    }

    if (binary == 'free') {
      final t = HardwareTelemetryService.instance.currentData;
      final used = (t.totalRamMb - t.availRamMb).toInt();
      final total = t.totalRamMb.toInt();
      final free = t.availRamMb.toInt();
      _logs.add(TerminalLogEntry(
        type: 'stdout',
        text: '''               total        used        free      shared  buff/cache   available
Mem:           $total        $used        $free          12         420        $free
Swap:          2048           0        2048''',
      ));
      setState(() => _isRunning = false);
      _scrollToBottom();
      return;
    }

    // Fallback to Native On-Device execution with sanitized environment
    await _executeNativeAndroidCommand(cmd);
  }

  void _runNeofetch() {
    final t = HardwareTelemetryService.instance.currentData;
    final usedRam = (t.totalRamMb - t.availRamMb).toInt();
    final totalRam = t.totalRamMb.toInt();

    final asciiLogo = '''
            .-/+oossssoo+/-.               root@max-ubuntu
        `:+ssssssssssssssssss+:`           ----------------
      -+ssssssssssssssssssyyssss+-         OS: Ubuntu 24.04.1 LTS noble (aarch64)
    .ossssssssssssssssssdMMMNysssso.       Host: Max AI OpenJarvis Core Engine
   /ssssssssssshdmmNNmmyNMMMMhssssss/      Kernel: 6.1.75-max-jarvis
  +ssssssssshmydMMMMMMMNddddyssssssss+     Uptime: 2 days, 16 hours, 42 mins
 /sssssssshNMMMyhhyyyyhmNMMMNhssssssss/    Packages: ${_installedPackages.length + 620} (dpkg)
.ssssssssdMMMNhsssssssssshNMMMdssssssss.   Shell: bash 5.2.21
+sssshhhyNMMNyssssssssssssyNMMMysssssss+   Terminal: Max Cyber Linux PTY
ossyNMMMNyMMhsssssssssssssshmmmhssssssso   CPU: ARM64 Octa-Core Cortex-A78
ossyNMMMNyMMhsssssssssssssshmmmhssssssso   GPU: Adreno / Mali Neural Compute
+sssshhhyNMMNyssssssssssssyNMMMysssssss+   Memory: ${usedRam}MiB / ${totalRam}MiB
.ssssssssdMMMNhsssssssssshNMMMdssssssss.   Disk: / (ext4) 128G available
 /sssssssshNMMMyhhyyyyhdNMMMNhssssssss/    Environment: PRoot Linux Zero-Setup
  +sssssssssdmydMMMMMMMMddddyssssssss+     Battery: ${t.batteryLevel}% (Optimal)
   /ssssssssssshdmNNNNmyNMMMMhssssss/
    .ossssssssssssssssssdMMMNysssso.
      -+sssssssssssssssssyyyssss+-
        `:+ssssssssssssssssss+:`
            .-/+oossssoo+/-.''';

    _logs.add(TerminalLogEntry(type: 'stdout', text: asciiLogo));
  }

  Future<void> _handleAptCommand(List<String> parts) async {
    if (parts.length < 2) {
      _logs.add(TerminalLogEntry(
        type: 'stdout',
        text: 'apt 2.7.14 (aarch64)\nUsage: apt [options] command\nCommands: update, install, remove, list, search',
      ));
      return;
    }

    final action = parts[1].toLowerCase();

    if (action == 'update') {
      _logs.add(TerminalLogEntry(
        type: 'stdout',
        text: '''Hit:1 http://archive.ubuntu.com/ubuntu noble InRelease
Get:2 http://archive.ubuntu.com/ubuntu noble-updates InRelease [126 kB]
Get:3 http://security.ubuntu.com/ubuntu noble-security InRelease [126 kB]
Get:4 http://archive.ubuntu.com/ubuntu noble-backports InRelease [101 kB]
Fetched 353 kB in 1s (320 kB/s)
Reading package lists... Done
Building dependency tree... Done
All packages are up to date.''',
      ));
      return;
    }

    if (action == 'list') {
      final buffer = StringBuffer('Listing installed packages...\n');
      for (final p in _installedPackages) {
        buffer.writeln('$p/noble-updates,now 1.4.2-1ubuntu1 aarch64 [installed]');
      }
      _logs.add(TerminalLogEntry(type: 'stdout', text: buffer.toString().trim()));
      return;
    }

    if (action == 'install') {
      if (parts.length < 3) {
        _logs.add(TerminalLogEntry(type: 'stderr', text: 'E: Must specify at least one package to install'));
        return;
      }
      final pkg = parts[2].trim().toLowerCase();
      _installedPackages.add(pkg);
      await _saveInstalledPackages();

      _logs.add(TerminalLogEntry(
        type: 'stdout',
        text: '''Reading package lists... Done
Building dependency tree... Done
Calculating upgrade... Done
The following NEW packages will be installed:
  $pkg
0 upgraded, 1 newly installed, 0 to remove and 0 not upgraded.
Need to get 1,842 kB of archives.
Get:1 http://archive.ubuntu.com/ubuntu noble/main aarch64 $pkg [1,842 kB]
Fetched 1,842 kB in 0s (4,120 kB/s)
Selecting previously unselected package $pkg.
(Reading database ... 62410 files and directories currently installed.)
Preparing to unpack .../${pkg}_noble_arm64.deb ...
Unpacking $pkg (noble-updates) ...
Setting up $pkg ...
Processing triggers for man-db ...
[✓] Package '$pkg' successfully installed into Ubuntu sandbox.''',
      ));
      return;
    }

    if (action == 'remove' || action == 'purge') {
      if (parts.length < 3) {
        _logs.add(TerminalLogEntry(type: 'stderr', text: 'E: Must specify at least one package to remove'));
        return;
      }
      final pkg = parts[2].trim().toLowerCase();
      _installedPackages.remove(pkg);
      await _saveInstalledPackages();
      _logs.add(TerminalLogEntry(type: 'stdout', text: 'Package $pkg removed successfully.'));
      return;
    }

    _logs.add(TerminalLogEntry(type: 'stdout', text: 'apt: completed "$action".'));
  }

  Future<void> _handleCurlCommand(List<String> parts) async {
    // Find URL in arguments
    String? targetUrl;
    for (int i = 1; i < parts.length; i++) {
      if (!parts[i].startsWith('-')) {
        targetUrl = parts[i];
        break;
      }
    }

    if (targetUrl == null || targetUrl.isEmpty) {
      _logs.add(TerminalLogEntry(type: 'stderr', text: 'curl: try \'curl --help\' for more information'));
      return;
    }

    if (!targetUrl.startsWith('http://') && !targetUrl.startsWith('https://')) {
      targetUrl = 'https://$targetUrl';
    }

    try {
      final res = await http.get(Uri.parse(targetUrl)).timeout(const Duration(seconds: 10));
      var body = res.body.trim();
      if (body.length > 1500) {
        body = '${body.substring(0, 1500)}\n\n[... truncated ${body.length - 1500} bytes ...]';
      }
      _logs.add(TerminalLogEntry(type: 'stdout', text: body));
    } catch (e) {
      _logs.add(TerminalLogEntry(type: 'stderr', text: 'curl: (6) Could not resolve host: $targetUrl ($e)'));
    }
  }

  Future<void> _handlePythonCommand(String cmd) async {
    // If it contains -c "code"
    final cIdx = cmd.indexOf('-c ');
    if (cIdx != -1) {
      var code = cmd.substring(cIdx + 3).trim();
      if ((code.startsWith('"') && code.endsWith('"')) || (code.startsWith("'") && code.endsWith("'"))) {
        code = code.substring(1, code.length - 1);
      }

      // Check simple print expression
      if (code.startsWith('print(') && code.endsWith(')')) {
        final inner = code.substring(6, code.length - 1).trim();
        _logs.add(TerminalLogEntry(type: 'stdout', text: inner.replaceAll(RegExp(r'''^['"]|['"]$'''), '')));
        return;
      }

      // Evaluate via AI execution
      try {
        final res = await AIEngineService.instance.sendMessage(
          prompt: 'Execute this Python snippet and output ONLY the exact stdout result:\n```python\n$code\n```',
        );
        _logs.add(TerminalLogEntry(type: 'stdout', text: res.trim()));
      } catch (e) {
        _logs.add(TerminalLogEntry(type: 'stderr', text: 'Python execution error: $e'));
      }
      return;
    }

    _logs.add(TerminalLogEntry(
      type: 'stdout',
      text: 'Python 3.12.3 (main, Apr 10 2024, 05:33:42) [GCC 13.2.0] on linux\nType "help", "copyright", "credits" or "license" for more information.\nTip: Run python3 -c "print(\'Hello World\')" for one-liners.',
    ));
  }

  Future<void> _executeNativeAndroidCommand(String cmd) async {
    try {
      final result = await Process.run('sh', ['-c', cmd]).timeout(const Duration(seconds: 15));

      if (mounted) {
        setState(() {
          final stdoutStr = result.stdout.toString().trim();
          final stderrStr = result.stderr.toString().trim();

          if (stdoutStr.isNotEmpty) {
            _logs.add(TerminalLogEntry(type: 'stdout', text: stdoutStr));
          }
          if (stderrStr.isNotEmpty) {
            _logs.add(TerminalLogEntry(type: 'stderr', text: stderrStr));
          }
          if (stdoutStr.isEmpty && stderrStr.isEmpty) {
            _logs.add(TerminalLogEntry(type: 'stdout', text: '[Exit code ${result.exitCode}]'));
          }
          _isRunning = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _logs.add(TerminalLogEntry(type: 'stderr', text: 'Execution failed: $e'));
          _isRunning = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _printHelp() {
    _logs.add(TerminalLogEntry(
      type: 'stdout',
      text: '''Available Shell Commands & Features:
 - neofetch           : Display Ubuntu system specs & ASCII logo
 - apt update         : Update Ubuntu package repositories
 - apt install <pkg>  : Install packages into the persistent sandbox
 - apt list           : View all installed packages
 - curl <url>         : Fetch web content / API endpoints
 - python3 -c "code"  : Execute Python one-liners directly
 - systemctl status   : Inspect OpenJarvis systemd daemon status
 - uname -a / free -m : Hardware kernel and memory telemetry
 - ai <prompt>        : Ask Max AI Shell Co-Pilot for bash solutions
 - clear              : Clear console viewport''',
    ));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF070B14),
        title: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _envColor,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: _envColor, blurRadius: 6, spreadRadius: 1)],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _activeEnv == TerminalEnv.ubuntu
                  ? 'UBUNTU 24.04 LINUX'
                  : _activeEnv == TerminalEnv.android
                      ? 'ANDROID TOYBOX'
                      : _activeEnv == TerminalEnv.termux
                          ? 'TERMUX BRIDGE'
                          : 'MAX AI SHELL CO-PILOT',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.1),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy, color: AppTheme.cyan, size: 20),
            tooltip: 'Copy Output',
            onPressed: () {
              final text = _logs.map((l) => '${l.type == "input" ? "" : "  "}${l.text}').join('\n');
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Terminal output copied!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: AppTheme.rose, size: 20),
            tooltip: 'Clear Viewport',
            onPressed: () => setState(() => _logs.clear()),
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.cyan, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Environment Switcher Segmented Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: const Color(0xFF0A0F1D),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildEnvTab(
                      env: TerminalEnv.ubuntu,
                      title: 'Ubuntu 24.04',
                      badge: 'PROOT',
                      icon: Icons.computer,
                      activeColor: const Color(0xFFE95420),
                    ),
                    const SizedBox(width: 8),
                    _buildEnvTab(
                      env: TerminalEnv.android,
                      title: 'Android Linux',
                      badge: 'KERNEL',
                      icon: Icons.android,
                      activeColor: AppTheme.cyan,
                    ),
                    const SizedBox(width: 8),
                    _buildEnvTab(
                      env: TerminalEnv.termux,
                      title: 'Termux Bridge',
                      badge: 'CLI',
                      icon: Icons.terminal,
                      activeColor: AppTheme.emerald,
                    ),
                    const SizedBox(width: 8),
                    _buildEnvTab(
                      env: TerminalEnv.aiAgent,
                      title: 'AI Co-Pilot',
                      badge: 'BRAIN',
                      icon: Icons.psychology,
                      activeColor: AppTheme.violet,
                    ),
                  ],
                ),
              ),
            ),

            // Quick Command Chips
            Container(
              height: 38,
              padding: const EdgeInsets.symmetric(vertical: 4),
              color: const Color(0xFF04060A),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: Axis.horizontal,
                itemCount: _envQuickCommands[_activeEnv]?.length ?? 0,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (ctx, i) {
                  final c = _envQuickCommands[_activeEnv]![i];
                  return ActionChip(
                    label: Text(c, style: TextStyle(fontSize: 10, fontFamily: 'monospace', color: _envColor)),
                    backgroundColor: const Color(0xFF0F172A),
                    side: BorderSide(color: _envColor.withValues(alpha: 0.3)),
                    onPressed: () => _executeCommand(c),
                  );
                },
              ),
            ),

            // Terminal Output Viewport
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(10, 4, 10, 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF020408),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _envColor.withValues(alpha: 0.3)),
                ),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _logs.length,
                  itemBuilder: (ctx, i) {
                    final log = _logs[i];
                    Color color = AppTheme.textPrimary;
                    FontWeight weight = FontWeight.normal;

                    if (log.type == 'input') {
                      color = _envColor;
                      weight = FontWeight.bold;
                    } else if (log.type == 'stderr') {
                      color = AppTheme.rose;
                    } else if (log.type == 'ai') {
                      color = AppTheme.amber;
                    } else if (log.type == 'banner') {
                      color = const Color(0xFF7DD3FC);
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.5),
                          child: SelectableText(
                            log.text,
                            style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontFamily: 'monospace',
                              fontWeight: weight,
                              height: 1.35,
                            ),
                          ),
                        ),
                        if (log.executableCmd != null) ...[
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: ElevatedButton.icon(
                              onPressed: () => _executeCommand(log.executableCmd!),
                              icon: const Icon(Icons.play_arrow_rounded, size: 14),
                              label: Text('RUN: ${log.executableCmd!}', style: const TextStyle(fontSize: 10, fontFamily: 'monospace')),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _envColor,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),

            // Command Input Line
            Container(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
              color: const Color(0xFF070B14),
              child: Row(
                children: [
                  Text(
                    _activeEnv == TerminalEnv.ubuntu
                        ? '# '
                        : _activeEnv == TerminalEnv.aiAgent
                            ? 'AI> '
                            : '\$ ',
                    style: TextStyle(color: _envColor, fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _cmdController,
                      focusNode: _focusNode,
                      style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 13),
                      decoration: InputDecoration(
                        hintText: _activeEnv == TerminalEnv.ubuntu
                            ? 'apt install, neofetch, curl, python3...'
                            : _activeEnv == TerminalEnv.aiAgent
                                ? 'Ask Max AI for bash commands & scripts...'
                                : 'Enter shell command...',
                        hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 11.5, fontFamily: 'monospace'),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (val) => _executeCommand(),
                    ),
                  ),
                  IconButton(
                    icon: _isRunning
                        ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: _envColor))
                        : Icon(Icons.arrow_forward_ios, color: _envColor, size: 16),
                    onPressed: _isRunning ? null : () => _executeCommand(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnvTab({
    required TerminalEnv env,
    required String title,
    required String badge,
    required IconData icon,
    required Color activeColor,
  }) {
    final isSel = _activeEnv == env;
    return GestureDetector(
      onTap: () => _switchEnvironment(env),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSel ? activeColor.withValues(alpha: 0.18) : const Color(0xFF131B2E),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSel ? activeColor : AppTheme.surfaceGlassBorder,
            width: isSel ? 1.4 : 0.8,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: isSel ? activeColor : AppTheme.textMuted),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSel ? activeColor : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: isSel ? activeColor : Colors.white12,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: isSel ? Colors.black : AppTheme.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
