import 'package:af/application/grid_model.dart';
import 'package:af/application/hardware_singleton.dart';
import 'package:af/application/states_singleton.dart';
import 'package:flutter/material.dart';
import '../presentation/grid_builder.dart';
import 'package:provider/provider.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (BuildContext newContext) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                  create: (context) => GridModel.default2020()),
              ChangeNotifierProvider(create: (context) => StatesSingleton()),
              ChangeNotifierProvider(create: (context) => HardwareSingleton())
            ],
            builder: (context, child) {
              return GridWidget();
            },
          );
        });
      case '/settings':
        return MaterialPageRoute(builder: (_) {
          return Container();
        });
      default:
        {
          return MaterialPageRoute(builder: (_) {
            return const Center(
              child: Text('someone fucked up, probably Ed..'),
            );
          });
        }
    }
  }
}
