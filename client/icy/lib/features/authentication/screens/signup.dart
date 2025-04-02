import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:icy/abstractions/navigation/state/navigation_cubit.dart';
import 'package:icy/abstractions/utils/validation_constants.dart';
import 'package:icy/data/models/department_model.dart';
import 'package:icy/data/repositories/department_repository.dart';
import 'package:icy/features/authentication/state/bloc/auth_bloc.dart';
import 'package:icy/data/repositories/auth_repository.dart';
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
  final _authRepository = AuthRepository();
  final _departmentRepository = DepartmentRepository();

  bool _isLoading = false;
  bool _codeRequested = false;
  bool _codeVerified = false;
  String? _verificationError;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  // Department selection
  String _selectedDepartment = 'ICT';
  List<Department> _departments = [];
  bool _loadingDepartments = true;
  // Add a scroll controller for the picker
  late FixedExtentScrollController _departmentScrollController;

  // Add new state variable to track if registering as admin
  bool _isAdminSignup = false;

  @override
  void initState() {
    super.initState();
    // Add listener to update UI when name changes
    _name.addListener(_onNameChanged);

    // Initialize the department scroll controller
    _departmentScrollController = FixedExtentScrollController(initialItem: 0);

    // Load departments from backend
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    setState(() {
      _loadingDepartments = true;
    });

    try {
      final departments = await _departmentRepository.getDepartments();
      setState(() {
        _departments = departments;
        if (departments.isNotEmpty) {
          _selectedDepartment = departments.first.name;
        }
        _loadingDepartments = false;
      });
    } catch (e) {
      print('Error loading departments: $e');
      setState(() {
        _loadingDepartments = false;
      });
    }
  }

  @override
  void dispose() {
    _name.removeListener(_onNameChanged);
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _verificationCode.dispose();
    // Dispose the controller
    _departmentScrollController.dispose();
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
      barrierDismissible: false,
      builder:
          (context) => FDialog(
            direction: Axis.horizontal,
            title: const Text('Email Verification'),
            body: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'We\'ve sent a verification code to:',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  _email.text,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: context.theme.colorScheme.primary,
                  ),
                ),
                SizedBox(height: 16),
                FTextField(
                  controller: _verificationCode,
                  label: const Text('Verification Code'),
                  keyboardType: TextInputType.number,
                  validator: ValidationConstants.validateVerificationCode,
                  hint: '6-digit code',
                ),
                if (_verificationError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _verificationError!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
            actions: [
              FButton(
                style: FButtonStyle.outline,
                label: const Text('Resend Code'),
                onPress: () {
                  Navigator.of(context).pop();
                  _requestVerificationCode();
                },
              ),
              FButton(
                label: const Text('Verify'),
                onPress: () {
                  Navigator.of(context).pop();
                  _verifyCode();
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
            title: const Text('Error'),
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

  Future<void> _requestVerificationCode() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _verificationError = null;
      });

      try {
        // Real API call to request verification code - now returns VerificationResult
        final result = await _authRepository.requestVerificationCode(
          _email.text,
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
            _codeRequested = result.success;

            if (result.code != null) {
              _verificationCode.text = result.code!;
            }
          });

          if (result.success) {
            _showVerificationDialog();
          } else {
            _showErrorDialog(result.message);
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _showErrorDialog('Error: ${e.toString()}');
        }
      }
    }
  }

  Future<void> _verifyCode() async {
    if (_verificationCode.text.isEmpty) {
      setState(() {
        _verificationError = 'Verification code is required';
      });
      _showVerificationDialog();
      return;
    }

    setState(() {
      _isLoading = true;
      _verificationError = null;
    });

    try {
      // Real API call to verify code
      final success = await _authRepository.verifyEmailCode(
        _email.text,
        _verificationCode.text,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _codeVerified = success;
        });

        if (success) {
          // If verified, proceed with signup
          _completeSignup();
        } else {
          _verificationError = 'Invalid verification code. Please try again.';
          _showVerificationDialog();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _verificationError = e.toString();
        });
        _showVerificationDialog();
      }
    }
  }

  void _completeSignup() async {
    if (!_codeVerified) {
      _showErrorDialog('Please verify your email first');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      const String avatarId = '1';

      // For debugging
      print(
        'Sending department: ${_isAdminSignup ? "admin" : _selectedDepartment}',
      );

      // Dispatch signup event to auth bloc
      context.read<AuthBloc>().add(
        AuthSignUpRequested(
          name: _name.text,
          email: _email.text,
          password: _password.text,
          avatarId: avatarId,
          department:
              _isAdminSignup
                  ? "admin"
                  : _selectedDepartment, // Use "admin" for admin accounts
          profileImage: _profileImage,
          verificationCode: _verificationCode.text,
          isAdmin: _isAdminSignup, // Add isAdmin flag
        ),
      );
    } catch (e) {
      print('Signup error: $e');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('Registration failed: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get initials for avatar
    final initials = _getInitials();

    // Replace the Department FTile with this fixed version
    FTileMixin buildDepartmentTile() {
      // Don't show department selection for admin signup
      if (_isAdminSignup) {
        return FTile(
          title: const Text("Info"),
          subtitle: const Text("Admins have no defaut department"),
        );
      }

      return FTile(
        title: const Text("Department"),
        subtitle:
            _loadingDepartments
                ? const Center(child: CircularProgressIndicator.adaptive())
                : _departments.isEmpty
                ? const Text("No departments available")
                : SizedBox(
                  height: 120,
                  child: CupertinoPicker(
                    scrollController: _departmentScrollController,
                    itemExtent: 40,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _selectedDepartment = _departments[index].name;
                      });
                    },
                    children:
                        _departments
                            .map(
                              (dept) => Center(
                                child: Text(
                                  dept.name,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
      );
    }

    return FScaffold(
      resizeToAvoidBottomInset: true,
      header: FHeader(title: Text("Create Account")),
      content: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          setState(() {
            _isLoading = state is AuthLoading;
          });

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
          return _isLoading
              ? const Center(child: CircularProgressIndicator.adaptive())
              : SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Avatar implementation with image picker
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
                              child:
                                  _profileImage != null
                                      ? ClipRRect(
                                        borderRadius: BorderRadius.circular(60),
                                        child: Image.file(
                                          _profileImage!,
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                      : Center(
                                        child: Text(
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
                                enabled: !_codeRequested,
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
                                enabled: !_codeRequested,
                              ),
                            ),
                            // Add admin account checkbox
                            FTile(
                              title: const Text("Admin Account"),
                              subtitle: Row(
                                children: [
                                  FCheckbox(
                                    value: _isAdminSignup,
                                    onChange:
                                        !_codeRequested
                                            ? (value) {
                                              setState(() {
                                                _isAdminSignup = value ?? false;
                                              });
                                            }
                                            : null,
                                  ),
                                  const Text("Register as administrator"),
                                ],
                              ),
                            ),
                            // Only show department selector if not admin signup
                            if (!_isAdminSignup) buildDepartmentTile(),
                            FTile(
                              title:
                                  _codeRequested
                                      ? FButton(
                                        onPress:
                                            () => _showVerificationDialog(),
                                        label:
                                            _codeVerified
                                                ? const Text("Verified ✓")
                                                : const Text(
                                                  "Enter Verification Code",
                                                ),
                                        style:
                                            _codeVerified
                                                ? FButtonStyle.primary
                                                : FButtonStyle.secondary,
                                      )
                                      : FButton(
                                        onPress: _requestVerificationCode,
                                        label: const Text(
                                          "Request Verification Code",
                                        ),
                                      ),
                            ),
                            if (_codeVerified)
                              FTile(
                                title: FButton(
                                  onPress: _completeSignup,
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
