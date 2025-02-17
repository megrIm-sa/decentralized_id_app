import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ethereum_service.dart';
import '../pages/home_page.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  final EthereumService _ethereumService = EthereumService();
  bool _isProcessing = false;

  Future<void> _registerUser() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      await _ethereumService.registerUser(
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
        _dobController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User registered successfully!")),
      );

      // Restart the page by replacing it with a new instance
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RegistrationPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error registering user: $e")),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }


  Future<void> _loginUser() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      Map<String, String> userData = await _ethereumService.getUser(
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
        _dobController.text.trim(),
      );

      // Save user data locally
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("firstName", userData["firstName"]!);
      await prefs.setString("lastName", userData["lastName"]!);
      await prefs.setString("dateOfBirth", userData["dateOfBirth"]!);
      await prefs.setString("did", userData["did"]!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login successful!")),
      );

      // Navigate to the main page after login
      _navigateToMainScreen();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error logging in: $e")),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _navigateToMainScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register or Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _firstNameController, decoration: InputDecoration(labelText: "First Name")),
            TextField(controller: _lastNameController, decoration: InputDecoration(labelText: "Last Name")),
            TextField(controller: _dobController, decoration: InputDecoration(labelText: "Date of Birth")),
            SizedBox(height: 20),
            _isProcessing
                ? CircularProgressIndicator()
                : Column(
              children: [
                ElevatedButton(onPressed: _registerUser, child: Text("Register")),
                SizedBox(height: 10),
                ElevatedButton(onPressed: _loginUser, child: Text("Login")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
