import 'package:flutter/material.dart';

void main() {
  runApp(const DateCalculatorApp());
}

class DateCalculatorApp extends StatelessWidget {
  const DateCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Date Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const DateCalculatorScreen(),
      },
    );
  }
}

class DateCalculatorScreen extends StatefulWidget {
  const DateCalculatorScreen({super.key});

  @override
  State<DateCalculatorScreen> createState() => _DateCalculatorScreenState();
}

class _DateCalculatorScreenState extends State<DateCalculatorScreen> {
  // Default dates requested: 20/04/2005 and 20/10/2000
  DateTime _date1 = DateTime(2005, 4, 20);
  DateTime _date2 = DateTime(2000, 10, 20);

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _selectDate(BuildContext context, bool isDate1) async {
    final DateTime initialDate = isDate1 ? _date1 : _date2;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isDate1) {
          _date1 = picked;
        } else {
          _date2 = picked;
        }
      });
    }
  }

  Map<String, int> _calculateDifference(DateTime d1, DateTime d2) {
    DateTime start = d1.isBefore(d2) ? d1 : d2;
    DateTime end = d1.isBefore(d2) ? d2 : d1;

    int years = end.year - start.year;
    int months = end.month - start.month;
    int days = end.day - start.day;

    if (days < 0) {
      months -= 1;
      // Get the number of days in the previous month
      final previousMonth = DateTime(end.year, end.month, 0);
      days += previousMonth.day;
    }

    if (months < 0) {
      years -= 1;
      months += 12;
    }

    return {
      'years': years,
      'months': months,
      'days': days,
      'totalDays': end.difference(start).inDays,
    };
  }

  @override
  Widget build(BuildContext context) {
    final diff = _calculateDifference(_date1, _date2);
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Date Calculator'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.date_range_rounded,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 32),
                  if (isDesktop)
                    Row(
                      children: [
                        Expanded(child: _buildDateCard(true, theme)),
                        const SizedBox(width: 24),
                        Expanded(child: _buildDateCard(false, theme)),
                      ],
                    )
                  else ...[
                    _buildDateCard(true, theme),
                    const SizedBox(height: 16),
                    _buildDateCard(false, theme),
                  ],
                  const SizedBox(height: 48),
                  Text(
                    'Difference',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildResultItem(diff['years']!, 'Years', theme),
                      _buildResultItem(diff['months']!, 'Months', theme),
                      _buildResultItem(diff['days']!, 'Days', theme),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Total: ${diff['totalDays']} days',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateCard(bool isDate1, ThemeData theme) {
    final date = isDate1 ? _date1 : _date2;
    final label = isDate1 ? 'First Date' : 'Second Date';

    return InkWell(
      onTap: () => _selectDate(context, isDate1),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(date),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap to change',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(int value, String label, ThemeData theme) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value.toString(),
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
