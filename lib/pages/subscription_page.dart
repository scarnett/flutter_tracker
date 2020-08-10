import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_tracker/actions.dart';
import 'package:flutter_tracker/model/groups_viewmodel.dart';
import 'package:flutter_tracker/model/plan.dart';
import 'package:flutter_tracker/model/product.dart';
import 'package:flutter_tracker/state.dart';
import 'package:flutter_tracker/widgets/pages.dart';
import 'package:flutter_tracker/widgets/subscription.dart';
import 'package:flutter_tracker/widgets/wavy_background.dart';

class SubscriptionPage extends StatefulWidget {
  SubscriptionPage({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  int _currentPlan;

  @override
  void dispose() {
    _currentPlan = null;
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return StoreConnector<AppState, GroupsViewModel>(
      converter: (store) => GroupsViewModel.fromStore(store),
      onInit: (store) {
        store.dispatch(RequestPlansAction());
      },
      builder: (_, viewModel) {
        if (viewModel.plans == null) {
          return Container();
        }

        if (_currentPlan == null) {
          for (Plan plan in viewModel.plans) {
            if ((plan.products != null) && (viewModel.user.purchase != null)) {
              if ((viewModel.user.purchase.sku == '${plan.code}_monthly') ||
                  (viewModel.user.purchase.sku == '${plan.code}_annually')) {
                _currentPlan = plan.sequence;
                break;
              }
            }
          }

          if (_currentPlan == null) {
            _currentPlan = 0;
          }
        }

        return Scaffold(
          body: Stack(
            children: <Widget>[
              Subscription(
                store: StoreProvider.of<AppState>(context),
                activeIndex: _currentPlan,
                pageList: _buildPageModel(viewModel),
                onDoneButtonPressed: () => null,
                onSkipButtonPressed: () => null,
              ),
              Positioned(
                top: 26.0,
                left: 5.0,
                child: RawMaterialButton(
                  shape: CircleBorder(),
                  constraints: BoxConstraints.tight(Size(40.0, 40.0)),
                  onPressed: () => Navigator.pop(context),
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white.withAlpha(90),
                    size: 26.0,
                  ),
                ),
              ),
            ]..addAll(
                PresetWaves().noWaves(
                  waves: PresetWaves().defaultWaves(),
                ),
              ),
          ),
        );
      },
    );
  }

  // TODO: This is nasty. clean it up
  List<PageModel> _buildPageModel(
    GroupsViewModel viewModel,
  ) {
    final store = StoreProvider.of<AppState>(context);
    List<PageModel> pages = List<PageModel>();

    for (Plan plan in viewModel.plans) {
      Product monthlyProduct;
      Product annualProduct;
      bool isSubscribed = false;

      if (plan.products != null) {
        String monthlyProductId = plan.products['monthly'];
        monthlyProduct = viewModel.products.firstWhere(
            (Product product) => product.documentId == monthlyProductId);

        String annualProductId = plan.products['annually'];
        annualProduct = viewModel.products.firstWhere(
            (Product product) => product.documentId == annualProductId);

        if (viewModel.user.purchase != null) {
          if ((viewModel.user.purchase.sku == '${plan.code}_monthly') ||
              (viewModel.user.purchase.sku == '${plan.code}_annually')) {
            isSubscribed = true;
          }
        }
      }

      pages
        ..add(
          plan.toPageModel(
            context,
            store,
            viewModel.user,
            monthlyProduct,
            annualProduct,
            isSubscribed,
            viewModel.configValue('cancel_subscription_endpoint_url'),
          ),
        );
    }

    return pages;
  }
}
