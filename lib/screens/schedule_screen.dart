import 'package:flutter/material.dart';
import '../widgets/ir_app_bar.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  static const _stops = [
    ['MUMBAI CENTRAL', 'Source', '16:35', 'Day 1'],
    ['SURAT',          '19:37',  '19:39', 'Day 1'],
    ['VADODARA JN',    '21:05',  '21:10', 'Day 1'],
    ['RATLAM JN',      '00:10',  '00:15', 'Day 2'],
    ['KOTA JN',        '03:55',  '04:00', 'Day 2'],
    ['SAWAI MADHOPUR', '05:10',  '05:12', 'Day 2'],
    ['BHARATPUR JN',   '07:05',  '07:07', 'Day 2'],
    ['MATHURA JN',     '08:10',  '08:15', 'Day 2'],
    ['NEW DELHI',      '09:55',  'Dest',  'Day 2'],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const IRAppBar(title: 'Train Schedule — Indian Railways'),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Train Schedule',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF333333))),
            const Divider(color: Color(0xFF337ab7), thickness: 2),
            const SizedBox(height: 12),
            // Info bar
            Container(
              key: const Key('schedule_info_bar'),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFf5f5f5),
                border: Border(left: BorderSide(color: Color(0xFF337ab7), width: 4)),
              ),
              child: const Text(
                '12951 — Mumbai Rajdhani Express  |  MUMBAI CENTRAL → NEW DELHI',
                style: TextStyle(fontSize: 13, color: Color(0xFF333333)),
              ),
            ),
            const SizedBox(height: 16),
            // Table
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                key: const Key('schedule_table'),
                headingRowColor: WidgetStateProperty.all(const Color(0xFF337ab7)),
                dataRowMinHeight: 40,
                columnSpacing: 24,
                columns: const [
                  DataColumn(label: Text('#',         style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
                  DataColumn(label: Text('Station',   style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
                  DataColumn(label: Text('Arrival',   style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
                  DataColumn(label: Text('Departure', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
                  DataColumn(label: Text('Day',       style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
                ],
                rows: List.generate(_stops.length, (i) {
                  final s = _stops[i];
                  return DataRow(
                    color: WidgetStateProperty.resolveWith(
                      (states) => i.isEven ? Colors.white : const Color(0xFFf5f5f5),
                    ),
                    cells: [
                      DataCell(Text('${i + 1}')),
                      DataCell(Text(s[0], style: const TextStyle(fontSize: 13))),
                      DataCell(Text(s[1], style: const TextStyle(fontSize: 13))),
                      DataCell(Text(s[2], style: const TextStyle(fontSize: 13))),
                      DataCell(Text(s[3], style: const TextStyle(fontSize: 13))),
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
