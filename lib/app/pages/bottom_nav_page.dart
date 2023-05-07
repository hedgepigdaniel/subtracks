import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../database/database.dart';
import '../../services/settings_service.dart';
import '../../state/settings.dart';
import '../app_router.dart';
import '../now_playing_bar.dart';

part 'bottom_nav_page.g.dart';

@Riverpod(keepAlive: true)
TabObserver bottomTabObserver(BottomTabObserverRef ref) {
  return TabObserver();
}

@Riverpod(keepAlive: true)
Stream<String> bottomTabPath(BottomTabPathRef ref) async* {
  final observer = ref.watch(bottomTabObserverProvider);
  await for (var tab in observer.path) {
    yield tab;
  }
}

@Riverpod(keepAlive: true)
class LastBottomNavStateService extends _$LastBottomNavStateService {
  @override
  Future<void> build() async {
    final db = ref.watch(databaseProvider);
    final tab = ref.watch(bottomTabPathProvider).valueOrNull;
    if (tab == null || tab == 'settings' || tab == 'search') {
      return;
    }

    await db.saveLastBottomNavState(LastBottomNavStateData(id: 1, tab: tab));
  }
}

class BottomNavTabsPage extends StatelessWidget {
  final Widget child;

  const BottomNavTabsPage({ super.key, required this.child });

  @override
  Widget build(BuildContext context) {
    const navElevation = 3.0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        systemNavigationBarColor: ElevationOverlay.applySurfaceTint(
          Theme.of(context).colorScheme.surface,
          Theme.of(context).colorScheme.surfaceTint,
          navElevation,
        ),
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: Stack(
          alignment: AlignmentDirectional.bottomStart,
          children: [
            // FadeTransition(
            //   opacity: animation,
            //   child: child,
            // ),
            child,
            const OfflineIndicator(),
          ],
        ),
        bottomNavigationBar: const _BottomNavBar(
          navElevation: navElevation,
        ),
      ),
    );
  }
}

class OfflineIndicator extends HookConsumerWidget {
  const OfflineIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offline = ref.watch(offlineModeProvider);
    final testing = useState(false);

    if (!offline) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: 20,
        bottom: 20,
      ),
      child: FilledButton.tonal(
        style: const ButtonStyle(
          padding: MaterialStatePropertyAll<EdgeInsetsGeometry>(
            EdgeInsets.zero,
          ),
          fixedSize: MaterialStatePropertyAll<Size>(
            Size(42, 42),
          ),
          minimumSize: MaterialStatePropertyAll<Size>(
            Size(42, 42),
          ),
        ),
        onPressed: () async {
          testing.value = true;
          await ref.read(offlineModeProvider.notifier).setMode(false);
          testing.value = false;
        },
        child: testing.value
            ? const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : const Padding(
                padding: EdgeInsets.only(left: 2, bottom: 2),
                child: Icon(
                  Icons.cloud_off_rounded,
                  // color: Theme.of(context).colorScheme.secondary,
                  size: 20,
                ),
              ),
      ),
    );
  }
}

int _tabIndexFromRoute(String name) {
  switch (name) {
    case '/artists':
    case '/albums':
    case '/songs':
    case '/playlists':
      return 0;
    case '/browse':
      return 1;
    case '/search':
      return 2;
    case '/settings':
      return 3;
    default:
      return 3;
  }
}

String _routeFromTabIndex(int index) {
  switch (index) {
    case 0:
      return '/artists';
    case 1:
      return '/browse';
    case 2:
      return '/search';
    case 3:
      return '/settings';
    default:
      return '/';
  }
}

class _BottomNavBar extends HookConsumerWidget {
  final double navElevation;

  const _BottomNavBar({
    required this.navElevation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = AutoRouter.of(context);
    final selectedIndex = _tabIndexFromRoute(router.currentPath);

    return Hero(
      tag: 'bottom-bar',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const NowPlayingBar(),
          NavigationBar(
            elevation: navElevation,
            height: 50,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              final router = AutoRouter.of(context);
              router.pushNamed(_routeFromTabIndex(index));
            },
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.music_note),
                label: 'Library',
              ),
              NavigationDestination(
                icon: Builder(builder: (context) {
                  return SvgPicture.asset(
                    'assets/tag_FILL0_wght400_GRAD0_opsz24.svg',
                    colorFilter: ColorFilter.mode(
                      IconTheme.of(context).color!.withOpacity(
                            IconTheme.of(context).opacity ?? 1,
                          ),
                      BlendMode.srcIn,
                    ),
                    height: 28,
                  );
                }),
                label: 'Browse',
              ),
              const NavigationDestination(
                icon: Icon(Icons.search_rounded),
                label: 'Search',
              ),
              const NavigationDestination(
                icon: Icon(Icons.settings_rounded),
                label: 'Settings',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
