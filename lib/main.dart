import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Customer Sentiment Analysis',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: const MyHomePage(title: 'Customer Sentiment Analysis'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<http.Response> predictSentiment(String sentence) {
    return http.post(
      Uri.http('127.0.0.1:5000', '/predict'),
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json',
        'Accept': '*/*'
      },
      body: jsonEncode(<String, String>{'sentence': sentence}),
    );
  }

  final _inputController = TextEditingController();
  String text = "";
  bool isLoading = false;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(30)),
                color: Colors.blueGrey[200],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  cursorColor: Colors.blueGrey[900],
                  controller: _inputController,
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter the sentence to be analysed'),
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            SizedBox(
              height: 50,
              width: 100,
              child: ElevatedButton(
                  onPressed: _setText,
                  style: ButtonStyle(
                      elevation: MaterialStateProperty.all(8),
                      backgroundColor:
                          MaterialStateProperty.all(Colors.blueGrey[900])),
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Analyse',
                          style: TextStyle(color: Colors.white),
                        )),
            ),
            const SizedBox(
              height: 8,
            ),
            text != ""
                ? text == "positive"
                    ? Container(
                        height: 250,
                        width: 150,
                        //happy
                        child: Column(
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            const Image(
                                image: AssetImage('../images/happy.png')),
                            SizedBox(
                              height: 20,
                            ),
                            const Text(
                              'Positive Sentiment',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17),
                            )
                          ],
                        ),
                      )
                    : Container(
                        height: 250,
                        width: 150,
                        //sad
                        child: Column(
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            const Image(image: AssetImage('../images/sad.png')),
                            SizedBox(
                              height: 20,
                            ),
                            const Text(
                              'Negative Sentiment',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17),
                            )
                          ],
                        ),
                      )
                : Container(
                    height: 250,
                    width: 150,
                  )
          ],
        ),
      ),
    );
  }

  void _setText() async {
    setState(() {
      isLoading = true;
    });
    http.Response response = await predictSentiment(_inputController.text);
    // {"result":"negative"}
    Future.delayed(
        const Duration(milliseconds: 1000),
        () => {
              setState(() {
                text = response.body.split(':')[1].substring(1, 9);
                isLoading = false;
              })
            });
  }
}
