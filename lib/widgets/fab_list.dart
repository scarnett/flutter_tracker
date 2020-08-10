import 'package:flutter/material.dart';
import 'package:flutter_tracker/colors.dart';

class FabList extends StatefulWidget {
  final List<Widget> tiles;
  final IconData icon;
  final String tooltip;
  final double bottom;
  final double right;
  final GestureTapCallback onTap;

  FabList({
    this.tiles,
    this.icon,
    this.tooltip,
    this.bottom = 20.0,
    this.right = 20.0,
    this.onTap,
  });

  @override
  _FabListState createState() => _FabListState();
}

class _FabListState extends State<FabList> with TickerProviderStateMixin {
  ScrollController _scrollController;
  AnimationController _fabAnimationController;
  Animation<Offset> _fabPositionAnimation;
  Animation<double> _fabOpacity;

  bool _showing = true;
  double _currentOffset = 0.0;
  double _lastOffset = 0.0;

  final alphaTween = Tween(begin: 0.0, end: 1.0);

  void initState() {
    setState(() {
      _scrollController = ScrollController();
      _scrollController.addListener(_scrollListener);

      _fabAnimationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 100),
      );

      if (_showing) {
        _fabAnimationController.forward();
      }

      _fabPositionAnimation = Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: const Offset(0.0, 0.0),
      ).animate(CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.decelerate,
      ));

      _fabOpacity = alphaTween.animate(_fabAnimationController);
    });

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    if (_showing && _fabAnimationController.isDismissed) {
      _fabAnimationController.forward();
    } else if (!_showing && _fabAnimationController.isCompleted) {
      _fabAnimationController.reverse();
    }

    return AnimatedBuilder(
      animation: _fabAnimationController,
      builder: (
        BuildContext context,
        Widget _widget,
      ) =>
          Stack(
        children: [
          Container(
            child: Material(
              child: ListView(
                controller: _scrollController,
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: widget.tiles,
              ),
            ),
          ),
          Positioned(
            bottom: widget.bottom,
            right: widget.right,
            child: SlideTransition(
              position: _fabPositionAnimation,
              child: FadeTransition(
                opacity: _fabOpacity,
                child: (widget.tooltip == null)
                    ? _buildFab()
                    : Tooltip(
                        message: widget.tooltip,
                        preferBelow: false,
                        margin: EdgeInsets.only(bottom: 10.0),
                        child: _buildFab(),
                      ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFab() {
    return FloatingActionButton(
      onPressed: widget.onTap,
      child: Icon(
        (widget.icon == null) ? Icons.add : widget.icon,
      ),
      backgroundColor: AppTheme.primaryAccent,
    );
  }

  _scrollListener() {
    _currentOffset = _scrollController.offset;
    if (_currentOffset > _lastOffset) {
      _lastOffset = _currentOffset;
      _showing = false;
      _fabAnimationController.reverse();
    } else if ((_currentOffset < _lastOffset) || (_currentOffset == 0.0)) {
      _lastOffset = _currentOffset;
      _showing = true;
      _fabAnimationController.forward();
    }
  }
}
