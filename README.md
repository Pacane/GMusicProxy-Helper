# Getting Started

### What is this project about?
It is a helper executable that issues commands for [GMusic Proxy](http://gmusicproxy.net/#command-line)

### Why?
If you use [MPD](http://www.musicpd.org/) as your music player, but also have access to Google Play Music, 
this is for you!

It allows you to download `m3u` playlists from Google Play Music and play them as a stream from any MPD 
client (such as [ncmpcpp](http://rybczak.net/ncmpcpp/)).

## Install
Install the executable using:

```bash
$ pub global activate gmusic_proxy_helper
```


## Usage
**IMPORTANT** **You need Google Play Music All Access to use this**

Make sure you have [GMusic Proxy](http://gmusicproxy.net/) configured and running.

```bash
$ gph --help
```

Will give you all the options.

### Fetch all your stations
```bash
$ gph stations > ~/.config/mpd/playlists
```

### Get a new station from artist name
```bash
$ gph station -a metallica > ~/.config/mpd/playlists/metallica.m3u
```

### Get a new station from song title
```bash
$ gph station -s enter sandman > ~/.config/mpd/playlists/enter_sandman.m3u
```

### Get an artist's discography (from Artist name)
```bash
$ gph discography "Liquid Tension Experiment" ~/.config/mpd/playlists
```

Note that it'll eventually be possible to configure the playlists directory.
