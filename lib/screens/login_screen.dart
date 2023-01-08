import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:instagram_clone/responsive/mobile_screen_layout.dart';
import 'package:instagram_clone/responsive/responsive_layout_screen.dart';
import 'package:instagram_clone/responsive/web_screen_layout.dart';
import 'package:instagram_clone/screens/signup_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/text_input_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  final AuthMethods _auth = AuthMethods();

  @override
  void dispose() {
    super.dispose();

    _emailController.dispose();
    _passwordController.dispose();
  }

  void LoginUser() async {
    setState(() => _isLoading = true);
    String res = await _auth.Login(
        email: _emailController.text, password: _passwordController.text);
    setState(() => _isLoading = false);
    if (res != 'success') {
      showSnackBar(context, res);
    } else {
      print(res);
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const ResponsiveLayout(
              mobileScreenLayout: MobileScreenLayout(),
              webScreenLayout: WebScreenLayout())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        //to avoid interfering with system UI
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          //color: Colors.amber,
          child: Column(
            children: [
              Flexible(child: Container(), flex: 1),
              SvgPicture.asset(
                //a custom widget --from flutter_svg-- to load picture of .svg
                'assets/ic_instagram.svg',
                color: primaryColor,
                height: 50,
              ),
              const SizedBox(height: 40),
              // a custom method to load 'generalized' TextField widget for email
              TextFieldInput(
                hintText: 'Enter your email',
                textEditingController: _emailController,
                textInputType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 13),
              // a custom method to load 'generalized' TextField widget for password
              TextFieldInput(
                hintText: 'Password',
                textEditingController: _passwordController,
                textInputType: TextInputType.text,
                isPass: true,
              ),
              const SizedBox(height: 50),
              //InkWell is used for buttons. They provide additional features
              InkWell(
                onTap: () => LoginUser(),
                child: Container(
                  width: double.infinity,
                  height: 40,
                  decoration: const ShapeDecoration(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(3))),
                      color: blueColor),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                            width: 25.0,
                            height: 25.0,
                            child: CircularProgressIndicator(
                                color: primaryColor, strokeWidth: 3.0),
                          )
                        : const Text(
                            'Log in',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Flexible(
                flex: 1,
                child: Container(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 3, horizontal: 3),
                    child: const Text("Don't have an account?"),
                  ),
                  GestureDetector(
                    //GestureDetector is used on buttons for different gestures
                    onTap: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const SignUpScreen()));
                    },
                    child: const Text(
                      'Sign up.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
