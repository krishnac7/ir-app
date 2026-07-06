import 'package:flutter/material.dart';
import '../widgets/ir_app_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _services = [
    ['PNR Status',        '/pnr',      'Check your ticket reservation status using PNR number.'],
    ['Train Schedule',    '/schedule', 'View complete train schedule between stations.'],
    ['Seat Availability', '/seats',    'Check real-time seat availability for any train.'],
    ['Fare Enquiry',      '/fare',     'Calculate fare for your journey across all classes.'],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const IRAppBar(title: 'Indian Railways Enquiry'),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero banner
            Container(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: const BoxDecoration(
                color: Color(0xFFf0f6fb),
                border: Border(bottom: BorderSide(color: Color(0xFF337ab7), width: 3)),
              ),
              child: Column(
                children: [
                  // IR logo circle
                  Container(
                    width: 56, height: 56,
                    decoration: const BoxDecoration(
                      color: Color(0xFF346db3), shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('IR\nभारतीय\nरेल',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold, height: 1.3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Indian Railways Passenger Enquiry',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF337ab7)),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Your one-stop portal for train schedules, PNR status, seat availability and fare enquiry.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Color(0xFF555555)),
                  ),
                ],
              ),
            ),
            // Services grid
            Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.5,
                children: _services.map((s) => _ServiceCard(s[0], s[1], s[2])).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String title, route, desc;
  const _ServiceCard(this.title, this.route, this.desc);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: Key('card_$title'),
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          // Note: a non-uniform Border (blue top accent + grey sides) cannot be
          // combined with borderRadius — Flutter throws during paint. Keep the
          // accent border and square corners instead.
          border: Border(
            top: const BorderSide(color: Color(0xFF337ab7), width: 3),
            left: BorderSide(color: Colors.grey.shade300),
            right: BorderSide(color: Colors.grey.shade300),
            bottom: BorderSide(color: Colors.grey.shade300),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF337ab7))),
            const SizedBox(height: 6),
            Expanded(
              child: Text(desc, style: const TextStyle(fontSize: 11, color: Color(0xFF555555)), overflow: TextOverflow.ellipsis, maxLines: 3),
            ),
          ],
        ),
      ),
    );
  }
}
