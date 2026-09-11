import 'package:objectbox/objectbox.dart';

@Entity()
class CompressionHistoryModel {
  @Id()
  int id;

  @Index()
  final String originalPath;

  final String outputPath;
  final String outputFileName;

  final int originalBytes;
  final int compressedBytes;
  
  @Index(type: IndexType.value)
  final int timestamp; 
  
  final String format;

  CompressionHistoryModel({
    this.id = 0,
    required this.originalPath,
    required this.outputPath,
    required this.outputFileName,
    required this.originalBytes,
    required this.compressedBytes,
    required this.timestamp,
    required this.format,
  });
}
