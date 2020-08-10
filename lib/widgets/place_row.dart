import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_tracker/model/groups_viewmodel.dart';
import 'package:flutter_tracker/state.dart';
import 'package:flutter_tracker/model/place.dart';
import 'package:flutter_tracker/utils/place_utils.dart';
import 'package:flutter_tracker/widgets/list_show_more.dart';
import 'package:flutter_tracker/widgets/place_icon.dart';

class PlaceRow extends StatefulWidget {
  final Place place;
  final Function tap;

  PlaceRow({
    this.place,
    this.tap,
  });

  @override
  State createState() => PlaceRowState();
}

class PlaceRowState extends State<PlaceRow> with TickerProviderStateMixin {
  initState() {
    super.initState();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return StoreConnector<AppState, GroupsViewModel>(
      converter: (store) => GroupsViewModel.fromStore(store),
      builder: (_, viewModel) => Container(
        color: Colors.white,
        child: Material(
          child: InkWell(
            onTap: widget.tap,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 8,
                    child: Container(
                      child: Wrap(
                        direction: Axis.vertical,
                        children: [
                          Row(
                            children: <Widget>[
                              PlaceIcon(),
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.max,
                                      children: _buildPlaceInfo(viewModel),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  ListShowMore(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPlaceInfo(
    GroupsViewModel viewModel,
  ) {
    List<Widget> widgets = [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            (widget.place.name == null)
                ? 'N/A'
                : widget.place.name, // Place name
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ];

    if (widget.place.lastUpdated != null) {
      widgets
        ..add(
          Text(
            lastPlaceActivity(
              viewModel.activePlace,
              viewModel.latestPlaceActivity,
              useTimeago: true,
            ),
            style: const TextStyle(
              fontSize: 12.0,
              color: Colors.black38,
              fontWeight: FontWeight.w400,
            ),
          ),
        );
    }

    return widgets;
  }
}
