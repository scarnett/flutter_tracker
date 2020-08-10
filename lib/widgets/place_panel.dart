import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_tracker/actions.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/model/place.dart';
import 'package:flutter_tracker/routes.dart';
import 'package:flutter_tracker/utils/common_utils.dart';
import 'package:flutter_tracker/utils/date_utils.dart';
import 'package:flutter_tracker/utils/slide_panel_utils.dart';
import 'package:flutter_tracker/widgets/date_range.dart';
import 'package:flutter_tracker/widgets/empty_state_message.dart';
import 'package:flutter_tracker/widgets/list_divider.dart';
import 'package:flutter_tracker/widgets/list_scrollable_items.dart';
import 'package:flutter_tracker/widgets/place_activity_row.dart';
import 'package:flutter_tracker/widgets/place_row.dart';
import 'package:flutter_tracker/widgets/section_header.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_tracker/state.dart';
import 'package:flutter_tracker/model/groups_viewmodel.dart';
import 'package:flutter_tracker/widgets/slide_up_panel.dart';
import 'package:flutter_tracker/widgets/groups_map.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

class PlacePanel extends StatefulWidget {
  final PanelController controller;

  PlacePanel({
    Key key,
    this.controller,
  }) : super(key: key);

  @override
  State createState() => PlacePanelState();
}

class PlacePanelState extends State<PlacePanel> with TickerProviderStateMixin {
  GroupsMap _map;
  double _panelHeightMax;
  bool _isViewingPlace = false;
  bool _isPanelOpened = false;

  final SlidableController _slidableController = SlidableController();

  void initState() {
    super.initState();

    // Open the panel on the first frame
    SchedulerBinding.instance.addPostFrameCallback(
        (_) => widget.controller.panelPosition = DEFAULT_PANEL_ACTIVE_HEIGHT);
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return StoreConnector<AppState, GroupsViewModel>(
      onInit: (store) {
        _map = GroupsMap();
        _setPanelMaxHeight();
      },
      converter: (store) => GroupsViewModel.fromStore(store),
      builder: (_, viewModel) {
        if (viewModel.activePlace == null) {
          return Container();
        }

        if (viewModel.activePlace != null) {
          if (!_isViewingPlace) {
            try {
              _isViewingPlace = !_isViewingPlace;
              _setPanelMaxHeight(viewModel);
            } catch (e) {
              // logger.e(e);
            }
          }
        } else if (_isViewingPlace) {
          _isViewingPlace = !_isViewingPlace;
          _setPanelMaxHeight(viewModel);
        }

        SlidingUpPanel slidingPanel = SlidingUpPanel(
          controller: widget.controller,
          maxHeight: _panelHeightMax,
          minHeight: DEFAULT_PANEL_MIN_HEIGHT_BOTTOM_BAR,
          boxShadow: [
            const BoxShadow(
              blurRadius: 0.0,
              color: Colors.transparent,
            ),
          ],
          panelSnapping: false,
          panel: _buildPanel(viewModel),
          body: _map,
          border: Border(
            top: BorderSide(
              color: AppTheme.inactive(),
            ),
          ),
          // onPanelSlide: (double pos) => _onPanelSlide(viewModel, pos),
          onPanelOpened: () {
            if (mounted && !_isPanelOpened) {
              setState(() {
                _isPanelOpened = true;
              });
            }
          },
          onPanelClosed: () {
            if (mounted && _isPanelOpened) {
              setState(() {
                _isPanelOpened = false;
              });
            }
          },
        );

        List<Widget> children = [
          slidingPanel,
        ];

        return Stack(
          children: children,
        );
      },
    );
  }

