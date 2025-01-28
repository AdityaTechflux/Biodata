class ShowBiodataResponse {
  final String message;
  final List<Data> data; // List of Data objects
  final bool status; // Indicates success or failure

  ShowBiodataResponse({
    required this.message,
    required this.data,
    required this.status,
  });

  factory ShowBiodataResponse.fromJson(Map<String, dynamic> json) {
    return ShowBiodataResponse(
      message: json['message'] as String,
      data: (json['data'] as List)
          .map((item) => Data.fromJson(item as Map<String, dynamic>))
          .toList(),
      status: json['status'] as bool,
    );
  }
}

class Data {
  final int id;
  final String? fbId;
  final String? gId;
  final String matriId;
  final String? referenceId;
  final String? prefix;
  final String title;
  final String isNri;
  final String? description;
  final String? keyword;
  final String? terms;
  final String? email;
  final String? password;
  final String? cpassword;
  final String cpassStatus;
  final String maritalStatus;
  final String? profileBy;
  final String? timeToCall;
  final String? reference;
  final String username;
  final String? firstname;
  final String? lastname;
  final String? gender;
  final String? birthdate;
  final String? birthtime;
  final String? birthplace;
  final String? totalChildren;
  final String? statusChildren;
  final String? category;
  final String? newEducationDetail;
  final String? educationDetail;
  final String? workingIn;
  final String income;
  final String occupation;
  final String? employeeIn;
  final String? designation;
  final String religion;
  final String caste;
  final String subcaste;
  final String gothra;
  final String? gothraShowInBio;
  final String? complexionShowInBio;
  final String? star;
  final String? moonsign;
  final String? horoscope;
  final String? manglik;
  final String? motherTongue;
  final String? height;
  final String? weight;
  final String? bloodGroup;
  final String? complexion;

  Data({
    required this.id,
    this.fbId,
    this.gId,
    required this.matriId,
    this.referenceId,
    this.prefix,
    required this.title,
    required this.isNri,
    this.description,
    this.keyword,
    this.terms,
    this.email,
    this.password,
    this.cpassword,
    required this.cpassStatus,
    required this.maritalStatus,
    this.profileBy,
    this.timeToCall,
    this.reference,
    required this.username,
    this.firstname,
    this.lastname,
    this.gender,
    this.birthdate,
    this.birthtime,
    this.birthplace,
    this.totalChildren,
    this.statusChildren,
    this.category,
    this.newEducationDetail,
    this.educationDetail,
    this.workingIn,
    required this.income,
    required this.occupation,
    this.employeeIn,
    this.designation,
    required this.religion,
    required this.caste,
    required this.subcaste,
    required this.gothra,
    this.gothraShowInBio,
    this.complexionShowInBio,
    this.star,
    this.moonsign,
    this.horoscope,
    this.manglik,
    this.motherTongue,
    this.height,
    this.weight,
    this.bloodGroup,
    this.complexion,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json['id'] as int,
      fbId: json['fb_id'] as String?,
      gId: json['g_id'] as String?,
      matriId: json['matri_id'] as String,
      referenceId: json['reference_id'] as String?,
      prefix: json['prefix'] as String?,
      title: json['title'] as String,
      isNri: json['is_nri'] as String,
      description: json['description'] as String?,
      keyword: json['keyword'] as String?,
      terms: json['terms'] as String?,
      email: json['email'] as String?,
      password: json['password'] as String?,
      cpassword: json['cpassword'] as String?,
      cpassStatus: json['cpass_status'] as String,
      maritalStatus: json['marital_status'] as String,
      profileBy: json['profileby'] as String?,
      timeToCall: json['time_to_call'] as String?,
      reference: json['reference'] as String?,
      username: json['username'] as String,
      firstname: json['firstname'] as String?,
      lastname: json['lastname'] as String?,
      gender: json['gender'] as String?,
      birthdate: json['birthdate'] as String?,
      birthtime: json['birthtime'] as String?,
      birthplace: json['birthplace'] as String?,
      totalChildren: json['total_children'] as String?,
      statusChildren: json['status_children'] as String?,
      category: json['category'] as String?,
      newEducationDetail: json['new_education_detail'] as String?,
      educationDetail: json['education_detail'] as String?,
      workingIn: json['working_in'] as String?,
      income: json['income'].toString(), // Ensure it's a string
      occupation: json['occupation'] as String,
      employeeIn: json['employee_in'] as String?,
      designation: json['designation'] as String?,
      religion: json['religion'].toString(), // Ensure it's a string
      caste: json['caste'] as String,
      subcaste: json['subcaste'] as String,
      gothra: json['gothra'] as String,
      gothraShowInBio: json['gothra_show_in_bio'] as String?,
      complexionShowInBio: json['complexion_show_in_bio'] as String?,
      star: json['star'] as String?,
      moonsign: json['moonsign'] as String?,
      horoscope: json['horoscope'] as String?,
      manglik: json['manglik'] as String?,
      motherTongue: json['mother_tongue'] as String?,
      height: json['height'] as String?,
      weight: json['weight'] as String?,
      bloodGroup: json['blood_group'] as String?,
      complexion: json['complexion'] as String?,
    );
  }
}
