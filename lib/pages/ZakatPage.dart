import 'package:flutter/material.dart';
import 'package:prayer_time_app/components/custom_app_bar.dart';

class ZakatPage extends StatefulWidget {
  @override
  _ZakatPageState createState() => _ZakatPageState();
}

class _ZakatPageState extends State<ZakatPage> {
  final _cashController = TextEditingController();
  final _goldController = TextEditingController(); // This is the value of gold/silver owned
  final _businessController = TextEditingController(); 
  final _otherController = TextEditingController();
  final _debtsController = TextEditingController();
  final _priceController = TextEditingController(); // Price per gram of selected metal
  
  String _nisabType = "gold"; // "gold" or "silver"
  double _totalZakat = 0.0;
  double _netWealth = 0.0;
  double _nisabValue = 0.0;
  bool _isEligible = false;
  final double _zakatRate = 0.025; // 2.5%

  void _calculateZakat() {
    double cash = double.tryParse(_cashController.text) ?? 0.0;
    double metalValue = double.tryParse(_goldController.text) ?? 0.0;
    double business = double.tryParse(_businessController.text) ?? 0.0;
    double other = double.tryParse(_otherController.text) ?? 0.0;
    double debts = double.tryParse(_debtsController.text) ?? 0.0;
    double unitPrice = double.tryParse(_priceController.text) ?? 0.0;

    // Nisab calculation
    // Gold: 87.48 grams
    // Silver: 612.36 grams
    if (_nisabType == "gold") {
      _nisabValue = unitPrice * 87.48;
    } else {
      _nisabValue = unitPrice * 612.36;
    }
    
    // Net wealth = Assets - Liabilities
    _netWealth = (cash + metalValue + business + other) - debts;
    
    setState(() {
      if (_netWealth >= _nisabValue && _nisabValue > 0) {
        _isEligible = true;
        _totalZakat = _netWealth * _zakatRate;
      } else {
        _isEligible = false;
        _totalZakat = 0.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: customAppBar(context, "Zakat Calculator", back: false),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF0f0f1e), const Color(0xFF1a1a2e)]
                : [const Color(0xFFf5f7fa), const Color(0xFFc3cfe2)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildResultCard(isDark),
              const SizedBox(height: 30),
              
              const Text(
                "1. Nisab Threshold Config",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // Nisab Type Toggle
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1e1e2e) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _buildToggleButton("Gold", "gold", isDark),
                    _buildToggleButton("Silver", "silver", isDark),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              _buildInputField(
                "Current ${_nisabType[0].toUpperCase()}${_nisabType.substring(1)} Price (per gram)", 
                _priceController, 
                Icons.monetization_on, 
                isDark, 
                helper: "Used to calculate Nisab (${_nisabType == 'gold' ? '87.48g gold' : '612.36g silver'})"
              ),
              const SizedBox(height: 20),

              const Text(
                "2. Your Assets (Zakatable)",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildInputField("Cash & Bank Balances", _cashController, Icons.account_balance_wallet, isDark),
              _buildInputField("Gold/Silver Owned (Value)", _goldController, Icons.brightness_high, isDark),
              _buildInputField("Business Assets/Stock", _businessController, Icons.storefront, isDark),
              _buildInputField("Other Investments", _otherController, Icons.trending_up, isDark),
              
              const SizedBox(height: 20),
              const Text(
                "3. Liabilities (Deductible)",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildInputField("Debts & Immediate Bills", _debtsController, Icons.money_off, isDark, helper: "Money you owe others"),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _calculateZakat,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFFe94560) : const Color(0xFF667eea),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: const Text("Calculate Zakat", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "* Zakat is obligatory (Fard) at 2.5% only if your Net Wealth exceeds the Nisab (${_nisabValue.toStringAsFixed(2)}) and has been held for one lunar year.",
                style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1e1e2e) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _isEligible ? "Total Zakat Payable" : "Zakat Not Due",
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Text(
            _isEligible ? _totalZakat.toStringAsFixed(2) : "0.00",
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: _isEligible 
                ? (isDark ? const Color(0xFFe94560) : const Color(0xFF667eea))
                : Colors.grey,
            ),
          ),
          const SizedBox(height: 5),
          if (!_isEligible && _netWealth > 0 && _nisabValue > 0)
            Text(
              "Wealth is below Nisab threshold",
              style: TextStyle(fontSize: 12, color: Colors.orange.shade400),
            ),
          if (_isEligible)
            const Text("Your Currency", style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, String value, bool isDark) {
    bool isSelected = _nisabType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _nisabType = value;
          });
          _calculateZakat();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected 
              ? (isDark ? const Color(0xFFe94560) : const Color(0xFF667eea)) 
              : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, IconData icon, bool isDark, {String? helper}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          helperText: helper,
          prefixIcon: Icon(icon, color: isDark ? Colors.white54 : Colors.grey),
          filled: true,
          fillColor: isDark ? const Color(0xFF1e1e2e).withOpacity(0.5) : Colors.white.withOpacity(0.8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: isDark ? const Color(0xFFe94560) : const Color(0xFF667eea)),
          ),
        ),
      ),
    );
  }
}
