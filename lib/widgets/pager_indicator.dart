import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_tracker/widgets/pages.dart';

class PagerIndicator extends StatelessWidget {
  final PagerIndicatorViewModel viewModel;

  PagerIndicator({
    this.viewModel,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    List<PageBubble> bubbles = [];
    for (int i = 0; i < viewModel.pages.length; ++i) {
      final PageModel page = viewModel.pages[i];
      double percentActive;

      if (i == viewModel.activeIndex) {
        percentActive = (1.0 - viewModel.slidePercent);
      } else if ((i == (viewModel.activeIndex - 1)) &&
          (viewModel.slideDirection == SlideDirection.leftToRight)) {
        percentActive = viewModel.slidePercent;
      } else if ((i == (viewModel.activeIndex + 1)) &&
          (viewModel.slideDirection == SlideDirection.rightToLeft)) {
        percentActive = viewModel.slidePercent;
      } else {
        percentActive = 0.0;
      }

      bool isHollow;

      if (viewModel.isStepper) {
        isHollow = (i > viewModel.activeIndex) ||
            ((i == viewModel.activeIndex) &&
                (viewModel.slideDirection == SlideDirection.leftToRight));
      } else {
        isHollow = (i != viewModel.activeIndex);
      }

      bubbles
        ..add(
          PageBubble(
            viewModel: PageBubbleViewModel(
              page.iconData,
              isHollow,
              percentActive,
            ),
          ),
        );
    }

    final bubbleWidth = 55.0;
    final baseTranslation =
        ((viewModel.pages.length * bubbleWidth) / 2) - (bubbleWidth / 2);
    double translation =
        (baseTranslation - (viewModel.activeIndex * bubbleWidth));
    if (viewModel.slideDirection == SlideDirection.leftToRight) {
      translation += (bubbleWidth * viewModel.slidePercent);
    } else if (viewModel.slideDirection == SlideDirection.rightToLeft) {
      translation -= (bubbleWidth * viewModel.slidePercent);
    }

    return Column(
      children: [
        Expanded(child: Container()),
        Transform(
          transform: Matrix4.translationValues(translation, 0.0, 0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: bubbles,
          ),
        ),
      ],
    );
  }
}

enum SlideDirection {
  leftToRight,
  rightToLeft,
  none,
}

class PagerIndicatorViewModel {
  final List<PageModel> pages;
  final int activeIndex;
  final SlideDirection slideDirection;
  final double slidePercent;
  final bool isStepper;

  PagerIndicatorViewModel(
    this.pages,
    this.activeIndex,
    this.slideDirection,
    this.slidePercent,
    this.isStepper,
  );
}

class PageBubble extends StatelessWidget {
  final PageBubbleViewModel viewModel;

  PageBubble({
    this.viewModel,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: (viewModel.iconData == null) ? 30.0 : 45.0,
      height: 80.0,
      child: Center(
        child: Container(
          width: (viewModel.iconData == null)
              ? 14.0
              : lerpDouble(14.0, 45.0, viewModel.activePercent),
          height: (viewModel.iconData == null)
              ? 14.0
              : lerpDouble(14.0, 45.0, viewModel.activePercent),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: viewModel.isHollow
                ? Colors.black
                    .withAlpha((0x30 * viewModel.activePercent).round())
                : Colors.black.withOpacity(0.3),
            border: Border.all(
              color: viewModel.isHollow
                  ? Colors.black.withAlpha(
                      (0x30 * (1.0 - viewModel.activePercent)).round())
                  : Colors.transparent,
              width: 3.0,
            ),
          ),
          child: (viewModel.iconData == null)
              ? Container()
              : Opacity(
                  opacity: viewModel.activePercent,
                  child: Transform.scale(
                    scale: viewModel.activePercent,
                    child: Container(
                      width: 50.0,
                      height: 50.0,
                      child: Icon(
                        viewModel.iconData,
                        color: Colors.white,
                        size: 24.0,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class PageBubbleViewModel {
  final IconData iconData;
  final bool isHollow;
  final double activePercent;

  PageBubbleViewModel(
    this.iconData,
    this.isHollow,
    this.activePercent,
  );
}
