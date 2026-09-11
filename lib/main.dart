import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'features/history/application/history_dependencies.dart';
import 'features/image_compression/application/image_compression_dependencies.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final historyDependencies = await HistoryDependencies.create();
  final dependencies = ImageCompressionDependencies.create(
    historyRepository: historyDependencies.repository,
  );
  runApp(One8App(
    dependencies: dependencies,
  ));
}

