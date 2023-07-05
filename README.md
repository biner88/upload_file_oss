# upload_file_oss

[![Pub](https://img.shields.io/pub/v/upload_file_oss.svg)](https://pub.dev/packages/upload_file_oss)

一个简单上传文件到阿里云对象存储OSS的库。
仅支持小文件上传。

## 安装

[pub.dev Install](https://pub.dev/packages/mysql_utils/upload_file_oss)

引入文件

```dart
import 'package:upload_file_oss/upload_file_oss.dart';
```

## 使用

详细见
example/lib/main.dart

```dart
 final UploadFileOSSClient client = UploadFileOSSClient(
    UploadFileOSSConfig(
      accessKeyId: '',
      accessKeySecret: '',
      endpoint: 'oss-cn-hangzhou.aliyuncs.com',
      bucket: '',
      fileDomain: '',
    ),
  );

  ///本地文件路径
  final String localFilePath = '/Users/xx.png';

  ///Object 存在OSS上的文件路径
  final String savePath = 'avatar/me.jpg';

  ///读取本地的文件，并转换为Uint8List
  final File file = File(localFilePath);
  final Uint8List fileContent = await file.readAsBytes();

  ///执行上传到 OSS
  Map res = await client.putObject(
    savePath,
    fileContent,
    overwrite: false,
  );
  print(res);
```

## 上传返回

上传成功返回

```json
  {
    "statusCode": 200, 
    "size": 3506, 
    "downloadUrl": "https://yourbucket.oss-cn-hangzhou.aliyuncs.com/avatar/me.jpg", 
    "url": "https://yourfiledomain/avatar/me.jpg",
  }
```

上传失败返回

```json
  {
    "statusCode": 4xx, 
    "size": 0, 
    "downloadUrl": "", 
    "url": "",
  }
```
