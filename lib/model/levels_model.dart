class LevelsModel {
  late int? count;
  late dynamic next;
  late dynamic previous;
  late List<Results>? results;

  LevelsModel({this.count, this.next, this.previous, this.results});

  LevelsModel.fromJson(Map<String, dynamic> json) {
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
  late int? id;
  late String? leveldetails;
  late String? name;
  late String? nameAr;
  late String? nameEn;
  late String? createdAt;
  late String? updatedAt;
  late bool? notActive;
  late bool? isGeneral;
  late int? myOrder;
  late int? createdBy;
  late int? updatedBy;

  Results(
      {this.id,
      this.leveldetails,
      this.name,
      this.nameAr,
      this.nameEn,
      this.createdAt,
      this.updatedAt,
      this.notActive,
      this.isGeneral,
      this.myOrder,
      this.createdBy,
      this.updatedBy});

  Results.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    leveldetails = json['Leveldetails'];
    name = json['name'];
    nameAr = json['name_ar'];
    nameEn = json['name_en'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    notActive = json['not_active'];
    isGeneral = json['is_general'];
    myOrder = json['my_order'];
    createdBy = json['created_by'];
    updatedBy = json['updated_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['Leveldetails'] = leveldetails;
    data['name'] = name;
    data['name_ar'] = nameAr;
    data['name_en'] = nameEn;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['not_active'] = notActive;
    data['is_general'] = isGeneral;
    data['my_order'] = myOrder;
    data['created_by'] = createdBy;
    data['updated_by'] = updatedBy;
    return data;
  }
}
