import 'package:flutter/material.dart';

import '../tracckmode.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? expense;

  const AddExpenseScreen({super.key, this.expense});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  String selectedCategory = 'Food';
  DateTime selectedDate = DateTime.now();
  final List<String> categories = [
    'Food',
    'Travel',
    'Shopping',
    'Bills',
    'Education',
    "Snacks",
    'Other',
  ];

  bool get isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();

    // If editing, load existing expense data
    if (widget.expense != null) {
      titleController.text = widget.expense!.title;
      amountController.text = widget.expense!.amount.toString();
      selectedCategory = widget.expense!.category;
      selectedDate = widget.expense!.date;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    super.dispose();
  }

  // Select date
  Future<void> selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  // Save / Update expense
  void saveExpense() {
    final String title = titleController.text.trim();
    final String amountText = amountController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter expense title')),
      );
      return;
    }

    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please enter amount')));
      return;
    }

    final double? amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final Expense expense = Expense(
      title: title,
      amount: amount,
      category: selectedCategory,
      date: selectedDate,
    );

    Navigator.pop(context, expense);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Expense' : 'Add Expense'),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Title
            TextField(
              controller: titleController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Expense Title',
                hintText: 'Example: Lunch',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),

            const SizedBox(height: 16),

            // Amount
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Amount',
                hintText: 'Example: 250',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.currency_rupee),
              ),
            ),

            const SizedBox(height: 16),
            // Category
            DropdownButtonFormField<String>(
              initialValue: selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    selectedCategory = value;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // Date
            InkWell(
              onTap: selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_month),
                ),
                child: Text(
                  '${selectedDate.day}/'
                  '${selectedDate.month}/'
                  '${selectedDate.year}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 25),
            // Save / Update button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: saveExpense,
                icon: Icon(isEditing ? Icons.update : Icons.save),
                label: Text(isEditing ? 'Update Expense' : 'Save Expense'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
