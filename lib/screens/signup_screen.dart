import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/responsive/mobile_screen_layout.dart';
import 'package:instagram_clone/responsive/responsive_layout_screen.dart';
import 'package:instagram_clone/responsive/web_screen_layout.dart';
import 'package:instagram_clone/screens/login_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/text_input_field.dart';
import 'package:instagram_clone/resources/auth_methods.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  Uint8List? _image;
  bool _isLoading = false;

  final AuthMethods _auth = AuthMethods();

  void _selectImage() async {
    Uint8List? im = await pickImage(ImageSource.gallery);
    setState(() {
      _image = im;
    });
  }

  void SignupUser() async {
    setState(() => _isLoading = true);
    String res = await _auth.SignupUser(
        email: _emailController.text,
        password: _passwordController.text,
        username: _usernameController.text,
        bio: _bioController.text,
        file: _image);
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
  void dispose() {
    super.dispose();

    _emailController.dispose();
    _bioController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              Flexible(flex: 1, child: Container()),
              SvgPicture.asset('assets/ic_instagram.svg',
                  color: primaryColor, height: 50),
              const SizedBox(height: 35),
              Stack(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: const Color.fromARGB(168, 255, 255, 255),
                    child: _image != null
                        ? CircleAvatar(
                            backgroundImage: MemoryImage(_image!),
                            radius: 39,
                          )
                        : const CircleAvatar(
                            backgroundImage: NetworkImage(
                                'https://media.istockphoto.com/vectors/default-profile-picture-avatar-photo-placeholder-vector-illustration-vector-id1223671392?k=6&m=1223671392&s=170667a&w=0&h=zP3l7WJinOFaGb2i1F4g8IS2ylw0FlIaa6x3tP9sebU='),
                            radius: 39,
                          ),
                  ),
                  Positioned(
                    bottom: -10,
                    left: 48,
                    child: IconButton(
                      onPressed: () => _selectImage(),
                      icon: const Icon(Icons.add_a_photo),
                      iconSize: 19,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 35),
              TextFieldInput(
                hintText: 'Enter your username',
                textEditingController: _usernameController,
                textInputType: TextInputType.text,
              ),
              const SizedBox(height: 13),
              TextFieldInput(
                hintText: 'Enter your email',
                textEditingController: _emailController,
                textInputType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 13),
              TextFieldInput(
                hintText: 'Password',
                textEditingController: _passwordController,
                textInputType: TextInputType.text,
                isPass: true,
              ),
              const SizedBox(height: 13),
              TextFieldInput(
                hintText: 'Enter your bio',
                textEditingController: _bioController,
                textInputType: TextInputType.text,
              ),
              const SizedBox(height: 30),
              InkWell(
                onTap: () => SignupUser(),
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
                            height: 25.0,
                            width: 25.0,
                            child: CircularProgressIndicator(
                                color: primaryColor, strokeWidth: 3.0),
                          )
                        : const Text(
                            'Sign Up',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ),
              Flexible(flex: 1, child: Container()),
              Row(
                children: [
                  Container(width: 50),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: const Text('Already have an account?'),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const LoginScreen()));
                    },
                    child: const Text(
                      'Login',
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
