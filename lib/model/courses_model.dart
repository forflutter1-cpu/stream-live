class CoursesModel {
  int? count;
  dynamic next;
  dynamic previous;
  List<Results>? results;

  CoursesModel({this.count, this.next, this.previous, this.results});

  CoursesModel.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    next = json['next'];
    previous = json['previous'];
    if (json['results'] != null) {
      results = <Results>[];
      json['results'].forEach((v) {
        results!.add( Results.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['count'] = count;
    data['next'] = next;
    data['previous'] = previous;
    if (results != null) {
      data['results'] = results!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Results {
  int? id;
  String? name;
  String? nameAr;
  String? nameEn;
  int? level;
  int? semester;
  String? image;
  String? createdAt;
  String? updatedAt;
  int? createdBy;
  int? updatedBy;
  int? teacher;
  int? myOrder;
  bool? notActive;
  List<Units>? units;

  Results(
      {this.id,
      this.name,
      this.nameAr,
      this.nameEn,
      this.level,
      this.semester,
      this.image,
      this.createdAt,
      this.updatedAt,
      this.createdBy,
      this.updatedBy,
      this.teacher,
      this.myOrder,
      this.notActive,
      this.units,
     });

  Results.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    nameAr = json['name_ar'];
    nameEn = json['name_en'];
    level = json['level'];
    semester = json['semester'];
    image = json['image'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    createdBy = json['created_by'];
    updatedBy = json['updated_by'];
    teacher = json['teacher'];
    myOrder = json['my_order'];
    notActive = json['not_active'];
    if (json['units'] != null) {
      units = <Units>[];
      json['units'].forEach((v) {
        units!.add(new Units.fromJson(v));
      });
    }
    
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['name'] = name;
    data['name_ar'] = nameAr;
    data['name_en'] = nameEn;
    data['level'] = level;
    data['semester'] = semester;
    data['image'] = image;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['created_by'] = createdBy;
    data['updated_by'] = updatedBy;
    data['teacher'] = teacher;
    data['my_order'] = myOrder;
    data['not_active'] = notActive;
    if (units != null) {
      data['units'] = units!.map((v) => v.toJson()).toList();
    }
    
    return data;
  }
}

class Units {
  int? id;
  String? name;
  String? nameAr;
  String? nameEn;
  int? course;
  String? createdAt;
  String? updatedAt;
  int? createdBy;
  int? updatedBy;
  int? myOrder;
  bool? notActive;
  List? exams;
  List<Attachments>? attachments;
  // List<Null>? examples;
  List<Classes>? classes;

  Units(
      {this.id,
      this.name,
      this.nameAr,
      this.nameEn,
      this.course,
      this.createdAt,
      this.updatedAt,
      this.createdBy,
      this.updatedBy,
      this.myOrder,
      this.notActive,
      this.exams,
      this.attachments,
      // this.examples,
      this.classes});

  Units.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    nameAr = json['name_ar'];
    nameEn = json['name_en'];
    course = json['course'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    createdBy = json['created_by'];
    updatedBy = json['updated_by'];
    myOrder = json['my_order'];
    notActive = json['not_active'];
    // if (json['exams'] != null) {
    //   exams = <Null>[];
    //   json['exams'].forEach((v) {
    //     exams!.add(new Null.fromJson(v));
    //   });
    // }
    if (json['attachments'] != null) {
      attachments = <Attachments>[];
      json['attachments'].forEach((v) {
        attachments!.add(new Attachments.fromJson(v));
      });
    }
    // if (json['examples'] != null) {
    //   examples = <Null>[];
    //   json['examples'].forEach((v) {
    //     examples!.add(new Null.fromJson(v));
    //   });
    // }
    if (json['classes'] != null) {
      classes = <Classes>[];
      json['classes'].forEach((v) {
        classes!.add(new Classes.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['name'] = name;
    data['name_ar'] = nameAr;
    data['name_en'] = nameEn;
    data['course'] = course;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['created_by'] = createdBy;
    data['updated_by'] = updatedBy;
    data['my_order'] = myOrder;
    data['not_active'] = notActive;
    // if (exams != null) {
    //   data['exams'] = exams!.map((v) => v.toJson()).toList();
    // }
    if (attachments != null) {
      data['attachments'] = attachments!.map((v) => v.toJson()).toList();
    }
    // if (examples != null) {
    //   data['examples'] = examples!.map((v) => v.toJson()).toList();
    // }
    if (classes != null) {
      data['classes'] = classes!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Attachments {
  int? id;
  String? name;
  String? nameAr;
  String? nameEn;
  String? file;
  String? createdAt;
  String? updatedAt;
  int? myOrder;
  bool? notActive;
  int? createdBy;
  int? updatedBy;

  Attachments(
      {this.id,
      this.name,
      this.nameAr,
      this.nameEn,
      this.file,
      this.createdAt,
      this.updatedAt,
      this.myOrder,
      this.notActive,
      this.createdBy,
      this.updatedBy});

  Attachments.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    nameAr = json['name_ar'];
    nameEn = json['name_en'];
    file = json['file'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    myOrder = json['my_order'];
    notActive = json['not_active'];
    createdBy = json['created_by'];
    updatedBy = json['updated_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['name'] = name;
    data['name_ar'] = nameAr;
    data['name_en'] = nameEn;
    data['file'] = file;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['my_order'] = myOrder;
    data['not_active'] = notActive;
    data['created_by'] = createdBy;
    data['updated_by'] = updatedBy;
    return data;
  }
}

class Classes {
  int? id;
  bool? isWatched;
  String? downloadLink;
  List<Attachments>? attachments;
  List<int>? exams;
  String? name;
  String? nameAr;
  String? nameEn;
  dynamic image;
  String? lessonLink;
  String? lessonLinkType;
  String? backupLink;
  String? backupLinkType;
  String? downloadLink2;
  dynamic duration;
  String? createdAt;
  String? updatedAt;
  dynamic videoFile;
  int? myOrder;
  bool? notActive;
  int? unit;
  int? explanation;
  int? createdBy;
  int? updatedBy;

  Classes(
      {this.id,
      this.isWatched,
      this.downloadLink,
      this.attachments,
      this.exams,
      this.name,
      this.nameAr,
      this.nameEn,
      this.image,
      this.lessonLink,
      this.lessonLinkType,
      this.backupLink,
      this.backupLinkType,
      this.downloadLink2,
      this.duration,
      this.createdAt,
      this.updatedAt,
      this.videoFile,
      this.myOrder,
      this.notActive,
      this.unit,
      this.explanation,
      this.createdBy,
      this.updatedBy});

  Classes.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    isWatched = json['is_watched'];
    downloadLink = json['download_link'];
    if (json['attachments'] != null) {
      attachments = <Attachments>[];
      json['attachments'].forEach((v) {
        attachments!.add(new Attachments.fromJson(v));
      });
    }
    exams = json['exams'].cast<int>();
    name = json['name'];
    nameAr = json['name_ar'];
    nameEn = json['name_en'];
    image = json['image'];
    lessonLink = json['lesson_link'];
    lessonLinkType = json['lesson_link_type'];
    backupLink = json['backup_link'];
    backupLinkType = json['backup_link_type'];
    downloadLink2 = json['download_link2'];
    duration = json['duration'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    videoFile = json['video_file'];
    myOrder = json['my_order'];
    notActive = json['not_active'];
    unit = json['unit'];
    explanation = json['explanation'];
    createdBy = json['created_by'];
    updatedBy = json['updated_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['is_watched'] = isWatched;
    data['download_link'] = downloadLink;
    if (attachments != null) {
      data['attachments'] = attachments!.map((v) => v.toJson()).toList();
    }
    data['exams'] = exams;
    data['name'] = name;
    data['name_ar'] = nameAr;
    data['name_en'] = nameEn;
    data['image'] = image;
    data['lesson_link'] = lessonLink;
    data['lesson_link_type'] = lessonLinkType;
    data['backup_link'] = backupLink;
    data['backup_link_type'] = backupLinkType;
    data['download_link2'] = downloadLink2;
    data['duration'] = duration;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['video_file'] = videoFile;
    data['my_order'] = myOrder;
    data['not_active'] = notActive;
    data['unit'] = unit;
    data['explanation'] = explanation;
    data['created_by'] = createdBy;
    data['updated_by'] = updatedBy;
    return data;
  }
}
