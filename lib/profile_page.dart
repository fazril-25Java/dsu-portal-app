import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? profile;
  bool _loading = false;

  Future<void> fetchProfile() async {
    setState(() => _loading = true);
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    final response = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();
    setState(() {
      profile = response;
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : profile == null
              ? const Center(child: Text('No profile found.'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (profile!['avatar_url'] != null)
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(profile!['avatar_url']),
                        ),
                      const SizedBox(height: 16),
                      Text(profile!['name'] ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Matric/Staff No: ${profile!['matric_or_staff_no'] ?? ''}'),
                      const SizedBox(height: 8),
                      Text('Contact No: ${profile!['contact_no'] ?? ''}'),
                      const SizedBox(height: 8),
                      Text('Mahallah/Room: ${profile!['mahallah_room'] ?? ''}'),
                      const SizedBox(height: 8),
                      Text('Program: ${profile!['program'] ?? ''}'),
                      const SizedBox(height: 8),
                      Text('Last Updated: ${profile!['updated_at'] ?? ''}'),
                    ],
                  ),
                ),
    );
  }
}
