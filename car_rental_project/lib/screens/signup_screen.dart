import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';

class SignupScreen extends StatelessWidget {
  SignupScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  // TextEditingControllers for the form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white, // Set the background color to white
      body: Padding(
        padding: const EdgeInsets.only(top: 80.0, left: 16.0, right: 16.0), // Add padding on top
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Get Started',
                style: TextStyle(
                  fontSize: 38.0,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _nameController,
                label: 'Full name',
                hintText: 'Enter fullname',
                validator: UserModel.validateName,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                hintText: 'Enter email',
                validator: UserModel.validateEmail,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                hintText: 'Enter password',
                obscureText: true,
                validator: UserModel.validatePassword,
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      userProvider.signup(
                        name: _nameController.text,
                        email: _emailController.text,
                        password: _passwordController.text,
                        context: context,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                  ),
                  child: userProvider.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Sign up'),
                ),
              ),
              const SizedBox(height: 20),
              _buildDivider(),
              const SizedBox(height: 10),
              _buildSocialMediaButtons(userProvider),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable method for creating text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required String? Function(String?)? validator,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      obscuringCharacter: '*',
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.black26),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  // Divider for the "Sign up with" section
  Widget _buildDivider() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Divider(
            thickness: 0.7,
            color: Colors.grey.withOpacity(0.5),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'Sign up with',
            style: TextStyle(color: Colors.black45),
          ),
        ),
        Expanded(
          child: Divider(
            thickness: 0.7,
            color: Colors.grey.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  // Social Media Buttons for Sign Up
  Widget _buildSocialMediaButtons(UserProvider userProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            // userProvider.signInWithFacebook(context);
          },
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1877F2),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(16.0),
            child: const Icon(
              FontAwesomeIcons.facebookF,
              color: Colors.white,
              size: 24.0,
            ),
          ),
        ),
        const SizedBox(width: 20),
        GestureDetector(
          onTap: () {
            // userProvider.signInWithGoogle(context);
          },
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(16.0),
            child: const Icon(
              FontAwesomeIcons.google,
              color: Colors.white,
              size: 24.0,
            ),
          ),
        ),
      ],
    );
  }
}
