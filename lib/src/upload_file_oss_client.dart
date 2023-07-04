import 'dart:typed_data';

import '../upload_file_oss.dart';
import 'dart:convert';
import 'dart:io';

// import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

///Config
class UploadFileOSSClient {
  Future<Map> upload(UploadFileOSSConfig config, Uint8List fileContent) async {
    final url = 'https://${config.bucket}.${config.endpoint}/${config.object}';
    final timestamp = _requestTime();
    final contentMd5 = base64Encode(md5.convert(fileContent).bytes);
    final stringToSign =
        'PUT\n$contentMd5\nimage/jpeg\n$timestamp\n/${config.bucket}/${config.object}';
    final signature = base64Encode(
        Hmac(sha1, utf8.encode(config.accessKeySecret))
            .convert(utf8.encode(stringToSign))
            .bytes);
    final headers = <String, String>{
      HttpHeaders.contentLengthHeader: fileContent.length.toString(),
      HttpHeaders.contentTypeHeader:
          'image/jpeg', //lookupMimeType(file.path) ?? "application/octet-stream",
      HttpHeaders.dateHeader: timestamp,
      HttpHeaders.authorizationHeader: 'OSS ${config.accessKeyId}:$signature',
      'Content-MD5': contentMd5,
    };
    final response = await http.put(
      Uri.parse(url),
      headers: headers,
      body: fileContent,
    );
    print(response.headers);
    if (response.statusCode == 200) {
      print('文件上传成功！');
    } else {
      print('文件上传失败：HTTP Code ${response.statusCode}');
    }
    return {};
  }

  ///
  String _requestTime() {
    initializeDateFormatting('en', null);
    final DateTime now = DateTime.now();
    final String string =
        DateFormat('EEE, dd MMM yyyy HH:mm:ss', 'en_ISO').format(now.toUtc());
    return '$string GMT';
  }
}
