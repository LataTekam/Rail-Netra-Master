// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:railway/src/components/custom_textfield.dart';
import 'package:railway/src/components/secondary_button.dart';
import 'package:railway/src/modal/user_model.dart';
import 'package:railway/src/user/login_screen.dart';
import 'package:railway/src/utils/constants.dart';
import 'package:railway/src/utils/custom_page_route.dart';
import 'package:url_launcher/url_launcher.dart';

class RegisterUser extends StatefulWidget {
  const RegisterUser({super.key});

  @override
  State<RegisterUser> createState() => _RegisterUserState();
}

class _RegisterUserState extends State<RegisterUser> {
  bool isPasswordHide = true;
  bool isConfirmPasswordHide = true;
  final _formKey = GlobalKey<FormState>();
  final _formData = <String, Object>{};
  bool isLoading = false;
  bool acceptConditions = false;

  // function to disable back button
  Future<bool> _onPop() async {
    return false;
  }

  // on submit function
  _onSubmit() async {
    _formKey.currentState!.save();

    // checking both password are equal or not
    if (_formData['password'] != _formData['confirm_password']) {
      showAlertDialogueBox(
          context, "Passwords do not match! \nPlease try again.");
    } else {
      progressIndicator(context);
      try {
        setState(() {
          isLoading = true;
        });
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: _formData['email'].toString(),
                password: _formData['password'].toString());

        if (userCredential.user != null) {
          setState(() {
            isLoading = true;
          });

          final value = userCredential.user!.uid;

          DocumentReference<Map<String, dynamic>> db =
              FirebaseFirestore.instance.collection('users').doc(value);

          final user = UserModel(
            id: value,
            email: _formData['email'].toString(),
            name: _formData['name'].toString(),
            phone: _formData['phone'].toString(),
            type: 'user',
            about: "Hey, I am using Rail Netra!",
            profilePic: null,
            pushToken: '',
          );

          final jsonData = user.toJson();

          await db.set(jsonData).whenComplete(() {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const LoginScreen()));
            setState(() {
              isLoading = false;
            });
          });
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          isLoading = false;
        });
        if (e.code == 'weak-password') {
          showAlertDialogueBox(context, "The password provided is too weak.");
        } else if (e.code == 'email-already-in-use') {
          showAlertDialogueBox(
              context, "The account already exists for that email.");
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        showAlertDialogueBox(context, "Something went wrong!");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onPop,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(color: bgColor),
          child: Center(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  children: [
                    isLoading
                        ? progressIndicator(context)
                        : SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // app icon
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.asset(
                                    "assets/images/icons/logo.png",
                                    width: 120,
                                  ),
                                ),

                                // login text
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    "User Registration",
                                    style: TextStyle(
                                        fontSize: 30,
                                        color: primaryColor,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),

                                // form
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 8,
                                            left: 8,
                                            right: 8,
                                            bottom: 5),
                                        child: CustomTextField(
                                          hintText: "Name",
                                          textInputAction: TextInputAction.next,
                                          keyboardType: TextInputType.name,
                                          prefix: const Icon(Icons.person),
                                          onSave: (name) {
                                            _formData['name'] = name ?? "";
                                          },
                                          validate: (name) {
                                            if (name!.isEmpty ||
                                                name.length < 3) {
                                              return "Incorrect name";
                                            } else if (name.length > 20) {
                                              return "Name is too long";
                                            } else {
                                              return null;
                                            }
                                          },
                                        ),
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 5,
                                            left: 8,
                                            right: 8,
                                            bottom: 5),
                                        child: CustomTextField(
                                          hintText: "Phone",
                                          textInputAction: TextInputAction.next,
                                          keyboardType: TextInputType.phone,
                                          prefix: const Icon(Icons.phone),
                                          onSave: (phone) {
                                            _formData['phone'] = phone ?? "";
                                          },
                                          validate: (phone) {
                                            if (phone!.isEmpty ||
                                                phone.length != 10) {
                                              return "Incorrect mobile number";
                                            } else {
                                              return null;
                                            }
                                          },
                                        ),
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 5,
                                            left: 8,
                                            right: 8,
                                            bottom: 5),
                                        child: CustomTextField(
                                          hintText: "Email",
                                          textInputAction: TextInputAction.next,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          prefix: const Icon(Icons.email),
                                          onSave: (email) {
                                            _formData['email'] = email ?? "";
                                          },
                                          validate: (email) {
                                            if (email!.isEmpty ||
                                                email.length < 8 ||
                                                !email.contains("@") ||
                                                email.contains(" ")) {
                                              return "Invalid email address";
                                            } else {
                                              return null;
                                            }
                                          },
                                        ),
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 5,
                                            left: 8,
                                            right: 8,
                                            bottom: 5),
                                        child: CustomTextField(
                                          hintText: "Password",
                                          textInputAction: TextInputAction.next,
                                          keyboardType:
                                              TextInputType.visiblePassword,
                                          prefix:
                                              const Icon(Icons.lock_rounded),
                                          onSave: (password) {
                                            _formData['password'] =
                                                password ?? "";
                                          },
                                          validate: (password) {
                                            if (password!.isEmpty ||
                                                password.length < 8 ||
                                                password.contains(" ")) {
                                              return "Password length should be more than 8 characters";
                                            } else {
                                              return null;
                                            }
                                          },
                                          isPassword: isPasswordHide,
                                          suffix: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                isPasswordHide =
                                                    !isPasswordHide;
                                              });
                                            },
                                            icon: isPasswordHide
                                                ? const Icon(
                                                    Icons.visibility_off)
                                                : const Icon(Icons.visibility),
                                          ),
                                        ),
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 5,
                                            left: 8,
                                            right: 8,
                                            bottom: 8),
                                        child: CustomTextField(
                                          hintText: "Confirm Password",
                                          keyboardType:
                                              TextInputType.visiblePassword,
                                          prefix:
                                              const Icon(Icons.lock_rounded),
                                          onSave: (password) {
                                            _formData['confirm_password'] =
                                                password ?? "";
                                          },
                                          validate: (confirmPassword) {
                                            if (confirmPassword!.isEmpty ||
                                                confirmPassword.length < 8 ||
                                                confirmPassword.contains(" ")) {
                                              return "Password length should be more than 8 characters";
                                            } else {
                                              return null;
                                            }
                                          },
                                          isPassword: isConfirmPasswordHide,
                                          suffix: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                isConfirmPasswordHide =
                                                    !isConfirmPasswordHide;
                                              });
                                            },
                                            icon: isConfirmPasswordHide
                                                ? const Icon(
                                                    Icons.visibility_off)
                                                : const Icon(Icons.visibility),
                                          ),
                                        ),
                                      ),

                                      // create new account button
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Checkbox(
                                            activeColor: primaryColor,
                                            value: acceptConditions,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                acceptConditions = value!;
                                              });
                                            },
                                          ),
                                          Flexible(
                                            child: RichText(
                                              text: TextSpan(
                                                  // Default Style
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xff383838)),
                                                  children: <TextSpan>[
                                                    const TextSpan(
                                                        text:
                                                            "By continuing, you have read the "),
                                                    TextSpan(
                                                        text: "Privacy Policy",
                                                        style: TextStyle(
                                                            color: primaryColor,
                                                            decoration:
                                                                TextDecoration
                                                                    .underline),
                                                        recognizer:
                                                            TapGestureRecognizer()
                                                              ..onTap =
                                                                  () async {
                                                                final Uri url =
                                                                    Uri.parse(
                                                                        "https://sites.google.com/view/railwayxpert-privacy-policy/home");
                                                                try {
                                                                  final result =
                                                                      await InternetAddress
                                                                          .lookup(
                                                                              'example.com');
                                                                  if (result
                                                                          .isNotEmpty &&
                                                                      result[0]
                                                                          .rawAddress
                                                                          .isNotEmpty) {
                                                                    if (!await launchUrl(
                                                                        url)) {
                                                                      throw Exception(
                                                                          'Could not launch $url');
                                                                    }
                                                                  }
                                                                } on SocketException catch (_) {
                                                                  showSnackbar(
                                                                      context,
                                                                      "No internet connection found!");
                                                                }
                                                              }),
                                                    const TextSpan(
                                                        text:
                                                            " and agree to the "),
                                                    TextSpan(
                                                        text:
                                                            "Terms & Conditions",
                                                        style: TextStyle(
                                                            color: primaryColor,
                                                            decoration:
                                                                TextDecoration
                                                                    .underline),
                                                        recognizer:
                                                            TapGestureRecognizer()
                                                              ..onTap =
                                                                  () async {
                                                                final Uri url =
                                                                    Uri.parse(
                                                                        "https://sites.google.com/view/railwayxpert-terms/home");
                                                                try {
                                                                  final result =
                                                                      await InternetAddress
                                                                          .lookup(
                                                                              'example.com');
                                                                  if (result
                                                                          .isNotEmpty &&
                                                                      result[0]
                                                                          .rawAddress
                                                                          .isNotEmpty) {
                                                                    if (!await launchUrl(
                                                                        url)) {
                                                                      throw Exception(
                                                                          'Could not launch $url');
                                                                    }
                                                                  }
                                                                } on SocketException catch (_) {
                                                                  showSnackbar(
                                                                      context,
                                                                      "No internet connection found!");
                                                                }
                                                              })
                                                  ]),
                                            ),
                                          ),
                                        ],
                                      ),

                                      // Register button
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          height: 60,
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: acceptConditions
                                                ? () {
                                                    if (_formKey.currentState!
                                                        .validate()) {
                                                      _onSubmit();
                                                    }
                                                  }
                                                : null,
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: primaryColor,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30))),
                                            child: const Text(
                                              "Register",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // create new account button
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Already have an account?",
                                    ),
                                    SecondaryButton(
                                        title: "Sign in",
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              CustomPageRoute(
                                                  child: const LoginScreen()));
                                        }),
                                  ],
                                )
                              ],
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
