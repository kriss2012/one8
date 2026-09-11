import 'image_engine_data_source.dart';
import 'image_engine_data_source_factory_stub.dart'
    if (dart.library.io) 'image_engine_data_source_factory_io.dart';

ImageEngineDataSource createImageEngineDataSource() {
  return createPlatformImageEngineDataSource();
}
