import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tracker/utils/shadow_utils.dart';
import 'package:flutter_tracker/widgets/page_dragger.dart';
import 'package:flutter_tracker/widgets/page_reveal.dart';
import 'package:flutter_tracker/widgets/pager_indicator.dart';
import 'package:flutter_tracker/widgets/pages.dart' as pages;

class OnBoarding extends StatefulWidget {
  final List<pages.PageModel> pageList;
  final VoidCallback onDoneButtonPressed;
  final VoidCallback onSkipButtonPressed;
  final String doneButtonText;
  final String skipButtonText;
  final bool showSkipButton;

  OnBoarding({
    @required this.pageList,
    @required this.onDoneButtonPressed,
    this.onSkipButtonPressed,
    this.doneButtonText = 'OK',
    this.skipButtonText = 'Skip',
    this.showSkipButton = true,
  }) : assert((pageList != null) && (onDoneButtonPressed != null));

  @override
  _OnBoardingState createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> with TickerProviderStateMixin {
  StreamController<SlideUpdate> slideUpdateStream;
  AnimatedPageDragger animatedPageDragger;
  int activeIndex = 0;
  int nextPageIndex = 0;
  SlideDirection slideDirection = SlideDirection.none;
  double slidePercent = 0.0;

  @override
  void initState() {
    super.initState();
    this.slideUpdateStream = StreamController<SlideUpdate>();
    _listenSlideUpdate();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    List<Widget> children = List<Widget>();

    // Show a spinner if the onboarding pages aren't ready yet
    if (widget.pageList.length == 0) {
      children
        ..add(
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 16.0, right: 16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.3, 0.9],
                colors: [
                  Colors.pink,
                  Colors.pink[900],
                ],
              ),
            ),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        );
    } else {
      children
        ..addAll(
          [
            pages.Page(
              model: widget.pageList[activeIndex],
              percentVisible: 1.0,
            ),
            PageReveal(
              revealPercent: slidePercent,
              child: pages.Page(
                model: widget.pageList[nextPageIndex],
                percentVisible: slidePercent,
              ),
            ),
            PagerIndicator(
              viewModel: PagerIndicatorViewModel(
                widget.pageList,
                activeIndex,
                slideDirection,
                slidePercent,
                true,
              ),
            ),
            PageDragger(
              pageLength: (widget.pageList.length - 1),
              currentIndex: activeIndex,
              canDragLeftToRight: (activeIndex > 0),
              canDragRightToLeft: (activeIndex < (widget.pageList.length - 1)),
              slideUpdateStream: this.slideUpdateStream,
            ),
          ],
        );
    }

    children
      ..addAll(
        [
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: Opacity(
              opacity: _getOpacity(),
              child: FlatButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                color: Colors.black.withOpacity(0.3),
                child: Text(
                  widget.doneButtonText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w800,
                    shadows: commonTextShadow(),
                  ),
                ),
                onPressed:
                    (_getOpacity() == 1.0) ? widget.onDoneButtonPressed : () {},
              ),
            ),
          ),
          widget.showSkipButton && (widget.pageList.length > 0)
              ? Positioned(
                  top: (MediaQuery.of(context).padding.top + 10.0),
                  right: 20.0,
                  child: RawMaterialButton(
                    shape: CircleBorder(),
                    constraints: BoxConstraints.tight(Size(40.0, 40.0)),
                    child: Text(
                      widget.skipButtonText,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w800,
                        shadows: commonTextShadow(),
                      ),
                    ),
                    onPressed: widget.onSkipButtonPressed,
                  ),
                )
              : Offstage(),
        ],
      );

    return Stack(
      children: children,
    );
  }

  _listenSlideUpdate() {
    slideUpdateStream.stream.listen((SlideUpdate event) {
      setState(() {
        if (event.updateType == UpdateType.dragging) {
          // logger.d('Sliding ${event.direction} at ${event.slidePercent}');
          slideDirection = event.direction;
          slidePercent = event.slidePercent;

          if (slideDirection == SlideDirection.leftToRight) {
            nextPageIndex = (activeIndex - 1);
          } else if (slideDirection == SlideDirection.rightToLeft) {
            nextPageIndex = (activeIndex + 1);
          } else {
            nextPageIndex = activeIndex;
          }
        } else if (event.updateType == UpdateType.doneDragging) {
          // logger.d('Done dragging.');
          if (slidePercent > 0.15) {
            animatedPageDragger = AnimatedPageDragger(
              slideDirection: slideDirection,
              transitionGoal: TransitionGoal.open,
              slidePercent: slidePercent,
              slideUpdateStream: slideUpdateStream,
              vsync: this,
            );
          } else {
            animatedPageDragger = AnimatedPageDragger(
              slideDirection: slideDirection,
              transitionGoal: TransitionGoal.close,
              slidePercent: slidePercent,
              slideUpdateStream: slideUpdateStream,
              vsync: this,
            );

            nextPageIndex = activeIndex;
          }

          animatedPageDragger.run();
        } else if (event.updateType == UpdateType.animating) {
          // logger.d('Sliding ${event.direction} at ${event.slidePercent}');
          slideDirection = event.direction;
          slidePercent = event.slidePercent;
        } else if (event.updateType == UpdateType.doneAnimating) {
          // logger.d('Done animating. Next page index: $nextPageIndex');
          activeIndex = nextPageIndex;
          slideDirection = SlideDirection.none;
          slidePercent = 0.0;
          animatedPageDragger.dispose();
        }
      });
    });
  }

  double _getOpacity() {
    if (((widget.pageList.length - 2) == activeIndex) &&
        (slideDirection == SlideDirection.rightToLeft)) {
      return slidePercent;
    }

    if (((widget.pageList.length - 1) == activeIndex) &&
        (slideDirection == SlideDirection.leftToRight)) {
      return (1.0 - slidePercent);
    }

    if ((widget.pageList.length - 1) == activeIndex) {
      return 1.0;
    }

    return 0.0;
  }

  @override
  void dispose() {
    slideUpdateStream?.close();
    super.dispose();
  }
}
