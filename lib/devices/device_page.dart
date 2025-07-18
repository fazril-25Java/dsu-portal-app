import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../bookings/booking_loan.dart';
import '../profile_page.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({Key? key}) : super(key: key);

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  String _searchQuery = '';
  Future<List<Map<String, dynamic>>> fetchDevices() async {
    final response = await Supabase.instance.client
        .from('devices')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.assignment),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const BookingLoanPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search devices',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim().toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchDevices(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                var devices = snapshot.data ?? [];
                if (_searchQuery.isNotEmpty) {
                  devices = devices.where((d) {
                    final name = (d['name'] ?? '').toString().toLowerCase();
                    final type = (d['type'] ?? '').toString().toLowerCase();
                    return name.contains(_searchQuery) || type.contains(_searchQuery);
                  }).toList();
                }
                if (devices.isEmpty) {
                  return const Center(child: Text('No devices found.'));
                }
                return ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: device['image'] != null
                            ? Image.network(device['image'], width: 50, height: 50, fit: BoxFit.cover)
                            : const Icon(Icons.devices),
                        title: Text(device['name'] ?? 'No Name'),
                        subtitle: Text(device['type'] ?? ''),
                        trailing: Text(device['status'] ?? ''),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(device['name'] ?? 'Device'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Type: ${device['type'] ?? ''}'),
                                  Text('Description: ${device['description'] ?? 'No description'}'),
                                  Text('Status: ${device['status'] ?? ''}'),
                                  if (device['image'] != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Image.network(device['image'], width: 100, height: 100, fit: BoxFit.cover),
                                    ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
