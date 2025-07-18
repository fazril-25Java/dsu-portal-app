import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingFormPage extends StatefulWidget {
  final int deviceId;
  const BookingFormPage({Key? key, required this.deviceId}) : super(key: key);

  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _bookingDate;
  int? _duration;
  String? _reason;
  bool _loading = false;

  Future<void> bookDevice() async {
    if (!_formKey.currentState!.validate() || _bookingDate == null) return;
    _formKey.currentState!.save();
    setState(() => _loading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      await Supabase.instance.client.from('bookings').insert({
        'device_id': widget.deviceId,
        'booking_date': _bookingDate!.toIso8601String().substring(0, 10),
        'duration': _duration,
        'reason': _reason,
        'supabase_user_id': user?.id,
        'status': 'pending',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking request sent!')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Device')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Reason to book'),
                  validator: (val) => val == null || val.isEmpty ? 'Enter reason' : null,
                  onSaved: (val) => _reason = val,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Duration (days)'),
                  keyboardType: TextInputType.number,
                  validator: (val) => val == null || int.tryParse(val) == null ? 'Enter valid duration' : null,
                  onSaved: (val) => _duration = int.tryParse(val ?? ''),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(_bookingDate == null
                          ? 'Select booking date'
                          : 'Booking Date: ${_bookingDate!.toLocal().toString().split(' ')[0]}'),
                    ),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() => _bookingDate = picked);
                        }
                      },
                      child: const Text('Pick Date'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : bookDevice,
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Book Device'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
