import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingLoanPage extends StatefulWidget {
  const BookingLoanPage({Key? key}) : super(key: key);

  @override
  State<BookingLoanPage> createState() => _BookingLoanPageState();
}

class _BookingLoanPageState extends State<BookingLoanPage> {
  Future<List<Map<String, dynamic>>> fetchLoans() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return [];
    final response = await Supabase.instance.client
        .from('bookings')
        .select('*, devices(*)')
        .eq('supabase_user_id', user.id)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> returnDevice(int bookingId, int deviceId) async {
    try {
      await Supabase.instance.client.from('bookings').update({
        'status': 'returned',
        'returned_at': DateTime.now().toIso8601String(),
      }).eq('id', bookingId);
      await Supabase.instance.client.from('devices').update({
        'status': 'available',
      }).eq('id', deviceId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Device returned successfully!')),
      );
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Booking Loans')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchLoans(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final loans = snapshot.data ?? [];
          if (loans.isEmpty) {
            return const Center(child: Text('No booking loans found.'));
          }
          return ListView.builder(
            itemCount: loans.length,
            itemBuilder: (context, index) {
              final loan = loans[index];
              final device = loan['devices'] ?? {};
              final isBooked = loan['status'] == 'booked';
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: device['image'] != null
                      ? Image.network(device['image'], width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.devices),
                  title: Text(device['name'] ?? 'No Name'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Type: ${device['type'] ?? ''}'),
                      Text('Booking Date: ${loan['booking_date'] ?? ''}'),
                      Text('Duration: ${loan['duration'] ?? ''} days'),
                      Text('Status: ${loan['status'] ?? ''}'),
                    ],
                  ),
                  trailing: isBooked
                      ? ElevatedButton(
                          onPressed: () => returnDevice(loan['id'], device['id']),
                          child: const Text('Return'),
                        )
                      : const Text('Returned'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
