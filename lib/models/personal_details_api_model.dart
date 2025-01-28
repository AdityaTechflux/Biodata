class PersonalDetailsApiModel {
  bool? response;
  String? successMsg;
  String? errorMsg;
  Data? data;

  PersonalDetailsApiModel(
      {this.response, this.successMsg, this.errorMsg, this.data});

  PersonalDetailsApiModel.fromJson(Map<String, dynamic> json) {
    response = json["response"];
    successMsg = json["success_msg"];
    errorMsg = json["error_msg"];
    data = json["data"] == null ? null : Data.fromJson(json["data"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["response"] = response;
    _data["success_msg"] = successMsg;
    _data["error_msg"] = errorMsg;
    if (data != null) {
      _data["data"] = data?.toJson();
    }
    return _data;
  }
}

class Data {
  int? biodataId;
  String? matriId;
  Biodata? biodata;

  Data({this.biodataId, this.matriId, this.biodata});

  Data.fromJson(Map<String, dynamic> json) {
    biodataId = json["biodata_id"];
    matriId = json["matri_id"];
    biodata =
        json["biodata"] == null ? null : Biodata.fromJson(json["biodata"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["biodata_id"] = biodataId;
    _data["matri_id"] = matriId;
    if (biodata != null) {
      _data["biodata"] = biodata?.toJson();
    }
    return _data;
  }
}

class Biodata {
  String? matriId;
  String? title;
  String? username;
  String? caste;
  String? subcaste;
  String? birthdate;
  String? birthtime;
  String? birthplace;
  String? height;
  String? bloodGroup;
  String? gothra;
  String? complexion;
  String? updatedAt;
  String? createdAt;
  int? id;

  Biodata(
      {this.matriId,
      this.title,
      this.username,
      this.caste,
      this.subcaste,
      this.birthdate,
      this.birthtime,
      this.birthplace,
      this.height,
      this.bloodGroup,
      this.gothra,
      this.complexion,
      this.updatedAt,
      this.createdAt,
      this.id});

  Biodata.fromJson(Map<String, dynamic> json) {
    matriId = json["matri_id"];
    title = json["title"];
    username = json["username"];
    caste = json["caste"];
    subcaste = json["subcaste"];
    birthdate = json["birthdate"];
    birthtime = json["birthtime"];
    birthplace = json["birthplace"];
    height = json["height"];
    bloodGroup = json["blood_group"];
    gothra = json["gothra"];
    complexion = json["complexion"];
    updatedAt = json["updated_at"];
    createdAt = json["created_at"];
    id = json["id"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["matri_id"] = matriId;
    _data["title"] = title;
    _data["username"] = username;
    _data["caste"] = caste;
    _data["subcaste"] = subcaste;
    _data["birthdate"] = birthdate;
    _data["birthtime"] = birthtime;
    _data["birthplace"] = birthplace;
    _data["height"] = height;
    _data["blood_group"] = bloodGroup;
    _data["gothra"] = gothra;
    _data["complexion"] = complexion;
    _data["updated_at"] = updatedAt;
    _data["created_at"] = createdAt;
    _data["id"] = id;
    return _data;
  }
}
