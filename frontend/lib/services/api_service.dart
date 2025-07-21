import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.8.219:8000';


  static Future<List<dynamic>> searchGoogle(String query) async {
    final url = Uri.parse('$baseUrl/search?query=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print("Search failed with status: ${response.statusCode}");
      print("Response body: ${response.body}");
      throw Exception('Search failed');
    }
  }

  static Future<Map<String, dynamic>> scrapeLink(String link) async {
    final url = Uri.parse('$baseUrl/scrape');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'link': link}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Scrape failed');
    }
  }
}
