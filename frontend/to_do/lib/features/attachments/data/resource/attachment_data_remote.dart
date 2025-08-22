import 'package:file_picker/file_picker.dart';
import 'package:get/get_connect/http/src/multipart/form_data.dart';
//import 'package:get/get_connect/http/src/multipart/multipart_file.dart';
import 'package:to_do/core/networks/dio_client.dart';
import 'package:to_do/features/attachments/data/models/attachment_model.dart';
import 'package:dio/dio.dart' as dio; // alias để tránh trùng
abstract class AttachmentDataRemote {
  Future<List<AttachmentModel>> getFilesByTask(String taskId); 
  // ignore: non_constant_identifier_names
  Future<List<AttachmentModel>> uploadFile(String taskId, FilePickerResult result, [bool? is_main]); 
}

class AttachmentDataRemoteImpl extends AttachmentDataRemote {
  dio.Dio dioClient; 
  AttachmentDataRemoteImpl({required this.dioClient}); 

  @override    
  Future<List<AttachmentModel>> getFilesByTask(String taskId, ) async {
    try {
      final response = await dioClient.get('/tasks/$taskId/attachments'); 

      if (response.statusCode == 200) {
        final dataRaw = response.data as Map<String,dynamic> ; 
        final data = dataRaw['data'] as List; 



        return data.map((item) => AttachmentModel.fromJson(item)).toList(); 
      }
      else {
        throw Exception('Fetched File failure');
      }
    }
    catch(error) {
      throw Exception(error); 
    }
  }

@override
Future<List<AttachmentModel>> uploadFile(String taskId, FilePickerResult result, [bool? is_main]) async {
  try {
    List<dio.MultipartFile> files = [];
    for (var file in result.files) {
      files.add(
        await dio.MultipartFile.fromFile(
          file.path!,
          filename: file.name,
        ),
      );
    }

    print('is_main value: $is_main');


    dio.FormData formData = dio.FormData.fromMap({
      'files': files,
      'is_main': is_main ?? false
    });

    final response = await dioClient.post(
      '/tasks/$taskId/attachments',
      data: formData,
    );

    final dataRaw = response.data; 
    final data = dataRaw['data'] as List; 

    return data.map((item) => AttachmentModel.fromJson(item)).toList(); 
  } catch (error, stackTrace) {
    print('[UPLOAD ERROR] $error');
    print(stackTrace);
    rethrow;
  }
}


}