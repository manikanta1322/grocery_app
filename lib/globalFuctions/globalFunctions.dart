// ignore_for_file: file_names


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grocery_app/constants/constants.dart';
import 'package:sizer/sizer.dart';
import 'package:get_storage/get_storage.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

final storage = GetStorage();

class Tgg {
  static createAlert(
      BuildContext context, String error, String errormsg) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(error),
            content: Text(errormsg),
          );
        });
  }

  static willpopAlert(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure you want to exit?'),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    navigateBack(context);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: cPrimaryColor),
                        borderRadius: BorderRadius.circular(6)),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: cPrimaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 30),
                GestureDetector(
                  onTap: () {
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                  },
                  child: Container(
                    alignment: Alignment.center,
                    padding:
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(6)),
                    child: const Text(
                      'Ok',
                      style: TextStyle(color: cWhite),
                    ),
                  ),
                )
              ],
            )
          ],
        );
      },
    );
  }

  static navigateTo(BuildContext context, page) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  static navigateBack(BuildContext context) async {
    Navigator.pop(context);
  }

  static showScaffoldSnackBar(BuildContext context, message) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  static showAwesomeSnackbar({
    required BuildContext context,
    required String title,
    required String message,
    required ContentType contentType,
  }) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: contentType,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static closeApp() {
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

  static errorHandler(BuildContext context, errorRes) async {
    switch (errorRes) {
      case 301:
        showAwesomeSnackbar(
          context: context,
          title: 'Error!',
          message: 'Moved Permanently',
          contentType: ContentType.failure,
        );
        break;
      case 302:
        showAwesomeSnackbar(
          context: context,
          title: 'Error!',
          message: 'Found',
          contentType: ContentType.failure,
        );
        break;
      case 401:
        showAwesomeSnackbar(
          context: context,
          title: 'Unauthorized!',
          message: 'You are not authorized to access this resource.',
          contentType: ContentType.warning,
        );
        break;
      case 403:
        showAwesomeSnackbar(
          context: context,
          title: 'Forbidden!',
          message: 'Access to this resource is denied.',
          contentType: ContentType.warning,
        );
        break;
      case 404:
        showAwesomeSnackbar(
          context: context,
          title: 'Not Found!',
          message: 'The requested resource could not be found.',
          contentType: ContentType.failure,
        );
        break;
      case 500:
        showAwesomeSnackbar(
          context: context,
          title: 'Server Error!',
          message: 'Internal Server Error occurred.',
          contentType: ContentType.failure,
        );
        break;
      case 502:
        showAwesomeSnackbar(
          context: context,
          title: 'Bad Gateway!',
          message: 'Received an invalid response from the server.',
          contentType: ContentType.failure,
        );
        break;
      case 503:
        showAwesomeSnackbar(
          context: context,
          title: 'Service Unavailable!',
          message: 'The server is temporarily unavailable.',
          contentType: ContentType.warning,
        );
        break;
      case 504:
        showAwesomeSnackbar(
          context: context,
          title: 'Gateway Timeout!',
          message: 'The server did not respond in time.',
          contentType: ContentType.failure,
        );
        break;
      default:
        showAwesomeSnackbar(
          context: context,
          title: 'Oops!',
          message: 'Something went wrong...',
          contentType: ContentType.failure,
        );
    }
  }

  static Future<bool> showExitConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(height: 12.0),
                    Text(
                      "Are you sure you want to exit the app..?",
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 24.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            navigateBack(context);
                          },
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.04,
                            width: MediaQuery.of(context).size.width * 0.2,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: Colors.green,
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.0),
                        GestureDetector(
                          onTap: () {
                            closeApp();
                          },
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.04,
                            width: MediaQuery.of(context).size.width * 0.2,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: cPrimaryColor,
                            ),
                            child: Text(
                              'Exit',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ) ??
        false;
  }

  static forceNavigateTo(BuildContext context, page) async {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (BuildContext context) => page));
  }

  /// **Gradient Animated Loading Text**
  static Widget loadingTextAnimation() {
    return LoadingTextAnimation();
  }
}

class LoadingTextAnimation extends StatefulWidget {
  @override
  _LoadingTextAnimationState createState() => _LoadingTextAnimationState();
}

class _LoadingTextAnimationState extends State<LoadingTextAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: [
            Colors.blue,
            Colors.purple
          ], // Customize your gradient colors
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds),
        child: const Text(
          "Loading...",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white, // This is necessary for ShaderMask to work
          ),
        ),
      ),
    );
  }
}
