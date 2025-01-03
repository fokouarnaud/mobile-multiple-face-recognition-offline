import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutterface/ui/box_selection/box_selection_page.dart';
import 'package:flutterface/ui/home/home_page.dart';

class Routes {
  static FluroRouter router = FluroRouter();

  static String root = '/';
  static String home = '/home/:boxId/:title';

  static void configureRoutes() {
    router.define(
      root,
      handler: Handler(
        handlerFunc: (context, params) => const BoxSelectionPage(),
      ),
    );

    router.define(
      home,
      handler: Handler(
        handlerFunc: (context, params) => HomePage(
          boxId: int.parse(params['boxId']![0]),
          title: params['title']![0],
        ),
      ),
      transitionType: TransitionType.fadeIn,
    );
  }

  static Future<void> navigateToHome(
      BuildContext context, int boxId, String title) async {
    await router.navigateTo(
      context,
      home.replaceAll(':boxId', boxId.toString()).replaceAll(':title', title),
      replace: true,
    );
  }

  static Future<void> navigateToRoot(BuildContext context) async {
    await router.navigateTo(
      context,
      root,
      replace: true,
    );
  }
}
