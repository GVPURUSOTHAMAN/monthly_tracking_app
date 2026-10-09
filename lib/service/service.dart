import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../model/tracckmode.dart';

class ExpenseService {
  static const String _expenseKey = 'expenses';

  // Save expenses permanently
  Future<void> saveExpenses(List<Expense> expenses) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final List<Map<String, dynamic>> data = expenses.map((expense) {
      return {
        'title': expense.title,
        'amount': expense.amount,
        'category': expense.category,
        'date': expense.date.toIso8601String(),
      };
    }).toList();

    final String jsonData = jsonEncode(data);

    await prefs.setString(_expenseKey, jsonData);
  }

  // Load expenses
  Future<List<Expense>> loadExpenses() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // First try the new String format
    try {
      final String? jsonData = prefs.getString(_expenseKey);

      if (jsonData != null && jsonData.isNotEmpty) {
        return _decodeExpenses(jsonData);
      }
    } catch (e) {
      // Old data may be List<String>.
      // We handle it below.
    }

    // Handle old List<String> data
    try {
      final List<String>? oldData = prefs.getStringList(_expenseKey);

      if (oldData != null && oldData.isNotEmpty) {
        final List<Expense> oldExpenses = oldData.map((item) {
          final Map<String, dynamic> data =
              jsonDecode(item) as Map<String, dynamic>;

          return Expense(
            title: data['title']?.toString() ?? '',
            amount: double.tryParse(data['amount'].toString()) ?? 0.0,
            category: data['category']?.toString() ?? 'Other',
            date:
                DateTime.tryParse(data['date']?.toString() ?? '') ??
                DateTime.now(),
          );
        }).toList();

        // Convert old data to the new format.
        await saveExpenses(oldExpenses);

        return oldExpenses;
      }
    } catch (e) {
      return [];
    }

    return [];
  }

  // Convert JSON String into Expense objects
  List<Expense> _decodeExpenses(String jsonData) {
    final List<dynamic> data = jsonDecode(jsonData);

    return data.map((item) {
      final Map<String, dynamic> expenseData = Map<String, dynamic>.from(item);

      return Expense(
        title: expenseData['title']?.toString() ?? '',
        amount: double.tryParse(expenseData['amount'].toString()) ?? 0.0,
        category: expenseData['category']?.toString() ?? 'Other',
        date:
            DateTime.tryParse(expenseData['date']?.toString() ?? '') ??
            DateTime.now(),
      );
    }).toList();
  }

  // Delete all expenses
  Future<void> clearExpenses() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove(_expenseKey);
  }
}
