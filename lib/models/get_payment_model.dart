class GetPaymentModel {
  bool? success;
  String? message;
  Order? order;
  SubscriptionDetails? subscriptionDetails;

  GetPaymentModel(
      {this.success, this.message, this.order, this.subscriptionDetails});

  GetPaymentModel.fromJson(Map<String, dynamic> json) {
    success = json["success"];
    message = json["message"];
    order = json["order"] == null ? null : Order.fromJson(json["order"]);
    subscriptionDetails = json["subscription_details"] == null
        ? null
        : SubscriptionDetails.fromJson(json["subscription_details"]);
  }

  static List<GetPaymentModel> fromList(List<Map<String, dynamic>> list) {
    return list.map(GetPaymentModel.fromJson).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["success"] = success;
    _data["message"] = message;
    if (order != null) {
      _data["order"] = order?.toJson();
    }
    if (subscriptionDetails != null) {
      _data["subscription_details"] = subscriptionDetails?.toJson();
    }
    return _data;
  }
}

class SubscriptionDetails {
  int? id;
  String? planName;
  int? price;
  int? iosPrice;
  int? planDays;
  String? expirationDate;
  String? planDesc;
  String? status;
  String? subscriptionCreated;
  String? subscriptionUpdated;
  String? isDeleted;

  SubscriptionDetails(
      {this.id,
      this.planName,
      this.price,
      this.iosPrice,
      this.planDays,
      this.expirationDate,
      this.planDesc,
      this.status,
      this.subscriptionCreated,
      this.subscriptionUpdated,
      this.isDeleted});

  SubscriptionDetails.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    planName = json["plan_name"];
    price = json["price"];
    iosPrice = json["ios_price"];
    planDays = json["plan_days"];
    expirationDate = json["expiration_date"];
    planDesc = json["plan_desc"];
    status = json["status"];
    subscriptionCreated = json["subscription_created"];
    subscriptionUpdated = json["subscription_updated"];
    isDeleted = json["is_deleted"];
  }

  static List<SubscriptionDetails> fromList(List<Map<String, dynamic>> list) {
    return list.map(SubscriptionDetails.fromJson).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["plan_name"] = planName;
    _data["price"] = price;
    _data["ios_price"] = iosPrice;
    _data["plan_days"] = planDays;
    _data["expiration_date"] = expirationDate;
    _data["plan_desc"] = planDesc;
    _data["status"] = status;
    _data["subscription_created"] = subscriptionCreated;
    _data["subscription_updated"] = subscriptionUpdated;
    _data["is_deleted"] = isDeleted;
    return _data;
  }
}

class Order {
  String? msg;
  String? key;
  int? amount;
  String? currency;
  String? customerId;
  String? businessName;
  String? businessLogo;
  String? callbackUrl;
  String? productDescription;
  CustomerDetail? customerDetail;
  String? razorpayModalTheme;
  List<dynamic>? notes;
  int? amountDue;
  int? amountPaid;
  int? attempts;
  int? createdAt;
  String? entity;
  String? id;
  dynamic offerId;
  String? receipt;
  String? status;

  Order(
      {this.msg,
      this.key,
      this.amount,
      this.currency,
      this.customerId,
      this.businessName,
      this.businessLogo,
      this.callbackUrl,
      this.productDescription,
      this.customerDetail,
      this.razorpayModalTheme,
      this.notes,
      this.amountDue,
      this.amountPaid,
      this.attempts,
      this.createdAt,
      this.entity,
      this.id,
      this.offerId,
      this.receipt,
      this.status});

  Order.fromJson(Map<String, dynamic> json) {
    msg = json["msg"];
    key = json["key"];
    amount = json["amount"];
    currency = json["currency"];
    customerId = json["customer_id"];
    businessName = json["business_name"];
    businessLogo = json["business_logo"];
    callbackUrl = json["callback_url"];
    productDescription = json["product_description"];
    customerDetail = json["customer_detail"] == null
        ? null
        : CustomerDetail.fromJson(json["customer_detail"]);
    razorpayModalTheme = json["razorpayModalTheme"];
    notes = json["notes"] ?? [];
    amountDue = json["amount_due"];
    amountPaid = json["amount_paid"];
    attempts = json["attempts"];
    createdAt = json["created_at"];
    entity = json["entity"];
    id = json["id"];
    offerId = json["offer_id"];
    receipt = json["receipt"];
    status = json["status"];
  }

  static List<Order> fromList(List<Map<String, dynamic>> list) {
    return list.map(Order.fromJson).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["msg"] = msg;
    _data["key"] = key;
    _data["amount"] = amount;
    _data["currency"] = currency;
    _data["customer_id"] = customerId;
    _data["business_name"] = businessName;
    _data["business_logo"] = businessLogo;
    _data["callback_url"] = callbackUrl;
    _data["product_description"] = productDescription;
    if (customerDetail != null) {
      _data["customer_detail"] = customerDetail?.toJson();
    }
    _data["razorpayModalTheme"] = razorpayModalTheme;
    if (notes != null) {
      _data["notes"] = notes;
    }
    _data["amount_due"] = amountDue;
    _data["amount_paid"] = amountPaid;
    _data["attempts"] = attempts;
    _data["created_at"] = createdAt;
    _data["entity"] = entity;
    _data["id"] = id;
    _data["offer_id"] = offerId;
    _data["receipt"] = receipt;
    _data["status"] = status;
    return _data;
  }
}

class CustomerDetail {
  String? name;
  String? email;
  String? contact;

  CustomerDetail({this.name, this.email, this.contact});

  CustomerDetail.fromJson(Map<String, dynamic> json) {
    name = json["name"];
    email = json["email"];
    contact = json["contact"];
  }

  static List<CustomerDetail> fromList(List<Map<String, dynamic>> list) {
    return list.map(CustomerDetail.fromJson).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["name"] = name;
    _data["email"] = email;
    _data["contact"] = contact;
    return _data;
  }
}
