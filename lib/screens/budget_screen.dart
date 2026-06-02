import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final TextEditingController _incomeController = TextEditingController();

  final Map<String, TextEditingController> _categoryControllers = {
    'Food': TextEditingController(),
    'Rent': TextEditingController(),
    'Education': TextEditingController(),
    'Transport': TextEditingController(),
    'Savings': TextEditingController(),
  };

  double _totalIncome = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();

    // Add listeners to recalculate when user manually edits
    for (var controller in _categoryControllers.values) {
      controller.addListener(() {
        setState(() {});
      });
    }
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? 'test_user_123';

    if (userId.isNotEmpty) {
      try {
        final data = await ApiService.getBudget(userId);

        if (data != null) {
          _incomeController.text = (data['totalIncome'] ?? 0.0).toStringAsFixed(0);
          _totalIncome = (data['totalIncome'] ?? 0.0).toDouble();

          _categoryControllers['Food']!.text = (data['food'] ?? 0.0).toStringAsFixed(0);
          _categoryControllers['Rent']!.text = (data['rent'] ?? 0.0).toStringAsFixed(0);
          _categoryControllers['Education']!.text = (data['education'] ?? 0.0).toStringAsFixed(0);
          _categoryControllers['Transport']!.text = (data['transport'] ?? 0.0).toStringAsFixed(0);
          _categoryControllers['Savings']!.text = (data['savings'] ?? 0.0).toStringAsFixed(0);
          setState(() {});
          return; // Skip local load
        }
      } catch (e) {
        print('Error loading from API: $e');
      }
    }

    final income = prefs.getDouble('budget_income') ?? 0.0;
    if (income > 0) {
      _incomeController.text = income.toStringAsFixed(0);
      _totalIncome = income;

      _categoryControllers['Food']!.text =
          (prefs.getDouble('budget_food') ?? 0.0).toStringAsFixed(0);
      _categoryControllers['Rent']!.text =
          (prefs.getDouble('budget_rent') ?? 0.0).toStringAsFixed(0);
      _categoryControllers['Education']!.text =
          (prefs.getDouble('budget_education') ?? 0.0).toStringAsFixed(0);
      _categoryControllers['Transport']!.text =
          (prefs.getDouble('budget_transport') ?? 0.0).toStringAsFixed(0);
      _categoryControllers['Savings']!.text =
          (prefs.getDouble('budget_savings') ?? 0.0).toStringAsFixed(0);
      setState(() {});
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save Locally
    await prefs.setDouble('budget_income', _totalIncome);
    await prefs.setDouble('budget_food', double.tryParse(_categoryControllers['Food']!.text) ?? 0.0);
    await prefs.setDouble('budget_rent', double.tryParse(_categoryControllers['Rent']!.text) ?? 0.0);
    await prefs.setDouble('budget_education', double.tryParse(_categoryControllers['Education']!.text) ?? 0.0);
    await prefs.setDouble('budget_transport', double.tryParse(_categoryControllers['Transport']!.text) ?? 0.0);
    await prefs.setDouble('budget_savings', double.tryParse(_categoryControllers['Savings']!.text) ?? 0.0);

    // Save to Backend API
    final userId = prefs.getString('user_id') ?? 'test_user_123';
    if (userId.isNotEmpty) {
      try {
        await ApiService.saveBudget({
          'user_id': userId,
          'totalIncome': _totalIncome,
          'food': double.tryParse(_categoryControllers['Food']!.text) ?? 0.0,
          'rent': double.tryParse(_categoryControllers['Rent']!.text) ?? 0.0,
          'education': double.tryParse(_categoryControllers['Education']!.text) ?? 0.0,
          'transport': double.tryParse(_categoryControllers['Transport']!.text) ?? 0.0,
          'savings': double.tryParse(_categoryControllers['Savings']!.text) ?? 0.0,
        });
      } catch (e) {
        print('API save error: $e');
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Budget saved successfully!'),
          backgroundColor: const Color(0xFF58CC02),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _resetData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('budget_income');
    await prefs.remove('budget_food');
    await prefs.remove('budget_rent');
    await prefs.remove('budget_education');
    await prefs.remove('budget_transport');
    await prefs.remove('budget_savings');

    // Reset API data
    final userId = prefs.getString('user_id') ?? 'test_user_123';
    if (userId.isNotEmpty) {
      try {
        await ApiService.saveBudget({
          'user_id': userId,
          'totalIncome': 0.0,
          'food': 0.0,
          'rent': 0.0,
          'education': 0.0,
          'transport': 0.0,
          'savings': 0.0,
        });
      } catch (e) {
        print('API reset error: $e');
      }
    }

    _incomeController.clear();
    for (var controller in _categoryControllers.values) {
      controller.clear();
    }
    setState(() {
      _totalIncome = 0.0;
    });
  }  double get _totalAllocated {
    double total = 0;
    for (var controller in _categoryControllers.values) {
      total += double.tryParse(controller.text) ?? 0.0;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    List<Color> categoryColors = [
      const Color(0xFF58CC02),
      const Color(0xFF1CB0F6),
      const Color(0xFFFF9800),
      const Color(0xFFCE82FF),
      const Color(0xFFFF4B4B),
    ];

    final Map<String, String> sampleAmounts = {
      'Food': '3000',
      'Rent': '4500',
      'Education': '2250',
      'Transport': '2250',
      'Savings': '3000',
    };

    return SafeArea(
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              const Text(
                'Budget Management',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              const SizedBox(height: 32),

              // Income Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _incomeController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Monthly Income (₹)',
                        hintText: 'e.g. 15000',
                        hintStyle: const TextStyle(color: Color(0xFFCCCCCC)),
                        prefixIcon: const Icon(
                          Icons.currency_rupee_rounded,
                          color: Color(0xFF58CC02),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF58CC02),
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _totalIncome = double.tryParse(value) ?? 0.0;
                        });
                      },
                    ),

                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Categories Section
              const Text(
                'Categories',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Column(
                  children: [
                    ..._categoryControllers.entries
                        .toList()
                        .asMap()
                        .entries
                        .map((mapEntry) {
                          int index = mapEntry.key;
                          var entry = mapEntry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color:
                                        categoryColors[index %
                                            categoryColors.length],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    entry.key,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1A1A1A),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: TextField(
                                    controller: entry.value,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.right,
                                    decoration: InputDecoration(
                                      prefixText: '₹ ',
                                      hintText: 'e.g. ${sampleAmounts[entry.key]}',
                                      hintStyle: const TextStyle(color: Color(0xFFCCCCCC)),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Color(0xFF58CC02),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    onChanged: (value) => setState(() {}),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Summary Section
              const Text(
                'Summary',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF58CC02), width: 2),
                ),
                child: Column(
                  children: [
                    _SummaryRow(
                      label: 'Total Income',
                      value: '₹${_totalIncome.toStringAsFixed(0)}',
                    ),
                    const SizedBox(height: 12),
                    _SummaryRow(
                      label: 'Total Allocated',
                      value: '₹${_totalAllocated.toStringAsFixed(0)}',
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0xFF58CC02),
                      ),
                    ),
                    _SummaryRow(
                      label: 'Remaining Balance',
                      value:
                          '₹${(_totalIncome - _totalAllocated).toStringAsFixed(0)}',
                      isBold: true,
                    ),
                    if (_totalAllocated > _totalIncome)
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text(
                          'Your budget exceeds your income.',
                          style: TextStyle(
                            color: Color(0xFFFF4B4B),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Suggested 50/30/20 Budget Section
              if (_totalIncome > 0) ...[
                const Text(
                  'Suggested Budget Breakdown',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Here is a recommended baseline for your expenses. You can compare this to your actual allocations above.',
                        style: TextStyle(color: Color(0xFF666666), fontSize: 14, height: 1.5),
                      ),
                      const SizedBox(height: 16),
                      _SummaryRow(
                        label: 'Food (20%)',
                        value: '₹${(_totalIncome * 0.20).toStringAsFixed(0)}',
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(color: Color(0xFFF0F0F0)),
                      ),
                      _SummaryRow(
                        label: 'Rent (Fixed)',
                        value: '₹${(double.tryParse(_categoryControllers['Rent']!.text) ?? 0.0).toStringAsFixed(0)}',
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(color: Color(0xFFF0F0F0)),
                      ),
                      _SummaryRow(
                        label: 'Education (15%)',
                        value: '₹${(_totalIncome * 0.15).toStringAsFixed(0)}',
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(color: Color(0xFFF0F0F0)),
                      ),
                      _SummaryRow(
                        label: 'Transport (15%)',
                        value: '₹${(_totalIncome * 0.15).toStringAsFixed(0)}',
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(color: Color(0xFFF0F0F0)),
                      ),
                      _SummaryRow(
                        label: 'Savings (20%)',
                        value: '₹${(_totalIncome * 0.20).toStringAsFixed(0)}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _resetData,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(
                          color: Color(0xFFAFAFAF),
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Reset Budget',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1CB0F6),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Save Budget',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 18 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isBold ? const Color(0xFF1A1A1A) : const Color(0xFF444444),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 18 : 16,
            fontWeight: FontWeight.bold,
            color: isBold ? const Color(0xFF1A1A1A) : const Color(0xFF58CC02),
          ),
        ),
      ],
    );
  }
}