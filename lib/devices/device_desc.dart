import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../bookings/booking_form.dart';

class DeviceDescPage extends StatefulWidget {
  final int deviceId;
  const DeviceDescPage({Key? key, required this.deviceId}) : super(key: key);

  @override
  State<DeviceDescPage> createState() => _DeviceDescPageState();
}

class _DeviceDescPageState extends State<DeviceDescPage> {
  Map<String, dynamic>? device;

  Future<void> fetchDevice() async {
    final response = await Supabase.instance.client
        .from('devices')
        .select()
        .eq('id', widget.deviceId)
        .single();
    setState(() {
      device = response;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchDevice();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Device Details')),
      body: device == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (device!['image'] != null)
                      Center(
                        child: Image.network(device!['image'], width: 150, height: 150, fit: BoxFit.cover),
                      ),
                    const SizedBox(height: 16),
                    Text(device!['name'] ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Type: ${device!['type'] ?? ''}'),
                    const SizedBox(height: 8),
                    Text('Status: ${device!['status'] ?? ''}'),
                    const SizedBox(height: 8),
                    Text('Description: ${device!['description'] ?? 'No description'}'),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => BookingFormPage(deviceId: widget.deviceId),
                            ),
                          );
                        },
                        child: const Text('Book Device'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
