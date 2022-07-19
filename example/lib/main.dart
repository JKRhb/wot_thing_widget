import 'package:dart_wot/dart_wot.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wot_thing_widget/wot_thing_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class Blah {
  WoT wot;

  ThingDescription thingDescription;

  Blah(this.wot, this.thingDescription);
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  @override
  void initState() {
    super.initState();
  }

  Future<WoT> _createWotRuntime() async {
    final servient = Servient()..addClientFactory(HttpClientFactory());

    if (!kIsWeb) {
      final coapConfig = CoapConfig(blocksize: 64);
      final coapClientFactory = CoapClientFactory(coapConfig);

      servient.addClientFactory(coapClientFactory);
    }

    return servient.start();
  }

  Future<Blah> getThingDescription() async {
    final wot = await _createWotRuntime();
    const thingUrl = "coap://plugfest.thingweb.io:5683/testthing";
    await for (final thingDescription in wot.discover(ThingFilter(
        url: Uri.parse(thingUrl), method: DiscoveryMethod.direct))) {
      return Blah(wot, thingDescription);
    }

    throw Exception("Error retrieving Thing Description");
  }

  Widget createThingWidget() {
    return FutureBuilder<Blah>(
        future: getThingDescription(),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            final blah = snapshot.data;
            if (blah == null) {
              throw Exception("Error retrieving Thing Description");
            }
            return ThingWidget(blah.thingDescription, blah.wot);
          }
          List<Widget> children;

          if (snapshot.hasError) {
            children = <Widget>[
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Error: ${snapshot.error}'),
              )
            ];
          } else {
            children = const <Widget>[
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('Awaiting result...'),
              )
            ];
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: children,
            ),
          );
        }));
  }

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
        child: SingleChildScrollView(
          child: createThingWidget(),
        ),
      ),
    );
  }
}
