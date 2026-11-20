import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/rainbow_edge_glow.dart';
import 'chat_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isBackCam = true;
  bool _isScanning = false;
  String _hudStatus = '> \$STANDBY — session shuru karo, Maya ko aankhein do 🎤';

  void _captureAndScan() {
    setState(() {
      _isScanning = true;
      _hudStatus = '> \$ANALYZING — Gemini Vision is reading frame...';
    });

    final chatProvider = context.read<ChatProvider>();
    chatProvider.sendMessage('Describe what you see in the active camera scanner.');

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _hudStatus = '> \$COMPLETE — Result sent to Maya Chat!';
        });
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final edgeGlow = context.watch<ChatProvider>().edgeGlowEnabled;

    return RainbowEdgeGlow(
      enabled: edgeGlow,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.black,
        drawer: CustomDrawer(selectedIndex: 1, onSelectIndex: (_) {}),
        body: SafeArea(
          child: Column(
            children: [
              // Scanner Header matching frame_010.jpg
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => _scaffoldKey.currentState?.openDrawer(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.menu_rounded, color: Colors.white, size: 22),
                      ),
                    ),
                    const Text(
                      'Scanner',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        children: [
                          const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 22),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Cyberpunk Camera Viewport matching frame_010.jpg
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF070B14),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF1E3A8A).withOpacity(0.4)),
                  ),
                  child: Stack(
                    children: [
                      // HUD Info Lines
                      Positioned(
                        top: 16,
                        left: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(color: Color(0xFF38BDF8), shape: BoxShape.circle),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'MAYA VISION',
                                      style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'monospace', letterSpacing: 1.2),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.5)),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _isBackCam ? 'BACK CAM' : 'FRONT CAM',
                                    style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 10, fontFamily: 'monospace'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _hudStatus,
                              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5, fontFamily: 'monospace'),
                            ),
                          ],
                        ),
                      ),

                      // Futuristic Reticle in Center
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 210,
                              height: 210,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.35), width: 1.5),
                              ),
                            ),
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.7), width: 2),
                              ),
                            ),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF38BDF8),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Bottom HUD Readout
                      Positioned(
                        bottom: 90,
                        left: 18,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'FRM 004282  SIG CA',
                              style: TextStyle(color: Color(0xFF0284C7), fontSize: 11, fontFamily: 'monospace'),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'AI-FEED READY · GEMINI 3.8',
                              style: TextStyle(color: Color(0xFF0284C7), fontSize: 11, fontFamily: 'monospace'),
                            ),
                          ],
                        ),
                      ),

                      // Camera Action Controls matching frame_010.jpg
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Flip
                            GestureDetector(
                              onTap: () => setState(() => _isBackCam = !_isBackCam),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.flip_camera_android_rounded, color: Color(0xFF94A3B8), size: 26),
                                  SizedBox(height: 4),
                                  Text('FLIP', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontFamily: 'monospace')),
                                ],
                              ),
                            ),

                            // Center Shutter Button
                            GestureDetector(
                              onTap: _captureAndScan,
                              child: Container(
                                width: 68,
                                height: 68,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF38BDF8).withOpacity(0.8),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: _isScanning
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(color: Color(0xFF2563EB), strokeWidth: 2.5),
                                        )
                                      : Container(
                                          width: 54,
                                          height: 54,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.black, width: 2),
                                          ),
                                        ),
                                ),
                              ),
                            ),

                            // Rec
                            GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recording frame sequence...')));
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.videocam_rounded, color: Color(0xFF94A3B8), size: 26),
                                  SizedBox(height: 4),
                                  Text('REC', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontFamily: 'monospace')),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
