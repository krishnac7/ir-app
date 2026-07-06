import 'package:flutter/material.dart';
import '../widgets/ir_app_bar.dart';

class SeatsScreen extends StatelessWidget {
  const SeatsScreen({super.key});

  static const _availability = [
    ['1A — First AC',        2],
    ['2A — Second AC',       8],
    ['3A — Third AC',       14],
    ['SL — Sleeper',        42],
    ['CC — Chair Car',      23],
    ['2S — Second Sitting', 110],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const IRAppBar(title: 'Seat Availability — Indian Railways'),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Seat Availability',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF333333))),
            const Divider(color: Color(0xFF337ab7), thickness: 2),
            const SizedBox(height: 12),
            Container(
              key: const Key('seats_info_bar'),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFf5f5f5),
                border: Border(left: BorderSide(color: Color(0xFF337ab7), width: 4)),
              ),
              child: const Text(
                '12951 — Mumbai Rajdhani Express  |  Journey Date: 15-Jul-2026',
                style: TextStyle(fontSize: 13, color: Color(0xFF333333)),
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                key: const Key('seats_table'),
                headingRowColor: WidgetStateProperty.all(const Color(0xFF337ab7)),
                dataRowMinHeight: 44,
                columnSpacing: 32,
                columns: const [
                  DataColumn(label: Text('Class',           style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
                  DataColumn(label: Text('Available Seats', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
                  DataColumn(label: Text('Status',          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
                ],
                rows: List.generate(_availability.length, (i) {
                  final cls = _availability[i][0] as String;
                  final cnt = _availability[i][1] as int;
                  final (label, bg, fg) = cnt > 20
                    ? ('Available',    const Color(0xFFdff0d8), const Color(0xFF3c763d))
                    : cnt > 5
                      ? ('Filling Fast', const Color(0xFFfcf8e3), const Color(0xFF8a6d3b))
                      : ('Almost Full',  const Color(0xFFf2dede), const Color(0xFFa94442));
                  return DataRow(
                    color: WidgetStateProperty.resolveWith(
                      (states) => i.isEven ? Colors.white : const Color(0xFFf5f5f5),
                    ),
                    cells: [
                      DataCell(Text(cls,         style: const TextStyle(fontSize: 13))),
                      DataCell(Text('$cnt',       style: const TextStyle(fontSize: 13))),
                      DataCell(
                        Container(
                          key: Key('badge_$cls'),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
                          child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
