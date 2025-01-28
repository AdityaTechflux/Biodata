class SubscriptionApiModel {
  bool? response;
  String? successMsg;
  String? errorMsg;
  List<Data>? data;

  SubscriptionApiModel(
      {this.response, this.successMsg, this.errorMsg, this.data});

  SubscriptionApiModel.fromJson(Map<String, dynamic> json) {
    response = json["response"];
    successMsg = json["success_msg"];
    errorMsg = json["error_msg"];
    data = json["data"] == null
        ? null
        : (json["data"] as List).map((e) => Data.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["response"] = response;
    _data["success_msg"] = successMsg;
    _data["error_msg"] = errorMsg;
    if (data != null) {
      _data["data"] = data?.map((e) => e.toJson()).toList();
    }
    return _data;
  }
}

class Data {
  int? id;
  String? planName;
  int? price;
  int? iosPrice;
  int? planDays;
  dynamic planDesc;
  String? status;
  String? subscriptionCreated;
  String? subscriptionUpdated;
  String? isDeleted;

  Data(
      {this.id,
      this.planName,
      this.price,
      this.iosPrice,
      this.planDays,
      this.planDesc,
      this.status,
      this.subscriptionCreated,
      this.subscriptionUpdated,
      this.isDeleted});

  Data.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    planName = json["plan_name"];
    price = json["price"];
    iosPrice = json["ios_price"];
    planDays = json["plan_days"];
    planDesc = json["plan_desc"];
    status = json["status"];
    subscriptionCreated = json["subscription_created"];
    subscriptionUpdated = json["subscription_updated"];
    isDeleted = json["is_deleted"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["plan_name"] = planName;
    _data["price"] = price;
    _data["ios_price"] = iosPrice;
    _data["plan_days"] = planDays;
    _data["plan_desc"] = planDesc;
    _data["status"] = status;
    _data["subscription_created"] = subscriptionCreated;
    _data["subscription_updated"] = subscriptionUpdated;
    _data["is_deleted"] = isDeleted;
    return _data;
  }
}
