import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:logger/logger.dart';
import 'package:flutter_tracker/actions.dart';
import 'package:flutter_tracker/model/message.dart';
import 'package:flutter_tracker/routes.dart';
import 'package:flutter_tracker/utils/common_utils.dart';
import 'package:flutter_tracker/utils/iap_utils.dart';
import 'package:flutter_tracker/widgets/backdrop.dart';
import 'package:flutter_tracker/widgets/page_dragger.dart';
import 'package:flutter_tracker/widgets/page_reveal.dart';
import 'package:flutter_tracker/widgets/pager_indicator.dart';
import 'package:flutter_tracker/widgets/pages.dart' as pages;

Logger logger = Logger();

class Subscription extends StatefulWidget {
  final store;
  final int activeIndex;
  final List<pages.PageModel> pageList;
  final VoidCallback onDoneButtonPressed;
  final VoidCallback onSkipButtonPressed;
  final bool showSkipButton;

  Subscription({
    @required this.store,
    @required this.activeIndex,
    @required this.pageList,
    @required this.onDoneButtonPressed,
    this.onSkipButtonPressed,
    this.showSkipButton = true,
  }) : assert((pageList.length != 0) && (onDoneButtonPressed != null));

  @override
  _SubscriptionState createState() => _SubscriptionState();
}

