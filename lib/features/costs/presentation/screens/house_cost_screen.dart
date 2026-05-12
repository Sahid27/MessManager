import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/role_guard.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../mess/presentation/bloc/mess_bloc.dart';
import '../../../mess/presentation/bloc/mess_state.dart';
import '../../domain/entities/house_cost.dart';
import '../../data/repos/cost_repo_impl.dart';

class HouseCostScreen extends StatefulWidget {
  const HouseCostScreen({super.key});
  @override
  State<HouseCostScreen> createState() => _State();
}
class _State extends State<HouseCostScreen> {
  HouseCost? _cost;
  bool _loading = true;
  final _rentCtrl  = TextEditingController(text: '1350');
  final _wifiCtrl  = TextEditingController(text: '120');
  final _dustCtrl  = TextEditingController(text: '30');
  final _wbEbCtrl  = TextEditingController(text: '131');
  final _gasCtrl   = TextEditingController(text: '0');
  String? _paidTo;

  String get _prevMonth {
    final now = DateTime.now();
    final prev = DateTime(now.year, now.month - 1);
    return '${prev.year}-${prev.month.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth  = context.read<AuthBloc>().state as AuthAuthenticated;
    final repo  = CostRepoImpl();
    final stream = repo.getHouseCostStream(auth.user.messId!, _prevMonth);
    stream.first.then((cost) {
      if (mounted) setState(() { _cost = cost; _loading = false; });
    });
  }

  Future<void> _save() async {
    final auth    = context.read<AuthBloc>().state as AuthAuthenticated;
    final members = (context.read<MessBloc>().state as MessLoaded).members;
    if (_paidTo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('কাকে দেওয়া হয়েছে সেটা বাছাই করো')));
      return;
    }
    final status = {for (final m in members) m.uid: 'due'};
    final cost = HouseCost(
      messId: auth.user.messId!, month: _prevMonth,
      rent:      double.tryParse(_rentCtrl.text) ?? 0,
      wifi:      double.tryParse(_wifiCtrl.text) ?? 0,
      dustBill:  double.tryParse(_dustCtrl.text) ?? 0,
      wbEb:      double.tryParse(_wbEbCtrl.text) ?? 0,
      cookerBill: double.tryParse(_gasCtrl.text) ?? 0,
      paidTo: _paidTo!, memberStatus: _cost?.memberStatus ?? status);
    await CostRepoImpl().saveHouseCost(cost);
    if (mounted) setState(() => _cost = cost);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('বাসার খরচ সেভ হয়েছে ✓'), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    final members = (context.watch<MessBloc>().state as MessLoaded).members;
    final total = (double.tryParse(_rentCtrl.text) ?? 0)
                + (double.tryParse(_wifiCtrl.text) ?? 0)
                + (double.tryParse(_dustCtrl.text) ?? 0)
                + (double.tryParse(_wbEbCtrl.text) ?? 0)
                + (double.tryParse(_gasCtrl.text) ?? 0);

    return Scaffold(
      appBar: AppBar(title: Text('বাসার খরচ — $_prevMonth'),
        backgroundColor: const Color(0xFF854F0B), foregroundColor: Colors.white),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : ListView(padding: const EdgeInsets.all(16), children: [
          const Text('গত মাসের বাসা সংক্রান্ত খরচ', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 12),
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
            _Row('বাড়ি ভাড়া (প্রতিজন)', _rentCtrl),
            _Row('Wifi (প্রতিজন)', _wifiCtrl),
            _Row('ডাস্ট বিল', _dustCtrl),
            _Row('WB + EB', _wbEbCtrl),
            _Row('কুকার বিল', _gasCtrl),
            const Divider(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('প্রতিজন মোট', style: TextStyle(fontWeight: FontWeight.w600)),
              Text('৳${total.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF854F0B))),
            ]),
          ]))),
          const SizedBox(height: 12),
          RoleGuard(child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('কাকে দেওয়া হয়েছে?', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: members.map((m) => DropdownMenuItem(value: m.uid, child: Text(m.name))).toList(),
              onChanged: (v) => setState(() => _paidTo = v)),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF854F0B)),
                child: const Text('সেভ করো'))),
          ])))),
          const SizedBox(height: 12),
          if (_cost != null) ...[
            const Text('পরিশোধের অবস্থা', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            ...members.map((m) {
              final status = _cost!.memberStatus[m.uid] ?? 'due';
              return Card(margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: const Color(0xFFEEEDFE),
                    child: Text(m.name[0], style: const TextStyle(color: Color(0xFF534AB7)))),
                  title: Text(m.name),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('৳${total.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: status == 'paid' ? const Color(0xFFE1F5EE) : const Color(0xFFFCEBEB),
                        borderRadius: BorderRadius.circular(10)),
                      child: Text(status == 'paid' ? 'পরিশোধিত' : 'বাকি',
                        style: TextStyle(fontSize: 10,
                          color: status == 'paid' ? const Color(0xFF085041) : const Color(0xFF791F1F)))),
                  ])));
            }),
          ],
        ]),
    );
  }
}

class _Row extends StatelessWidget {
  final String label; final TextEditingController ctrl;
  const _Row(this.label, this.ctrl);
  @override
  Widget build(BuildContext _) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      Expanded(child: Text(label)),
      SizedBox(width: 90, child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.right,
        decoration: const InputDecoration(
          isDense: true, prefixText: '৳',
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          border: OutlineInputBorder()))),
    ]));
}