import 'package:unscripted/unscripted.dart';
import 'package:http/http.dart';

main(arguments) => new Script(RootCommand).execute(arguments);

var client = new Client();
var baseUrl = 'localhost:9999';

class RootCommand extends Object with SearchArtist {
  @Command(
      help: 'Google Play Music Proxy Helper',
      plugins: const [const Completion()])
  RootCommand();
}

class SearchArtist {
  @SubCommand(help: 'Search artist name.')
  artist(String query) async {
    var uri = new Uri.http(baseUrl, 'get_new_station_by_search',
        {'type': 'artist', 'artist': query, 'num_tracks': 100.toString()});

    var response = await client.get(uri);
    print(response.body);
  }
}
