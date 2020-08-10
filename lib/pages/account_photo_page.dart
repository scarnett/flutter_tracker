import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_tracker/actions.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/model/groups_viewmodel.dart';
import 'package:flutter_tracker/model/cloudinary.dart';
import 'package:flutter_tracker/routes.dart';
import 'package:flutter_tracker/services/authentication.dart';
import 'package:flutter_tracker/state.dart';
import 'package:flutter_tracker/utils/common_utils.dart';
import 'package:flutter_tracker/widgets/user_avatar.dart';
import 'package:image_picker/image_picker.dart';

class AccountPhotoPage extends StatefulWidget {
  final BaseAuthService authService;

  AccountPhotoPage({
    Key key,
    this.authService,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AccountPhotoPageState();
}

class _AccountPhotoPageState extends State<AccountPhotoPage>
    with TickerProviderStateMixin {
  double _size = 80.0;

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
          resizeToAvoidBottomPadding: true,
          appBar: AppBar(
            title: Text(
              'Account Photo',
              style: const TextStyle(fontSize: 18.0),
            ),
            titleSpacing: 0.0,
          ),
          body: _buildContent(viewModel),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildContent(
    GroupsViewModel viewModel,
  ) {
    List<Widget> children = [
      _buildPhotoPreview(viewModel),
    ];

    return Stack(
      children: filterNullWidgets(children),
    );
  }

  Widget _buildPhotoPreview(
    GroupsViewModel viewModel,
  ) {
    return Container(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 80.0, 20.0, 20.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Text(
                'Your Current Photo',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: (viewModel.user.image == null)
                        ? Container()
                        : UserAvatar(
                            user: viewModel.user,
                            imageUrl: viewModel.user.image.secureUrl,
                            avatarRadius: _size,
                          ),
                  ),
                ),
                _buildSpinner(viewModel),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: FlatButton(
                      color: AppTheme.primary,
                      splashColor: AppTheme.primaryAccent,
                      textColor: Colors.white,
                      child: Text('Take Photo'),
                      shape: StadiumBorder(),
                      onPressed: () => _tapTakePhoto(),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: FlatButton(
                      color: AppTheme.primary,
                      splashColor: AppTheme.primaryAccent,
                      textColor: Colors.white,
                      child: Text('Select Photo'),
                      shape: StadiumBorder(),
                      onPressed: () => _tapSelectPhoto(viewModel),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpinner(
    GroupsViewModel viewModel,
  ) {
    if (viewModel.updatingImage) {
      return Align(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: ClipOval(
            child: Container(
              color: Colors.black.withOpacity(0.7),
              width: (_size * 2.0),
              height: (_size * 2.0),
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container();
  }

  void _tapTakePhoto() {
    StoreProvider.of<AppState>(context)
        .dispatch(NavigatePushAction(AppRoutes.accountCamera));
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
}
