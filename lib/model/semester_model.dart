class SemesterModel {
  int? count;
  dynamic next;
  dynamic previous;
  List<Results>? results;

  SemesterModel({this.count, this.next, this.previous, this.results});

  SemesterModel.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    next = json['next'];
    previous = json['previous'];
    if (json['results'] != null) {
      results = <Results>[];
      json['results'].forEach((v) {
        results!.add(Results.fromJson(v));
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
  String? semesterdetails;
  String? name;
  String? nameAr;
  String? nameEn;
  bool? onlyExams;
  String? createdAt;
  String? updatedAt;
  int? myOrder;
  bool? notActive;
  int? createdBy;
  int? updatedBy;

  Results(
      {this.id,
      this.semesterdetails,
      this.name,
      this.nameAr,
      this.nameEn,
      this.onlyExams,
      this.createdAt,
      this.updatedAt,
      this.myOrder,
      this.notActive,
      this.createdBy,
      this.updatedBy});

  Results.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    semesterdetails = json['Semesterdetails'];
    name = json['name'];
    nameAr = json['name_ar'];
    nameEn = json['name_en'];
    onlyExams = json['only_exams'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    myOrder = json['my_order'];
    notActive = json['not_active'];
    createdBy = json['created_by'];
    updatedBy = json['updated_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['Semesterdetails'] = semesterdetails;
    data['name'] = name;
    data['name_ar'] = nameAr;
    data['name_en'] = nameEn;
    data['only_exams'] = onlyExams;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['my_order'] = myOrder;
    data['not_active'] = notActive;
    data['created_by'] = createdBy;
    data['updated_by'] = updatedBy;
    return data;
  }
}
