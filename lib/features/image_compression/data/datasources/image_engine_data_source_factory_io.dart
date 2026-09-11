import 'image_engine_data_source.dart';
import 'raster_image_engine_data_source.dart';
import 'rust_ffi_image_engine_data_source.dart';

ImageEngineDataSource createPlatformImageEngineDataSource() {
  if (RustFfiImageEngineDataSource.isSupportedPlatform()) {
    return RustFfiImageEngineDataSource(
      fallbackDataSource: RasterImageEngineDataSource(),
    );
  }

  return RasterImageEngineDataSource();
}
