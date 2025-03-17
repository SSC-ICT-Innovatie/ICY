import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:icy/abstractions/navigation/state/navigation_cubit.dart';
import 'package:icy/abstractions/utils/validation_constants.dart';
import 'package:icy/features/authentication/state/bloc/auth_bloc.dart';
import 'package:icy/tabs.dart';
import 'package:image_picker/image_picker.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _verificationCode = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Add listener to update UI when name changes
    _name.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _name.removeListener(_onNameChanged);
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _verificationCode.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    // This will trigger a rebuild whenever the name changes
    setState(() {});
  }

  // Function to get user initials from their name
  String _getInitials() {
    final name = _name.text.trim();
    if (name.isEmpty) return '';

    final parts = name.split(' ');
    if (parts.length == 1) {
      // Only one name, take the first character
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '';
    } else {
      // Multiple names, take first character of first and last name
      String firstInitial =
          parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '';
      String lastInitial =
          parts.last.isNotEmpty ? parts.last[0].toUpperCase() : '';
      return '$firstInitial$lastInitial';
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      _showErrorDialog('Failed to pick image: $e');
    }
  }

  void _showVerificationDialog() {
    showAdaptiveDialog(
      context: context,
      builder:
          (context) => FDialog(
            direction: Axis.horizontal,
            title: const Text('Email Verification'),
            body: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'We\'ve sent a verification code to your email. Please enter it below:',
                ),
                const SizedBox(height: 16),
                FTextField(
                  controller: _verificationCode,
                  label: const Text('Verification Code'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              FButton(
                style: FButtonStyle.outline,
                label: const Text('Cancel'),
                onPress: () => Navigator.of(context).pop(),
              ),
              FButton(
                label: const Text('Verify'),
                onPress: () {
                  Navigator.of(context).pop();
                  _completeSignup();
                },
              ),
            ],
          ),
    );
  }

  void _showErrorDialog(String message) {
    showAdaptiveDialog(
      context: context,
      builder:
          (context) => FDialog(
            direction: Axis.horizontal,
            title: const Text('Registration Error'),
            body: Text(message),
            actions: [
              FButton(
                style: FButtonStyle.outline,
                label: const Text('OK'),
                onPress: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
  }

  void _initiateSignup() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        // In a real app, we would send an API request to send the verification code
        // For now, we'll simulate this process
        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _showVerificationDialog();
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _showErrorDialog('Failed to send verification code: ${e.toString()}');
        }
      }
    }
  }

  void _completeSignup() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Default avatar ID (can be customized later)
      final avatarId = '1';

      // In a real app, we would validate the verification code here
      // For now, we'll proceed with the signup

      // Dispatch signup event to auth bloc
      context.read<AuthBloc>().add(
        AuthSignUpRequested(
          name: _name.text,
          email: _email.text,
          password: _password.text,
          avatarId: avatarId,
          department: 'ICT',
          profileImage: _profileImage,
        ),
      );
    } catch (e) {
      print('Signup error: $e');

      // Show error dialog
      if (mounted) {
        _showErrorDialog('Registration failed: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get initials for avatar
    final initials = _getInitials();

    return FScaffold(
      resizeToAvoidBottomInset: true,
      header: FHeader(title: Text("Create Account")),
      content: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            final navCubit = context.read<NavigationCubit>();
            // Refresh tabs with new auth state
            navCubit.refreshTabs(injectNavigationTabs(context));
          } else if (state is AuthFailure) {
            // Show error dialog
            _showErrorDialog(state.message);
          }
        },
        builder: (context, state) {
          return state is AuthLoading || _isLoading
              ? const Center(child: CircularProgressIndicator.adaptive())
              : SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // New avatar implementation with image picker
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(
                                  context,
                                ).primaryColor.withAlpha(26),
                              ),
                              child: FAvatar(
                                image: FileImage(_profileImage ?? File('')),  
                                size: 64,
                                fallback: Text(
                                  initials,
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: context.theme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FTileGroup(
                          description: const Text(
                            "Enter your information to create an account",
                          ),
                          children: [
                            FTile(
                              title: const Text("Full Name"),
                              subtitle: FTextField(
                                autocorrect: false,
                                controller: _name,
                                label: const SizedBox(),
                                hint: 'Enter your full name',
                                validator: ValidationConstants.validateName,
                              ),
                            ),
                            FTile(
                              title: const Text("Email"),
                              subtitle: FTextField.email(
                                controller: _email,
                                autocorrect: false,
                                label: const SizedBox(),
                                hint: 'Enter your work email',
                                validator: ValidationConstants.validateEmail,
                              ),
                            ),
                            FTile(
                              title: const Text("Password"),
                              subtitle: FTextField.password(
                                autocorrect: false,
                                controller: _password,
                                label: const SizedBox(),
                                hint: 'Create a secure password',
                                validator: ValidationConstants.validatePassword,
                              ),
                            ),
                            FTile(
                              title: FButton(
                                onPress: _initiateSignup,
                                label: const Text("Create Account"),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      FButton(
                        style: FButtonStyle.ghost,
                        onPress: () {
                          // Navigate to login screen
                          context
                              .read<NavigationCubit>()
                              .changeVisibleTabByIndex(0);
                        },
                        label: const Text("Already have an account? Login"),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              );
        },
      ),
    );
  }
}
