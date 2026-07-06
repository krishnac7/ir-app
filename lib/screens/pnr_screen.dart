import 'package:flutter/material.dart';
import '../widgets/ir_app_bar.dart';

class PnrScreen extends StatefulWidget {
  const PnrScreen({super.key});
  @override
  State<PnrScreen> createState() => _PnrScreenState();
}

class _PnrScreenState extends State<PnrScreen> {
  static const _db = {
    '1234567890': ['12951 - Mumbai Rajdhani', 'MUMBAI CENTRAL', 'NEW DELHI',   'CNF / Coach S4 / Berth 32'],
    '9876543210': ['12002 - Bhopal Shatabdi',  'BHOPAL JN',      'NEW DELHI',   'CNF / Coach C3 / Seat 14'],
    '5555555555': ['11077 - Jhelum Express',   'PUNE JN',        'JAMMU TAWI', 'WL / 12'],
  };

  final _controller = TextEditingController();
  List<String>? _result;
  bool _notFound = false;
  bool _searched = false;

  void _check() {
    final pnr = _controller.text.trim();
    setState(() {
      _searched = true;
      _result = _db[pnr];
      _notFound = _result == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const IRAppBar(title: 'PNR Status — Indian Railways'),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('PNR Status Enquiry',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF333333)),
            ),
            const Divider(color: Color(0xFF337ab7), thickness: 2),
            const SizedBox(height: 16),
            // Form card
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
                  const Text('Enter PNR Number', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    key: const Key('pnr_input'),
                    controller: _controller,
                    maxLength: 10,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '10-digit PNR',
                      counterText: '',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(3)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(3),
                        borderSide: const BorderSide(color: Color(0xFF337ab7), width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    key: const Key('pnr_submit'),
                    onPressed: _check,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF337ab7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                    ),
                    child: const Text('Check Status', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text('Try: 1234567890 | 9876543210 | 5555555555',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 20),
            if (_searched) _buildResult(),
          ],
        ),
      ),
    );
  }

  Widget _buildResult() {
    if (_notFound) {
      return Container(
        key: const Key('pnr_error'),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFfdf3f2),
          border: Border(left: const BorderSide(color: Color(0xFFc0392b), width: 4)),
        ),
        child: Text('No record found for PNR: ${_controller.text.trim()}',
          style: const TextStyle(color: Color(0xFFc0392b))),
      );
    }
    final r = _result!;
    return Container(
      key: const Key('pnr_result'),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFFf0f6fb),
        border: Border(left: BorderSide(color: Color(0xFF337ab7), width: 4)),
      ),
      child: Column(
        children: [
          _ResultRow('Train',  r[0]),
          _ResultRow('From',   r[1]),
          _ResultRow('To',     r[2]),
          _ResultRow('Status', r[3], isStatus: true),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label, value;
  final bool isStatus;
  const _ResultRow(this.label, this.value, {this.isStatus = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label.toUpperCase(),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF777777))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: isStatus
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF337ab7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 12)),
                )
              : Text(value, style: const TextStyle(fontSize: 13, color: Color(0xFF333333))),
          ),
        ],
      ),
    );
  }
}
