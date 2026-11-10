import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../services/ai_engine_service.dart';
import '../../services/skill_registry_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_panel.dart';

class MarketTickerItem {
  final String symbol;
  final String displayName;
  final double price;
  final double changePercent;
  final double high24h;
  final double low24h;
  final double volume;

  MarketTickerItem({
    required this.symbol,
    required this.displayName,
    required this.price,
    required this.changePercent,
    required this.high24h,
    required this.low24h,
    required this.volume,
  });

  bool get isUp => changePercent >= 0;
}

class MarketsScreen extends StatefulWidget {
  const MarketsScreen({super.key});

  @override
  State<MarketsScreen> createState() => _MarketsScreenState();
}

class _MarketsScreenState extends State<MarketsScreen> {
  final TextEditingController _queryController = TextEditingController();
  bool _isLoadingPrices = false;
  bool _isAnalyzing = false;
  String? _marketAnalysis;
  String? _errorMessage;

  final List<MarketTickerItem> _liveTickers = [];

  @override
  void initState() {
    super.initState();
    _fetchLiveMarketData();
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _fetchLiveMarketData() async {
    if (!mounted) return;
    setState(() {
      _isLoadingPrices = true;
      _errorMessage = null;
    });

    try {
      final uri = Uri.parse(
        'https://api.binance.com/api/v3/ticker/24hr?symbols=[%22BTCUSDT%22,%22ETHUSDT%22,%22SOLUSDT%22,%22BNBUSDT%22,%22XRPUSDT%22,%22DOGEUSDT%22]',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        final names = {
          'BTCUSDT': 'Bitcoin',
          'ETHUSDT': 'Ethereum',
          'SOLUSDT': 'Solana',
          'BNBUSDT': 'BNB Chain',
          'XRPUSDT': 'Ripple XRP',
          'DOGEUSDT': 'Dogecoin',
        };

        final List<MarketTickerItem> parsed = [];
        for (final item in data) {
          final sym = item['symbol'] as String;
          final lastPrice = double.tryParse(item['lastPrice']?.toString() ?? '0') ?? 0.0;
          final changePct = double.tryParse(item['priceChangePercent']?.toString() ?? '0') ?? 0.0;
          final high = double.tryParse(item['highPrice']?.toString() ?? '0') ?? 0.0;
          final low = double.tryParse(item['lowPrice']?.toString() ?? '0') ?? 0.0;
          final vol = double.tryParse(item['volume']?.toString() ?? '0') ?? 0.0;

          parsed.add(
            MarketTickerItem(
              symbol: sym.replaceAll('USDT', '/USD'),
              displayName: names[sym] ?? sym,
              price: lastPrice,
              changePercent: changePct,
              high24h: high,
              low24h: low,
              volume: vol,
            ),
          );
        }

        if (mounted) {
          setState(() {
            _liveTickers.clear();
            _liveTickers.addAll(parsed);
            _isLoadingPrices = false;
          });
        }
      } else {
        throw Exception('Server responded with HTTP ${res.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPrices = false;
          _errorMessage = 'Could not fetch live tickers: $e';
        });
      }
    }
  }

