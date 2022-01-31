import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// TODO remove the alias
import 'package:provider/provider.dart' as asdfasdf;
import 'package:widgetbook/src/configure_non_web.dart'
    if (dart.library.html) 'package:widgetbook/src/configure_web.dart';
import 'package:widgetbook/src/devices/devices.dart';
import 'package:widgetbook/src/localization/localization.dart';
import 'package:widgetbook/src/models/app_info.dart';
import 'package:widgetbook/src/models/organizers/organizer_helper/story_helper.dart';
import 'package:widgetbook/src/models/organizers/organizers.dart';
import 'package:widgetbook/src/providers/canvas_provider.dart';
import 'package:widgetbook/src/providers/organizer_provider.dart';
import 'package:widgetbook/src/providers/organizer_state.dart';
import 'package:widgetbook/src/providers/theme_provider.dart';
import 'package:widgetbook/src/rendering/rendering.dart';
import 'package:widgetbook/src/repositories/selected_story_repository.dart';
import 'package:widgetbook/src/repositories/story_repository.dart';
import 'package:widgetbook/src/routing/route_information_parser.dart';
import 'package:widgetbook/src/routing/story_router_delegate.dart';
import 'package:widgetbook/src/services/filter_service.dart';
import 'package:widgetbook/src/theming/theming_provider.dart';
import 'package:widgetbook/src/theming/theming_state.dart';
import 'package:widgetbook/src/theming/widgetbook_theme.dart';
import 'package:widgetbook/src/utils/styles.dart';
import 'package:widgetbook/src/workbench/workbench_provider.dart';
import 'package:widgetbook/src/workbench/workbench_state.dart';
import 'package:widgetbook/src/zoom/zoom_provider.dart';
import 'package:widgetbook_models/widgetbook_models.dart';

class Widgetbook<CustomTheme> extends StatelessWidget {
  const Widgetbook({
    Key? key,
    required this.categories,
    List<Device>? devices,
    required this.appInfo,
    this.localizationsDelegates,
    required this.themes,
    this.defaultTheme = ThemeMode.system,
    this.deviceFrameBuilder,
    this.localizationBuilder,
    this.themeBuilder,
    this.scaffoldBuilder,
    this.useCaseBuilder,
    List<Locale>? supportedLocales,
    List<DeviceFrame>? deviceFrames,
    // TODO check if this works
  })  : assert(
          themes.length > 0,
          'please provide a theme by using one of these properties: '
          'lightTheme, darkTheme or themes',
        ),
        supportedLocales = supportedLocales ??
            const [
              Locale('us'),
            ],
        deviceFrames = deviceFrames ??
            const <DeviceFrame>[
              // TODO how to use the factory constructors here?
              DeviceFrame(
                name: 'Widgetbook',
                allowsDevices: true,
              ),
              DeviceFrame(
                name: 'None',
                allowsDevices: false,
              )
            ],
        devices = devices ??
            const [
              Apple.iPhone11,
              Apple.iPhone12,
              Samsung.s21ultra,
            ],
        super(key: key);

  /// Categories which host Folders and WidgetElements.
  /// This can be used to organize the structure of the Widgetbook on a large
  /// scale.
  final List<WidgetbookCategory> categories;

  /// The devices on which Stories are previewed.
  final List<Device> devices;

  /// Information about the app that is catalogued in the Widgetbook.
  final AppInfo appInfo;

  /// The default theme mode Widgetbook starts with
  final ThemeMode defaultTheme;

  final List<Locale> supportedLocales;

  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;

  final List<WidgetbookTheme<CustomTheme>> themes;

  final List<DeviceFrame> deviceFrames;

  final DeviceFrameBuilderFunction? deviceFrameBuilder;

  final LocalizationBuilderFunction? localizationBuilder;

  final ThemeBuilderFunction<CustomTheme>? themeBuilder;

  final ScaffoldBuilderFunction? scaffoldBuilder;

  final UseCaseBuilderFunction? useCaseBuilder;

