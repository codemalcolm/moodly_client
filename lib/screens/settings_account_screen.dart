import 'package:flutter/material.dart';
import 'package:moodly_client/widgets/custom_text_input.dart';

class SettingsAccountScreen extends StatefulWidget {
  const SettingsAccountScreen({super.key});

  @override
  State<SettingsAccountScreen> createState() => _SettingsAccountScreenState();
}

class _SettingsAccountScreenState extends State<SettingsAccountScreen> {
  bool _isPasswordEditable = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Account Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (context) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.visibility),
                                title: const Text('View Profile Picture'),
                                onTap: () {
                                  Navigator.pop(context);
                                  // TODO: Vollbild-Vorschau öffnen
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.photo),
                                title: const Text('Change Profile Picture'),
                                onTap: () {
                                  Navigator.pop(context);
                                  // TODO: Bildauswahl starten
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.delete),
                                title: const Text('Remove Profile Picture'),
                                onTap: () {
                                  Navigator.pop(context);
                                  // TODO: Zurücksetzen des Bilds
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Align(
              alignment: Alignment.centerLeft,
              child: Text('Username', style: textTheme.titleMedium),
            ),
            const SizedBox(height: 8),
            const CustomTextInput(
              hintText: 'Username',
              initialValue: 'moodly_user',
            ),
            const SizedBox(height: 24),

            Align(
              alignment: Alignment.centerLeft,
              child: Text('Name & Last name', style: textTheme.titleMedium),
            ),
            const SizedBox(height: 8),
            const CustomTextInput(
              hintText: 'Full Name',
              initialValue: 'Max Exampleman',
            ),
            const SizedBox(height: 24),

            Align(
              alignment: Alignment.centerLeft,
              child: Text('Email', style: textTheme.titleMedium),
            ),
            const SizedBox(height: 8),
            const CustomTextInput(
              hintText: 'Email',
              keyboardType: TextInputType.emailAddress,
              initialValue: 'max.exampleman@moodly.com',
            ),
            const SizedBox(height: 24),

            // Password
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Password', style: textTheme.titleMedium),
            ),
            const SizedBox(height: 8),
            Stack(
              children: [
                AbsorbPointer(
                  absorbing: !_isPasswordEditable,
                  child: CustomTextInput(
                    hintText: 'Password',
                    initialValue: '***********',
                    obscureText: true,
                  ),
                ),
                Positioned(
                  right: 16,
                  top: 14,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isPasswordEditable = !_isPasswordEditable;
                      });
                    },
                    child: Text(
                      _isPasswordEditable ? 'cancel' : 'change password',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
