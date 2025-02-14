import 'dart:math' as math;

import 'package:bloodinsight/core/styles/sizes.dart';
import 'package:bloodinsight/shared/widgets/bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension ScaffoldStateExtension on BuildContext {
  void hideBottomNav() {
    final scaffold = Scaffold.maybeOf(this);
    if (scaffold != null) {
      final ancestorScaffoldState =
          findAncestorStateOfType<_ScaffoldWithNavBarState>();
      ancestorScaffoldState?.hideNavBar();
    }
  }

  void showBottomNav() {
    final scaffold = Scaffold.maybeOf(this);
    if (scaffold != null) {
      final ancestorScaffoldState =
          findAncestorStateOfType<_ScaffoldWithNavBarState>();
      ancestorScaffoldState?.showNavBar();
    }
  }
}

class ScaffoldWithNavBar extends StatefulWidget {
  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;
  static const FloatingActionButtonLocation centerDocked =
      _CenterDockedFloatingActionButtonLocation();

  @override
  State<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends State<ScaffoldWithNavBar> {
  bool _isNavBarVisible = true;

  void hideNavBar() {
    if (_isNavBarVisible) {
      setState(() {
        _isNavBarVisible = false;
      });
    }
  }

  void showNavBar() {
    if (!_isNavBarVisible) {
      setState(() {
        _isNavBarVisible = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: ScaffoldWithNavBar.centerDocked,
      floatingActionButton: Visibility(
        visible: _isNavBarVisible,
        child: Hero(
          tag: 'addButton',
          child: GestureDetector(
            onTap: () => _showAddBottomSheet(context),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Visibility(
        visible: _isNavBarVisible,
        child: FloatingBottomNavBar(navigationShell: widget.navigationShell),
      ),
      body: widget.navigationShell,
    );
  }

  void _showAddBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: Sizes.kPadd20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add New Bloodwork',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Sizes.kGap20,
              ListTile(
                leading: const Icon(Icons.add_chart),
                title: const Text('Add Results'),
                subtitle: const Text('Enter your bloodwork results manually'),
                onTap: () {
                  context
                    ..pop()
                    ..push('/bloodwork/add');
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_month),
                title: const Text('Schedule Test'),
                subtitle: const Text('Set a reminder for your next bloodwork'),
                onTap: () {
                  context
                    ..pop()
                    ..push('/reminder/add');
                },
              ),
              Sizes.kGap20,
            ],
          ),
        ),
      ),
    );
  }
}

class _CenterDockedFloatingActionButtonLocation
    extends _DockedFloatingActionButtonLocation {
  const _CenterDockedFloatingActionButtonLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final fabX = (scaffoldGeometry.scaffoldSize.width -
            scaffoldGeometry.floatingActionButtonSize.width) /
        2.0;
    return Offset(fabX, getDockedY(scaffoldGeometry));
  }
}

abstract class _DockedFloatingActionButtonLocation
    extends FloatingActionButtonLocation {
  const _DockedFloatingActionButtonLocation();
  @protected
  double getDockedY(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final contentBottom = scaffoldGeometry.contentBottom + 25;
    final appBarHeight = scaffoldGeometry.bottomSheetSize.height;
    final fabHeight = scaffoldGeometry.floatingActionButtonSize.height;
    final snackBarHeight = scaffoldGeometry.snackBarSize.height;

    var fabY = contentBottom - fabHeight / 2.0;
    if (snackBarHeight > 0.0) {
      fabY = math.min(
        fabY,
        contentBottom -
            snackBarHeight -
            fabHeight -
            kFloatingActionButtonMargin,
      );
    }
    if (appBarHeight > 0.0) {
      fabY = math.min(fabY, contentBottom - appBarHeight - fabHeight / 2.0);
    }

    final maxFabY = scaffoldGeometry.scaffoldSize.height - fabHeight;
    return math.min(maxFabY, fabY);
  }
}
