import 'package:flutter/material.dart';
import '../services/invoice_service.dart';

class InvoiceProvider extends ChangeNotifier {
  List<dynamic> invoices = [];
  bool loading = false;

  Future<void> loadInvoices(int userId) async {
    loading = true;
    notifyListeners();

    invoices = await InvoiceService.getInvoicesByUser(userId);

    loading = false;
    notifyListeners();
  }
}
