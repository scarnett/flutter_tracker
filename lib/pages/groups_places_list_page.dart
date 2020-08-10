import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_tracker/actions.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/model/place.dart';
import 'package:flutter_tracker/model/user.dart';
import 'package:flutter_tracker/routes.dart';
import 'package:flutter_tracker/utils/place_utils.dart';
import 'package:flutter_tracker/widgets/backdrop.dart';
import 'package:flutter_tracker/widgets/empty_state_message.dart';
import 'package:flutter_tracker/widgets/fab_list.dart';
import 'package:flutter_tracker/widgets/list_divider.dart';
import 'package:flutter_tracker/widgets/place_icon.dart';
import 'package:flutter_tracker/widgets/section_header.dart';
import 'package:flutter_tracker/widgets/text_field.dart';
import 'package:flutter_tracker/model/groups_viewmodel.dart';
import 'package:flutter_tracker/state.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

class GroupsPlacesListPage extends StatefulWidget {
  GroupsPlacesListPage({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GroupsPlacesListPageState();
}

class _GroupsPlacesListPageState extends State<GroupsPlacesListPage>
    with TickerProviderStateMixin {
  final TextEditingController _criteriaController = TextEditingController();
  AnimationController _backdropAnimationController;
  Timer _searchDebounce;
  String _criteria;
  List<dynamic> _placeTiles = [];
  List<dynamic> _places = [];

  @override
  void initState() {
    super.initState();

    if (!mounted) {
      return;
    }

    setState(() {
      _backdropAnimationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 350),
      );
    });

    _criteriaController.addListener(() {
      if (_hasCriteria() &&
          ((_criteriaController.text == null) ||
              (_criteriaController.text == ''))) {
        setState(() {
          _criteria = null;
        });
      }

      if (_criteria != _criteriaController.text) {
        if (_searchDebounce?.isActive ?? false) {
          _searchDebounce.cancel();
        }

        _searchDebounce = Timer(const Duration(milliseconds: 500), () {
          String criteria = _criteriaController.text;
          if ((criteria != null) && (criteria != '')) {
            final store = StoreProvider.of<AppState>(context);

            if (criteria != _criteria) {
              store.dispatch(ClearPlacesAction());
            }

            store.dispatch(QueryPlacesAction(
              _criteriaController.text,
              store.state.user.mapData.currentPosition,
            ));

            setState(() {
              _criteria = _criteriaController.text;
              _places = [];
              _placeTiles = [];
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _criteriaController.dispose();
    _backdropAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return StoreConnector<AppState, GroupsViewModel>(
      converter: (store) => GroupsViewModel.fromStore(store),
      onInit: (store) {
        _backdropAnimationController.forward();
        store.dispatch(ClearActivePlaceAction());
        store.dispatch(RequestNearByPlacesAction(
            store.state.user, _backdropAnimationController));
      },
      builder: (_, viewModel) => WillPopScope(
        onWillPop: () {
          final store = StoreProvider.of<AppState>(context);
          store.dispatch(ClearActivePlaceAction());
          store.dispatch(NavigatePopAction());
          return Future.value(true);
        },
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: AppBar(
            title: const Text(
              'Add a New Place',
              style: const TextStyle(fontSize: 18.0),
            ),
            titleSpacing: 0.0,
          ),
          body: _createContent(viewModel),
        ),
      ),
    );
  }

  Widget _createContent(
    GroupsViewModel viewModel,
  ) {
    List<Widget> tiles = [];
    tiles..add(SectionHeader(text: 'Search Places'));
    tiles..add(_buildSearch());

    String searchHeaderText;

    if (_hasCriteria()) {
      searchHeaderText = 'Suggestions';
    } else {
      searchHeaderText = 'Nearby Places';
    }

    if (_places.length == 0) {
      _buildPlaces(viewModel);
    }

    List<Widget> searchTiles = [];

    if (viewModel.searchingPlaces) {
      searchTiles
        ..add(
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 20.0),
              width: 50.0,
              height: 50.0,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
              ),
            ),
          ),
        );
    } else {
      searchTiles.addAll(_buildPlaceTiles(viewModel));
    }

    tiles.add(
      StickyHeader(
        header: SectionHeader(text: searchHeaderText),
        content: Column(children: searchTiles),
      ),
    );

    /*
    if (needsUpgrade(viewModel.activePlan, 'advertisements_enabled', true)) {
      tiles
        ..addAll(
          [
            ListDivider(),
            bannerAd(viewModel),
          ],
        );
    }
    */

    List<Widget> children = List<Widget>();
    children
      ..addAll([
        Container(
          child: Material(
            child: FabList(
              tiles: tiles,
              icon: Icons.location_searching,
              tooltip: 'Locate on Map',
              onTap: () => _tapLocatePlace(),
            ),
          ),
        ),
        showLoadingBackdrop(
          _backdropAnimationController,
          condition:
              (_places.length == 0) && _backdropAnimationController.isCompleted,
        ),
      ]);

    return Stack(
      fit: StackFit.expand,
      children: children,
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 10.0,
      ),
      child: CustomTextField(
        controller: _criteriaController,
        hintText: 'Search address or location name',
        icon: Icons.location_on,
        iconColor: AppTheme.primary,
        suffixIcon: _hasCriteria() ? _clearIcon() : null,
      ),
    );
  }

  /*
  List<Widget> _buildLocateOnMapIcon() {
    return <Widget>[]
      ..add(SectionHeader(text: 'Locate on Map'))
      ..add(ListTile(
        title: PlaceIcon(),
        onTap: () => StoreProvider.of<AppState>(context)
            .dispatch(NavigatePushAction(AppRoutes.groupPlacesLocate)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      ));
  }

  List<Widget> _buildLocateOnMapButton() {
    return <Widget>[]
      ..add(SectionHeader(text: 'Locate on Map'))
      ..add(
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10.0,
            horizontal: 10.0,
          ),
          child: FlatButton(
            color: AppTheme.primary,
            splashColor: AppTheme.primaryAccent,
            textColor: Colors.white,
            child: Text('Locate on Map'),
            shape: StadiumBorder(),
            onPressed: () => _tapLocatePlace(),
          ),
        ),
      );
  }
  */

  Widget _clearIcon() {
    double size = 30.0;

    return InkWell(
      onTap: _clearCriteria,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment(0.0, 0.0), // all centered
          children: <Widget>[
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[100],
              ),
            ),
            Icon(
              Icons.clear,
              size: (size * 0.6), // 60% width for icon
            ),
          ],
        ),
      ),
    );
  }

  void _clearCriteria() {
    setState(() {
      _criteria = null;
      _places = [];
      _placeTiles = [];
    });

    StoreProvider.of<AppState>(context).dispatch(ClearPlacesAction());
    FocusScope.of(context).requestFocus(FocusNode()); // Closes the keyboard

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _criteriaController.clear());
  }

  void _buildPlaces(
    GroupsViewModel viewModel,
  ) {
    if (_hasCriteria()) {
      if (viewModel.searchPlaces != null) {
        _placeTiles = [];
        _places = viewModel.searchPlaces;
      }
    } else {
      if (viewModel.user.nearBy.places != null) {
        _placeTiles = [];
        viewModel.user.nearBy.places.forEach((place) => _places..add(place));
      }
    }
  }

  List<Widget> _buildPlaceTiles(
    GroupsViewModel viewModel,
  ) {
    int size = _places.length;
    int count = 0;

    if (size == 0) {
      if (_backdropAnimationController.isCompleted) {
        return []..add(
            EmptyStateMessage(
              icon: Icons.search,
              title: 'Searching',
              message: null,
              padding: 10.0,
            ),
          );
      }

      return []
        ..add(EmptyStateMessage(
          message: 'We didn\'t find anything nearby',
          padding: 10.0,
        ))
        ..add(
          Padding(
            padding: const EdgeInsets.only(
              bottom: 10.0,
              left: 100.0,
              right: 100.0,
            ),
            child: FlatButton(
              color: Colors.pink[200],
              splashColor: AppTheme.primaryAccent,
              textColor: Colors.white,
              child: Text('Try Again'),
              shape: StadiumBorder(),
              onPressed: () => _tapTryAgain(viewModel.user),
            ),
          ),
        );
    } else if (_placeTiles.length == 0) {
      /*
      if (needsUpgrade(viewModel.activePlan, 'advertisements_enabled', true)) {
        _places = injectAd<dynamic>(_places, bannerAd(viewModel));
      }
      */

      _places.forEach((entry) {
        if (entry.runtimeType == Place) {
          String name = entry.name;
          if (name == null) {
            name = entry.details.title;
          }

          _placeTiles
            ..add(
              ListTile(
                title: Text(
                  (name == null) ? 'n/a' : name,
                  style: const TextStyle(fontSize: 16.0),
                ),
                leading: PlaceIcon(
                  places: viewModel.groupPlaces,
                  place: entry,
                  showUsed: true,
                ),
                subtitle: Text(
                  (entry.details.vicinity == null)
                      ? ''
                      : entry.details.vicinity,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.2),
                    fontSize: 12.0,
                  ),
                ),
                onTap: () =>
                    _tapPlace(Place.create(entry.details.title, entry.details)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              ),
            );
        } else {
          _placeTiles..add(entry);
        }

        if (count < size) {
          _placeTiles..add(ListDivider());
        }

        count++;
      });
    }

    List<Widget> _list = List<Widget>.from(_placeTiles);
    return _list;
  }

  void _tapPlace(
    Place place,
  ) {
    final store = StoreProvider.of<AppState>(context);

    // Check to see if this place has already been saved. This allows us to edit instead of creating a new place.
    if (hasPlace(store.state.groupPlaces, place)) {
      store.dispatch(
          ActivatePlaceAction(getPlace(store.state.groupPlaces, place)));
    } else {
      store.dispatch(ActivatePlaceAction(place));
    }

    store.dispatch(NavigatePushAction(AppRoutes.groupPlacesDetails));
  }

  void _tapLocatePlace() {
    StoreProvider.of<AppState>(context)
        .dispatch(NavigatePushAction(AppRoutes.groupPlacesLocate));
  }

  void _tapTryAgain(
    User user,
  ) {
    _backdropAnimationController.forward();
    StoreProvider.of<AppState>(context).dispatch(
        RequestNearByPlacesAction(user, _backdropAnimationController));
  }

  bool _hasCriteria() {
    return ((_criteria != null) && (_criteria != ''));
  }
}
