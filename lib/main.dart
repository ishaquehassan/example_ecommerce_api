import 'dart:convert';

import 'package:example_ecommerce_api/models/all_categories_model.dart';
import 'package:example_ecommerce_api/models/login_response.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Login(),
    );
  }
}

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  UserData? userData;
  List<AllCategoriesData>? categories;
  bool isLoading = false;
  String? error;
  TextEditingController usernameCtrl = TextEditingController();
  TextEditingController passwordCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("HTTP Demo"),
      ),
      body: !isLoading
          ? Column(
              children: [
                if (error != null) Text("There was an error : $error"),
                if (userData == null) ...[
                  TextField(controller: usernameCtrl),
                  TextField(controller: passwordCtrl),
                  ElevatedButton(onPressed: login, child: Text("Login"))
                ],
                if (userData != null) Text(userData?.accessToken ?? ""),
                if (categories != null)
                  Expanded(
                      child: ListView.builder(
                    itemCount: categories!.length,
                    itemBuilder: (_, index) => ListTile(
                      title: Text(categories![index].title ?? ""),
                      leading: Image.network(categories![index].icon ?? ""),
                    ),
                  ))
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }

  void login() async {
    var url = Uri.parse('http://ishaqhassan.com:9001/user/signin');
    setState(() {
      isLoading = true;
    });
    try {
      var response = await http.post(url,
          body: {'email': usernameCtrl.text, 'password': passwordCtrl.text});
      var responseJSON = LoginResponse.fromJson(jsonDecode(response.body));
      setState(() {
        userData = responseJSON.data;
      });
      await getAllCategories();
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> getAllCategories() async {
    var url = Uri.parse('http://ishaqhassan.com:9001/category');
    setState(() {
      isLoading = true;
    });
    try {
      var response = await http.get(url,
          headers: {"Authorization": "Bearer ${userData?.accessToken}"});
      var responseJSON =
          AllCategoriesResponse.fromJson(jsonDecode(response.body));
      setState(() {
        categories = responseJSON.data;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
    setState(() {
      isLoading = false;
    });
  }
}
