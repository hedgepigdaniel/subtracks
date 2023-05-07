// ignore_for_file: use_key_in_widget_constructors

import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'pages/artist_page.dart';
import 'pages/bottom_nav_page.dart';
import 'pages/browse_page.dart';
import 'pages/library_albums_page.dart';
import 'pages/library_artists_page.dart';
import 'pages/library_page.dart';
import 'pages/library_playlists_page.dart';
import 'pages/library_songs_page.dart';
import 'pages/now_playing_page.dart';
import 'pages/search_page.dart';
import 'pages/settings_page.dart';
import 'pages/songs_page.dart';
import 'pages/source_page.dart';

part 'app_router.gr.dart';

const kCustomTransitionBuilder = TransitionsBuilders.slideRightWithFade;
const kCustomTransitionDuration = 160;

class EmptyRouterPage extends AutoRouter {
  const EmptyRouterPage({Key? key})
      : super(
          key: key,
          inheritNavigatorObservers: false,
        );
}

@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: <AutoRoute>[
    AutoRoute(path: '/albums', page: LibraryAlbumsPage),
    AutoRoute(path: '/artists', page: LibraryArtistsPage),
    AutoRoute(path: '/playlists', page: LibraryPlaylistsPage),
    AutoRoute(path: '/songs', page: LibrarySongsPage),
    AutoRoute(
        path: '/browse',
        page: BrowsePage),
    AutoRoute(
        path: '/search',
        page: SearchPage),
    AutoRoute(
        path: '/settings',
        page: SettingsPage),
    CustomRoute(
        path: '/source/:id',
        page: SourcePage,
        transitionsBuilder: kCustomTransitionBuilder,
        durationInMilliseconds: kCustomTransitionDuration,
        reverseDurationInMilliseconds: kCustomTransitionDuration,
      ),
    CustomRoute(
      path: '/now-playing',
      page: NowPlayingPage,
      transitionsBuilder: TransitionsBuilders.slideBottom,
      durationInMilliseconds: 200,
      reverseDurationInMilliseconds: 160,
    ),
    CustomRoute(
      path: 'album/:id',
      page: AlbumSongsPage,
      transitionsBuilder: kCustomTransitionBuilder,
      durationInMilliseconds: kCustomTransitionDuration,
      reverseDurationInMilliseconds: kCustomTransitionDuration,
    ),
    CustomRoute(
      path: 'artist/:id',
      page: ArtistPage,
      transitionsBuilder: kCustomTransitionBuilder,
      durationInMilliseconds: kCustomTransitionDuration,
      reverseDurationInMilliseconds: kCustomTransitionDuration,
    ),
    CustomRoute(
      path: 'playlist/:id',
      page: PlaylistSongsPage,
      transitionsBuilder: kCustomTransitionBuilder,
      durationInMilliseconds: kCustomTransitionDuration,
      reverseDurationInMilliseconds: kCustomTransitionDuration,
    ),
    CustomRoute(
      path: 'genre/:genre',
      page: GenreSongsPage,
      transitionsBuilder: kCustomTransitionBuilder,
      durationInMilliseconds: kCustomTransitionDuration,
      reverseDurationInMilliseconds: kCustomTransitionDuration,
    ),
  ],
)
class AppRouter extends _$AppRouter {}

class TabObserver extends AutoRouterObserver {
  final StreamController<String> _controller = StreamController.broadcast();
  Stream<String> get path => _controller.stream;

  @override
  void didInitTabRoute(TabPageRoute route, TabPageRoute? previousRoute) {
    _controller.add(route.path);
  }

  @override
  void didChangeTabRoute(TabPageRoute route, TabPageRoute previousRoute) {
    _controller.add(route.path);
  }
}
