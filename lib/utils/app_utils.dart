import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';

typedef Future<T> FutureGenerator<T>();

bool isAppActive(
  AppLifecycleState state,
) {
  switch (state) {
    case AppLifecycleState.resumed:
      return true;

    case AppLifecycleState.inactive:
    case AppLifecycleState.paused:
    default:
      return false;
  }
}

Widget buildLogo({
  height: 80.0,
}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.only(
        top: 80.0,
      ),
      child: Container(
        height: height,
        child: Stack(
          children: <Widget>[
            Opacity(
              opacity: 0.7,
              child: Image.asset('assets/flutter_tracker-logo-shadow.png'),
            ),
            Image.asset('assets/flutter_tracker-logo.png'),
          ],
        ),
      ),
    ),
  );
}

Future<T> retryFuture<T>(
  int retries,
  FutureGenerator aFuture,
) async {
  try {
    return await aFuture();
  } catch (e) {
    if (retries > 1) {
      return retryFuture((retries - 1), aFuture);
    }

    rethrow;
  }
}

void closeKeyboard(
  BuildContext context,
) {
  FocusScope.of(context).unfocus();
}
