// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/user_provider.dart';
// import '../models/user_model.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// class LoginScreen extends StatelessWidget {
//   LoginScreen({super.key});

//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     final userProvider = Provider.of<UserProvider>(context);

//     return Scaffold(
//       backgroundColor: Colors.black, // Set background color to black
//       body: Stack(
//         children: [
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             height: MediaQuery.of(context).size.height / 2, // Half the screen height
//             child: Container(
//               decoration: const BoxDecoration(
//                 image: DecorationImage(
//                   image: AssetImage('assets/images/onboarding1.png'),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//           ),
//           // Gradient overlay on the image
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             height: MediaQuery.of(context).size.height / 2, // Half the screen height
//             child: Container(
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.bottomCenter,
//                   end: Alignment.topCenter,
//                   colors: [
//                     Color.fromARGB(255, 39, 38, 44), // Background color
//                     Colors.transparent, // Fully transparent at the top
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           Column(
//             children: [
//               // Empty space for the background
//               const Expanded(
//                 flex: 2,
//                 child: SizedBox(),
//               ),
//               // White container with rounded corners
//               Expanded(
//                 flex: 3,
//                 child: Container(
//                   padding: const EdgeInsets.fromLTRB(25, 50, 25, 20),
//                   decoration: const BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(40.0),
//                       topRight: Radius.circular(40.0),
//                     ),
//                   ),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         const Text(
//                           'Welcome back',
//                           style: TextStyle(
//                             fontSize: 38.0,
//                             fontWeight: FontWeight.w900,
//                             color: Colors.black,
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         TextFormField(
//                           controller: _emailController,
//                       validator: UserModel.validateEmail,
//                           decoration: InputDecoration(
//                             label: const Text('Email'),
//                             hintText: 'Enter email',
//                             hintStyle: const TextStyle(
//                               color: Colors.black26,
//                             ),
//                             border: OutlineInputBorder(
//                               borderSide: const BorderSide(
//                                 color: Colors.black12,
//                               ),
//                               borderRadius: BorderRadius.circular(10.0),
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderSide: const BorderSide(
//                                 color: Colors.black12,
//                               ),
//                               borderRadius: BorderRadius.circular(10.0),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         TextFormField(
//                           controller: _passwordController,
//                           obscureText: true,
//                           obscuringCharacter: '*',
//                         validator: UserModel.validatePassword,
//                           decoration: InputDecoration(
//                             label: const Text('Password'),
//                             hintText: 'Enter password',
//                             hintStyle: const TextStyle(
//                               color: Colors.black26,
//                             ),
//                             border: OutlineInputBorder(
//                               borderSide: const BorderSide(
//                                 color: Colors.black12,
//                               ),
//                               borderRadius: BorderRadius.circular(10.0),
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderSide: const BorderSide(
//                                 color: Colors.black12,
//                               ),
//                               borderRadius: BorderRadius.circular(10.0),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         Align(
//                           alignment: Alignment.centerRight,
//                           child: TextButton(
//                             onPressed: () {
//                               if (_emailController.text.isEmpty) {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                     content: Text('Please enter your email to reset password.'),
//                                   ),
//                                 );
//                                 return;
//                               }

//                               userProvider.resetPassword(_emailController.text, context);
//                             },
//                             child: const Text(
//                               'Forgot Password?',
//                               style: TextStyle(
//                                 color: Colors.black54,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         SizedBox(
//                           width: double.infinity,
//                           height: 54,
//                           child: ElevatedButton(
//                             onPressed: () {
//                               if (_formKey.currentState!.validate()) {
//                                 userProvider.login(
//                                   email: _emailController.text,
//                                   password: _passwordController.text,
//                                   context: context,
//                                 );
//                               }
//                             },
//                             style: ElevatedButton.styleFrom(
//                               foregroundColor: Colors.white,
//                               backgroundColor: Colors.black,
//                             ),
//                             child: userProvider.isLoading
//                                 ? const CircularProgressIndicator(
//                                     color: Colors.white,
//                                   )
//                                 : const Text('Login'),
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Expanded(
//                               child: Divider(
//                                 thickness: 0.7,
//                                 color: Colors.grey.withOpacity(0.5),
//                               ),
//                             ),
//                             const Padding(
//                               padding: EdgeInsets.symmetric(
//                                 vertical: 0,
//                                 horizontal: 10,
//                               ),
//                               child: Text(
//                                 'Sign up with',
//                                 style: TextStyle(
//                                   color: Colors.black45,
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               child: Divider(
//                                 thickness: 0.7,
//                                 color: Colors.grey.withOpacity(0.5),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 10),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             GestureDetector(
//                               onTap: () {
//                               //  userProvider.signInWithFacebook(context);
//                               },
//                               child: Container(
//                                 decoration: const BoxDecoration(
//                                   color: Color(0xFF1877F2),
//                                   shape: BoxShape.circle,
//                                 ),
//                                 padding: const EdgeInsets.all(16.0),
//                                 child: const Icon(
//                                   FontAwesomeIcons.facebookF,
//                                   color: Colors.white,
//                                   size: 24.0,
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 20),
//                             GestureDetector(
//                               onTap: () {
//                               //  userProvider.signInWithGoogle(context);
//                               },
//                               child: Container(
//                                 decoration: const BoxDecoration(
//                                   color: Colors.black,
//                                   shape: BoxShape.circle,
//                                 ),
//                                 padding: const EdgeInsets.all(16.0),
//                                 child: const Icon(
//                                   FontAwesomeIcons.google,
//                                   color: Colors.white,
//                                   size: 24.0,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
