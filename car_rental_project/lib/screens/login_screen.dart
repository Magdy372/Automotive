import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode? Colors.black:Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(top: 80.0, left: 16.0, right: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
               Text(
                'Welcome back',
                style: GoogleFonts.poppins(
                  fontSize: 38.0,
                  fontWeight: FontWeight.w900,
                  color: isDarkMode? Colors.grey[300]:Color(0XFF97B3AE),
                ),
              ),
              const SizedBox(height: 10),
              _buildEmailField(context),
              const SizedBox(height: 10),
              _buildPasswordField(context),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: _buildForgotPasswordButton(context, userProvider,isDarkMode),
              ),
              const SizedBox(height: 10),
              _buildLoginButton(userProvider, context,isDarkMode),
              const SizedBox(height: 20),
              _buildSignUpWithDivider(context),
              const SizedBox(height: 10),
              _buildSocialMediaButtons(userProvider,context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField(BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: _emailController,
      validator: UserModel.validateEmail,
      decoration: InputDecoration(
        label: const Text('Email'),
        hintStyle: GoogleFonts.poppins(color: isDarkMode?Colors.grey[300]: Color(0XFF97B3AE)),
      ),
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: _passwordController,
      obscureText: true,
      obscuringCharacter: '*',
      validator: UserModel.validatePassword,
      decoration: InputDecoration(
        label: const Text('Password'),
        hintStyle:  GoogleFonts.poppins(color: isDarkMode?Colors.grey[300]: Color(0XFF97B3AE)),
      ),
    );
  }

  Widget _buildForgotPasswordButton(
      BuildContext context, UserProvider userProvider, bool isDarkMode) {
            final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
      child:Text(
        'Forgot Password?',
        style: GoogleFonts.poppins(color: isDarkMode?Colors.grey[300]: Color(0XFF97B3AE)),
      ),
    );
  }

  Widget _buildLoginButton(UserProvider userProvider, BuildContext context, bool isDarkMode) {
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
                    foregroundColor: isDarkMode? Colors.black:Colors.white,
                    backgroundColor: isDarkMode? Colors.white:Color(0XFF997B3AE)
                  ),
        child: userProvider.isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Login'),
      ),
    );
  }

  Widget _buildSignUpWithDivider(BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Divider(
            thickness: 0.7,
            color: Colors.grey.withOpacity(0.5),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'Sign up with',
            style: GoogleFonts.poppins(color: isDarkMode? Colors.white:Color(0XFF97B3AE)),
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


  Widget _buildSocialMediaButtons(UserProvider userProvider, BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            // userProvider.signInWithFacebook(context);
          },
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode? Colors.grey[800]:Color(0XFF97B3AE),
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
            decoration: BoxDecoration(
              color: isDarkMode? Colors.grey[800]:Color(0XFF97B3AE),
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