class _SubscriptionState extends State<Subscription>
    with TickerProviderStateMixin {
  AnimationController _backdropAnimationController;
  StreamController<SlideUpdate> _slideUpdateStream;
  AnimatedPageDragger _animatedPageDragger;
  List<pages.PageModel> _pageList;
  int _activeIndex = 0;
  int _nextPageIndex = 0;
  SlideDirection _slideDirection = SlideDirection.none;
  double _slidePercent = 0.0;
  StreamSubscription<List<PurchaseDetails>> _subscription;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();

    Stream purchaseUpdated =
        InAppPurchaseConnection.instance.purchaseUpdatedStream;
    _subscription = purchaseUpdated.listen(
      (purchaseDetailsList) => _listenToPurchaseUpdated(purchaseDetailsList),
      onDone: () => _subscription.cancel(),
      onError: (error) {
        // TODO: handle error
      },
    );

    this._activeIndex = widget.activeIndex;
    this._pageList = widget.pageList;
    this._slideUpdateStream = StreamController<SlideUpdate>();
    _listenSlideUpdate();

    setState(() {
      _backdropAnimationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 350),
      );
    });
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Stack(
      children: [
        pages.Page(
          model: _pageList[_activeIndex],
          percentVisible: 1.0,
        ),
        PageReveal(
          revealPercent: _slidePercent,
          child: pages.Page(
            model: _pageList[_nextPageIndex],
            percentVisible: _slidePercent,
          ),
        ),
        PagerIndicator(
          viewModel: PagerIndicatorViewModel(
            _pageList,
            _activeIndex,
            _slideDirection,
            _slidePercent,
            false,
          ),
        ),
        PageDragger(
          pageLength: (_pageList.length - 1),
          currentIndex: _activeIndex,
          canDragLeftToRight: (_activeIndex > 0),
          canDragRightToLeft: (_activeIndex < (_pageList.length - 1)),
          slideUpdateStream: this._slideUpdateStream,
        ),
        widget.showSkipButton
            ? Positioned(
                top: (MediaQuery.of(context).padding.top + 10.0),
                right: 20.0,
                child: RawMaterialButton(
                  shape: CircleBorder(),
                  constraints: BoxConstraints.tight(Size(40.0, 40.0)),
                  onPressed: widget.onSkipButtonPressed,
                ),
              )
            : Offstage(),
        showLoadingBackdrop(
          _backdropAnimationController,
          condition: _isProcessing,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _slideUpdateStream?.close();
    _backdropAnimationController.dispose();
    super.dispose();
  }

  void _listenToPurchaseUpdated(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    await Future.forEach(purchaseDetailsList,
        (PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // ...
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          _handleError(widget.store, purchaseDetails.error);
        } else if (purchaseDetails.status == PurchaseStatus.purchased) {
          bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            _deliverProduct(widget.store, purchaseDetails);
          } else {
            _handleInvalidPurchase(widget.store, purchaseDetails);
          }
        }

        // TODO: Do this in _verifyPurchase instead
        if ((purchaseDetails != null) &&
            (purchaseDetails.verificationData != null)) {
          if (Platform.isIOS) {
            InAppPurchaseConnection.instance.completePurchase(purchaseDetails);
          } else if (Platform.isAndroid) {
            InAppPurchaseConnection.instance.consumePurchase(purchaseDetails);
          }

          widget.store.dispatch(SavePurchaseDetailsAction(purchaseDetails));
          widget.store.dispatch(SetSelectedTabIndexAction(TAB_HOME));
          widget.store.dispatch(NavigateReplaceAction(AppRoutes.home));
        }
      }
    });
  }

  Future<bool> _verifyPurchase(
    PurchaseDetails purchaseDetails,
  ) {
    // TODO: IMPORTANT!! Need to verify the purchase before delivering the product.
    return Future<bool>.value(true);
  }

  void _deliverProduct(
    final store,
    PurchaseDetails purchaseDetails,
  ) async {
    store.dispatch(SendMessageAction(Message(message: 'Purchase complete!')));
  }

  void _handleInvalidPurchase(
    final store,
    PurchaseDetails purchaseDetails,
  ) {
    store.dispatch(SendMessageAction(
      Message(message: 'Invalid purchase request. Please contact support.'),
    ));
  }

  void _handleError(
    final store,
    IAPError error,
  ) {
    String responseType = getResponseType(error.message);
    if (responseType != null) {
      switch (responseType) {
        case 'userCanceled':
          break;

        case 'developerError':
          logger.d('IAP developerError: $error; ${error.message}');
          break;

        case 'itemAlreadyOwned':
          logger.d('IAP itemAlreadyOwned: $error; ${error.message}');
          store.dispatch(SendMessageAction(
            Message(message: 'You are already subscribed to this plan'),
          ));
          break;

        default:
          // TODO: sentry?
          logger.d('IAP Error: $error; ${error.message}');
          store.dispatch(SendMessageAction(
            Message(
                message:
                    'There was an error with this purchase. Please contact support.'),
          ));
      }
    }
  }

  _listenSlideUpdate() {
    _slideUpdateStream.stream.listen((
      SlideUpdate event,
    ) {
      setState(() {
        if (event.updateType == UpdateType.dragging) {
          // logger.d('Sliding ${event.direction} at ${event.slidePercent}');
          _slideDirection = event.direction;
          _slidePercent = event.slidePercent;

          if (_slideDirection == SlideDirection.leftToRight) {
            _nextPageIndex = (_activeIndex - 1);
          } else if (_slideDirection == SlideDirection.rightToLeft) {
            _nextPageIndex = (_activeIndex + 1);
          } else {
            _nextPageIndex = _activeIndex;
          }
        } else if (event.updateType == UpdateType.doneDragging) {
          // logger.d('Done dragging.');
          if (_slidePercent > 0.15) {
            _animatedPageDragger = AnimatedPageDragger(
              slideDirection: _slideDirection,
              transitionGoal: TransitionGoal.open,
              slidePercent: _slidePercent,
              slideUpdateStream: _slideUpdateStream,
              vsync: this,
            );
          } else {
            _animatedPageDragger = AnimatedPageDragger(
              slideDirection: _slideDirection,
              transitionGoal: TransitionGoal.close,
              slidePercent: _slidePercent,
              slideUpdateStream: _slideUpdateStream,
              vsync: this,
            );

            _nextPageIndex = _activeIndex;
          }

          _animatedPageDragger.run();
        } else if (event.updateType == UpdateType.animating) {
          // logger.d('Sliding ${event.direction} at ${event.slidePercent}');
          _slideDirection = event.direction;
          _slidePercent = event.slidePercent;
        } else if (event.updateType == UpdateType.doneAnimating) {
          // logger.d('Done animating. Next page index: $nextPageIndex');
          _activeIndex = _nextPageIndex;
          _slideDirection = SlideDirection.none;
          _slidePercent = 0.0;
          _animatedPageDragger.dispose();
        }
      });
    });
  }

  /*
  double _getOpacity() {
    if (((pageList.length - 2) == activeIndex) &&
        (slideDirection == SlideDirection.rightToLeft)) {
      return slidePercent;
    }

    if (((pageList.length - 1) == activeIndex) &&
        (slideDirection == SlideDirection.leftToRight)) {
      return (1 - slidePercent);
    }

    if ((pageList.length - 1) == activeIndex) {
      return 1.0;
    }

    return 0.0;
  }
  */
}
