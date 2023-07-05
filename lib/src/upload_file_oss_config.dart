library upload_file_oss;

///Config
class UploadFileOSSConfig {
  ///您的accessKeyId
  String accessKeyId;

  ///您的accessKeySecret
  String accessKeySecret;

  ///您的存储域名地址，例如：oss-cn-hangzhou.aliyuncs.com
  ///https://help.aliyun.com/document_detail/31837.html
  String? endpoint;

  ///你的bucket名称
  String bucket;

  ///自定义域名，不要加最后的/，没有域名请去掉该参数或保持空字符
  String? fileDomain;
  UploadFileOSSConfig({
    required this.accessKeyId,
    required this.accessKeySecret,
    required this.bucket,
    this.endpoint = 'oss-cn-hangzhou.aliyuncs.com',
    this.fileDomain = '',
  });
}
