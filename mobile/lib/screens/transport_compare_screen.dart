import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:smart_expense_co2/services/api_service.dart';
import 'package:smart_expense_co2/utils/app_theme.dart';

class TransportCompareScreen extends StatefulWidget {
  const TransportCompareScreen({super.key});

  @override
  State<TransportCompareScreen> createState() => _TransportCompareScreenState();
}

class _TransportCompareScreenState extends State<TransportCompareScreen> {
  double _distanceKm = 10.0;
  List<dynamic> _modes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchComparison();
  }

  Future<void> _fetchComparison() async {
    final data = await apiService.compareTransport(_distanceKm);
    if (mounted && data != null) {
      setState(() {
        _modes = data['comparison'] ?? [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transport Carbon Comparator', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDistanceSlider(isDark),
            const SizedBox(height: 24),
            Text(
              'Side-by-Side Transport Comparison',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 14),
            if (_isLoading)
              const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
            else
              ..._modes.map((mode) => _buildModeCard(mode, isDark)),
          ],
        ),
      ),
    );
  }

  Future<void> _showCustomDistanceDialog() async {
    final controller = TextEditingController(text: _distanceKm.toStringAsFixed(1));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final newDistStr = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('✏️ Custom Trip Distance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter exact trip distance in km (e.g. 2.5, 7.8, 14.2):', style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Distance (km)',
                suffixText: 'km',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Apply', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (newDistStr != null && newDistStr.isNotEmpty) {
      final parsed = double.tryParse(newDistStr);
      if (parsed != null && parsed > 0) {
        setState(() {
          _distanceKm = parsed;
        });
        _fetchComparison();
      }
    }
  }

  Widget _buildDistanceSlider(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TRIP DISTANCE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
              InkWell(
                onTap: _showCustomDistanceDialog,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_distanceKm.toStringAsFixed(1)} km',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.edit_rounded, size: 14, color: AppTheme.primaryGreen),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Slider(
            value: _distanceKm.clamp(0.5, 50.0),
            min: 0.5,
            max: 50.0,
            divisions: 99,
            activeColor: AppTheme.primaryGreen,
            onChanged: (val) {
              setState(() => _distanceKm = val);
              _fetchComparison();
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('0.5 km', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('25.0 km', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('50.0 km', style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard(Map<String, dynamic> mode, bool isDark) {
    final title = mode['mode'] as String;
    final co2 = (mode['co2_kg'] as num).toDouble();
    final cost = (mode['cost_inr'] as num).toDouble();
    final xp = (mode['xp_reward'] as num).toInt();
    final badge = mode['badge'] as String;

    final isZero = co2 == 0.0;

    return FadeInUp(
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.cardShadow,
          border: Border.all(
            color: isZero ? AppTheme.primaryGreen.withOpacity(0.5) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isZero ? AppTheme.primaryGreen.withOpacity(0.15) : Colors.blue.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: isZero ? AppTheme.primaryGreen : Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text('Est: ₹${cost.toStringAsFixed(0)}', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                      if (xp > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('+$xp XP', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFFFD700))),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${co2.toStringAsFixed(2)} kg',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isZero ? AppTheme.primaryGreen : (co2 > 1.5 ? AppTheme.error : Colors.amber.shade700),
                  ),
                ),
                Text('CO₂ Emissions', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
