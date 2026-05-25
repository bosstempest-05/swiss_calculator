import 'package:flutter/material.dart';

class AgeCalculator extends StatefulWidget {
  const AgeCalculator({super.key});

  @override
  State<AgeCalculator> createState() => _AgeCalculatorState();
}

class _AgeCalculatorState extends State<AgeCalculator> {
  // A great default starting date that will automatically calculate correctly
  DateTime _birthDate = DateTime(2005, 1, 5);

  int _years = 0;
  int _months = 0;
  int _days = 0;

  @override
  void initState() {
    super.initState();
    _calculateAge(); // Calculate initially so the screen isn't blank
  }

  void _calculateAge() {
    DateTime today = DateTime.now();

    int years = today.year - _birthDate.year;
    int months = today.month - _birthDate.month;
    int days = today.day - _birthDate.day;

    if (days < 0) {
      months--;
      // Find out how many days were in the previous month to borrow them
      int prevMonth = today.month == 1 ? 12 : today.month - 1;
      int yearOfPrevMonth = today.month == 1 ? today.year - 1 : today.year;
      int daysInPrevMonth = DateTime(yearOfPrevMonth, prevMonth + 1, 0).day;
      days += daysInPrevMonth;
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    setState(() {
      _years = years;
      _months = months;
      _days = days;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Theme.of(
                context,
              ).colorScheme.primary, // Calendar header color
              onPrimary: Colors.black, // Text color on calendar header
              surface: Theme.of(
                context,
              ).colorScheme.surface, // Background color
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
      _calculateAge();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Grab the adaptive color once for clean access
    final adaptiveTextColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        // ---> FIXED: Removed const, added adaptive color <---
        title: Text(
          'Age Calculator',
          style: TextStyle(color: adaptiveTextColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Makes the back arrow visible in light mode
        iconTheme: IconThemeData(color: adaptiveTextColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date Picker Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Date of Birth',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${_birthDate.day}/${_birthDate.month}/${_birthDate.year}',
                    // ---> FIXED: Removed the const keyword here <---
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: adaptiveTextColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () => _selectDate(context),
                    icon: Icon(
                      Icons.calendar_month,
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    label: Text(
                      'CHANGE DATE',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Result Display
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Current Age',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildAgeBox('Years', _years.toString()),
                        _buildAgeBox('Months', _months.toString()),
                        _buildAgeBox('Days', _days.toString()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgeBox(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          label,
          // ---> FIXED: Removed the const keyword here <---
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
