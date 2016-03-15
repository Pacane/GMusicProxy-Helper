import 'package:unscripted/unscripted.dart';
import 'package:http/http.dart';
import 'dart:async';

Future<dynamic> main(List<String> arguments) =>
    new Script(RootCommand).execute(arguments);

/// Specifies the base URL of GMusic Proxy (ie: localhost:9999)
String baseUrl = 'localhost:9999';

Client _client = new Client();

/// The root command for the CLI executable
class RootCommand extends Object with GetStationByArtist, GetAllStations {
  @Command(
      help: 'Google Play Music Proxy Helper',
      plugins: const [const Completion()])
  RootCommand();
}

class GetStationByArtist {
  @SubCommand(help: 'Search artist name.')
  Future<Null> artist(String query) async {
    var queryParameters = <String, String>{
      'type': 'artist',
      'artist': query,
      'num_tracks': 100.toString()
    };

    var uri =
        new Uri.http(baseUrl, 'get_new_station_by_search', queryParameters);

    var response = await _client.get(uri);
    print(response.body);
  }
}

class GetAllStations {
  @SubCommand(help: 'Get all registered stations.')
  Future<Null> stations() async {
    var uri = new Uri.http(baseUrl, 'get_all_stations');

    var response = await _client.get(uri);
    print(response.body);
  }
}
