import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:mutex/mutex.dart';

class BookingScraper {
  static final Map<String, http.Response> cachedHTML = {};
  static final Map<String, Mutex> mutexes = {};
  static final m = Mutex();

  static Future<String> getTitle(String link) async {
    var html = parse((await BookingScraper.fetchBookingHTML(link)).body);
    return (html.getElementById("hp_hotel_name")?.text)!;
  }

  static Future<String> getPrice(String link) async {
    var html = parse((await BookingScraper.fetchBookingHTML(link)).body);
    return (html.getElementById("hp_hotel_name")?.text)!;
  }

  static Future<String> getOccupantsSearch(String link) async {
    var html = parse((await BookingScraper.fetchBookingHTML(link)).body);
    var regex = RegExp("([0-9]+) adult");
    var guestsHtml = (html
        .getElementById("xp__guests__toggle")
        ?.getElementsByClassName("xp__guests__count")
        .first
        .innerHtml)!;
    log(guestsHtml.replaceAll('\n', ' '));
    log(guestsHtml.length.toString());
    var adultsCount = (regex.firstMatch(guestsHtml)?.group(1))!;
    return adultsCount;
  }

  static Future<http.Response> fetchBookingHTML(String link) async {
    await m.acquire();
    if (!mutexes.containsKey(link)) {
      mutexes[link] = Mutex();
    }
    await mutexes[link]!.acquire();
    m.release();
    try {
      if (cachedHTML.containsKey(link)) {
        return cachedHTML[link]!;
      }
      var response = await http.Client().get(Uri.parse(link));
      // Uri.parse('https://www.booking.com/hotel/nl/zoku-amsterdam.html'),
      log("${response.statusCode}");
      cachedHTML[link] = response;
      return response;
    } finally {
      mutexes[link]!.release();
    }
  }
}
