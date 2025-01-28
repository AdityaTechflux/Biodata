class FetchBiodataDetailsModel {
  String? message;
  Data? data;
  bool? status;

  FetchBiodataDetailsModel({this.message, this.data, this.status});

  FetchBiodataDetailsModel.fromJson(Map<String, dynamic> json) {
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
  int? id;
  dynamic fbId;
  dynamic gId;
  String? matriId;
  dynamic referenceId;
  dynamic prefix;
  String? title;
  String? isNri;
  dynamic description;
  dynamic keyword;
  dynamic terms;
  String? email;
  dynamic password;
  dynamic cpassword;
  String? cpassStatus;
  String? maritalStatus;
  dynamic profileby;
  dynamic timeToCall;
  dynamic reference;
  String? username;
  dynamic firstname;
  dynamic lastname;
  dynamic gender;
  dynamic birthdate;
  String? birthtime;
  String? birthplace;
  dynamic totalChildren;
  dynamic statusChildren;
  dynamic category;
  dynamic newEducationDetail;
  dynamic educationDetail;
  dynamic workingIn;
  dynamic income;
  dynamic occupation;
  dynamic employeeIn;
  dynamic designation;
  String? religion;
  String? caste;
  String? subcaste;
  String? gothra;
  dynamic gothraShowInBio;
  dynamic complexionShowInBio;
  dynamic star;
  dynamic moonsign;
  dynamic horoscope;
  dynamic manglik;
  dynamic motherTongue;
  String? height;
  dynamic weight;
  dynamic bloodGroup;
  String? complexion;
  dynamic bodytype;
  dynamic diet;
  dynamic smoke;
  dynamic drink;
  dynamic healthProblem;
  dynamic languagesKnown;
  String? address;
  String? countryId;
  dynamic stateId;
  dynamic city;
  dynamic nativeTaluka;
  dynamic phone;
  String? mobile;
  String? contactViewSecurity;
  dynamic residence;
  String? fatherName;
  String? motherName;
  dynamic fatherLivingStatus;
  dynamic motherLivingStatus;
  String? fatherOccupation;
  String? motherOccupation;
  dynamic profileText;
  dynamic lookingFor;
  dynamic familyDetails;
  dynamic familyType;
  dynamic familyStatus;
  dynamic fatherStatus;
  dynamic motherStatus;
  String? mamaSurname;
  String? surnameOfRelatives;
  dynamic familyValue;
  String? noOfBrothers;
  String? noOfSisters;
  dynamic noOfMarriedBrother;
  dynamic noOfMarriedSister;
  dynamic familyMobile;
  dynamic familyResidentAddress;
  String? familyNativePlace;
  String? fatherNameShowInBio;
  String? fatherOccupationShowInBio;
  String? motherNameShowInBio;
  String? motherOccupationShowInBio;
  String? familyMobileShowInBio;
  String? noOfBrothersShowInBio;
  String? noOfMarriedBrotherShowInBio;
  String? noOfSistersShowInBio;
  String? noOfMarriedSisterShowInBio;
  String? surnameOfRelativesShowInBio;
  String? familyResidentAddressShowInBio;
  String? familyNativePlaceShowInBio;
  String? mamaSurnameShowInBio;
  String? partFrmAge;
  String? partToAge;
  dynamic partBodytype;
  dynamic partDiet;
  dynamic partSmoke;
  dynamic partDrink;
  dynamic partIncome;
  dynamic partEmployeeIn;
  dynamic partOccupation;
  dynamic partDesignation;
  dynamic partExpect;
  String? partHeight;
  String? partHeightTo;
  dynamic partComplexion;
  dynamic partMotherTongue;
  dynamic partReligion;
  dynamic partCaste;
  dynamic partManglik;
  dynamic partStar;
  dynamic partEducation;
  dynamic partEducationNew;
  String? partCountryLiving;
  dynamic partState;
  dynamic partCity;
  dynamic partResiStatus;
  dynamic hobby;
  String? horoscopePhotoApprove;
  dynamic horoscopePhoto;
  String? photoProtect;
  dynamic photoPassword;
  dynamic video;
  String? videoApproval;
  dynamic videoUrl;
  String? videoViewStatus;
  String? photoViewStatus;
  dynamic photo1;
  String? photo1Approve;
  dynamic photo2;
  String? photo2Approve;
  dynamic photo3;
  dynamic photo3Approve;
  dynamic photo4;
  dynamic photo4Approve;
  dynamic photo5;
  dynamic photo5Approve;
  dynamic photo6;
  dynamic photo6Approve;
  dynamic photo7;
  dynamic photo7Approve;
  dynamic photo8;
  dynamic photo8Approve;
  dynamic photo1UploadedOn;
  dynamic photo2UploadedOn;
  dynamic photo3UploadedOn;
  dynamic photo4UploadedOn;
  dynamic photo5UploadedOn;
  dynamic photo6UploadedOn;
  dynamic photo7UploadedOn;
  dynamic photo8UploadedOn;
  dynamic registeredOn;
  dynamic ip;
  dynamic agent;
  dynamic agentApprove;
  dynamic lastLogin;
  String? status;
  String? fstatus;
  dynamic loggedIn;
  dynamic adminroleId;
  dynamic franchisedBy;
  dynamic staffAssignId;
  dynamic franchiseAssignId;
  dynamic staffAssignDate;
  dynamic franchiseAssignDate;
  String? commented;
  dynamic adminroleViewStatus;
  String? mobileVerifyStatus;
  dynamic planId;
  dynamic planName;
  String? planStatus;
  dynamic planExpiredOn;
  String? isDeleted;
  dynamic idProof;
  String? idProofApprove;
  dynamic idProofUploadedOn;
  dynamic horoscopePhotoUploadedOn;
  String? registeredFrom;
  dynamic coverPhoto;
  String? coverPhotoApprove;
  dynamic coverPhotoUploadedOn;
  dynamic cpasswordExpire;
  dynamic bioDataTitle;
  dynamic androidDeviceId;
  dynamic iosDeviceId;
  dynamic latitude;
  dynamic longitude;
  dynamic webDeviceId;
  dynamic educationDetailOther;
  dynamic employeeInOther;
  dynamic designationOther;
  dynamic occupationOther;
  String? visitYourProfileNotification;
  String? shortlistYourProfileNotification;
  String? remindNotification;
  String? chatMessageNotification;
  String? adminNotification;
  String? adminApproval;
  dynamic step;
  String? contact;
  String? property;
  String? expectations;
  dynamic educationLevel;
  String? updatedAt;
  String? createdAt;
  dynamic fromDate;
  dynamic toDate;

  Data(
      {this.id,
      this.fbId,
      this.gId,
      this.matriId,
      this.referenceId,
      this.prefix,
      this.title,
      this.isNri,
      this.description,
      this.keyword,
      this.terms,
      this.email,
      this.password,
      this.cpassword,
      this.cpassStatus,
      this.maritalStatus,
      this.profileby,
      this.timeToCall,
      this.reference,
      this.username,
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
      this.income,
      this.occupation,
      this.employeeIn,
      this.designation,
      this.religion,
      this.caste,
      this.subcaste,
      this.gothra,
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
      this.bodytype,
      this.diet,
      this.smoke,
      this.drink,
      this.healthProblem,
      this.languagesKnown,
      this.address,
      this.countryId,
      this.stateId,
      this.city,
      this.nativeTaluka,
      this.phone,
      this.mobile,
      this.contactViewSecurity,
      this.residence,
      this.fatherName,
      this.motherName,
      this.fatherLivingStatus,
      this.motherLivingStatus,
      this.fatherOccupation,
      this.motherOccupation,
      this.profileText,
      this.lookingFor,
      this.familyDetails,
      this.familyType,
      this.familyStatus,
      this.fatherStatus,
      this.motherStatus,
      this.mamaSurname,
      this.surnameOfRelatives,
      this.familyValue,
      this.noOfBrothers,
      this.noOfSisters,
      this.noOfMarriedBrother,
      this.noOfMarriedSister,
      this.familyMobile,
      this.familyResidentAddress,
      this.familyNativePlace,
      this.fatherNameShowInBio,
      this.fatherOccupationShowInBio,
      this.motherNameShowInBio,
      this.motherOccupationShowInBio,
      this.familyMobileShowInBio,
      this.noOfBrothersShowInBio,
      this.noOfMarriedBrotherShowInBio,
      this.noOfSistersShowInBio,
      this.noOfMarriedSisterShowInBio,
      this.surnameOfRelativesShowInBio,
      this.familyResidentAddressShowInBio,
      this.familyNativePlaceShowInBio,
      this.mamaSurnameShowInBio,
      this.partFrmAge,
      this.partToAge,
      this.partBodytype,
      this.partDiet,
      this.partSmoke,
      this.partDrink,
      this.partIncome,
      this.partEmployeeIn,
      this.partOccupation,
      this.partDesignation,
      this.partExpect,
      this.partHeight,
      this.partHeightTo,
      this.partComplexion,
      this.partMotherTongue,
      this.partReligion,
      this.partCaste,
      this.partManglik,
      this.partStar,
      this.partEducation,
      this.partEducationNew,
      this.partCountryLiving,
      this.partState,
      this.partCity,
      this.partResiStatus,
      this.hobby,
      this.horoscopePhotoApprove,
      this.horoscopePhoto,
      this.photoProtect,
      this.photoPassword,
      this.video,
      this.videoApproval,
      this.videoUrl,
      this.videoViewStatus,
      this.photoViewStatus,
      this.photo1,
      this.photo1Approve,
      this.photo2,
      this.photo2Approve,
      this.photo3,
      this.photo3Approve,
      this.photo4,
      this.photo4Approve,
      this.photo5,
      this.photo5Approve,
      this.photo6,
      this.photo6Approve,
      this.photo7,
      this.photo7Approve,
      this.photo8,
      this.photo8Approve,
      this.photo1UploadedOn,
      this.photo2UploadedOn,
      this.photo3UploadedOn,
      this.photo4UploadedOn,
      this.photo5UploadedOn,
      this.photo6UploadedOn,
      this.photo7UploadedOn,
      this.photo8UploadedOn,
      this.registeredOn,
      this.ip,
      this.agent,
      this.agentApprove,
      this.lastLogin,
      this.status,
      this.fstatus,
      this.loggedIn,
      this.adminroleId,
      this.franchisedBy,
      this.staffAssignId,
      this.franchiseAssignId,
      this.staffAssignDate,
      this.franchiseAssignDate,
      this.commented,
      this.adminroleViewStatus,
      this.mobileVerifyStatus,
      this.planId,
      this.planName,
      this.planStatus,
      this.planExpiredOn,
      this.isDeleted,
      this.idProof,
      this.idProofApprove,
      this.idProofUploadedOn,
      this.horoscopePhotoUploadedOn,
      this.registeredFrom,
      this.coverPhoto,
      this.coverPhotoApprove,
      this.coverPhotoUploadedOn,
      this.cpasswordExpire,
      this.bioDataTitle,
      this.androidDeviceId,
      this.iosDeviceId,
      this.latitude,
      this.longitude,
      this.webDeviceId,
      this.educationDetailOther,
      this.employeeInOther,
      this.designationOther,
      this.occupationOther,
      this.visitYourProfileNotification,
      this.shortlistYourProfileNotification,
      this.remindNotification,
      this.chatMessageNotification,
      this.adminNotification,
      this.adminApproval,
      this.step,
      this.contact,
      this.property,
      this.expectations,
      this.educationLevel,
      this.updatedAt,
      this.createdAt,
      this.fromDate,
      this.toDate});

  Data.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    fbId = json["fb_id"];
    gId = json["g_id"];
    matriId = json["matri_id"];
    referenceId = json["reference_id"];
    prefix = json["prefix"];
    title = json["title"];
    isNri = json["is_nri"];
    description = json["description"];
    keyword = json["keyword"];
    terms = json["terms"];
    email = json["email"];
    password = json["password"];
    cpassword = json["cpassword"];
    cpassStatus = json["cpass_status"];
    maritalStatus = json["marital_status"];
    profileby = json["profileby"];
    timeToCall = json["time_to_call"];
    reference = json["reference"];
    username = json["username"];
    firstname = json["firstname"];
    lastname = json["lastname"];
    gender = json["gender"];
    birthdate = json["birthdate"];
    birthtime = json["birthtime"];
    birthplace = json["birthplace"];
    totalChildren = json["total_children"];
    statusChildren = json["status_children"];
    category = json["category"];
    newEducationDetail = json["new_education_detail"];
    educationDetail = json["education_detail"];
    workingIn = json["working_in"];
    income = json["income"];
    occupation = json["occupation"];
    employeeIn = json["employee_in"];
    designation = json["designation"];
    religion = json["religion"];
    caste = json["caste"];
    subcaste = json["subcaste"];
    gothra = json["gothra"];
    gothraShowInBio = json["gothra_show_in_bio"];
    complexionShowInBio = json["complexion_show_in_bio"];
    star = json["star"];
    moonsign = json["moonsign"];
    horoscope = json["horoscope"];
    manglik = json["manglik"];
    motherTongue = json["mother_tongue"];
    height = json["height"];
    weight = json["weight"];
    bloodGroup = json["blood_group"];
    complexion = json["complexion"];
    bodytype = json["bodytype"];
    diet = json["diet"];
    smoke = json["smoke"];
    drink = json["drink"];
    healthProblem = json["health_problem"];
    languagesKnown = json["languages_known"];
    address = json["address"];
    countryId = json["country_id"];
    stateId = json["state_id"];
    city = json["city"];
    nativeTaluka = json["native_taluka"];
    phone = json["phone"];
    mobile = json["mobile"];
    contactViewSecurity = json["contact_view_security"];
    residence = json["residence"];
    fatherName = json["father_name"];
    motherName = json["mother_name"];
    fatherLivingStatus = json["father_living_status"];
    motherLivingStatus = json["mother_living_status"];
    fatherOccupation = json["father_occupation"];
    motherOccupation = json["mother_occupation"];
    profileText = json["profile_text"];
    lookingFor = json["looking_for"];
    familyDetails = json["family_details"];
    familyType = json["family_type"];
    familyStatus = json["family_status"];
    fatherStatus = json["father_status"];
    motherStatus = json["mother_status"];
    mamaSurname = json["mama_surname"];
    surnameOfRelatives = json["surname_of_relatives"];
    familyValue = json["family_value"];
    noOfBrothers = json["no_of_brothers"];
    noOfSisters = json["no_of_sisters"];
    noOfMarriedBrother = json["no_of_married_brother"];
    noOfMarriedSister = json["no_of_married_sister"];
    familyMobile = json["family_mobile"];
    familyResidentAddress = json["family_resident_address"];
    familyNativePlace = json["family_native_place"];
    fatherNameShowInBio = json["father_name_show_in_bio"];
    fatherOccupationShowInBio = json["father_occupation_show_in_bio"];
    motherNameShowInBio = json["mother_name_show_in_bio"];
    motherOccupationShowInBio = json["mother_occupation_show_in_bio"];
    familyMobileShowInBio = json["family_mobile_show_in_bio"];
    noOfBrothersShowInBio = json["no_of_brothers_show_in_bio"];
    noOfMarriedBrotherShowInBio = json["no_of_married_brother_show_in_bio"];
    noOfSistersShowInBio = json["no_of_sisters_show_in_bio"];
    noOfMarriedSisterShowInBio = json["no_of_married_sister_show_in_bio"];
    surnameOfRelativesShowInBio = json["surname_of_relatives_show_in_bio"];
    familyResidentAddressShowInBio =
        json["family_resident_address_show_in_bio"];
    familyNativePlaceShowInBio = json["family_native_place_show_in_bio"];
    mamaSurnameShowInBio = json["mama_surname_show_in_bio"];
    partFrmAge = json["part_frm_age"];
    partToAge = json["part_to_age"];
    partBodytype = json["part_bodytype"];
    partDiet = json["part_diet"];
    partSmoke = json["part_smoke"];
    partDrink = json["part_drink"];
    partIncome = json["part_income"];
    partEmployeeIn = json["part_employee_in"];
    partOccupation = json["part_occupation"];
    partDesignation = json["part_designation"];
    partExpect = json["part_expect"];
    partHeight = json["part_height"];
    partHeightTo = json["part_height_to"];
    partComplexion = json["part_complexion"];
    partMotherTongue = json["part_mother_tongue"];
    partReligion = json["part_religion"];
    partCaste = json["part_caste"];
    partManglik = json["part_manglik"];
    partStar = json["part_star"];
    partEducation = json["part_education"];
    partEducationNew = json["part_education_new"];
    partCountryLiving = json["part_country_living"];
    partState = json["part_state"];
    partCity = json["part_city"];
    partResiStatus = json["part_resi_status"];
    hobby = json["hobby"];
    horoscopePhotoApprove = json["horoscope_photo_approve"];
    horoscopePhoto = json["horoscope_photo"];
    photoProtect = json["photo_protect"];
    photoPassword = json["photo_password"];
    video = json["video"];
    videoApproval = json["video_approval"];
    videoUrl = json["video_url"];
    videoViewStatus = json["video_view_status"];
    photoViewStatus = json["photo_view_status"];
    photo1 = json["photo1"];
    photo1Approve = json["photo1_approve"];
    photo2 = json["photo2"];
    photo2Approve = json["photo2_approve"];
    photo3 = json["photo3"];
    photo3Approve = json["photo3_approve"];
    photo4 = json["photo4"];
    photo4Approve = json["photo4_approve"];
    photo5 = json["photo5"];
    photo5Approve = json["photo5_approve"];
    photo6 = json["photo6"];
    photo6Approve = json["photo6_approve"];
    photo7 = json["photo7"];
    photo7Approve = json["photo7_approve"];
    photo8 = json["photo8"];
    photo8Approve = json["photo8_approve"];
    photo1UploadedOn = json["photo1_uploaded_on"];
    photo2UploadedOn = json["photo2_uploaded_on"];
    photo3UploadedOn = json["photo3_uploaded_on"];
    photo4UploadedOn = json["photo4_uploaded_on"];
    photo5UploadedOn = json["photo5_uploaded_on"];
    photo6UploadedOn = json["photo6_uploaded_on"];
    photo7UploadedOn = json["photo7_uploaded_on"];
    photo8UploadedOn = json["photo8_uploaded_on"];
    registeredOn = json["registered_on"];
    ip = json["ip"];
    agent = json["agent"];
    agentApprove = json["agent_approve"];
    lastLogin = json["last_login"];
    status = json["status"];
    fstatus = json["fstatus"];
    loggedIn = json["logged_in"];
    adminroleId = json["adminrole_id"];
    franchisedBy = json["franchised_by"];
    staffAssignId = json["staff_assign_id"];
    franchiseAssignId = json["franchise_assign_id"];
    staffAssignDate = json["staff_assign_date"];
    franchiseAssignDate = json["franchise_assign_date"];
    commented = json["commented"];
    adminroleViewStatus = json["adminrole_view_status"];
    mobileVerifyStatus = json["mobile_verify_status"];
    planId = json["plan_id"];
    planName = json["plan_name"];
    planStatus = json["plan_status"];
    planExpiredOn = json["plan_expired_on"];
    isDeleted = json["is_deleted"];
    idProof = json["id_proof"];
    idProofApprove = json["id_proof_approve"];
    idProofUploadedOn = json["id_proof_uploaded_on"];
    horoscopePhotoUploadedOn = json["horoscope_photo_uploaded_on"];
    registeredFrom = json["registered_from"];
    coverPhoto = json["cover_photo"];
    coverPhotoApprove = json["cover_photo_approve"];
    coverPhotoUploadedOn = json["cover_photo_uploaded_on"];
    cpasswordExpire = json["cpassword_expire"];
    bioDataTitle = json["bio_data_title"];
    androidDeviceId = json["android_device_id"];
    iosDeviceId = json["ios_device_id"];
    latitude = json["latitude"];
    longitude = json["longitude"];
    webDeviceId = json["web_device_id"];
    educationDetailOther = json["education_detail_other"];
    employeeInOther = json["employee_in_other"];
    designationOther = json["designation_other"];
    occupationOther = json["occupation_other"];
    visitYourProfileNotification = json["visit_your_profile_notification"];
    shortlistYourProfileNotification =
        json["shortlist_your_profile_notification"];
    remindNotification = json["remind_notification"];
    chatMessageNotification = json["chat_message_notification"];
    adminNotification = json["admin_notification"];
    adminApproval = json["admin_approval"];
    step = json["step"];
    contact = json["contact"];
    property = json["property"];
    expectations = json["expectations"];
    educationLevel = json["education_level"];
    updatedAt = json["updated_at"];
    createdAt = json["created_at"];
    fromDate = json["from_date"];
    toDate = json["to_date"];
  }

  get residentialAddress => null;

  get totalBrothers => null;

  get totalSisters => null;

  get mobileNumber => null;

  get maternalUncle => null;

  get nativePlace => null;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["fb_id"] = fbId;
    _data["g_id"] = gId;
    _data["matri_id"] = matriId;
    _data["reference_id"] = referenceId;
    _data["prefix"] = prefix;
    _data["title"] = title;
    _data["is_nri"] = isNri;
    _data["description"] = description;
    _data["keyword"] = keyword;
    _data["terms"] = terms;
    _data["email"] = email;
    _data["password"] = password;
    _data["cpassword"] = cpassword;
    _data["cpass_status"] = cpassStatus;
    _data["marital_status"] = maritalStatus;
    _data["profileby"] = profileby;
    _data["time_to_call"] = timeToCall;
    _data["reference"] = reference;
    _data["username"] = username;
    _data["firstname"] = firstname;
    _data["lastname"] = lastname;
    _data["gender"] = gender;
    _data["birthdate"] = birthdate;
    _data["birthtime"] = birthtime;
    _data["birthplace"] = birthplace;
    _data["total_children"] = totalChildren;
    _data["status_children"] = statusChildren;
    _data["category"] = category;
    _data["new_education_detail"] = newEducationDetail;
    _data["education_detail"] = educationDetail;
    _data["working_in"] = workingIn;
    _data["income"] = income;
    _data["occupation"] = occupation;
    _data["employee_in"] = employeeIn;
    _data["designation"] = designation;
    _data["religion"] = religion;
    _data["caste"] = caste;
    _data["subcaste"] = subcaste;
    _data["gothra"] = gothra;
    _data["gothra_show_in_bio"] = gothraShowInBio;
    _data["complexion_show_in_bio"] = complexionShowInBio;
    _data["star"] = star;
    _data["moonsign"] = moonsign;
    _data["horoscope"] = horoscope;
    _data["manglik"] = manglik;
    _data["mother_tongue"] = motherTongue;
    _data["height"] = height;
    _data["weight"] = weight;
    _data["blood_group"] = bloodGroup;
    _data["complexion"] = complexion;
    _data["bodytype"] = bodytype;
    _data["diet"] = diet;
    _data["smoke"] = smoke;
    _data["drink"] = drink;
    _data["health_problem"] = healthProblem;
    _data["languages_known"] = languagesKnown;
    _data["address"] = address;
    _data["country_id"] = countryId;
    _data["state_id"] = stateId;
    _data["city"] = city;
    _data["native_taluka"] = nativeTaluka;
    _data["phone"] = phone;
    _data["mobile"] = mobile;
    _data["contact_view_security"] = contactViewSecurity;
    _data["residence"] = residence;
    _data["father_name"] = fatherName;
    _data["mother_name"] = motherName;
    _data["father_living_status"] = fatherLivingStatus;
    _data["mother_living_status"] = motherLivingStatus;
    _data["father_occupation"] = fatherOccupation;
    _data["mother_occupation"] = motherOccupation;
    _data["profile_text"] = profileText;
    _data["looking_for"] = lookingFor;
    _data["family_details"] = familyDetails;
    _data["family_type"] = familyType;
    _data["family_status"] = familyStatus;
    _data["father_status"] = fatherStatus;
    _data["mother_status"] = motherStatus;
    _data["mama_surname"] = mamaSurname;
    _data["surname_of_relatives"] = surnameOfRelatives;
    _data["family_value"] = familyValue;
    _data["no_of_brothers"] = noOfBrothers;
    _data["no_of_sisters"] = noOfSisters;
    _data["no_of_married_brother"] = noOfMarriedBrother;
    _data["no_of_married_sister"] = noOfMarriedSister;
    _data["family_mobile"] = familyMobile;
    _data["family_resident_address"] = familyResidentAddress;
    _data["family_native_place"] = familyNativePlace;
    _data["father_name_show_in_bio"] = fatherNameShowInBio;
    _data["father_occupation_show_in_bio"] = fatherOccupationShowInBio;
    _data["mother_name_show_in_bio"] = motherNameShowInBio;
    _data["mother_occupation_show_in_bio"] = motherOccupationShowInBio;
    _data["family_mobile_show_in_bio"] = familyMobileShowInBio;
    _data["no_of_brothers_show_in_bio"] = noOfBrothersShowInBio;
    _data["no_of_married_brother_show_in_bio"] = noOfMarriedBrotherShowInBio;
    _data["no_of_sisters_show_in_bio"] = noOfSistersShowInBio;
    _data["no_of_married_sister_show_in_bio"] = noOfMarriedSisterShowInBio;
    _data["surname_of_relatives_show_in_bio"] = surnameOfRelativesShowInBio;
    _data["family_resident_address_show_in_bio"] =
        familyResidentAddressShowInBio;
    _data["family_native_place_show_in_bio"] = familyNativePlaceShowInBio;
    _data["mama_surname_show_in_bio"] = mamaSurnameShowInBio;
    _data["part_frm_age"] = partFrmAge;
    _data["part_to_age"] = partToAge;
    _data["part_bodytype"] = partBodytype;
    _data["part_diet"] = partDiet;
    _data["part_smoke"] = partSmoke;
    _data["part_drink"] = partDrink;
    _data["part_income"] = partIncome;
    _data["part_employee_in"] = partEmployeeIn;
    _data["part_occupation"] = partOccupation;
    _data["part_designation"] = partDesignation;
    _data["part_expect"] = partExpect;
    _data["part_height"] = partHeight;
    _data["part_height_to"] = partHeightTo;
    _data["part_complexion"] = partComplexion;
    _data["part_mother_tongue"] = partMotherTongue;
    _data["part_religion"] = partReligion;
    _data["part_caste"] = partCaste;
    _data["part_manglik"] = partManglik;
    _data["part_star"] = partStar;
    _data["part_education"] = partEducation;
    _data["part_education_new"] = partEducationNew;
    _data["part_country_living"] = partCountryLiving;
    _data["part_state"] = partState;
    _data["part_city"] = partCity;
    _data["part_resi_status"] = partResiStatus;
    _data["hobby"] = hobby;
    _data["horoscope_photo_approve"] = horoscopePhotoApprove;
    _data["horoscope_photo"] = horoscopePhoto;
    _data["photo_protect"] = photoProtect;
    _data["photo_password"] = photoPassword;
    _data["video"] = video;
    _data["video_approval"] = videoApproval;
    _data["video_url"] = videoUrl;
    _data["video_view_status"] = videoViewStatus;
    _data["photo_view_status"] = photoViewStatus;
    _data["photo1"] = photo1;
    _data["photo1_approve"] = photo1Approve;
    _data["photo2"] = photo2;
    _data["photo2_approve"] = photo2Approve;
    _data["photo3"] = photo3;
    _data["photo3_approve"] = photo3Approve;
    _data["photo4"] = photo4;
    _data["photo4_approve"] = photo4Approve;
    _data["photo5"] = photo5;
    _data["photo5_approve"] = photo5Approve;
    _data["photo6"] = photo6;
    _data["photo6_approve"] = photo6Approve;
    _data["photo7"] = photo7;
    _data["photo7_approve"] = photo7Approve;
    _data["photo8"] = photo8;
    _data["photo8_approve"] = photo8Approve;
    _data["photo1_uploaded_on"] = photo1UploadedOn;
    _data["photo2_uploaded_on"] = photo2UploadedOn;
    _data["photo3_uploaded_on"] = photo3UploadedOn;
    _data["photo4_uploaded_on"] = photo4UploadedOn;
    _data["photo5_uploaded_on"] = photo5UploadedOn;
    _data["photo6_uploaded_on"] = photo6UploadedOn;
    _data["photo7_uploaded_on"] = photo7UploadedOn;
    _data["photo8_uploaded_on"] = photo8UploadedOn;
    _data["registered_on"] = registeredOn;
    _data["ip"] = ip;
    _data["agent"] = agent;
    _data["agent_approve"] = agentApprove;
    _data["last_login"] = lastLogin;
    _data["status"] = status;
    _data["fstatus"] = fstatus;
    _data["logged_in"] = loggedIn;
    _data["adminrole_id"] = adminroleId;
    _data["franchised_by"] = franchisedBy;
    _data["staff_assign_id"] = staffAssignId;
    _data["franchise_assign_id"] = franchiseAssignId;
    _data["staff_assign_date"] = staffAssignDate;
    _data["franchise_assign_date"] = franchiseAssignDate;
    _data["commented"] = commented;
    _data["adminrole_view_status"] = adminroleViewStatus;
    _data["mobile_verify_status"] = mobileVerifyStatus;
    _data["plan_id"] = planId;
    _data["plan_name"] = planName;
    _data["plan_status"] = planStatus;
    _data["plan_expired_on"] = planExpiredOn;
    _data["is_deleted"] = isDeleted;
    _data["id_proof"] = idProof;
    _data["id_proof_approve"] = idProofApprove;
    _data["id_proof_uploaded_on"] = idProofUploadedOn;
    _data["horoscope_photo_uploaded_on"] = horoscopePhotoUploadedOn;
    _data["registered_from"] = registeredFrom;
    _data["cover_photo"] = coverPhoto;
    _data["cover_photo_approve"] = coverPhotoApprove;
    _data["cover_photo_uploaded_on"] = coverPhotoUploadedOn;
    _data["cpassword_expire"] = cpasswordExpire;
    _data["bio_data_title"] = bioDataTitle;
    _data["android_device_id"] = androidDeviceId;
    _data["ios_device_id"] = iosDeviceId;
    _data["latitude"] = latitude;
    _data["longitude"] = longitude;
    _data["web_device_id"] = webDeviceId;
    _data["education_detail_other"] = educationDetailOther;
    _data["employee_in_other"] = employeeInOther;
    _data["designation_other"] = designationOther;
    _data["occupation_other"] = occupationOther;
    _data["visit_your_profile_notification"] = visitYourProfileNotification;
    _data["shortlist_your_profile_notification"] =
        shortlistYourProfileNotification;
    _data["remind_notification"] = remindNotification;
    _data["chat_message_notification"] = chatMessageNotification;
    _data["admin_notification"] = adminNotification;
    _data["admin_approval"] = adminApproval;
    _data["step"] = step;
    _data["contact"] = contact;
    _data["property"] = property;
    _data["expectations"] = expectations;
    _data["education_level"] = educationLevel;
    _data["updated_at"] = updatedAt;
    _data["created_at"] = createdAt;
    _data["from_date"] = fromDate;
    _data["to_date"] = toDate;
    return _data;
  }
}
