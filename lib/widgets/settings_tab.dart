import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  File? _pickedImageFile;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  bool _isLoading = false;

  Future<void> _showImageSourceDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Camera'),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Gallery'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(
      source: source,
      imageQuality: 50,
      maxWidth: 150,
    );

    if (pickedImage != null) {
      setState(() {
        _pickedImageFile = File(pickedImage.path);
      });
    }
  }

  void _showMessageInfo(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = _auth.currentUser;
        if (user == null) {
          return;
        }

        setState(() => _isLoading = true);

        if (_pickedImageFile != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('image_user')
              .child('${user.uid}.jpg');
          await storageRef.putFile(_pickedImageFile!);
          final imageUrl = await storageRef.getDownloadURL();
          await _firestore.collection('users').doc(user.uid).update({
            'first_name': _firstNameController.text,
            'last_name': _lastNameController.text,
            'image_url': imageUrl,
          });
        } else {
          await _firestore.collection('users').doc(user.uid).update({
            'first_name': _firstNameController.text,
            'last_name': _lastNameController.text,
          });
        }

        setState(() => _isLoading = false);
        _showMessageInfo('Profile updated successfully.');
      } catch (e) {
        setState(() => _isLoading = false);
        _showMessageInfo('Failed to update profile.');
      }
    }
  }

  void _reset() async {
    _formKey.currentState!.reset();
    setState(() => _pickedImageFile = null);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _firestore.collection('users').doc(_auth.currentUser?.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final user = snapshot.data;
        if (user == null) {
          return const Center(child: Text('Something went wrong!'));
        }

        _firstNameController.text = user['first_name'];
        _lastNameController.text = user['last_name'];

        return Align(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              const SizedBox(height: 16),
              if (_pickedImageFile != null)
                CircleAvatar(
                  radius: 50,
                  backgroundImage: FileImage(_pickedImageFile!),
                ),
              if (_pickedImageFile == null)
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(user['image_url']),
                ),
              const SizedBox(height: 16),
              Text(
                '${user['first_name']} ${user['last_name']}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                _auth.currentUser?.email ?? '',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                  onPressed: _showImageSourceDialog,
                  child: const Text('Change Profile Photo')),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _firstNameController,
                          decoration:
                              const InputDecoration(label: Text("First name")),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter first name.";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _lastNameController,
                          decoration:
                              const InputDecoration(label: Text("Last name")),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter last name.";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: _isLoading ? null : _reset,
                              child: const Text('Reset'),
                            ),
                            const SizedBox(width: 24),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _saveProfile,
                              child: _isLoading
                                  ? const Text('Loading..')
                                  : const Text('Save'),
                            ),
                          ],
                        )
                      ],
                    )),
              ),
            ],
          ),
        );
      },
    );
  }
}