  static Widgetbook<CupertinoThemeData> cupertino({
    required List<WidgetbookCategory> categories,
    required List<WidgetbookTheme<CupertinoThemeData>> themes,
    required AppInfo appInfo,
    List<Device>? devices,
    List<DeviceFrame>? deviceFrames,
    List<Locale>? supportedLocales,
    Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates,
    DeviceFrameBuilderFunction? deviceFrameBuilder,
    LocalizationBuilderFunction? localizationBuilder,
    ThemeBuilderFunction<CupertinoThemeData>? themeBuilder,
    ScaffoldBuilderFunction? scaffoldBuilder,
    UseCaseBuilderFunction? useCaseBuilder,
    Key? key,
  }) {
    return Widgetbook<CupertinoThemeData>(
      key: key,
      categories: categories,
      themes: themes,
      appInfo: appInfo,
      devices: devices,
      supportedLocales: supportedLocales,
      localizationsDelegates: localizationsDelegates,
      deviceFrameBuilder: deviceFrameBuilder,
      localizationBuilder: localizationBuilder,
      themeBuilder: themeBuilder,
      scaffoldBuilder: scaffoldBuilder,
      useCaseBuilder: useCaseBuilder,
      deviceFrames: deviceFrames,
    );
  }

  static Widgetbook<ThemeData> material({
    required List<WidgetbookCategory> categories,
    required List<WidgetbookTheme<ThemeData>> themes,
    required AppInfo appInfo,
    List<Device>? devices,
    List<DeviceFrame>? deviceFrames,
    List<Locale>? supportedLocales,
    Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates,
    DeviceFrameBuilderFunction? deviceFrameBuilder,
    LocalizationBuilderFunction? localizationBuilder,
    ThemeBuilderFunction<ThemeData>? themeBuilder,
    ScaffoldBuilderFunction? scaffoldBuilder,
    UseCaseBuilderFunction? useCaseBuilder,
    Key? key,
  }) {
    return Widgetbook<ThemeData>(
      key: key,
      categories: categories,
      themes: themes,
      appInfo: appInfo,
      devices: devices,
      supportedLocales: supportedLocales,
      localizationsDelegates: localizationsDelegates,
      deviceFrameBuilder: deviceFrameBuilder,
      localizationBuilder: localizationBuilder,
      themeBuilder: themeBuilder,
      scaffoldBuilder: scaffoldBuilder,
      useCaseBuilder: useCaseBuilder,
      deviceFrames: deviceFrames,
    );
  }

  @override
  Widget build(BuildContext context) {
    return asdfasdf.MultiProvider(
      providers: [
        // TODO this can be moved down the tree
        asdfasdf.ChangeNotifierProvider(
          create: (_) => ZoomProvider(),
        ),
        // TODO can this be removed and put into workbench provider?
        asdfasdf.ChangeNotifierProvider(
          create: (_) => ThemingProvider<CustomTheme>(
            state: ThemingState<CustomTheme>(
              themes: themes,
            ),
          ),
        ),
        asdfasdf.ChangeNotifierProvider(
          create: (_) => WorkbenchProvider(
            locales: supportedLocales,
            themes: themes,
            devices: devices,
            deviceFrames: deviceFrames,
          ),
        )
      ],
      child: UncontrolledProviderScope(
        container: ProviderContainer(),
        child: WidgetbookWrapper<CustomTheme>(
          categories: categories,
          appInfo: appInfo,
          devices: devices,
          defaultTheme: defaultTheme,
          supportedLocales: supportedLocales,
          localizationsDelegates: localizationsDelegates,
          themes: themes,
          deviceFrames: deviceFrames,
          deviceFrameBuilder: deviceFrameBuilder,
          localizationBuilder: localizationBuilder,
          themeBuilder: themeBuilder,
          scaffoldBuilder: scaffoldBuilder,
          useCaseBuilder: useCaseBuilder,
        ),
      ),
    );
  }
}

class WidgetbookWrapper<CustomTheme> extends ConsumerStatefulWidget {
  const WidgetbookWrapper({
    Key? key,
    required this.categories,
    List<Device>? devices,
    required this.appInfo,
    required this.themes,
    Iterable<Locale>? supportedLocales,
    this.localizationsDelegates,
    this.defaultTheme = ThemeMode.system,
    required this.deviceFrames,
    this.deviceFrameBuilder,
    this.localizationBuilder,
    this.themeBuilder,
    this.scaffoldBuilder,
    this.useCaseBuilder,
  })  : supportedLocales =
            supportedLocales ?? const <Locale>[Locale('en', 'US')],
        // TODO check that devices cannot be empty if not null
        devices = devices ??
            const [
              Apple.iPhone11,
              Apple.iPhone12,
              Apple.iPhone12Mini,
              Apple.iPhone12Pro,
              Samsung.s10,
              Samsung.s21ultra,
            ],
        super(key: key);

