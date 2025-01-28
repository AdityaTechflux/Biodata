class ShowBiodataByBiodataId {
  final String message;
  final Data data;
  final bool status;

  ShowBiodataByBiodataId({
    required this.message,
    required this.data,
    required this.status,
  });

  ShowBiodataByBiodataId copyWith({
    String? message,
    Data? data,
    bool? status,
  }) =>
      ShowBiodataByBiodataId(
        message: message ?? this.message,
        data: data ?? this.data,
        status: status ?? this.status,
      );
}

class Data {
  final int id;
  final dynamic fbId;
  final dynamic gId;
  final String matriId;
  final dynamic referenceId;
  final dynamic prefix;
  final String title;
  final String isNri;
  final dynamic description;
  final dynamic keyword;
  final dynamic terms;
  final dynamic email;
  final dynamic password;
  final dynamic cpassword;
  final String cpassStatus;
  final String maritalStatus;
  final dynamic profileby;
  final dynamic timeToCall;
  final dynamic reference;
  final String username;
  final dynamic firstname;
  final dynamic lastname;
  final dynamic gender;
  final DateTime birthdate;
  final String birthtime;
  final String birthplace;
  final dynamic totalChildren;
  final dynamic statusChildren;
  final dynamic category;
  final dynamic newEducationDetail;
  final String educationDetail;
  final dynamic workingIn;
  final String income;
  final String occupation;
  final dynamic employeeIn;
  final dynamic designation;
  final int religion;
  final String caste;
  final String subcaste;
  final String gothra;
  final dynamic gothraShowInBio;
  final dynamic complexionShowInBio;
  final dynamic star;
  final dynamic moonsign;
  final dynamic horoscope;
  final dynamic manglik;
  final dynamic motherTongue;
  final String height;
  final dynamic weight;
  final String bloodGroup;
  final String complexion;
  final dynamic bodytype;
  final dynamic diet;
  final dynamic smoke;
  final dynamic drink;
  final dynamic healthProblem;
  final dynamic languagesKnown;
  final String address;
  final int countryId;
  final dynamic stateId;
  final dynamic city;
  final dynamic nativeTaluka;
  final dynamic phone;
  final String mobile;
  final String contactViewSecurity;
  final dynamic residence;
  final String fatherName;
  final String motherName;
  final dynamic fatherLivingStatus;
  final dynamic motherLivingStatus;
  final String fatherOccupation;
  final String motherOccupation;
  final dynamic profileText;
  final dynamic lookingFor;
  final dynamic familyDetails;
  final dynamic familyType;
  final dynamic familyStatus;
  final dynamic fatherStatus;
  final dynamic motherStatus;
  final String mamaSurname;
  final String surnameOfRelatives;
  final dynamic familyValue;
  final String noOfBrothers;
  final String noOfSisters;
  final dynamic noOfMarriedBrother;
  final dynamic noOfMarriedSister;
  final dynamic familyMobile;
  final dynamic familyResidentAddress;
  final String familyNativePlace;
  final String fatherNameShowInBio;
  final String fatherOccupationShowInBio;
  final String motherNameShowInBio;
  final String motherOccupationShowInBio;
  final String familyMobileShowInBio;
  final String noOfBrothersShowInBio;
  final String noOfMarriedBrotherShowInBio;
  final String noOfSistersShowInBio;
  final String noOfMarriedSisterShowInBio;
  final String surnameOfRelativesShowInBio;
  final String familyResidentAddressShowInBio;
  final String familyNativePlaceShowInBio;
  final String mamaSurnameShowInBio;
  final int partFrmAge;
  final int partToAge;
  final dynamic partBodytype;
  final dynamic partDiet;
  final dynamic partSmoke;
  final dynamic partDrink;
  final dynamic partIncome;
  final dynamic partEmployeeIn;
  final dynamic partOccupation;
  final dynamic partDesignation;
  final dynamic partExpect;
  final String partHeight;
  final String partHeightTo;
  final dynamic partComplexion;
  final dynamic partMotherTongue;
  final dynamic partReligion;
  final dynamic partCaste;
  final dynamic partManglik;
  final dynamic partStar;
  final dynamic partEducation;
  final dynamic partEducationNew;
  final int partCountryLiving;
  final dynamic partState;
  final dynamic partCity;
  final dynamic partResiStatus;
  final dynamic hobby;
  final String horoscopePhotoApprove;
  final dynamic horoscopePhoto;
  final String photoProtect;
  final dynamic photoPassword;
  final dynamic video;
  final String videoApproval;
  final dynamic videoUrl;
  final String videoViewStatus;
  final String photoViewStatus;
  final dynamic photo1;
  final String photo1Approve;
  final dynamic photo2;
  final String photo2Approve;
  final dynamic photo3;
  final dynamic photo3Approve;
  final dynamic photo4;
  final dynamic photo4Approve;
  final dynamic photo5;
  final dynamic photo5Approve;
  final dynamic photo6;
  final dynamic photo6Approve;
  final dynamic photo7;
  final dynamic photo7Approve;
  final dynamic photo8;
  final dynamic photo8Approve;
  final dynamic photo1UploadedOn;
  final dynamic photo2UploadedOn;
  final dynamic photo3UploadedOn;
  final dynamic photo4UploadedOn;
  final dynamic photo5UploadedOn;
  final dynamic photo6UploadedOn;
  final dynamic photo7UploadedOn;
  final dynamic photo8UploadedOn;
  final dynamic registeredOn;
  final dynamic ip;
  final dynamic agent;
  final dynamic agentApprove;
  final dynamic lastLogin;
  final String status;
  final String fstatus;
  final dynamic loggedIn;
  final dynamic adminroleId;
  final dynamic franchisedBy;
  final dynamic staffAssignId;
  final dynamic franchiseAssignId;
  final dynamic staffAssignDate;
  final dynamic franchiseAssignDate;
  final String commented;
  final dynamic adminroleViewStatus;
  final String mobileVerifyStatus;
  final dynamic planId;
  final dynamic planName;
  final String planStatus;
  final dynamic planExpiredOn;
  final String isDeleted;
  final dynamic idProof;
  final String idProofApprove;
  final dynamic idProofUploadedOn;
  final dynamic horoscopePhotoUploadedOn;
  final String registeredFrom;
  final dynamic coverPhoto;
  final String coverPhotoApprove;
  final dynamic coverPhotoUploadedOn;
  final dynamic cpasswordExpire;
  final dynamic bioDataTitle;
  final dynamic androidDeviceId;
  final dynamic iosDeviceId;
  final dynamic latitude;
  final dynamic longitude;
  final dynamic webDeviceId;
  final dynamic educationDetailOther;
  final dynamic employeeInOther;
  final dynamic designationOther;
  final dynamic occupationOther;
  final String visitYourProfileNotification;
  final String shortlistYourProfileNotification;
  final String remindNotification;
  final String chatMessageNotification;
  final String adminNotification;
  final String adminApproval;
  final dynamic step;
  final dynamic contact;
  final String property;
  final String expectations;
  final String educationLevel;
  final DateTime updatedAt;
  final DateTime createdAt;
  final dynamic fromDate;
  final dynamic toDate;

