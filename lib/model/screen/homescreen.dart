import 'package:flutter/material.dart';

import '../../service/service.dart';
import '../tracckmode.dart';
import 'addexpensescreen.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final ExpenseService _expenseService = ExpenseService();

  List<Expense> expenses = [];

  bool isLoading = true;

  // Selected category
  String selectedCategory = 'All';

  // Selected month
  DateTime selectedMonth = DateTime.now();

  final List<String> categories = [
    'All',
    'Food',
    'Travel',
    'Shopping',
    'Bills',
    'Education',
    "snacks",
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    loadExpenses();
  }

  // ------------------------------------------------------------
  // LOAD EXPENSES
  // ------------------------------------------------------------

  Future<void> loadExpenses() async {
    final List<Expense> loadedExpenses = await _expenseService.loadExpenses();
    if (!mounted) return;
    setState(() {
      expenses = loadedExpenses;
      isLoading = false;
    });
  }

  // ------------------------------------------------------------
  // ADD EXPENSE
  // ------------------------------------------------------------

  Future<void> addExpense() async {
    final Expense? expense = await Navigator.push<Expense>(
      context,
      MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
    );

    if (expense != null) {
      setState(() {
        expenses.add(expense);
      });

      await _expenseService.saveExpenses(expenses);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense saved successfully')),
      );
    }
  }

  // ------------------------------------------------------------
  // EDIT EXPENSE
  // ------------------------------------------------------------

  Future<void> editExpense(int index) async {
    final Expense? updatedExpense = await Navigator.push<Expense>(
      context,
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(expense: expenses[index]),
      ),
    );

    if (updatedExpense != null) {
      setState(() {
        expenses[index] = updatedExpense;
      });

      await _expenseService.saveExpenses(expenses);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense updated successfully')),
      );
    }
  }

  // ------------------------------------------------------------
  // DELETE EXPENSE WITH CONFIRMATION
  // ------------------------------------------------------------

  Future<void> deleteExpense(int index) async {
    final Expense expense = expenses[index];

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Expense?'),
          content: Text('Are you sure you want to delete "${expense.title}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        expenses.removeAt(index);
      });

      await _expenseService.saveExpenses(expenses);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense deleted successfully')),
      );
    }
  }

  // ------------------------------------------------------------
  // CLEAR ALL
  // ------------------------------------------------------------

  Future<void> clearAllExpenses() async {
    if (expenses.isEmpty) {
      return;
    }

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear All Expenses?'),
          content: const Text('Are you sure you want to delete all expenses?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        expenses.clear();
      });

      await _expenseService.clearExpenses();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('All expenses cleared')));
    }
  }

  // ------------------------------------------------------------
  // ALL EXPENSE TOTAL
  // ------------------------------------------------------------

  double get totalExpense {
    double total = 0;

    for (final expense in expenses) {
      total += expense.amount;
    }

    return total;
  }

  // ------------------------------------------------------------
  // MONTHLY TOTAL
  // ------------------------------------------------------------

  double get monthlyTotal {
    double total = 0;

    for (final expense in expenses) {
      if (expense.date.year == selectedMonth.year &&
          expense.date.month == selectedMonth.month) {
        total += expense.amount;
      }
    }

    return total;
  }

  // ------------------------------------------------------------
  // FILTER EXPENSES
  // ------------------------------------------------------------

  List<Expense> get filteredExpenses {
    return expenses.where((expense) {
      final bool categoryMatches =
          selectedCategory == 'All' || expense.category == selectedCategory;

      final bool monthMatches = expense.date.year == selectedMonth.year &&
          expense.date.month == selectedMonth.month;

      return categoryMatches && monthMatches;
    }).toList();
  }

  // ------------------------------------------------------------
  // MONTH NAME
  // ------------------------------------------------------------

  String get monthName {
    const List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[selectedMonth.month - 1]} '
        '${selectedMonth.year}';
  }

  // ------------------------------------------------------------
  // CHANGE MONTH
  // ------------------------------------------------------------

  void changeMonth(int value) {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + value);
    });
  }

  // ------------------------------------------------------------
  // FORMAT DATE
  // ------------------------------------------------------------

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // ------------------------------------------------------------
  // BUILD UI
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final List<Expense> filtered = filteredExpenses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: clearAllExpenses,
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear All',
          ),
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ------------------------------------------------
                // TOTAL EXPENSE CARD
                // ------------------------------------------------

                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Total Expenses',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        '₹${totalExpense.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // ------------------------------------------------
                // MONTH SELECTOR
                // ------------------------------------------------
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              changeMonth(-1);
                            },
                            icon: const Icon(Icons.chevron_left),
                          ),

                          Column(
                            children: [
                              Text(
                                monthName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 3),

                              Text(
                                'Monthly: ₹${monthlyTotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),

                          IconButton(
                            onPressed: () {
                              changeMonth(1);
                            },
                            icon: const Icon(Icons.chevron_right),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ------------------------------------------------
                // CATEGORY FILTER
                // ------------------------------------------------
                SizedBox(
                  height: 55,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final String category = categories[index];
                      final bool isSelected = selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              selectedCategory = category;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),

                // ------------------------------------------------
                // EXPENSE LIST
                // ------------------------------------------------
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long,
                                size: 70,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'No expenses found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Try another category or month',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final Expense expense = filtered[index];

                            // Find original index.
                            final int originalIndex = expenses.indexOf(expense);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Icon(
                                    getCategoryIcon(expense.category),
                                  ),
                                ),
                                title: Text(
                                  expense.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  '${expense.category} • '
                                  '${formatDate(expense.date)}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '₹${expense.amount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    // Edit
                                    IconButton(
                                      onPressed: () {
                                        editExpense(originalIndex);
                                      },
                                      icon: const Icon(Icons.edit),
                                      tooltip: 'Edit',
                                    ),

                                    // Delete
                                    IconButton(
                                      onPressed: () {
                                        deleteExpense(originalIndex);
                                      },
                                      icon: const Icon(Icons.delete),
                                      tooltip: 'Delete',
                                      color: Colors.red,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),

      // ----------------------------------------------------------
      // ADD BUTTON
      // ----------------------------------------------------------
      floatingActionButton: FloatingActionButton(
        onPressed: addExpense,
        child: const Icon(Icons.add),
      ),
    );
  }

  // ------------------------------------------------------------
  // CATEGORY ICON
  // ------------------------------------------------------------

  IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant;
      case 'Travel':
        return Icons.directions_car;
      case 'Shopping':
        return Icons.shopping_cart;
      case 'Bills':
        return Icons.receipt;
      case 'Education':
        return Icons.school;
      case 'Snacks':
        return Icons.restaurant_menu;

      default:
        return Icons.more_horiz;
    }
  }
}