  /// Categories which host Folders and WidgetElements.
  /// This can be used to organize the structure of the Widgetbook on a large
  /// scale.
  final List<WidgetbookCategory> categories;

  /// The devices on which Stories are previewed.
  final List<Device> devices;

  /// Information about the app that is catalogued in the Widgetbook.
  final AppInfo appInfo;

  /// The default theme mode Widgetbook starts with
  final ThemeMode defaultTheme;

  final Iterable<Locale> supportedLocales;

  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;

  final Iterable<WidgetbookTheme<CustomTheme>> themes;

  final List<DeviceFrame> deviceFrames;

  final DeviceFrameBuilderFunction? deviceFrameBuilder;

  final LocalizationBuilderFunction? localizationBuilder;

  final ThemeBuilderFunction<CustomTheme>? themeBuilder;

  final ScaffoldBuilderFunction? scaffoldBuilder;

  final UseCaseBuilderFunction? useCaseBuilder;

  @override
  _WidgetbookState<CustomTheme> createState() =>
      _WidgetbookState<CustomTheme>();
}

class _WidgetbookState<CustomTheme>
    extends ConsumerState<WidgetbookWrapper<CustomTheme>> {
  // TODO ugly hack
  late BuildContext contextWithProviders;

  SelectedStoryRepository selectedStoryRepository = SelectedStoryRepository();
  StoryRepository storyRepository = StoryRepository();

  @override
  void initState() {
    configureApp();
    _initializeProviders();
    _onHotReload();

    super.initState();
  }

  void _initializeProviders() {
    initializeRenderingProvider<CustomTheme>();
  }

  void _onHotReload() {
    ref.read(localizationProvider.notifier).hotReloadUpdate(
          localizationsDelegates: widget.localizationsDelegates?.toList(),
          supportedLocales: widget.supportedLocales.toList(),
        );

    ref.read(devicesProvider.notifier).hotReloadUpdate(
          devices: widget.devices,
        );

    ref.read(getRenderingProvider<CustomTheme>().notifier)
      ..deviceFramesChanged(widget.deviceFrames)
      ..deviceFrameBuilderChanged(widget.deviceFrameBuilder)
      ..localizationBuilderChanged(widget.localizationBuilder)
      ..themeBuilderChanged(widget.themeBuilder)
      ..scaffoldBuilderChanged(widget.scaffoldBuilder)
      ..useCaseBuilderChanged(widget.useCaseBuilder);
  }

  @override
  void didUpdateWidget(covariant WidgetbookWrapper<CustomTheme> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _onHotReload();

    // TODO remove this and put into the Builders
    OrganizerProvider.of(contextWithProviders)!.update(widget.categories);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return OrganizerBuilder(
          initialState: OrganizerState.unfiltered(
            categories: widget.categories,
          ),
          storyRepository: storyRepository,
          selectedStoryRepository: selectedStoryRepository,
          filterService: const FilterService(),
          child: CanvasBuilder(
            selectedStoryRepository: selectedStoryRepository,
            storyRepository: storyRepository,
            child: ThemeBuilder(
              themeMode: widget.defaultTheme,
              child: Builder(
                builder: (context) {
                  contextWithProviders = context;
                  final canvasState = CanvasProvider.of(context)!.state;
                  final storiesState = OrganizerProvider.of(context)!.state;
                  final themeMode = ThemeProvider.of(context)!.state;

                  return MaterialApp.router(
                    routeInformationParser: StoryRouteInformationParser(
                      onRoute: (path) {
                        final stories = StoryHelper.getAllStoriesFromCategories(
                          storiesState.allCategories,
                        );
                        final selectedStory =
                            selectStoryFromPath(path, stories);
                        CanvasProvider.of(context)!.selectStory(selectedStory);
                      },
                    ),
                    routerDelegate: StoryRouterDelegate<CustomTheme>(
                      canvasState: canvasState,
                      appInfo: widget.appInfo,
                    ),
                    title: widget.appInfo.name,
                    debugShowCheckedModeBanner: false,
                    themeMode: themeMode,
                    darkTheme: Styles.darkTheme,
                    theme: Styles.lightTheme,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  WidgetbookUseCase? selectStoryFromPath(
    String? path,
    List<WidgetbookUseCase> stories,
  ) {
    final storyPath = path?.replaceFirst('/stories/', '') ?? '';
    WidgetbookUseCase? story;
    for (final element in stories) {
      if (element.path == storyPath) {
        story = element;
      }
    }
    return story;
  }
}
