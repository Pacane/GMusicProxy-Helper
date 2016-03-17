import 'package:unscripted/unscripted.dart';
import 'package:http/http.dart';
import 'dart:async';
import 'dart:io';
import 'package:quiver/strings.dart';

/// The default amount of songs to fetch, when configurable.
final int numberOfSongsToFetch = 100;

/// The main function dispatches all arguments to the Root command.
Future<dynamic> main(List<String> arguments) =>
    new Script(RootCommand).execute(arguments);

/// Specifies the base URL of GMusic Proxy (ie: localhost:9999)
String baseUrl = 'localhost:9999';

Client _client = new Client();

/// The root command for the CLI executable
class RootCommand extends Object
    with GetNewStation, GetAllStations, GetDiscography {
  /// Available commands:
  /// artist
  /// stations
  @Command(help: 'GMusic Proxy Helper', plugins: const [const Completion()])
  RootCommand();
}

/// The command to get a new station from an artist name.
class GetNewStation {
  /// example:
  /// gph station --artist metallica
  /// gph station --song 'enter sandman'
  @SubCommand(help: 'Fetch a new station.', allowTrailingOptions: true)
  Future<Null> station(
      @Rest(required: true, help: 'The text that will be used for the query', valueHelp: 'Song title or Artist name')
          List<String> query,
      {@Flag(name: 'artist', help: 'By artist', abbr: 'a', defaultsTo: false)
          bool artist,
      @Flag(name: 'song', help: 'By song name', abbr: 's', defaultsTo: false)
          bool song}) async {
    var queryParameters = <String, String>{};

    var queryString = query.join(' ');

    if (artist) {
      print('Searching by artist: $queryString');
      queryParameters = <String, String>{
        'type': 'artist',
        'artist': queryString,
        'num_tracks': numberOfSongsToFetch.toString()
      };
    } else if (song) {
      print('Searching by song: $query');
      queryParameters = <String, String>{
        'type': 'song',
        'title': queryString,
        'num_tracks': numberOfSongsToFetch.toString()
      };
    } else {
      print('Cannot search for nothing.');
      return;
    }

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

    await _writeMultiplePlaylists(response.body, outputDirectory);
  }
}

/// Get artist discography command.
class GetDiscography {
  /// example:
  /// gph discography Metallica
  @SubCommand(help: 'Get the discography of an artist.')
  Future<Null> discography(String artistName, String outputDirectory) async {
    var artistId = await _getArtistId(artistName);

    if (isEmpty(artistId)) {
      print("No ArtistId found");
      return null;
    }

    var uri = new Uri.http(
        baseUrl, 'get_discography_artist', <String, String>{'id': artistId});

    var response = await _client.get(uri);

    await _writeMultiplePlaylists(response.body, outputDirectory);

    return null;
  }
}

Future<String> _getArtistId(String artistName) async {
  var uri = new Uri.http(baseUrl, 'search_id');

  uri = uri.replace(queryParameters: {'type': 'artist', 'artist': artistName});

  var response = await _client.get(uri);
  return response.body;
}

Future _writeMultiplePlaylists(String body, String outputDirectory,
    {String artistName: ''}) async {
  var lines = body.split('\n');

  var playlistName = '';

  for (var line in lines) {
    if (line.startsWith('#EXTM3U') || isEmpty(line)) {
      continue;
    }

    if (line.startsWith('#EXTINF')) {
      playlistName = line
          .replaceAll('#EXTINF:-1,', '')
          .replaceAll(' ', '_')
          .replaceAll('/', '_');
      continue;
    } else if (isEmpty(line)) {
      continue;
    }

    var downloadedPlaylist = await _client.get(line);

    var sanitizedArtistName =
        artistName.trim().replaceAll('/', '_').replaceAll(' ', '_');

    var playlistFilename =
        '$outputDirectory/${sanitizedArtistName}_$playlistName.m3u';

    print('Writing $playlistName');

    await new File(playlistFilename).create();
    var contentToWrite = downloadedPlaylist.body;
    await new File(playlistFilename).writeAsString(contentToWrite);
  }
}
