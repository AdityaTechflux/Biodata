class DummySampleModel {
  String? message;
  Data? data;
  bool? status;

  DummySampleModel({this.message, this.data, this.status});

  DummySampleModel.fromJson(Map<String, dynamic> json) {
    message = json["message"];
    data = json["data"] == null ? null : Data.fromJson(json["data"]);
    status = json["status"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["message"] = message;
    if (data != null) {
      _data["data"] = data?.toJson();
    }
    _data["status"] = status;
    return _data;
  }
}

class Data {
  String? parentId;
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
  String? fatherName;
  String? motherName;
  String? fatherOccupation;
  String? motherOccupation;
  String? address;
  String? noOfBrothers;
  String? noOfSisters;
  String? mobile;
  String? mamaSurname;
  String? surnameOfRelatives;
  String? familyNativePlace;
  String? educationDetail;
  String? income;
  String? occupation;
  String? updatedAt;
  String? createdAt;
  int? id;

  Data(
      {this.parentId,
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
      this.fatherName,
      this.motherName,
      this.fatherOccupation,
      this.motherOccupation,
      this.address,
      this.noOfBrothers,
      this.noOfSisters,
      this.mobile,
      this.mamaSurname,
      this.surnameOfRelatives,
      this.familyNativePlace,
      this.educationDetail,
      this.income,
      this.occupation,
      this.updatedAt,
      this.createdAt,
      this.id});

  Data.fromJson(Map<String, dynamic> json) {
    parentId = json["parent_id"];
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
    fatherName = json["father_name"];
    motherName = json["mother_name"];
    fatherOccupation = json["father_occupation"];
    motherOccupation = json["mother_occupation"];
    address = json["address"];
    noOfBrothers = json["no_of_brothers"];
    noOfSisters = json["no_of_sisters"];
    mobile = json["mobile"];
    mamaSurname = json["mama_surname"];
    surnameOfRelatives = json["surname_of_relatives"];
    familyNativePlace = json["family_native_place"];
    educationDetail = json["education_detail"];
    income = json["income"];
    occupation = json["occupation"];
    updatedAt = json["updated_at"];
    createdAt = json["created_at"];
    id = json["id"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["parent_id"] = parentId;
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
    _data["father_name"] = fatherName;
    _data["mother_name"] = motherName;
    _data["father_occupation"] = fatherOccupation;
    _data["mother_occupation"] = motherOccupation;
    _data["address"] = address;
    _data["no_of_brothers"] = noOfBrothers;
    _data["no_of_sisters"] = noOfSisters;
    _data["mobile"] = mobile;
    _data["mama_surname"] = mamaSurname;
    _data["surname_of_relatives"] = surnameOfRelatives;
    _data["family_native_place"] = familyNativePlace;
    _data["education_detail"] = educationDetail;
    _data["income"] = income;
    _data["occupation"] = occupation;
    _data["updated_at"] = updatedAt;
    _data["created_at"] = createdAt;
    _data["id"] = id;
    return _data;
  }
}
