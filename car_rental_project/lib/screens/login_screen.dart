import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(top: 80.0, left: 16.0, right: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(flex: 2),
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.fromLTRB(25, 50, 25, 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40.0),
                    topRight: Radius.circular(40.0),
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Welcome back',
                        style: TextStyle(
                          fontSize: 38.0,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildEmailField(),
                      const SizedBox(height: 10),
                      _buildPasswordField(),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: _buildForgotPasswordButton(context, userProvider),
                      ),
                      const SizedBox(height: 10),
                      _buildLoginButton(userProvider, context),
                      const SizedBox(height: 20),
                      _buildSignUpWithDivider(),
                      const SizedBox(height: 10),
                      _buildSocialLoginButtons(userProvider),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      validator: UserModel.validateEmail,
      decoration: InputDecoration(
        label: const Text('Email'),
        hintText: 'Enter email',
        hintStyle: const TextStyle(color: Colors.black26),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black12),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: true,
      obscuringCharacter: '*',
      validator: UserModel.validatePassword,
      decoration: InputDecoration(
        label: const Text('Password'),
        hintText: 'Enter password',
        hintStyle: const TextStyle(color: Colors.black26),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black12),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  Widget _buildForgotPasswordButton(BuildContext context, UserProvider userProvider) {
    return TextButton(
      onPressed: () {
        if (_emailController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter your email to reset password.'),
            ),
          );
          return;
        }

        userProvider.resetPassword(_emailController.text, context);
      },
      child: const Text(
        'Forgot Password?',
        style: TextStyle(color: Colors.black54),
      ),
    );
  }

  Widget _buildLoginButton(UserProvider userProvider, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            userProvider.login(
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
            : const Text('Login'),
      ),
    );
  }

  Widget _buildSignUpWithDivider() {
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

  Widget _buildSocialLoginButtons(UserProvider userProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton(
          color: const Color(0xFF1877F2),
          icon: FontAwesomeIcons.facebookF,
          onTap: () {
            // userProvider.signInWithFacebook(context);
          },
        ),
        const SizedBox(width: 20),
        _buildSocialButton(
          color: Colors.black,
          icon: FontAwesomeIcons.google,
          onTap: () {
            // userProvider.signInWithGoogle(context);
          },
        ),
      ],
    );
  }

  Widget _buildSocialButton({required Color color, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        padding: const EdgeInsets.all(16.0),
        child: Icon(icon, color: Colors.white, size: 24.0),
      ),
    );
  }
}
