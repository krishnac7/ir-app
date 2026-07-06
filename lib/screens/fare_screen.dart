import 'package:flutter/material.dart';
import '../widgets/ir_app_bar.dart';

class FareScreen extends StatefulWidget {
  const FareScreen({super.key});
  @override
  State<FareScreen> createState() => _FareScreenState();
}

class _FareScreenState extends State<FareScreen> {
  static const _rates = {
    '1A — First AC':       4.5,
    '2A — Second AC':      2.8,
    '3A — Third AC':       2.1,
    'SL — Sleeper':        0.9,
    'CC — Chair Car':      1.4,
    '2S — Second Sitting': 0.5,
  };

  final _fromCtrl = TextEditingController();
  final _toCtrl   = TextEditingController();
  final _distCtrl = TextEditingController();

  List<Map<String, dynamic>>? _results;
  String _fromLabel = '', _toLabel = '';

  void _calculate() {
    final dist = int.tryParse(_distCtrl.text.trim());
    if (dist == null || dist <= 0) return;
    setState(() {
      _fromLabel = _fromCtrl.text.trim();
      _toLabel   = _toCtrl.text.trim();
      _results = _rates.entries.map((e) {
        final base  = (e.value * dist).roundToDouble();
        const rsv   = 40.0;
        return {'cls': e.key, 'base': base, 'rsv': rsv, 'total': base + rsv};
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const IRAppBar(title: 'Fare Enquiry — Indian Railways'),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Fare Enquiry',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF333333))),
            const Divider(color: Color(0xFF337ab7), thickness: 2),
            const SizedBox(height: 16),
            // Form
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFf9f9f9),
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FormField('From Station', 'e.g. MUMBAI CENTRAL', _fromCtrl, 'fare_from'),
                  const SizedBox(height: 12),
                  _FormField('To Station',   'e.g. NEW DELHI',      _toCtrl,   'fare_to'),
                  const SizedBox(height: 12),
                  _FormField('Distance (km)', 'e.g. 1384',          _distCtrl, 'fare_dist',
                    isNumber: true),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    key: const Key('fare_submit'),
                    onPressed: _calculate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF337ab7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                    ),
                    child: const Text('Calculate Fare', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            if (_results != null) ...[
              const SizedBox(height: 20),
              Container(
                key: const Key('fare_route_bar'),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: const BoxDecoration(
                  color: Color(0xFFf5f5f5),
                  border: Border(left: BorderSide(color: Color(0xFF337ab7), width: 4)),
                ),
                child: Text(
                  '$_fromLabel → $_toLabel  |  Distance: ${_distCtrl.text.trim()} km',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  key: const Key('fare_table'),
                  headingRowColor: WidgetStateProperty.all(const Color(0xFF337ab7)),
                  dataRowMinHeight: 44,
                  columnSpacing: 24,
                  columns: const [
                    DataColumn(label: Text('Class',       style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
                    DataColumn(label: Text('Base Fare',   style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
                    DataColumn(label: Text('Reservation', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
                    DataColumn(label: Text('Total (₹)',   style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
                  ],
                  rows: _results!.asMap().entries.map((entry) {
                    final i = entry.key;
                    final r = entry.value;
                    return DataRow(
                      color: WidgetStateProperty.resolveWith(
                        (states) => i.isEven ? Colors.white : const Color(0xFFf5f5f5),
                      ),
                      cells: [
                        DataCell(Text(r['cls'],                                  style: const TextStyle(fontSize: 13))),
                        DataCell(Text('₹${r['base'].toStringAsFixed(0)}',        style: const TextStyle(fontSize: 13))),
                        DataCell(Text('₹${r['rsv'].toStringAsFixed(0)}',         style: const TextStyle(fontSize: 13))),
                        DataCell(Text('₹${r['total'].toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700))),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label, hint, widgetKey;
  final TextEditingController ctrl;
  final bool isNumber;
  const _FormField(this.label, this.hint, this.ctrl, this.widgetKey, {this.isNumber = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          key: Key(widgetKey),
          controller: ctrl,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(3)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3),
              borderSide: const BorderSide(color: Color(0xFF337ab7), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
