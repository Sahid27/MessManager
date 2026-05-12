import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../mess/presentation/bloc/mess_bloc.dart';
import '../../../mess/presentation/bloc/mess_state.dart';
import '../../domain/entities/cost_entry.dart';
import '../bloc/cost_bloc.dart';
import '../bloc/cost_event.dart';
import '../bloc/cost_state.dart';

class AddCostScreen extends StatefulWidget {
  const AddCostScreen({super.key});
  @override
  State<AddCostScreen> createState() => _State();
}
class _State extends State<AddCostScreen> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl   = TextEditingController();
  String?   _selectedUid;
  String?   _selectedName;
  CostType  _type   = CostType.market;
  bool      _isPaid = true;

  @override
  void dispose() { _amountCtrl.dispose(); _noteCtrl.dispose(); super.dispose(); }

  String get _monthKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  void _save() {
    if (_amountCtrl.text.isEmpty || _selectedUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('পরিমাণ ও কে দিয়েছে সেটা দাও')));
      return;
    }
    final auth = context.read<AuthBloc>().state as AuthAuthenticated;
    context.read<CostBloc>().add(AddCostRequested(
      messId: auth.user.messId!, month: _monthKey,
      paidBy: _selectedUid!, paidByName: _selectedName!,
      amount: double.tryParse(_amountCtrl.text) ?? 0,
      note: _noteCtrl.text.trim(), isPaid: _isPaid, type: _type));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final members = (context.watch<MessBloc>().state as MessLoaded).members;

    return Scaffold(
      appBar: AppBar(
        title: const Text('খরচ যোগ করো'),
        backgroundColor: const Color(0xFF0F6E56),
        foregroundColor: Colors.white,
        actions: [TextButton(
          onPressed: _save,
          child: const Text('সেভ করো', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)))]),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('খরচের বিস্তারিত', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'কে দিয়েছে', border: OutlineInputBorder()),
            items: members.map((m) => DropdownMenuItem(value: m.uid, child: Text(m.name))).toList(),
            onChanged: (v) { setState(() { _selectedUid = v; _selectedName = members.firstWhere((m) => m.uid == v).name; }); }),
          const SizedBox(height: 12),
          DropdownButtonFormField<CostType>(
            value: _type,
            decoration: const InputDecoration(labelText: 'ধরন', border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: CostType.market, child: Text('বাজার / মুদিখানা')),
              DropdownMenuItem(value: CostType.gas, child: Text('রান্নার গ্যাস')),
              DropdownMenuItem(value: CostType.utility, child: Text('ইউটিলিটি')),
              DropdownMenuItem(value: CostType.other, child: Text('অন্যান্য')),
            ],
            onChanged: (v) => setState(() => _type = v ?? CostType.market)),
          const SizedBox(height: 12),
          TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'পরিমাণ (৳)', border: OutlineInputBorder(), prefixText: '৳ ')),
          const SizedBox(height: 12),
          TextField(
            controller: _noteCtrl,
            decoration: const InputDecoration(labelText: 'নোট (ঐচ্ছিক)', border: OutlineInputBorder())),
          const SizedBox(height: 14),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('পরিশোধিত হয়েছে?'),
            subtitle: const Text('টগল করলে status পরিবর্তন হবে'),
            value: _isPaid,
            onChanged: (v) => setState(() => _isPaid = v),
            activeColor: const Color(0xFF0F6E56)),
        ]))),
      ]),
    );
  }
}