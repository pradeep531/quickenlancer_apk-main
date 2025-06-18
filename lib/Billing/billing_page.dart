import 'package:flutter/material.dart';

class BillingPage extends StatelessWidget {
  const BillingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(
      primaryColor: const Color(0xFF191E3E), // JRE red for vibrancy
      scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Light gray background
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF191E3E), // Bold JRE red
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Slightly rounder edges
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700, // Bolder text
            letterSpacing: 1.0,
            fontFamily: 'RobotoCondensed', // Edgy, condensed font
          ),
          elevation: 3, // Subtle shadow for depth
          shadowColor: Colors.black.withOpacity(0.2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white, // Clean white input background
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF191E3E), width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 14,
          fontFamily: 'RobotoCondensed',
        ),
        suffixIconColor: const Color(0xFF191E3E),
      ),
    );

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'BILLING',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A2526), // Darker text for contrast
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: const IconThemeData(color: Color(0xFF1A2526)),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFE5E7EB),
                    Color(0xFFE5E7EB)
                  ], // Red to coral
                  begin: Alignment.topLeft,
                  end: Alignment.topRight,
                ),
              ),
            ),
          ),
        ),
        body: Container(
          color: const Color(0xFFF5F5F5), // Light gray for clean look
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildDatePicker(context, 'FROM')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildDatePicker(context, 'TO')),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showSnackBar(context, 'HUNTING BILLS...'),
                    child: const Text('SEARCH'),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: DataTable(
                        columnSpacing: 16,
                        dataRowHeight: 48,
                        headingRowHeight: 36,
                        headingRowColor:
                            const WidgetStatePropertyAll(Color(0xFFECECEC)),
                        headingTextStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A2526),
                          fontSize: 13,
                          fontFamily: 'RobotoCondensed',
                        ),
                        dataTextStyle: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                          fontFamily: 'RobotoCondensed',
                        ),
                        dividerThickness: 0,
                        decoration: const BoxDecoration(),
                        columns: const [
                          DataColumn(label: Text('S.N.')),
                          DataColumn(label: Text('INVOICE')),
                          DataColumn(label: Text('DATE')),
                          DataColumn(label: Text('AMOUNT')),
                          DataColumn(label: Text('DOWNLOAD')),
                        ],
                        rows: [
                          _buildDataRow(
                              context, '1', 'INV001', '2025-06-01', '\₹100'),
                          _buildDataRow(
                              context, '2', 'INV002', '2025-06-02', '\₹150'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A2526),
            fontFamily: 'RobotoCondensed',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          readOnly: true,
          decoration: InputDecoration(
            hintText: 'PICK A DATE',
            suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontFamily: 'RobotoCondensed',
            ),
          ),
          onTap: () async {
            await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFF191E3E),
                      onPrimary: Colors.white,
                      surface: Colors.white,
                    ),
                    dialogBackgroundColor: Colors.white,
                    textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(
                        foregroundColor: Color(0xFF1A2526),
                        textStyle:
                            const TextStyle(fontFamily: 'RobotoCondensed'),
                      ),
                    ),
                  ),
                  child: child!,
                );
              },
            );
          },
        ),
      ],
    );
  }

  DataRow _buildDataRow(BuildContext context, String sn, String invoice,
      String date, String amount) {
    return DataRow(
      cells: [
        DataCell(Text(sn)),
        DataCell(Text(invoice)),
        DataCell(Text(date)),
        DataCell(Text(amount)),
        DataCell(
          IconButton(
            icon: const Icon(Icons.download_outlined,
                size: 18, color: Color(0xFF191E3E)),
            onPressed: () => _showSnackBar(context, 'DOWNLOADING $invoice'),
          ),
        ),
      ],
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontFamily: 'RobotoCondensed',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF191E3E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
    );
  }
}
