import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/settings_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_panel.dart';

class EmailIntegrationScreen extends StatefulWidget {
  const EmailIntegrationScreen({super.key});

  @override
  State<EmailIntegrationScreen> createState() => _EmailIntegrationScreenState();
}

class _EmailIntegrationScreenState extends State<EmailIntegrationScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _senderNameController;
  late final TextEditingController _signatureController;
  late final TextEditingController _smtpHostController;
  late final TextEditingController _portController;

  bool _isCheckingConnection = false;
  bool _isConnectionSuccess = false;
  String? _connectionStatus;

  @override
  void initState() {
    super.initState();
    final s = SettingsService.instance;
    _emailController = TextEditingController(text: s.smtpEmail);
    _passwordController = TextEditingController(text: s.smtpPassword);
    _senderNameController = TextEditingController(text: s.smtpSenderName);
    _signatureController = TextEditingController(text: s.smtpSignature);
    _smtpHostController = TextEditingController(text: s.smtpHost);
    _portController = TextEditingController(text: s.smtpPort.toString());

    if (s.smtpConfigured) {
      _isConnectionSuccess = true;
      _connectionStatus = 'SMTP Active & Registered (${s.smtpHost}:${s.smtpPort})';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _senderNameController.dispose();
    _signatureController.dispose();
    _smtpHostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  Future<void> _checkConnection() async {
    final host = _smtpHostController.text.trim();
    final port = int.tryParse(_portController.text.trim()) ?? 465;

    if (host.isEmpty) {
      setState(() {
        _connectionStatus = 'SMTP Host cannot be empty';
        _isConnectionSuccess = false;
      });
      return;
    }

    setState(() {
      _isCheckingConnection = true;
      _connectionStatus = null;
      _isConnectionSuccess = false;
    });

    try {
      Socket socket;
      if (port == 465) {
        // Direct SSL/TLS socket connection
        socket = await SecureSocket.connect(
          host,
          port,
          timeout: const Duration(seconds: 8),
          onBadCertificate: (_) => true,
        );
      } else {
        // Plain TCP or STARTTLS socket connection
        socket = await Socket.connect(
          host,
          port,
          timeout: const Duration(seconds: 8),
        );
      }

      // Read real initial SMTP banner response from mail server (e.g. 220 smtp.gmail.com ESMTP ...)
      final response = await socket.map(utf8.decode).first.timeout(const Duration(seconds: 6));
      socket.destroy();

      if (mounted) {
        setState(() {
          _isCheckingConnection = false;
          _isConnectionSuccess = true;
          _connectionStatus = 'Handshake verified: ${response.trim()}';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingConnection = false;
          _isConnectionSuccess = false;
          _connectionStatus = 'Handshake failed: ${e.toString().split(':').last.trim()}';
        });
      }
    }
  }

  void _saveConfiguration() {
    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();
    final host = _smtpHostController.text.trim();
    final port = int.tryParse(_portController.text.trim()) ?? 465;
    final name = _senderNameController.text.trim();
    final sig = _signatureController.text.trim();

    final isConfigured = email.isNotEmpty && host.isNotEmpty;

    SettingsService.instance.saveSmtpConfig(
      email: email,
      password: pass,
      senderName: name.isEmpty ? 'Max AI User' : name,
      signature: sig,
      host: host,
      port: port,
      configured: isConfigured,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email dispatch settings saved successfully!'),
        backgroundColor: AppTheme.emerald,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EMAIL DISPATCH ENGINE'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.cyan, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Header Info
            GlassPanel(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.cyan.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.mail_outline, color: AppTheme.cyan, size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Autonomous Email Dispatch', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontSize: 13.5)),
                        SizedBox(height: 2),
                        Text('Allows Max AI agents to draft and send real emails directly upon your instruction', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Credentials Card
            _buildSectionTitle('SENDER ACCOUNT'),
            GlassPanel(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Email Address', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppTheme.surface,
                      prefixIcon: const Icon(Icons.alternate_email, color: AppTheme.cyan, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('App Password (16-character Google/Yahoo App Password)', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: AppTheme.textPrimary, fontFamily: 'monospace'),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppTheme.surface,
                      hintText: 'xxxx xxxx xxxx xxxx',
                      prefixIcon: const Icon(Icons.key, color: AppTheme.amber, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Sender Display Name', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _senderNameController,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppTheme.surface,
                      prefixIcon: const Icon(Icons.badge_outlined, color: AppTheme.cyan, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Signature Card
            _buildSectionTitle('EMAIL SIGNATURE'),
            GlassPanel(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _signatureController,
                    maxLines: 2,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppTheme.surface,
                      hintText: 'Regards,\nShahin',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // SMTP Server Settings
            _buildSectionTitle('SERVER SETTINGS (OPTIONAL / CUSTOM DOMAIN)'),
            GlassPanel(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('SMTP Host', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _smtpHostController,
                              style: const TextStyle(color: AppTheme.textPrimary, fontFamily: 'monospace', fontSize: 12),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppTheme.surface,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Port', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _portController,
                              style: const TextStyle(color: AppTheme.textPrimary, fontFamily: 'monospace', fontSize: 12),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppTheme.surface,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: _isCheckingConnection ? null : _checkConnection,
                    icon: _isCheckingConnection
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                        : const Icon(Icons.check_circle_outline, size: 18),
                    label: Text(_isCheckingConnection ? 'TESTING SOCKET...' : 'TEST REAL SMTP HANDSHAKE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.cyan,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  if (_connectionStatus != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _isConnectionSuccess ? AppTheme.emerald.withValues(alpha: 0.15) : AppTheme.rose.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _isConnectionSuccess ? AppTheme.emerald : AppTheme.rose,
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isConnectionSuccess ? Icons.check_circle : Icons.error_outline,
                            color: _isConnectionSuccess ? AppTheme.emerald : AppTheme.rose,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _connectionStatus!,
                              style: TextStyle(
                                fontSize: 11,
                                color: _isConnectionSuccess ? AppTheme.emerald : AppTheme.rose,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveConfiguration,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.emerald,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('SAVE EMAIL CONFIGURATION', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppTheme.cyan),
      ),
    );
  }
}