  Future<void> _runMarketAnalysis(String prompt) async {
    setState(() {
      _isAnalyzing = true;
      _marketAnalysis = null;
    });

    final tickerContext = _liveTickers.isNotEmpty
        ? 'Current Real Live Prices (Binance Feed):\n' +
            _liveTickers.map((t) => '- ${t.symbol} (${t.displayName}): \$${t.price.toStringAsFixed(2)} (${t.changePercent >= 0 ? "+" : ""}${t.changePercent.toStringAsFixed(2)}% 24h, High: \$${t.high24h}, Low: \$${t.low24h})').join('\n')
        : 'Live market prices are updating.';

    try {
      final reply = await AIEngineService.instance.sendMessage(
        prompt: 'You are Max AI Financial & Market Intelligence Specialist with access to live order books.\n\n$tickerContext\n\nUser Question/Instruction:\n$prompt\n\nProvide institutional-grade analysis: market trend, sentiment, key support/resistance levels, macro drivers, and risk factors. Be actionable and objective.',
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MARKETS & FINANCIAL INTELLIGENCE'),
        actions: [
          IconButton(
            icon: _isLoadingPrices
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.emerald))
                : const Icon(Icons.refresh, color: AppTheme.emerald),
            tooltip: 'Refresh Live Prices',
            onPressed: _isLoadingPrices ? null : _fetchLiveMarketData,
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.cyan, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: SkillRegistryService.instance,
          builder: (context, _) {
            final isSkillInstalled = SkillRegistryService.instance.isSkillInstalled('markets_scanner');

            return RefreshIndicator(
              onRefresh: _fetchLiveMarketData,
              color: AppTheme.cyan,
              backgroundColor: AppTheme.surfaceElevated,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // Skill status warning if not installed
                  if (!isSkillInstalled)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.amber, width: 1),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: AppTheme.amber, size: 22),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Financial Markets Scanner skill is not installed. Live analysis capability is limited.',
                              style: TextStyle(color: AppTheme.amber, fontSize: 11),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => SkillRegistryService.instance.installSkill('markets_scanner'),
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.amber, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                            child: const Text('INSTALL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),

                  // Search & Query Box
                  GlassPanel(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _queryController,
                            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                            decoration: const InputDecoration(
                              hintText: 'Ask Max AI: Market trend, Bitcoin catalysts, Fed rates...',
                              hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 11.5),
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
                          tooltip: 'Run AI Macro Analysis',
                          onPressed: () {
                            final q = _queryController.text.trim();
                            _runMarketAnalysis(q.isNotEmpty ? q : 'Synthesize current crypto market structure and institutional sentiment.');
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Live Ticker Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.emerald)),
                          const SizedBox(width: 6),
                          const Text(
                            'LIVE BINANCE TICKERS (REAL-TIME)',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppTheme.emerald),
                          ),
                        ],
                      ),
                      Text(
                        _isLoadingPrices ? 'Updating...' : '${_liveTickers.length} Pairs Live',
                        style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(_errorMessage!, style: const TextStyle(color: AppTheme.rose, fontSize: 11)),
                    ),

                  if (_liveTickers.isEmpty && _isLoadingPrices)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: CircularProgressIndicator(color: AppTheme.cyan),
                      ),
                    )
                  else
                    ..._liveTickers.map((t) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: GlassPanel(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          onTap: () {
                            _queryController.text = 'Analyze ${t.displayName} (${t.symbol}) price momentum, volume profile and next target.';
                            _runMarketAnalysis(_queryController.text);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(t.displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppTheme.textPrimary)),
                                      const SizedBox(width: 6),
                                      Text(t.symbol, style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: AppTheme.textMuted)),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '24h H: \$${t.high24h.toStringAsFixed(2)} • L: \$${t.low24h.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 9.5, color: AppTheme.textMuted),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '\$${t.price >= 1 ? t.price.toStringAsFixed(2) : t.price.toStringAsFixed(4)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary, fontFamily: 'monospace'),
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: (t.isUp ? AppTheme.emerald : AppTheme.rose).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${t.isUp ? "+" : ""}${t.changePercent.toStringAsFixed(2)}%',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                        color: t.isUp ? AppTheme.emerald : AppTheme.rose,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                  const SizedBox(height: 14),

                  // AI Analysis Viewport
                  if (_marketAnalysis != null) ...[
                    const Row(
                      children: [
                        Icon(Icons.auto_awesome, color: AppTheme.cyan, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'MAX AI QUANTITATIVE MARKET SYNTHESIS',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppTheme.cyan),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    GlassPanel(
                      padding: const EdgeInsets.all(14),
                      borderColor: AppTheme.cyan.withValues(alpha: 0.3),
                      child: SelectableText(
                        _marketAnalysis!,
                        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12.5, height: 1.5),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
