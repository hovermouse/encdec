import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';

const key_other=   '12345678901234561234567890123456';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String result = "Press button for enc/dec test";


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$result',
            ),

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:()async {
          String log = await encDecTest(context: context);
          setState(() {
            result = log;
          });},
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<String> encDecTest({BuildContext context}) async {


    String log = "";

    final stopwatch = Stopwatch()..start();
    final key = encrypt.Key.fromUtf8(key_other);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.ctr));
    print('Encrypter ready in ${Duration(milliseconds: stopwatch.elapsedMilliseconds).toString()} ms.');
    stopwatch.reset();

    final fileBytes = await DefaultAssetBundle.of(context).load("assets/walden_c01_64kb.mp3");

    final fileBuffer = fileBytes.buffer;
    final bytesToEncrypt = fileBuffer.asUint8List(fileBytes.offsetInBytes, fileBytes.lengthInBytes);

    // var fileBytes = await _readFileByte(arguments[0]);
    log = log + 'Asset file in memory in ${Duration(milliseconds: stopwatch.elapsedMilliseconds).toString()} .\n';
    print('Asset file in memory in ${Duration(milliseconds: stopwatch.elapsedMilliseconds).toString()} .');
    stopwatch.reset();

    final encrypted = encrypter.encryptBytes(bytesToEncrypt, iv: iv);
    var encryptedBytes = encrypted.bytes;
    log = log + 'Encryption done in ${Duration(milliseconds: stopwatch.elapsedMilliseconds).toString()} ms.\n';
    print('Encryption done in ${Duration(milliseconds: stopwatch.elapsedMilliseconds).toString()} .');
    stopwatch.reset();

    final outputFilePath = await buildOutputDecryptedFileName("walden");
    var outputFile = await _writeFileByte(outputFilePath, encryptedBytes);
    log = log + 'Temp file writtern ${Duration(milliseconds: stopwatch.elapsedMilliseconds).toString()} .\n';

    debugPrint('temp file written');
    stopwatch.reset();

    final decryptedBytes = encrypter.decryptBytes(encrypted, iv: iv);
    log = log + 'Decryption done in ${Duration(milliseconds: stopwatch.elapsedMilliseconds).toString()} .\n';

    print('Decryption done in ${Duration(milliseconds: stopwatch.elapsedMilliseconds).toString()} .');
    stopwatch.reset();

    return log;
  }

  Future<String> buildOutputDecryptedFileName(String dataSource) async {
    final directory = await getTemporaryDirectory();
    final outputFileDirectory = directory.path;
    final outputFileName = basename(dataSource);
    final outputFilePath = '$outputFileDirectory/$outputFileName';
    return outputFilePath;
  }


  Future<Uint8List> _readFileByte(String filePath) async {
    Uri assetUri = Uri.parse(filePath);
    File assetFile = new File.fromUri(assetUri);
    Uint8List bytes;
    await assetFile.readAsBytes().then((value) {
      bytes = Uint8List.fromList(value);
    }).catchError((onError) {
      print('Exception while reading file from path:' +
          onError.toString());
    });
    return bytes;
  }

  Future<File> _writeFileByte(String filePath, List<int> bytes) async {
    Uri assetUri = Uri.parse(filePath);
    File assetFile = new File.fromUri(assetUri);
    var outputFile = await assetFile.writeAsBytes(bytes)
        .catchError((onError) {
      print('Exception while writing file to path:' +
          onError.toString());
    });
    return outputFile;
  }

}


