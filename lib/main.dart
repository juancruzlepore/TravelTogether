import 'dart:math';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travel_together/booking_scraper.dart';
import 'package:url_launcher/url_launcher.dart';

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
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final List<String> _hotels = [];
  final hotelInputController = TextEditingController();
  late Future<String> _title;

  @override
  void initState() {
    super.initState();
    _title = BookingScraper.getTitle(
        'https://www.booking.com/hotel/nl/zoku-amsterdam.html');
  }

  void _addHotel() {
    var link = hotelInputController.text;
    setState(() {
      _hotels.add(link);
    });
    hotelInputController.clear();
  }

  FutureBuilder _futureText(Future<String> title) {
    return FutureBuilder<String>(
      future: title,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text(snapshot.data!);
        } else if (snapshot.hasError) {
          dev.log("snapshot has error");
          dev.log(snapshot.error!.toString());
          return Text(snapshot.error!.toString());
        }
        return const CircularProgressIndicator();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const maxLinkLength = 40;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextField(
                      onSubmitted: (_) {
                        _addHotel();
                      },
                      decoration:
                          const InputDecoration(hintText: "link to hotel"),
                      controller: hotelInputController,
                    ),
                    ListView(
                      shrinkWrap: true,
                      children: [
                        for (var hotelLink in _hotels)
                          ListTile(
                              title: _futureText(
                                  BookingScraper.getTitle(hotelLink)),
                              subtitle: TextButton(
                                onPressed: () async {
                                  await launch(hotelLink.toString());
                                },
                                child: Text(
                                    hotelLink.toString().length > maxLinkLength
                                        ? hotelLink
                                                .toString()
                                                .substring(0, maxLinkLength) +
                                            "..."
                                        : hotelLink.toString()),
                              ),
                              trailing: Column(
                                children: [
                                  _futureText(BookingScraper.getOccupantsSearch(
                                      hotelLink)),
                                  _futureText(BookingScraper.getPrice(
                                      hotelLink)),
                                ],
                              ))
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addHotel,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
