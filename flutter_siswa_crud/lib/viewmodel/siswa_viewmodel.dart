import 'package:flutter/foundation.dart';
import '../models/siswa_model.dart';
import '../services/siswa_service.dart';

enum ViewState { idle, loading, success, error }

class SiswaViewModel extends ChangeNotifier {
  final SiswaService _service = SiswaService();

  // ── State ────────────────────────────────────────────────────
  ViewState _state = ViewState.idle;
  List<Siswa> _siswaList = [];
  String _errorMessage = '';
  bool _isSubmitting = false;

  // ── Getters ──────────────────────────────────────────────────
  ViewState get state => _state;
  List<Siswa> get siswaList => _siswaList;
  String get errorMessage => _errorMessage;
  bool get isLoading => _state == ViewState.loading;
  bool get isSubmitting => _isSubmitting;
  bool get hasError => _state == ViewState.error;

  // ── Private helpers ──────────────────────────────────────────
  void _setState(ViewState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _setState(ViewState.error);
  }

  // ── Fetch all siswa ──────────────────────────────────────────
  Future<void> fetchSiswa() async {
    _setState(ViewState.loading);
    try {
      _siswaList = await _service.getAllSiswa();
      _setState(ViewState.success);
    } catch (e) {
      _setError(e.toString());
    }
  }

  // ── Create siswa ─────────────────────────────────────────────
  Future<bool> createSiswa(Siswa siswa) async {
    _isSubmitting = true;
    notifyListeners();
    try {
      final newSiswa = await _service.createSiswa(siswa);
      _siswaList.add(newSiswa);
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  // ── Update siswa ─────────────────────────────────────────────
  Future<bool> updateSiswa(String id, Siswa siswa) async {
    _isSubmitting = true;
    notifyListeners();
    try {
      var updated = await _service.updateSiswa(id, siswa);
      if (updated.id == null || updated.id!.isEmpty) {
        updated = updated.copyWith(id: id);
      }
      final index = _siswaList.indexWhere((s) => s.id == id);
      if (index != -1) {
        _siswaList[index] = updated;
      }
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  // ── Delete siswa ─────────────────────────────────────────────
  Future<bool> deleteSiswa(String id) async {
    try {
      await _service.deleteSiswa(id);
      _siswaList.removeWhere((s) => s.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ── Clear error ──────────────────────────────────────────────
  void clearError() {
    _errorMessage = '';
    if (_state == ViewState.error) {
      _setState(ViewState.idle);
    }
  }
}
