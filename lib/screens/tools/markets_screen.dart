import 'package:flutter/material.dart';
import '../../services/ai_engine_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_panel.dart';

class MarketsScreen extends StatefulWidget {
  const MarketsScreen({super.key});

  @override
  State<MarketsScreen> createState() => _MarketsScreenState();
}

class _MarketsScreenState extends State<MarketsScreen> {
  final TextEditingController _queryController = TextEditingController();
  bool _isAnalyzing = false;
  String? _marketAnalysis;

  final List<Map<String, dynamic>> _tickers = [
    {'symbol': 'BTC/USD', 'name': 'Bitcoin', 'price': '\$91,420.00', 'change': '+3.4%', 'isUp': true},
    {'symbol': 'ETH/USD', 'name': 'Ethereum', 'price': '\$3,180.50', 'change': '+2.1%', 'isUp': true},
    {'symbol': 'SOL/USD', 'name': 'Solana', 'price': '\$214.20', 'change': '+6.8%', 'isUp': true},
    {'symbol': 'NVDA', 'name': 'NVIDIA Corp', 'price': '\$148.80', 'change': '-0.5%', 'isUp': false},
    {'symbol': 'GOOGL', 'name': 'Alphabet Inc', 'price': '\$182.10', 'change': '+1.2%', 'isUp': true},
    {'symbol': 'GOLD', 'name': 'Gold Spot', 'price': '\$2,684.00', 'change': '+0.4%', 'isUp': true},
  ];

  Future<void> _runMarketAnalysis(String prompt) async {
    setState(() {
      _isAnalyzing = true;
      _marketAnalysis = null;
    });

    try {
      final reply = await AIEngineService.instance.sendMessage(
        prompt: 'You are Max AI Financial & Market Intelligence Specialist. Provide high-level macroeconomic sentiment, technical catalysts, and risk factors for: $prompt. Be clear, concise, and structured.',
      );

      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _marketAnalysis = reply;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _marketAnalysis = 'Market Intelligence Error: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MARKETS & FINANCIAL INTELLIGENCE'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.cyan, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Market Query Box
            GlassPanel(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _queryController,
                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'Ask about BTC, Tech Stocks, Gold or Fed Rates...',
                        hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (val) {
                        if (val.trim().isNotEmpty) _runMarketAnalysis(val.trim());
                      },
                    ),
                  ),
                  IconButton(
                    icon: _isAnalyzing
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.cyan))
                        : const Icon(Icons.analytics, color: AppTheme.cyan),
                    onPressed: () {
                      final q = _queryController.text.trim();
                      if (q.isNotEmpty) _runMarketAnalysis(q);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Market Ticker Grid
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'LIVE WATCHLIST & METRICS',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppTheme.cyan),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.6,
              ),
              itemCount: _tickers.length,
              itemBuilder: (ctx, i) {
                final t = _tickers[i];
                final isUp = t['isUp'] as bool;
                return GestureDetector(
                  onTap: () {
                    _queryController.text = '${t['symbol']} Technical & Fundamental Outlook';
                    _runMarketAnalysis(_queryController.text);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isUp ? AppTheme.emerald.withValues(alpha: 0.3) : AppTheme.rose.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(t['symbol'] as String, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontSize: 13)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: (isUp ? AppTheme.emerald : AppTheme.rose).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                t['change'] as String,
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isUp ? AppTheme.emerald : AppTheme.rose),
                              ),
                            ),
                          ],
                        ),
                        Text(t['name'] as String, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                        Text(t['price'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontFamily: 'monospace')),
                      ],
                    ),
                  ),
                );
              },
            ),

            if (_marketAnalysis != null) ...[
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'MAX AI MARKET SYNTHESIS',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppTheme.emerald),
                ),
              ),
              GlassPanel(
                borderColor: AppTheme.emerald.withValues(alpha: 0.4),
                padding: const EdgeInsets.all(14),
                child: Text(
                  _marketAnalysis!,
                  style: const TextStyle(fontSize: 12.5, color: AppTheme.textPrimary, height: 1.45),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