  Data({
    required this.id,
    required this.fbId,
    required this.gId,
    required this.matriId,
    required this.referenceId,
    required this.prefix,
    required this.title,
    required this.isNri,
    required this.description,
    required this.keyword,
    required this.terms,
    required this.email,
    required this.password,
    required this.cpassword,
    required this.cpassStatus,
    required this.maritalStatus,
    required this.profileby,
    required this.timeToCall,
    required this.reference,
    required this.username,
    required this.firstname,
    required this.lastname,
    required this.gender,
    required this.birthdate,
    required this.birthtime,
    required this.birthplace,
    required this.totalChildren,
    required this.statusChildren,
    required this.category,
    required this.newEducationDetail,
    required this.educationDetail,
    required this.workingIn,
    required this.income,
    required this.occupation,
    required this.employeeIn,
    required this.designation,
    required this.religion,
    required this.caste,
    required this.subcaste,
    required this.gothra,
    required this.gothraShowInBio,
    required this.complexionShowInBio,
    required this.star,
    required this.moonsign,
    required this.horoscope,
    required this.manglik,
    required this.motherTongue,
    required this.height,
    required this.weight,
    required this.bloodGroup,
    required this.complexion,
    required this.bodytype,
    required this.diet,
    required this.smoke,
    required this.drink,
    required this.healthProblem,
    required this.languagesKnown,
    required this.address,
    required this.countryId,
    required this.stateId,
    required this.city,
    required this.nativeTaluka,
    required this.phone,
    required this.mobile,
    required this.contactViewSecurity,
    required this.residence,
    required this.fatherName,
    required this.motherName,
    required this.fatherLivingStatus,
    required this.motherLivingStatus,
    required this.fatherOccupation,
    required this.motherOccupation,
    required this.profileText,
    required this.lookingFor,
    required this.familyDetails,
    required this.familyType,
    required this.familyStatus,
    required this.fatherStatus,
    required this.motherStatus,
    required this.mamaSurname,
    required this.surnameOfRelatives,
    required this.familyValue,
    required this.noOfBrothers,
    required this.noOfSisters,
    required this.noOfMarriedBrother,
    required this.noOfMarriedSister,
    required this.familyMobile,
    required this.familyResidentAddress,
    required this.familyNativePlace,
    required this.fatherNameShowInBio,
    required this.fatherOccupationShowInBio,
    required this.motherNameShowInBio,
    required this.motherOccupationShowInBio,
    required this.familyMobileShowInBio,
    required this.noOfBrothersShowInBio,
    required this.noOfMarriedBrotherShowInBio,
    required this.noOfSistersShowInBio,
    required this.noOfMarriedSisterShowInBio,
    required this.surnameOfRelativesShowInBio,
    required this.familyResidentAddressShowInBio,
    required this.familyNativePlaceShowInBio,
    required this.mamaSurnameShowInBio,
    required this.partFrmAge,
    required this.partToAge,
    required this.partBodytype,
    required this.partDiet,
    required this.partSmoke,
    required this.partDrink,
    required this.partIncome,
    required this.partEmployeeIn,
    required this.partOccupation,
    required this.partDesignation,
    required this.partExpect,
    required this.partHeight,
    required this.partHeightTo,
    required this.partComplexion,
    required this.partMotherTongue,
    required this.partReligion,
    required this.partCaste,
    required this.partManglik,
    required this.partStar,
    required this.partEducation,
    required this.partEducationNew,
    required this.partCountryLiving,
    required this.partState,
    required this.partCity,
    required this.partResiStatus,
    required this.hobby,
    required this.horoscopePhotoApprove,
    required this.horoscopePhoto,
    required this.photoProtect,
    required this.photoPassword,
    required this.video,
    required this.videoApproval,
    required this.videoUrl,
    required this.videoViewStatus,
    required this.photoViewStatus,
    required this.photo1,
    required this.photo1Approve,
    required this.photo2,
    required this.photo2Approve,
    required this.photo3,
    required this.photo3Approve,
    required this.photo4,
    required this.photo4Approve,
    required this.photo5,
    required this.photo5Approve,
    required this.photo6,
    required this.photo6Approve,
    required this.photo7,
    required this.photo7Approve,
    required this.photo8,
    required this.photo8Approve,
    required this.photo1UploadedOn,
    required this.photo2UploadedOn,
    required this.photo3UploadedOn,
    required this.photo4UploadedOn,
    required this.photo5UploadedOn,
    required this.photo6UploadedOn,
    required this.photo7UploadedOn,
    required this.photo8UploadedOn,
    required this.registeredOn,
    required this.ip,
    required this.agent,
    required this.agentApprove,
    required this.lastLogin,
    required this.status,
    required this.fstatus,
    required this.loggedIn,
    required this.adminroleId,
    required this.franchisedBy,
    required this.staffAssignId,
    required this.franchiseAssignId,
    required this.staffAssignDate,
    required this.franchiseAssignDate,
    required this.commented,
    required this.adminroleViewStatus,
    required this.mobileVerifyStatus,
    required this.planId,
    required this.planName,
    required this.planStatus,
    required this.planExpiredOn,
    required this.isDeleted,
    required this.idProof,
    required this.idProofApprove,
    required this.idProofUploadedOn,
    required this.horoscopePhotoUploadedOn,
    required this.registeredFrom,
    required this.coverPhoto,
    required this.coverPhotoApprove,
    required this.coverPhotoUploadedOn,
    required this.cpasswordExpire,
    required this.bioDataTitle,
    required this.androidDeviceId,
    required this.iosDeviceId,
    required this.latitude,
    required this.longitude,
    required this.webDeviceId,
    required this.educationDetailOther,
    required this.employeeInOther,
    required this.designationOther,
    required this.occupationOther,
    required this.visitYourProfileNotification,
    required this.shortlistYourProfileNotification,
    required this.remindNotification,
    required this.chatMessageNotification,
    required this.adminNotification,
    required this.adminApproval,
    required this.step,
    required this.contact,
    required this.property,
    required this.expectations,
    required this.educationLevel,
    required this.updatedAt,
    required this.createdAt,
    required this.fromDate,
    required this.toDate,
  });

