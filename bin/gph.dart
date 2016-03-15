import 'package:unscripted/unscripted.dart';
import 'package:http/http.dart';
import 'dart:async';
import 'dart:io';

/// The main function dispatches all arguments to the Root command.
Future<dynamic> main(List<String> arguments) =>
    new Script(RootCommand).execute(arguments);

/// Specifies the base URL of GMusic Proxy (ie: localhost:9999)
String baseUrl = 'localhost:9999';

Client _client = new Client();

/// The root command for the CLI executable
class RootCommand extends Object with GetStationByArtist, GetAllStations {
  /// Available commands:
  /// artist
  /// stations
  @Command(help: 'GMusic Proxy Helper', plugins: const [const Completion()])
  RootCommand();
}

/// The command to get a station from an artist name.
class GetStationByArtist {
  /// example:
  /// gph artist metallica
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

/// Get all stations command.
class GetAllStations {
  /// example:
  /// gph stations
  @SubCommand(help: 'Get all registered stations.')
  Future<Null> stations(String outputDirectory) async {
    var uri = new Uri.http(baseUrl, 'get_all_stations');

    var response = await _client.get(uri);

    print(response.body);

    var lines = response.body.split('\n');

    var playlistName = '';

    for (var line in lines) {
      if (line == '#EXTm3U') {
        continue;
      }

      if (line.startsWith('#')) {
        playlistName = line
            .replaceAll('#EXTINF:-1,', '')
            .replaceAll(' ', '_')
            .replaceAll('/', '_');
        continue;
      }

      var downloadedPlaylist = await _client.get(line);

      var playlistFilename = '$outputDirectory/$playlistName.m3u';

      print('Writing $playlistName');

      await new File(playlistFilename).create();
      await new File(playlistFilename).writeAsString(downloadedPlaylist.body);
    }
  }
}