  SlideUpPanel _buildPanel(
    GroupsViewModel viewModel,
  ) {
    final store = StoreProvider.of<AppState>(context);

    Widget _panelHeader;
    List<Widget> _panelItems = [];

    if (viewModel.activePlace != null) {
      _panelHeader = Container(
        child: _buildPlaceRow(viewModel.activePlace),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppTheme.inactive(),
            ),
          ),
        ),
      );

      _panelItems..add(_panelHeader)..add(_buildPabelBody(store, viewModel));
    }

    /*
      if (needsUpgrade(viewModel.activePlan, 'advertisements_enabled', true)) {
        panelItems..add(bannerAd(viewModel));
      }
      */

    return SlideUpPanel(
      body: _panelItems,
    );
  }

  Widget _buildPabelBody(
    final store,
    GroupsViewModel viewModel,
  ) {
    List<Widget> _panelItems = [];

    _panelItems
      ..add(_buildDateRangeSelector(store, viewModel))
      ..addAll(_buildActivePlaceActivityItems(store, viewModel));

    return ListScrollableItems(
      items: _panelItems,
      disableScroll: !_isPanelOpened,
    );
  }

  Widget _buildDateRangeSelector(
    final store,
    GroupsViewModel viewModel,
  ) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: DateRange(
        plan: viewModel.activePlan,
        onTap: (List<DateTime> picked) {
          if ((picked != null) && (picked.length == 2)) {
            store.dispatch(CancelPlaceActivityAction());
            store.dispatch(RequestPlaceActivityAction(
              viewModel.activePlace.documentId,
              startGt: picked[0],
              endLte: picked[1],
            ));
          }
        },
      ),
    );
  }

  Widget _buildPlaceRow(
    Place place,
  ) {
    return Slidable(
      key: ValueKey(place.documentId),
      controller: _slidableController,
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      child: PlaceRow(
        place: place,
      ),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Edit',
          color: AppTheme.secondary,
          foregroundColor: Colors.white,
          icon: Icons.edit,
          onTap: () => _tapEditPlace(),
        ),
      ],
    );
  }

  List<Widget> _buildActivePlaceActivityItems(
    final store,
    GroupsViewModel viewModel,
  ) {
    List<Widget> panelItems = [];
    Map<String, List<dynamic>> activityData =
        _buildActivePlaceActivitySections(viewModel);
    if (activityData == null) {
      panelItems..add(_buildLoading());
    } else if (activityData.length == 0) {
      panelItems
        ..add(EmptyStateMessage(
          icon: Icons.av_timer,
          title: null,
          message: 'Waiting for some activity...',
        ));
    } else {
      activityData.forEach((key, value) {
        List<Widget> items = [];
        value.forEach((activity) => items..add(activity));

        panelItems
          ..add(
            StickyHeader(
              header: SectionHeader(text: key),
              content: Column(children: items),
            ),
          );
      });
    }

    return panelItems;
  }

  Map<String, List<dynamic>> _buildActivePlaceActivitySections(
    GroupsViewModel viewModel,
  ) {
    if (viewModel.placeActivity == null) {
      return null;
    }

    Iterable<PlaceActivity> activity = viewModel.placeActivity.where((entry) =>
        (entry.runtimeType == PlaceActivity) && (entry.created != null));

    String dateStr;
    Map<String, List<dynamic>> entires = Map<String, List<dynamic>>();
    int size = activity.length;
    int count = 1;

    /*
    if (needsUpgrade(viewModel.activePlan, 'advertisements_enabled', true)) {
      activity = injectAd<dynamic>(
        activity,
        bannerAd(viewModel),
        minEntriesNeeded: 5,
      );
    }
    */

    activity.forEach((entry) {
      dateStr = formatTimestamp(entry.created, 'MM/dd/yyyy');

      if (entires.containsKey(dateStr)) {
        entires[dateStr]
          ..add(PlaceActivityRow(
            activity: entry,
            tap: null, // () => _tapActivePlaceActivityDetails(entry),
          ));
      } else {
        entires[dateStr] = [
          PlaceActivityRow(
            activity: entry,
            tap: null, // () => _tapActivePlaceActivityDetails(entry),
          )
        ];
      }

      if (count < size) {
        entires[dateStr]..add(ListDivider());
      }

      count++;
    });

    return entires;
  }

  Widget _buildLoading() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(
          top: 20.0,
          bottom: 20.0,
        ),
        width: 50.0,
        height: 50.0,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
        ),
      ),
    );
  }

  void _tapActivePlaceActivityDetails(
    PlaceActivity data,
  ) {
    // TODO
  }

  void _tapEditPlace() {
    StoreProvider.of<AppState>(context)
        .dispatch(NavigatePushAction(AppRoutes.groupPlacesDetails));
  }

  void _setPanelMaxHeight([
    GroupsViewModel viewModel,
  ]) {
    double windowHeight = MediaQuery.of(context).size.height;
    if ((viewModel != null) &&
        (viewModel.user != null) &&
        (viewModel.activePlace != null)) {
      _panelHeightMax =
          (windowHeight - (APPBAR_HEIGHT - 1.0)); // Accounts for 1px border
    } else {
      _panelHeightMax = windowHeight;
    }
  }
}
