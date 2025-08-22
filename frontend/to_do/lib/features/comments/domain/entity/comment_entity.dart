import 'package:to_do/features/auth/domain/entities/user_entity.dart';

class CommentEntity {
  final String id;
  final UserEntity user;
  final String taskId;
  final String content;
  final DateTime createdAt;
  final String? parentId; 
  final List<CommentEntity> replies; // các comment trả lời

  CommentEntity({
    required this.id,
    required this.taskId,
    required this.user,
    required this.content,
    required this.createdAt,
    this.parentId,
    this.replies = const [], // mặc định rỗng
  });

  factory CommentEntity.fromJson(Map<String, dynamic> json) {
    return CommentEntity(
      parentId: json['parentId'] ?? '',
      replies: (json['replies'] as List<dynamic>?)
              ?.map((item) =>
                  CommentEntity.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      id: json['id'],
      taskId: json['taskId'],
      content: json['content'],
      user: UserEntity.fromJson(json['user'] as Map<String, dynamic>),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(), // hoặc để null nếu field này nullable,
    );
  }

    /// Debug-friendly string output
  @override
  String toString() {
    return 'CommentEntity('
        'id: $id, '
        'taskId: $taskId, '
        'user: ${user}, '
        'content: $content, '
        'createdAt: $createdAt, '
        'replies: ${replies.length}, '
        'parentId: ${parentId}'; 
        
  }
  static List<CommentEntity> mockComments = data.map(
    (e) {
      return CommentEntity.fromJson(e);
    },
  ).toList();
}

final data = [
  {
    "id": "0c2b5542-2e65-4259-aee6-169a850113ac",
    "content": "hi",
    "taskId": "0456c638-29ff-4973-942d-1a4b65430438",
    "user": {
      "id": "5e53a3d9-369e-46b4-9562-2c627c4ef350",
      "name": "Vo Ngoc Bao Tran",
      "birthday": "2004-05-26T17:00:00.000Z",
      "avatar":
          "https://res.cloudinary.com/dehehzz2t/image/upload/v1753894194/z6857734984011_84ebccd962262e15afe8906658c0face_aqv6oq.jpg",
      "email": "22521508@gm.uit.edu.vn"
    },
    "createdAt": "2025-08-11T07:37:08.272Z",
    "replies": [
      {
        "id": "12464bbe-fe0f-4e2f-8708-694e10812b94",
        "content": "omgnice",
        "taskId": "0456c638-29ff-4973-942d-1a4b65430438",
        "user": {
          "id": "5e53a3d9-369e-46b4-9562-2c627c4ef350",
          "name": "Vo Ngoc Bao Tran",
          "birthday": "2004-05-26T17:00:00.000Z",
          "avatar":
              "https://res.cloudinary.com/dehehzz2t/image/upload/v1753894194/z6857734984011_84ebccd962262e15afe8906658c0face_aqv6oq.jpg",
          "email": "22521508@gm.uit.edu.vn"
        }
      }
    ]
  },
  {
    "id": "641477fa-e06b-4252-b9a8-2f64e5aca657",
    "content": "hehe",
    "taskId": "0456c638-29ff-4973-942d-1a4b65430438",
    "user": {
      "id": "5e53a3d9-369e-46b4-9562-2c627c4ef350",
      "name": "Vo Ngoc Bao Tran",
      "birthday": "2004-05-26T17:00:00.000Z",
      "avatar":
          "https://res.cloudinary.com/dehehzz2t/image/upload/v1753894194/z6857734984011_84ebccd962262e15afe8906658c0face_aqv6oq.jpg",
      "email": "22521508@gm.uit.edu.vn"
    },
    "createdAt": "2025-08-11T09:56:17.429Z",
    "replies": [
      {
        "id": "50af58c3-59e4-44ae-b979-d4093bf7500d",
        "content": "omgnice",
        "taskId": "0456c638-29ff-4973-942d-1a4b65430438",
        "user": {
          "id": "5e53a3d9-369e-46b4-9562-2c627c4ef350",
          "name": "Vo Ngoc Bao Tran",
          "birthday": "2004-05-26T17:00:00.000Z",
          "avatar":
              "https://res.cloudinary.com/dehehzz2t/image/upload/v1753894194/z6857734984011_84ebccd962262e15afe8906658c0face_aqv6oq.jpg",
          "email": "22521508@gm.uit.edu.vn"
        }
      }
    ]
  },
  {
    "id": "843d96a9-6580-4ad5-a9e6-243566b7a214",
    "content": "ke ban",
    "taskId": "0456c638-29ff-4973-942d-1a4b65430438",
    "user": {
      "id": "5e53a3d9-369e-46b4-9562-2c627c4ef350",
      "name": "Vo Ngoc Bao Tran",
      "birthday": "2004-05-26T17:00:00.000Z",
      "avatar":
          "https://res.cloudinary.com/dehehzz2t/image/upload/v1753894194/z6857734984011_84ebccd962262e15afe8906658c0face_aqv6oq.jpg",
      "email": "22521508@gm.uit.edu.vn"
    },
    "createdAt": "2025-08-11T09:51:40.738Z",
    "replies": []
  },
  {
    "id": "e9c99f7f-59ee-4c5b-9319-4c9759193d73",
    "content": "toi muon gap ban",
    "taskId": "0456c638-29ff-4973-942d-1a4b65430438",
    "user": {
      "id": "5e53a3d9-369e-46b4-9562-2c627c4ef350",
      "name": "Vo Ngoc Bao Tran",
      "birthday": "2004-05-26T17:00:00.000Z",
      "avatar":
          "https://res.cloudinary.com/dehehzz2t/image/upload/v1753894194/z6857734984011_84ebccd962262e15afe8906658c0face_aqv6oq.jpg",
      "email": "22521508@gm.uit.edu.vn"
    },
    "createdAt": "2025-08-11T09:53:33.249Z",
    "replies": []
  },
  {
    "id": "12464bbe-fe0f-4e2f-8708-694e10812b94",
    "content": "omgnice",
    "taskId": "0456c638-29ff-4973-942d-1a4b65430438",
    "user": {
      "id": "5e53a3d9-369e-46b4-9562-2c627c4ef350",
      "name": "Vo Ngoc Bao Tran",
      "birthday": "2004-05-26T17:00:00.000Z",
      "avatar":
          "https://res.cloudinary.com/dehehzz2t/image/upload/v1753894194/z6857734984011_84ebccd962262e15afe8906658c0face_aqv6oq.jpg",
      "email": "22521508@gm.uit.edu.vn"
    },
    "createdAt": "2025-08-11T07:37:17.845Z",
    "replies": []
  },
  {
    "id": "8f8b941e-6e81-4a79-b636-6dea3dfc80b9",
    "content": "toi bun qua",
    "taskId": "0456c638-29ff-4973-942d-1a4b65430438",
    "user": {
      "id": "5e53a3d9-369e-46b4-9562-2c627c4ef350",
      "name": "Vo Ngoc Bao Tran",
      "birthday": "2004-05-26T17:00:00.000Z",
      "avatar":
          "https://res.cloudinary.com/dehehzz2t/image/upload/v1753894194/z6857734984011_84ebccd962262e15afe8906658c0face_aqv6oq.jpg",
      "email": "22521508@gm.uit.edu.vn"
    },
    "createdAt": "2025-08-11T09:50:07.901Z",
    "replies": []
  },
  {
    "id": "c36599ac-4079-4935-937b-638da687bb46",
    "content": "toi nho ban",
    "taskId": "0456c638-29ff-4973-942d-1a4b65430438",
    "user": {
      "id": "5e53a3d9-369e-46b4-9562-2c627c4ef350",
      "name": "Vo Ngoc Bao Tran",
      "birthday": "2004-05-26T17:00:00.000Z",
      "avatar":
          "https://res.cloudinary.com/dehehzz2t/image/upload/v1753894194/z6857734984011_84ebccd962262e15afe8906658c0face_aqv6oq.jpg",
      "email": "22521508@gm.uit.edu.vn"
    },
    "createdAt": "2025-08-11T08:57:01.505Z",
    "replies": []
  },
  {
    "id": "8cb8a460-dc5d-4e3d-82b6-c39c6808b4aa",
    "content": "cố lên",
    "taskId": "0456c638-29ff-4973-942d-1a4b65430438",
    "user": {
      "id": "5e53a3d9-369e-46b4-9562-2c627c4ef350",
      "name": "Vo Ngoc Bao Tran",
      "birthday": "2004-05-26T17:00:00.000Z",
      "avatar":
          "https://res.cloudinary.com/dehehzz2t/image/upload/v1753894194/z6857734984011_84ebccd962262e15afe8906658c0face_aqv6oq.jpg",
      "email": "22521508@gm.uit.edu.vn"
    },
    "createdAt": "2025-08-11T09:55:16.554Z",
    "replies": []
  },
  {
    "id": "50af58c3-59e4-44ae-b979-d4093bf7500d",
    "content": "omgnice",
    "taskId": "0456c638-29ff-4973-942d-1a4b65430438",
    "user": {
      "id": "5e53a3d9-369e-46b4-9562-2c627c4ef350",
      "name": "Vo Ngoc Bao Tran",
      "birthday": "2004-05-26T17:00:00.000Z",
      "avatar":
          "https://res.cloudinary.com/dehehzz2t/image/upload/v1753894194/z6857734984011_84ebccd962262e15afe8906658c0face_aqv6oq.jpg",
      "email": "22521508@gm.uit.edu.vn"
    },
    "createdAt": "2025-08-11T09:57:28.706Z",
    "replies": []
  }
];
