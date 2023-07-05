import 'dart:io';
import 'dart:typed_data';

import 'package:upload_file_oss/upload_file_oss.dart';

void main(List<String> args) async {
  final UploadFileOSSClient client = UploadFileOSSClient(
    UploadFileOSSConfig(
      accessKeyId: '',
      accessKeySecret: '',
      endpoint: 'oss-cn-hangzhou.aliyuncs.com',
      bucket: '',
      fileDomain: '',
    ),
  );

  ///local file path
  final String localFilePath = '/Users/xxx.png';

  ///Object folder/fileName
  final String savePath = 'avatar/xxx1.jpg';

  /// read local file content as Uint8List
  final File file = File(localFilePath);
  final Uint8List fileContent = await file.readAsBytes();

  ///upload OSS
  Map res = await client.putObject(
    savePath,
    fileContent,
    overwrite: true,
  );
  print(res);
}
