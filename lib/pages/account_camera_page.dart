import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:logger/logger.dart';
import 'package:flutter_tracker/actions.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/model/groups_viewmodel.dart';
import 'package:flutter_tracker/model/cloudinary.dart';
import 'package:flutter_tracker/routes.dart';
import 'package:flutter_tracker/services/authentication.dart';
import 'package:flutter_tracker/state.dart';
import 'package:flutter_tracker/utils/date_utils.dart';
import 'package:flutter_tracker/widgets/backdrop.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class AccountCameraPage extends StatefulWidget {
  final BaseAuthService authService;
  final List<CameraDescription> cameras;

  AccountCameraPage({
    Key key,
    this.authService,
    this.cameras,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AccountCameraPageState();
}

class _AccountCameraPageState extends State<AccountCameraPage>
    with TickerProviderStateMixin {
  AnimationController _backdropAnimationController;

  CameraController _controller;
  int _selectedCamera = 0;

  double min = (pi * -2.0);
  double max = (pi * 2.0);

  Logger logger = Logger();

  @override
  void initState() {
    super.initState();

    CameraDescription camera = widget.cameras[_selectedCamera];
    _onNewCameraSelected(camera);

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
    return StoreConnector<AppState, GroupsViewModel>(
      converter: (store) => GroupsViewModel.fromStore(store),
      builder: (_, viewModel) => WillPopScope(
        onWillPop: () {
          StoreProvider.of<AppState>(context).dispatch(NavigatePopAction());
          return Future.value(true);
        },
        child: Scaffold(
          backgroundColor: Colors.black.withOpacity(0.5),
          resizeToAvoidBottomPadding: true,
          appBar: AppBar(
            title: Text(
              'Take Photo',
              style: const TextStyle(fontSize: 18.0),
            ),
            titleSpacing: 0.0,
          ),
          body: _createContent(context, viewModel),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _backdropAnimationController.dispose();
    super.dispose();
  }

  Widget _createContent(
    BuildContext context,
    GroupsViewModel viewModel,
  ) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Container(
            child: Center(
              child: _cameraPreviewWidget(context, viewModel),
            ),
          ),
        ),
      ],
    );
  }

  Widget _cameraPreviewWidget(
    BuildContext context,
    GroupsViewModel viewModel,
  ) {
    List<Widget> children = List<Widget>();
    children
      ..addAll([
        _buildPreview(),
        _buildPreviewOverlays(viewModel),
        showLoadingBackdrop(
          _backdropAnimationController,
          condition: (_controller == null) || !_controller.value.isInitialized,
        ),
      ]);

    return Stack(
      children: children,
    );
  }

  Widget _buildPreview() {
    if ((_controller == null) || !_controller.value.isInitialized) {
      _backdropAnimationController.forward();
      return Container();
    } else if (_backdropAnimationController.isCompleted) {
      _backdropAnimationController.reverse();
    }

    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;

    return Transform.scale(
      scale: _controller.value.aspectRatio / deviceRatio,
      child: Center(
        child: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: CameraPreview(_controller),
        ),
      ),
    );
  }

  Widget _buildPreviewOverlays(
    GroupsViewModel viewModel,
  ) {
    if ((_controller == null) || !_controller.value.isInitialized) {
      return Container();
    }

    return Container(
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          _buildRuleOfThirdsLayer(),
          _buildControls(viewModel),
        ],
      ),
    );
  }

  Widget _buildRuleOfThirdsLayer() {
    return Expanded(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  _buildRuleOfThirdsCell(0),
                  _buildRuleOfThirdsCell(1),
                  _buildRuleOfThirdsCell(2),
                ],
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  _buildRuleOfThirdsCell(3),
                  _buildRuleOfThirdsCell(4),
                  _buildRuleOfThirdsCell(5),
                ],
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  _buildRuleOfThirdsCell(6),
                  _buildRuleOfThirdsCell(7),
                  _buildRuleOfThirdsCell(8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(
    GroupsViewModel viewModel,
  ) {
    if ((_controller == null) || !_controller.value.isInitialized) {
      // TODO: loading...
      return Container();
    }

    CameraDescription camera =
        (_controller == null) ? null : _controller.description;

    return ClipRect(
      child: Container(
        width: MediaQuery.of(context).size.width,
        color: Colors.black.withOpacity(0.7),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 5.0,
            sigmaY: 5.0,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 20.0,
              horizontal: 20.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                RawMaterialButton(
                  onPressed: () => _tapSelectCamera(context),
                  child: Icon(
                    _getCameraLensIcon(camera),
                    color: Colors.white,
                  ),
                  shape: CircleBorder(),
                  elevation: 0.0,
                  fillColor: Colors.black87,
                  padding: const EdgeInsets.all(10.0),
                ),
                RawMaterialButton(
                  onPressed: () =>
                      (_controller != null) && _controller.value.isInitialized
                          ? _tapTakePicture(viewModel)
                          : null,
                  child: Container(
                    width: 60.0,
                    height: 60.0,
                    child: Stack(
                      children: <Widget>[
                        Icon(
                          Icons.brightness_1,
                          color: Colors.white,
                          size: 60.0,
                        ),
                        Center(
                          child: Icon(
                            Icons.camera,
                            color: AppTheme.primary,
                            size: 50.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  shape: CircleBorder(),
                  elevation: 0.0,
                  fillColor: Colors.black.withOpacity(0.3),
                  padding: const EdgeInsets.all(2.0),
                ),
                RawMaterialButton(
                  onPressed: () => _tapSelectPhoto(viewModel),
                  child: Icon(
                    Icons.add_a_photo,
                    color: Colors.white,
                  ),
                  shape: CircleBorder(),
                  elevation: 0.0,
                  fillColor: Colors.black87,
                  padding: const EdgeInsets.all(10.0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRuleOfThirdsCell(
    int index,
  ) {
    return Expanded(
      child: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.black.withOpacity(0.5),
            ),
            right: BorderSide(
              color: (((index + 1) % 3) == 0)
                  ? Colors.transparent
                  : Colors.black.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }

  void _tapSelectCamera(
    context,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        List<Widget> children = <Widget>[];

        for (CameraDescription camera in widget.cameras) {
          children
            ..add(
              ListTile(
                leading: const Icon(Icons.image),
                title: Text(_getCameraName(camera)),
                onTap: () => _onNewCameraSelected(camera, popNav: true),
              ),
            );
        }

        return Container(
          child: Wrap(
            children: children,
          ),
        );
      },
    );
  }

  void _tapSelectPhoto(
    GroupsViewModel viewModel,
  ) async {
    try {
      final image = await ImagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (mounted) {
        _uploadImage(viewModel, image.path);
      }
    } catch (e) {
      // TODO
    }
  }

  void _tapTakePicture(
    GroupsViewModel viewModel,
  ) {
    _takePicture(viewModel.configValue('picture_folder'))
        .then((String filePath) {
      if (mounted) {
        _uploadImage(viewModel, filePath);
      }
    });
  }

  void _uploadImage(
    GroupsViewModel viewModel,
    String filePath,
  ) async {
    FirebaseUser user = await widget.authService.getCurrentUser();

    setState(() {
      CloudinaryUploadData data = CloudinaryUploadData(
        filePath: filePath,
        user: user,
        apiKey: viewModel.configValue('cloudinary_key'),
        apiSecret: viewModel.configValue('cloudinary_secret'),
        apiUrl: viewModel.configValue('cloudinary_url'),
        publicId: viewModel.configValue('cloudinary_public_id'),
      );

      final store = StoreProvider.of<AppState>(context);
      store.dispatch(UpdatingImageAction(true));
      store.dispatch(SaveCloudinaryAction(data));
      store.dispatch(NavigateReplaceAction(AppRoutes.accountPhoto));
    });
  }

  Future<String> _takePicture(
    String folder,
  ) async {
    if (!_controller.value.isInitialized) {
      return null;
    }

    final String timestamp = getNow().millisecondsSinceEpoch.toString();
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}$folder';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/$timestamp.png';

    if (_controller.value.isTakingPicture) {
      return null;
    }

    try {
      await _controller.takePicture(filePath);
    } on CameraException {
      return null;
    }

    return filePath;
  }

  void _onNewCameraSelected(
    CameraDescription camera, {
    bool popNav = false,
  }) async {
    if (_controller != null) {
      await _controller.dispose();
    }

    _controller = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
    );

    _controller.addListener(() {
      if (mounted) {
        setState(() {
          // ...
        });
      }

      if (_controller.value.hasError) {
        // TODO send message action
        // showInSnackBar('Camera error ${_controller.value.errorDescription}');
      }
    });

    try {
      await _controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {
        // ...
      });
    }

    if (popNav) {
      Navigator.pop(context);
    }
  }

  void _showCameraException(CameraException e) {
    logger.d('code: ${e.code}, message: ${e.description}');
    // showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  IconData _getCameraLensIcon(
    CameraDescription camera,
  ) {
    switch (camera.lensDirection) {
      case CameraLensDirection.back:
        return Icons.camera_rear;

      case CameraLensDirection.front:
        return Icons.camera_front;

      case CameraLensDirection.external:
        return Icons.camera;
    }

    throw ArgumentError('Unknown lens direction');
  }

  String _getCameraName(
    CameraDescription camera,
  ) {
    switch (camera.lensDirection) {
      case CameraLensDirection.back:
        return 'Back';

      case CameraLensDirection.front:
        return 'Front';

      case CameraLensDirection.external:
        return 'External';
    }

    throw ArgumentError('Unknown camera');
  }
}
