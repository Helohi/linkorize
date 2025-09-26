import 'package:flutter/material.dart';
import 'package:linkorize/screens/categories_screen.dart';
import 'package:provider/provider.dart';

import 'managers/shared_text_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SharedTextManager>(
      create: (context) => SharedTextManager(),
      builder: (context, child) => MaterialApp(
        themeMode: ThemeMode.light,
        builder: (context, child) {
          assert(child != null, "Material App got null child!");
          return OrientationBuilder(
            builder: (context, orientation) =>
                orientation == Orientation.portrait
                    ? child!
                    : Center(
                        child: Container(
                          color: Colors.grey,
                          width: MediaQuery.sizeOf(context).height * 5 / 6,
                          child: child!,
                        ),
                      ),
          );
        },
        home: CategoriesScreen(),
      ),
    );
  }
}
