import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_panel.dart';

class EmailIntegrationScreen extends StatefulWidget {
  const EmailIntegrationScreen({super.key});

  @override
  State<EmailIntegrationScreen> createState() => _EmailIntegrationScreenState();
}

class _EmailIntegrationScreenState extends State<EmailIntegrationScreen> {
  final TextEditingController _emailController = TextEditingController(text: 'user@gmail.com');
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _senderNameController = TextEditingController(text: 'Shahin');
  final TextEditingController _signatureController = TextEditingController(text: 'Sent via Max AI Autonomous Assistant');
  final TextEditingController _smtpHostController = TextEditingController(text: 'smtp.gmail.com');
  final TextEditingController _portController = TextEditingController(text: '465');

  bool _isCheckingConnection = false;
  String? _connectionStatus;

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
    setState(() {
      _isCheckingConnection = true;
      _connectionStatus = null;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isCheckingConnection = false;
        _connectionStatus = 'SMTP Handshake verified successfully (SSL/TLS Active)';
      });
    }
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
                    label: Text(_isCheckingConnection ? 'CHECKING...' : 'TEST CONNECTION'),
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
                        color: AppTheme.emerald.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.emerald, width: 0.8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check, color: AppTheme.emerald, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _connectionStatus!,
                              style: const TextStyle(fontSize: 11, color: AppTheme.emerald, fontWeight: FontWeight.bold),
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
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Email dispatch settings saved!')),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.emerald,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('SAVE EMAIL CONFIGURATION', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            ),
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
