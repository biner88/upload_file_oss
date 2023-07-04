library upload_file_oss;

///Config
class UploadFileOSSConfig {
  ///accessKeyId
  String accessKeyId;
  String accessKeySecret;
  String endpoint;
  String bucket;
  String object;
  UploadFileOSSConfig({
    required this.accessKeyId,
    required this.accessKeySecret,
    required this.endpoint,
    required this.bucket,
    required this.object,
  });
}
