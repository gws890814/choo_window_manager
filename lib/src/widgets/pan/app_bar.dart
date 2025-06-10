part of 'pan.dart';

// ignore: must_be_immutable
class ChooAppBar extends AppBar {
  bool _isMovable = false;
  // ignore: library_private_types_in_public_api
  static _WindowPanState? of(BuildContext context) =>
      WindowPanWidget.of(context);

  factory ChooAppBar({required Widget child, double height = 28}) {
    late ChooAppBar instance;
    instance = ChooAppBar._(
      child: GestureDetector(
        onDoubleTap: () async {
          bool isMaximized = await ChooWindowManager.current.isMaximized();
          if (isMaximized) {
            await ChooWindowManager.current.unmaximize();
          } else {
            await ChooWindowManager.current.maximize();
          }
        },
        child: SizedBox(
          width: double.maxFinite,
          height: height,
          child: WindowPanWidget(
            spread: true,
            child: child,
            onEnter: (event) async {
              instance._isMovable = await ChooWindowManager.current.isMovable();
            },
            onExit: (event) async {
              await ChooWindowManager.current.movable(true);
            },
          ),
        ),
      ),
    );
    return instance;
  }
  //   : super(
  //       toolbarHeight: height,
  //       title: GestureDetector(
  //         onDoubleTap: () async {
  //           bool isMaximized = await ChooWindowManager.current.isMaximized();
  //           if (isMaximized) {
  //             await ChooWindowManager.current.unmaximize();
  //           } else {
  //             await ChooWindowManager.current.maximize();
  //           }
  //         },
  //         child: SizedBox(
  //           width: double.maxFinite,
  //           height: height,
  //           child: MouseRegion(
  //             onEnter: (event) async {
  //               _isMovable = ChooWindowManager.current.isMovable() as bool;
  //             },
  //             onExit: (event) {
  //               print("~~~exit");
  //             },
  //             child: WindowPanWidget(spread: true, child: child),
  //           ),
  //         ),
  //       ),
  //       titleSpacing: 0,
  //       automaticallyImplyLeading: false,
  //       elevation: 0,
  //       scrolledUnderElevation: 0,
  //     ) {
  //   ChooWindowManager.current.setWindowButtonRegionHeight(height);
  // }

  ChooAppBar._({required Widget child, double height = 28})
    : super(
        title: child,
        toolbarHeight: height,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        elevation: 0,
        scrolledUnderElevation: 0,
      ) {
    ChooWindowManager.current.setWindowButtonRegionHeight(height);
  }
}
