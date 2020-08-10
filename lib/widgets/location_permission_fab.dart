import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/model/groups_viewmodel.dart';
import 'package:flutter_tracker/state.dart';

class LocationPermissionFab extends StatefulWidget {
  final double bottomPosition;
  final Function onTap;

  LocationPermissionFab({
    this.bottomPosition = 10.0,
    this.onTap,
  });

  @override
  _LocationPermissionFabState createState() => _LocationPermissionFabState();
}

class _LocationPermissionFabState extends State<LocationPermissionFab> {
  PermissionStatus _permissionStatus = PermissionStatus.granted;

  @override
  void initState() {
    super.initState();
    _checkLocationPermissionStatus();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return StoreConnector<AppState, GroupsViewModel>(
        converter: (store) => GroupsViewModel.fromStore(store),
        builder: (_, viewModel) {
          if (viewModel.locationPermissionStatus == PermissionStatus.granted) {
            return Container();
          }

          return _buildMapTypeFab();
        });
  }

  void _checkLocationPermissionStatus() {
    final Future<PermissionStatus> statusFuture =
        LocationPermissions().checkPermissionStatus();

    statusFuture.then((PermissionStatus status) {
      setState(() {
        _permissionStatus = status;
      });
    });
  }

  Widget _buildMapTypeFab() {
    return (_permissionStatus == PermissionStatus.granted)
        ? Container()
        : Positioned(
            bottom: widget.bottomPosition,
            left: 0.0,
            right: 0.0,
            child: RawMaterialButton(
              fillColor: AppTheme.error(),
              shape: CircleBorder(),
              padding: const EdgeInsets.all(6.0),
              elevation: 1.0,
              child: Icon(
                Icons.warning,
                color: Colors.white,
                size: 20.0,
              ),
              onPressed: (widget.onTap == null) ? null : widget.onTap,
            ),
          );
  }
}
