import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class ManageSlots extends StatefulWidget {
  const ManageSlots({super.key});
  @override
  State<ManageSlots> createState() => _ManageSlotsState();
}

class _ManageSlotsState extends State<ManageSlots> {
  final _allSlots = ['08:00','08:30','09:00','09:30','10:00','10:30','11:00','11:30','14:00','14:30','15:00','15:30','16:00','16:30','17:00','17:30'];
  Map<String, List<String>> _slotsMap = {};
  String _selectedDate = '';
  bool _loading = true;
  bool _saving = false;

  List<Map<String, String>> get _dates {
    final list = <Map<String, String>>[];
    for (int i = 0; i < 14; i++) {
      final d = DateTime.now().add(Duration(days: i));
      list.add({'iso': d.toIso8601String().split('T')[0], 'label': '${_dayName(d.weekday)} ${d.day}/${d.month}'});
    }
    return list;
  }

  String _dayName(int w) => ['Lun','Mar','Mer','Jeu','Ven','Sam','Dim'][w - 1];

  @override
  void initState() {
    super.initState();
    _selectedDate = _dates[0]['iso']!;
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final data = await ApiService.getMySlots();
      final map = <String, List<String>>{};
      for (final s in (data['availableSlots'] ?? [])) { map[s['date']] = List<String>.from(s['slots']); }
      setState(() { _slotsMap = map; _loading = false; });
    } catch (e) { setState(() => _loading = false); }
  }

  void _toggle(String slot) {
    final current = _slotsMap[_selectedDate] ?? [];
    setState(() {
      if (current.contains(slot)) { _slotsMap[_selectedDate] = current.where((s) => s != slot).toList(); }
      else { _slotsMap[_selectedDate] = [...current, slot]..sort(); }
    });
  }

 Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final slots = _slotsMap.entries
          .where((e) => e.value.isNotEmpty)
          .map((e) => {'date': e.key, 'slots': e.value})
          .toList();
      await ApiService.updateSlots(slots);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Planning sauvegardé'), backgroundColor: AppTheme.success),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur de sauvegarde'), backgroundColor: AppTheme.danger),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final current = _slotsMap[_selectedDate] ?? [];
    final total = _slotsMap.values.fold(0, (s, l) => s + l.length);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: Text('Planning — $total créneaux actifs'), backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
      body: Column(children: [
        // Dates
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: _dates.map((d) {
              final count = (_slotsMap[d['iso']] ?? []).length;
              final active = _selectedDate == d['iso'];
              return GestureDetector(
                onTap: () => setState(() => _selectedDate = d['iso']!),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: active ? AppTheme.primary : AppTheme.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: active ? AppTheme.primary : const Color(0xFFdddddd)),
                  ),
                  child: Column(children: [
                    Text(d['label']!, style: TextStyle(fontSize: 12, color: active ? Colors.white : AppTheme.textSecondary, fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
                    if (count > 0) Container(
                      margin: const EdgeInsets.only(top: 3),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(color: active ? Colors.white.withValues(alpha: 0.3) : AppTheme.primaryLight, borderRadius: BorderRadius.circular(10)),
                      child: Text('$count', style: TextStyle(fontSize: 10, color: active ? Colors.white : AppTheme.primary, fontWeight: FontWeight.bold)),
                    ),
                  ]),
                ),
              );
            }).toList()),
          ),
        ),
        // Infos jour
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_selectedDate, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('${current.length} créneau(x) sélectionné(s)', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ]),
            Row(children: [
              GestureDetector(onTap: () => setState(() => _slotsMap[_selectedDate] = [..._allSlots]), child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(16)), child: const Text('Tout', style: TextStyle(fontSize: 12, color: AppTheme.primary)))),
              const SizedBox(width: 8),
              GestureDetector(onTap: () => setState(() => _slotsMap[_selectedDate] = []), child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFfdecea), borderRadius: BorderRadius.circular(16)), child: const Text('Effacer', style: TextStyle(fontSize: 12, color: AppTheme.danger)))),
            ]),
          ]),
        ),
        // Créneaux
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _slotsSection('Matin', _allSlots.where((s) => int.parse(s.split(':')[0]) < 12).toList(), current),
              const SizedBox(height: 16),
              _slotsSection('Après-midi', _allSlots.where((s) => int.parse(s.split(':')[0]) >= 12).toList(), current),
              const SizedBox(height: 80),
            ]),
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saving ? null : _save,
        backgroundColor: AppTheme.primary,
        label: _saving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('💾 Sauvegarder'),
      ),
    );
  }

  Widget _slotsSection(String title, List<String> slots, List<String> current) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
      const SizedBox(height: 10),
      Wrap(spacing: 10, runSpacing: 10, children: slots.map((slot) {
        final active = current.contains(slot);
        return GestureDetector(
          onTap: () => _toggle(slot),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: active ? AppTheme.primary : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: active ? AppTheme.primary : const Color(0xFFdddddd)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(slot, style: TextStyle(fontSize: 13, color: active ? Colors.white : AppTheme.textPrimary, fontWeight: FontWeight.w500)),
              if (active) ...[const SizedBox(width: 4), const Icon(Icons.check, size: 14, color: Colors.white)],
            ]),
          ),
        );
      }).toList()),
    ],
  );
}