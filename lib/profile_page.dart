import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? profile;
  bool _loading = false;
  final TextEditingController _statusController = TextEditingController();
  File? _imageFile;

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
      _statusController.text = response['status'] ?? '';
      _loading = false;
    });
  }

  Future<void> updateProfile() async {
    setState(() => _loading = true);
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    String? avatarUrl = profile?['avatar_url'];
    // Upload image if selected
    if (_imageFile != null) {
      final bytes = await _imageFile!.readAsBytes();
      final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.png';
      // ignore: unused_local_variable
      final storageResponse = await Supabase.instance.client.storage
          .from('avatars')
          .uploadBinary(fileName, bytes, fileOptions: const FileOptions(contentType: 'image/png'));
      avatarUrl = Supabase.instance.client.storage.from('avatars').getPublicUrl(fileName);
    }
    await Supabase.instance.client
        .from('profiles')
        .update({
          'status': _statusController.text,
          'avatar_url': avatarUrl,
        })
        .eq('id', user.id);
    await fetchProfile();
    setState(() => _loading = false);
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
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
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: pickImage,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: _imageFile != null
                                ? FileImage(_imageFile!)
                                : (profile!['avatar_url'] != null
                                    ? NetworkImage(profile!['avatar_url'])
                                    : null) as ImageProvider?,
                            child: _imageFile == null && profile!['avatar_url'] == null
                                ? const Icon(Icons.person, size: 50)
                                : null,
                          ),
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
                        const SizedBox(height: 16),
                        TextField(
                          controller: _statusController,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: updateProfile,
                          child: const Text('Save Changes'),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
