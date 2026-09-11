import 'image_engine_data_source.dart';
import 'raster_image_engine_data_source.dart';

ImageEngineDataSource createPlatformImageEngineDataSource() {
  return RasterImageEngineDataSource();
}
