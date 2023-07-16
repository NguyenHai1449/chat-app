import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  File? _pickedImageFile;
  final _formKey = GlobalKey<FormState>();

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

  void _saveProfile() {
    //
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    return Align(
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage:
                _pickedImageFile != null ? FileImage(_pickedImageFile!) : null,
          ),
          const SizedBox(height: 16),
          Text(
            user?.email ?? '',
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
                      initialValue: user?.displayName ?? '',
                      decoration:
                          const InputDecoration(label: Text("Username")),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: user?.phoneNumber ?? '',
                      keyboardType: TextInputType.phone,
                      decoration:
                          const InputDecoration(label: Text("Phone number")),
                    ),
                  ],
                )),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  _formKey.currentState!.reset();
                },
                child: const Text('Reset'),
              ),
              const SizedBox(width: 24),
              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text('Save'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
