import 'package:flutter/material.dart';
import '../models/company_model.dart';
import '../services/company_service.dart';

class CompanyProvider extends ChangeNotifier {
  final CompanyService _service = CompanyService();

  bool loading = false;
  List<Company> companies = [];
  Company? myCompany;

  // ============================================================
  // 🔵 Cargar todas las empresas
  // ============================================================
  Future<void> loadCompanies() async {
    loading = true;
    notifyListeners();

    companies = await _service.getCompanies();

    loading = false;
    notifyListeners();
  }

  // ============================================================
  // 🔵 Registrar empresa
  // ============================================================
  Future<bool> registerCompany(Company company) async {
    loading = true;
    notifyListeners();

    final ok = await _service.registerCompany(company);

    if (ok) {
      await loadCompanies();
    }

    loading = false;
    notifyListeners();
    return ok;
  }

  // ============================================================
  // 🔵 Obtener empresa por ID
  // ============================================================
  Future<Company?> getById(int id) async {
    loading = true;
    notifyListeners();

    final c = await _service.getCompanyById(id);

    loading = false;
    notifyListeners();

    return c;
  }

  // ============================================================
  // 🔵 Obtener empresa por ID de usuario
  // ============================================================
  Future<void> loadByUserId(int userId) async {
    loading = true;
    notifyListeners();

    myCompany = await _service.getCompanyByUserId(userId);

    loading = false;
    notifyListeners();
  }
}