  Data copyWith({
    int? id,
    dynamic fbId,
    dynamic gId,
    String? matriId,
    dynamic referenceId,
    dynamic prefix,
    String? title,
    String? isNri,
    dynamic description,
    dynamic keyword,
    dynamic terms,
    dynamic email,
    dynamic password,
    dynamic cpassword,
    String? cpassStatus,
    String? maritalStatus,
    dynamic profileby,
    dynamic timeToCall,
    dynamic reference,
    String? username,
    dynamic firstname,
    dynamic lastname,
    dynamic gender,
    DateTime? birthdate,
    String? birthtime,
    String? birthplace,
    dynamic totalChildren,
    dynamic statusChildren,
    dynamic category,
    dynamic newEducationDetail,
    String? educationDetail,
    dynamic workingIn,
    String? income,
    String? occupation,
    dynamic employeeIn,
    dynamic designation,
    int? religion,
    String? caste,
    String? subcaste,
    String? gothra,
    dynamic gothraShowInBio,
    dynamic complexionShowInBio,
    dynamic star,
    dynamic moonsign,
    dynamic horoscope,
    dynamic manglik,
    dynamic motherTongue,
    String? height,
    dynamic weight,
    String? bloodGroup,
    String? complexion,
    dynamic bodytype,
    dynamic diet,
    dynamic smoke,
    dynamic drink,
    dynamic healthProblem,
    dynamic languagesKnown,
    String? address,
    int? countryId,
    dynamic stateId,
    dynamic city,
    dynamic nativeTaluka,
    dynamic phone,
    String? mobile,
    String? contactViewSecurity,
    dynamic residence,
    String? fatherName,
    String? motherName,
    dynamic fatherLivingStatus,
    dynamic motherLivingStatus,
    String? fatherOccupation,
    String? motherOccupation,
    dynamic profileText,
    dynamic lookingFor,
    dynamic familyDetails,
    dynamic familyType,
    dynamic familyStatus,
    dynamic fatherStatus,
    dynamic motherStatus,
    String? mamaSurname,
    String? surnameOfRelatives,
    dynamic familyValue,
    String? noOfBrothers,
    String? noOfSisters,
    dynamic noOfMarriedBrother,
    dynamic noOfMarriedSister,
    dynamic familyMobile,
    dynamic familyResidentAddress,
    String? familyNativePlace,
    String? fatherNameShowInBio,
    String? fatherOccupationShowInBio,
    String? motherNameShowInBio,
    String? motherOccupationShowInBio,
    String? familyMobileShowInBio,
    String? noOfBrothersShowInBio,
    String? noOfMarriedBrotherShowInBio,
    String? noOfSistersShowInBio,
    String? noOfMarriedSisterShowInBio,
    String? surnameOfRelativesShowInBio,
    String? familyResidentAddressShowInBio,
    String? familyNativePlaceShowInBio,
    String? mamaSurnameShowInBio,
    int? partFrmAge,
    int? partToAge,
    dynamic partBodytype,
    dynamic partDiet,
    dynamic partSmoke,
    dynamic partDrink,
    dynamic partIncome,
    dynamic partEmployeeIn,
    dynamic partOccupation,
    dynamic partDesignation,
    dynamic partExpect,
    String? partHeight,
    String? partHeightTo,
    dynamic partComplexion,
    dynamic partMotherTongue,
    dynamic partReligion,
    dynamic partCaste,
    dynamic partManglik,
    dynamic partStar,
    dynamic partEducation,
    dynamic partEducationNew,
    int? partCountryLiving,
    dynamic partState,
    dynamic partCity,
    dynamic partResiStatus,
    dynamic hobby,
    String? horoscopePhotoApprove,
    dynamic horoscopePhoto,
    String? photoProtect,
    dynamic photoPassword,
    dynamic video,
    String? videoApproval,
    dynamic videoUrl,
    String? videoViewStatus,
    String? photoViewStatus,
    dynamic photo1,
    String? photo1Approve,
    dynamic photo2,
    String? photo2Approve,
    dynamic photo3,
    dynamic photo3Approve,
    dynamic photo4,
    dynamic photo4Approve,
    dynamic photo5,
    dynamic photo5Approve,
    dynamic photo6,
    dynamic photo6Approve,
    dynamic photo7,
    dynamic photo7Approve,
    dynamic photo8,
    dynamic photo8Approve,
    dynamic photo1UploadedOn,
    dynamic photo2UploadedOn,
    dynamic photo3UploadedOn,
    dynamic photo4UploadedOn,
    dynamic photo5UploadedOn,
    dynamic photo6UploadedOn,
    dynamic photo7UploadedOn,
    dynamic photo8UploadedOn,
    dynamic registeredOn,
    dynamic ip,
    dynamic agent,
    dynamic agentApprove,
    dynamic lastLogin,
    String? status,
    String? fstatus,
    dynamic loggedIn,
    dynamic adminroleId,
    dynamic franchisedBy,
    dynamic staffAssignId,
    dynamic franchiseAssignId,
    dynamic staffAssignDate,
    dynamic franchiseAssignDate,
    String? commented,
    dynamic adminroleViewStatus,
    String? mobileVerifyStatus,
    dynamic planId,
    dynamic planName,
    String? planStatus,
    dynamic planExpiredOn,
    String? isDeleted,
    dynamic idProof,
    String? idProofApprove,
    dynamic idProofUploadedOn,
    dynamic horoscopePhotoUploadedOn,
    String? registeredFrom,
    dynamic coverPhoto,
    String? coverPhotoApprove,
    dynamic coverPhotoUploadedOn,
    dynamic cpasswordExpire,
    dynamic bioDataTitle,
    dynamic androidDeviceId,
    dynamic iosDeviceId,
    dynamic latitude,
    dynamic longitude,
    dynamic webDeviceId,
    dynamic educationDetailOther,
    dynamic employeeInOther,
    dynamic designationOther,
    dynamic occupationOther,
    String? visitYourProfileNotification,
    String? shortlistYourProfileNotification,
    String? remindNotification,
    String? chatMessageNotification,
    String? adminNotification,
    String? adminApproval,
    dynamic step,
    dynamic contact,
    String? property,
    String? expectations,
    String? educationLevel,
    DateTime? updatedAt,
    DateTime? createdAt,
    dynamic fromDate,
    dynamic toDate,
  }) =>
      Data(
        id: id ?? this.id,
        fbId: fbId ?? this.fbId,
        gId: gId ?? this.gId,
        matriId: matriId ?? this.matriId,
        referenceId: referenceId ?? this.referenceId,
        prefix: prefix ?? this.prefix,
        title: title ?? this.title,
        isNri: isNri ?? this.isNri,
        description: description ?? this.description,
        keyword: keyword ?? this.keyword,
        terms: terms ?? this.terms,
        email: email ?? this.email,
        password: password ?? this.password,
        cpassword: cpassword ?? this.cpassword,
        cpassStatus: cpassStatus ?? this.cpassStatus,
        maritalStatus: maritalStatus ?? this.maritalStatus,
        profileby: profileby ?? this.profileby,
        timeToCall: timeToCall ?? this.timeToCall,
        reference: reference ?? this.reference,
        username: username ?? this.username,
        firstname: firstname ?? this.firstname,
        lastname: lastname ?? this.lastname,
        gender: gender ?? this.gender,
        birthdate: birthdate ?? this.birthdate,
        birthtime: birthtime ?? this.birthtime,
        birthplace: birthplace ?? this.birthplace,
        totalChildren: totalChildren ?? this.totalChildren,
        statusChildren: statusChildren ?? this.statusChildren,
        category: category ?? this.category,
        newEducationDetail: newEducationDetail ?? this.newEducationDetail,
        educationDetail: educationDetail ?? this.educationDetail,
        workingIn: workingIn ?? this.workingIn,
        income: income ?? this.income,
        occupation: occupation ?? this.occupation,
        employeeIn: employeeIn ?? this.employeeIn,
        designation: designation ?? this.designation,
        religion: religion ?? this.religion,
        caste: caste ?? this.caste,
        subcaste: subcaste ?? this.subcaste,
        gothra: gothra ?? this.gothra,
        gothraShowInBio: gothraShowInBio ?? this.gothraShowInBio,
        complexionShowInBio: complexionShowInBio ?? this.complexionShowInBio,
        star: star ?? this.star,
        moonsign: moonsign ?? this.moonsign,
        horoscope: horoscope ?? this.horoscope,
        manglik: manglik ?? this.manglik,
        motherTongue: motherTongue ?? this.motherTongue,
        height: height ?? this.height,
        weight: weight ?? this.weight,
        bloodGroup: bloodGroup ?? this.bloodGroup,
        complexion: complexion ?? this.complexion,
        bodytype: bodytype ?? this.bodytype,
        diet: diet ?? this.diet,
        smoke: smoke ?? this.smoke,
        drink: drink ?? this.drink,
        healthProblem: healthProblem ?? this.healthProblem,
        languagesKnown: languagesKnown ?? this.languagesKnown,
        address: address ?? this.address,
        countryId: countryId ?? this.countryId,
        stateId: stateId ?? this.stateId,
        city: city ?? this.city,
        nativeTaluka: nativeTaluka ?? this.nativeTaluka,
        phone: phone ?? this.phone,
        mobile: mobile ?? this.mobile,
        contactViewSecurity: contactViewSecurity ?? this.contactViewSecurity,
        residence: residence ?? this.residence,
        fatherName: fatherName ?? this.fatherName,
        motherName: motherName ?? this.motherName,
        fatherLivingStatus: fatherLivingStatus ?? this.fatherLivingStatus,
        motherLivingStatus: motherLivingStatus ?? this.motherLivingStatus,
        fatherOccupation: fatherOccupation ?? this.fatherOccupation,
        motherOccupation: motherOccupation ?? this.motherOccupation,
        profileText: profileText ?? this.profileText,
        lookingFor: lookingFor ?? this.lookingFor,
        familyDetails: familyDetails ?? this.familyDetails,
        familyType: familyType ?? this.familyType,
        familyStatus: familyStatus ?? this.familyStatus,
        fatherStatus: fatherStatus ?? this.fatherStatus,
        motherStatus: motherStatus ?? this.motherStatus,
        mamaSurname: mamaSurname ?? this.mamaSurname,
        surnameOfRelatives: surnameOfRelatives ?? this.surnameOfRelatives,
        familyValue: familyValue ?? this.familyValue,
        noOfBrothers: noOfBrothers ?? this.noOfBrothers,
        noOfSisters: noOfSisters ?? this.noOfSisters,
        noOfMarriedBrother: noOfMarriedBrother ?? this.noOfMarriedBrother,
        noOfMarriedSister: noOfMarriedSister ?? this.noOfMarriedSister,
        familyMobile: familyMobile ?? this.familyMobile,
        familyResidentAddress:
            familyResidentAddress ?? this.familyResidentAddress,
        familyNativePlace: familyNativePlace ?? this.familyNativePlace,
        fatherNameShowInBio: fatherNameShowInBio ?? this.fatherNameShowInBio,
        fatherOccupationShowInBio:
            fatherOccupationShowInBio ?? this.fatherOccupationShowInBio,
        motherNameShowInBio: motherNameShowInBio ?? this.motherNameShowInBio,
        motherOccupationShowInBio:
            motherOccupationShowInBio ?? this.motherOccupationShowInBio,
        familyMobileShowInBio:
            familyMobileShowInBio ?? this.familyMobileShowInBio,
        noOfBrothersShowInBio:
            noOfBrothersShowInBio ?? this.noOfBrothersShowInBio,
        noOfMarriedBrotherShowInBio:
            noOfMarriedBrotherShowInBio ?? this.noOfMarriedBrotherShowInBio,
        noOfSistersShowInBio: noOfSistersShowInBio ?? this.noOfSistersShowInBio,
        noOfMarriedSisterShowInBio:
            noOfMarriedSisterShowInBio ?? this.noOfMarriedSisterShowInBio,
        surnameOfRelativesShowInBio:
            surnameOfRelativesShowInBio ?? this.surnameOfRelativesShowInBio,
        familyResidentAddressShowInBio: familyResidentAddressShowInBio ??
            this.familyResidentAddressShowInBio,
        familyNativePlaceShowInBio:
            familyNativePlaceShowInBio ?? this.familyNativePlaceShowInBio,
        mamaSurnameShowInBio: mamaSurnameShowInBio ?? this.mamaSurnameShowInBio,
        partFrmAge: partFrmAge ?? this.partFrmAge,
        partToAge: partToAge ?? this.partToAge,
        partBodytype: partBodytype ?? this.partBodytype,
        partDiet: partDiet ?? this.partDiet,
        partSmoke: partSmoke ?? this.partSmoke,
        partDrink: partDrink ?? this.partDrink,
        partIncome: partIncome ?? this.partIncome,
        partEmployeeIn: partEmployeeIn ?? this.partEmployeeIn,
        partOccupation: partOccupation ?? this.partOccupation,
        partDesignation: partDesignation ?? this.partDesignation,
        partExpect: partExpect ?? this.partExpect,
        partHeight: partHeight ?? this.partHeight,
        partHeightTo: partHeightTo ?? this.partHeightTo,
        partComplexion: partComplexion ?? this.partComplexion,
        partMotherTongue: partMotherTongue ?? this.partMotherTongue,
        partReligion: partReligion ?? this.partReligion,
        partCaste: partCaste ?? this.partCaste,
        partManglik: partManglik ?? this.partManglik,
        partStar: partStar ?? this.partStar,
        partEducation: partEducation ?? this.partEducation,
        partEducationNew: partEducationNew ?? this.partEducationNew,
        partCountryLiving: partCountryLiving ?? this.partCountryLiving,
        partState: partState ?? this.partState,
        partCity: partCity ?? this.partCity,
        partResiStatus: partResiStatus ?? this.partResiStatus,
        hobby: hobby ?? this.hobby,
        horoscopePhotoApprove:
            horoscopePhotoApprove ?? this.horoscopePhotoApprove,
        horoscopePhoto: horoscopePhoto ?? this.horoscopePhoto,
        photoProtect: photoProtect ?? this.photoProtect,
        photoPassword: photoPassword ?? this.photoPassword,
        video: video ?? this.video,
        videoApproval: videoApproval ?? this.videoApproval,
        videoUrl: videoUrl ?? this.videoUrl,
        videoViewStatus: videoViewStatus ?? this.videoViewStatus,
        photoViewStatus: photoViewStatus ?? this.photoViewStatus,
        photo1: photo1 ?? this.photo1,
        photo1Approve: photo1Approve ?? this.photo1Approve,
        photo2: photo2 ?? this.photo2,
        photo2Approve: photo2Approve ?? this.photo2Approve,
        photo3: photo3 ?? this.photo3,
        photo3Approve: photo3Approve ?? this.photo3Approve,
        photo4: photo4 ?? this.photo4,
        photo4Approve: photo4Approve ?? this.photo4Approve,
        photo5: photo5 ?? this.photo5,
        photo5Approve: photo5Approve ?? this.photo5Approve,
        photo6: photo6 ?? this.photo6,
        photo6Approve: photo6Approve ?? this.photo6Approve,
        photo7: photo7 ?? this.photo7,
        photo7Approve: photo7Approve ?? this.photo7Approve,
        photo8: photo8 ?? this.photo8,
        photo8Approve: photo8Approve ?? this.photo8Approve,
        photo1UploadedOn: photo1UploadedOn ?? this.photo1UploadedOn,
        photo2UploadedOn: photo2UploadedOn ?? this.photo2UploadedOn,
        photo3UploadedOn: photo3UploadedOn ?? this.photo3UploadedOn,
        photo4UploadedOn: photo4UploadedOn ?? this.photo4UploadedOn,
        photo5UploadedOn: photo5UploadedOn ?? this.photo5UploadedOn,
        photo6UploadedOn: photo6UploadedOn ?? this.photo6UploadedOn,
        photo7UploadedOn: photo7UploadedOn ?? this.photo7UploadedOn,
        photo8UploadedOn: photo8UploadedOn ?? this.photo8UploadedOn,
        registeredOn: registeredOn ?? this.registeredOn,
        ip: ip ?? this.ip,
        agent: agent ?? this.agent,
        agentApprove: agentApprove ?? this.agentApprove,
        lastLogin: lastLogin ?? this.lastLogin,
        status: status ?? this.status,
        fstatus: fstatus ?? this.fstatus,
        loggedIn: loggedIn ?? this.loggedIn,
        adminroleId: adminroleId ?? this.adminroleId,
        franchisedBy: franchisedBy ?? this.franchisedBy,
        staffAssignId: staffAssignId ?? this.staffAssignId,
        franchiseAssignId: franchiseAssignId ?? this.franchiseAssignId,
        staffAssignDate: staffAssignDate ?? this.staffAssignDate,
        franchiseAssignDate: franchiseAssignDate ?? this.franchiseAssignDate,
        commented: commented ?? this.commented,
        adminroleViewStatus: adminroleViewStatus ?? this.adminroleViewStatus,
        mobileVerifyStatus: mobileVerifyStatus ?? this.mobileVerifyStatus,
        planId: planId ?? this.planId,
        planName: planName ?? this.planName,
        planStatus: planStatus ?? this.planStatus,
        planExpiredOn: planExpiredOn ?? this.planExpiredOn,
        isDeleted: isDeleted ?? this.isDeleted,
        idProof: idProof ?? this.idProof,
        idProofApprove: idProofApprove ?? this.idProofApprove,
        idProofUploadedOn: idProofUploadedOn ?? this.idProofUploadedOn,
        horoscopePhotoUploadedOn:
            horoscopePhotoUploadedOn ?? this.horoscopePhotoUploadedOn,
        registeredFrom: registeredFrom ?? this.registeredFrom,
        coverPhoto: coverPhoto ?? this.coverPhoto,
        coverPhotoApprove: coverPhotoApprove ?? this.coverPhotoApprove,
        coverPhotoUploadedOn: coverPhotoUploadedOn ?? this.coverPhotoUploadedOn,
        cpasswordExpire: cpasswordExpire ?? this.cpasswordExpire,
        bioDataTitle: bioDataTitle ?? this.bioDataTitle,
        androidDeviceId: androidDeviceId ?? this.androidDeviceId,
        iosDeviceId: iosDeviceId ?? this.iosDeviceId,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        webDeviceId: webDeviceId ?? this.webDeviceId,
        educationDetailOther: educationDetailOther ?? this.educationDetailOther,
        employeeInOther: employeeInOther ?? this.employeeInOther,
        designationOther: designationOther ?? this.designationOther,
        occupationOther: occupationOther ?? this.occupationOther,
        visitYourProfileNotification:
            visitYourProfileNotification ?? this.visitYourProfileNotification,
        shortlistYourProfileNotification: shortlistYourProfileNotification ??
            this.shortlistYourProfileNotification,
        remindNotification: remindNotification ?? this.remindNotification,
        chatMessageNotification:
            chatMessageNotification ?? this.chatMessageNotification,
        adminNotification: adminNotification ?? this.adminNotification,
        adminApproval: adminApproval ?? this.adminApproval,
        step: step ?? this.step,
        contact: contact ?? this.contact,
        property: property ?? this.property,
        expectations: expectations ?? this.expectations,
        educationLevel: educationLevel ?? this.educationLevel,
        updatedAt: updatedAt ?? this.updatedAt,
        createdAt: createdAt ?? this.createdAt,
        fromDate: fromDate ?? this.fromDate,
        toDate: toDate ?? this.toDate,
      );
}
