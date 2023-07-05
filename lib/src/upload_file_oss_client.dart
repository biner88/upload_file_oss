import 'dart:typed_data';

import 'package:mime/mime.dart';

import '../upload_file_oss.dart';
import 'dart:convert';
import 'dart:io';

// import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

///UploadFileOSSClient
class UploadFileOSSClient {
  late UploadFileOSSConfig config;

  UploadFileOSSClient(UploadFileOSSConfig _config) {
    config = _config;
  }

  ///putObject
  ///https://help.aliyun.com/document_detail/31978.html
  Future<Map> putObject(
    String savePath,
    Uint8List fileContent, {
    ///是否覆盖已存在文件，默认不覆盖
    bool overwrite = false,
  }) async {
    final url = 'https://${config.bucket}.${config.endpoint}/$savePath';
    final timestamp = _requestTime();
    final contentMd5 = base64Encode(md5.convert(fileContent).bytes);
    final contentType = lookupMimeType(savePath) ?? "application/octet-stream";
    final Map<String, String> securityHeaders = {
      'x-oss-forbid-overwrite': overwrite ? 'false' : 'true',
    };
    final canonicalizedOSSHeaders =
        _buildCanonicalizedOSSHander(securityHeaders);
    final stringToSign = [
      'PUT',
      contentMd5,
      contentType,
      timestamp,
      canonicalizedOSSHeaders,
      '/${config.bucket}/$savePath',
    ].join('\n');

    final signature = base64Encode(
        Hmac(sha1, utf8.encode(config.accessKeySecret))
            .convert(utf8.encode(stringToSign))
            .bytes);
    final Map<String, String> headers = <String, String>{
      HttpHeaders.contentLengthHeader: fileContent.lengthInBytes.toString(),
      HttpHeaders.contentTypeHeader: contentType,
      HttpHeaders.dateHeader: timestamp,
      HttpHeaders.authorizationHeader: 'OSS ${config.accessKeyId}:$signature',
      HttpHeaders.contentMD5Header: contentMd5,
    };
    headers.addAll(securityHeaders);
    //PutBucket
    //https://help.aliyun.com/document_detail/31959.htm
    final response = await http.put(
      Uri.parse(url),
      headers: headers,
      body: fileContent,
    );
    if (response.statusCode == 200) {
      return {
        'statusCode': response.statusCode,
        'size': fileContent.lengthInBytes,
        'downloadUrl': url,
        'requestId': response.headers['x-oss-request-id'],
        'url': (config.fileDomain != null && config.fileDomain != '')
            ? (config.fileDomain! + '/' + savePath)
            : '',
      };
    } else {
      return {
        'statusCode': response.statusCode,
        'size': 0,
        'downloadUrl': '',
        'requestId': response.headers['x-oss-request-id'],
        'url': ''
      };
    }
  }

  ///buildCanonicalizedOSSHander
  String _buildCanonicalizedOSSHander(Map<String, String>? headers) {
    final securityHeaders = {
      if (headers != null) ...headers,
    };
    final sortedHeaders = _sortByLowerKey(securityHeaders);
    return sortedHeaders
        .where((e) => e.key.startsWith('x-oss-'))
        .map((e) => '${e.key}:${e.value}')
        .join('\n');
  }

  ///sortByLowerKey
  List<MapEntry<String, String>> _sortByLowerKey(Map<String, String> map) {
    final lowerPairs = map.entries.map(
        (e) => MapEntry(e.key.toLowerCase().trim(), e.value.toString().trim()));
    return lowerPairs.toList()..sort((a, b) => a.key.compareTo(b.key));
  }

  ///requestTime
  String _requestTime() {
    initializeDateFormatting('en', null);
    final DateTime now = DateTime.now();
    final String string =
        DateFormat('EEE, dd MMM yyyy HH:mm:ss', 'en_ISO').format(now.toUtc());
    return '$string GMT';
  }
}
