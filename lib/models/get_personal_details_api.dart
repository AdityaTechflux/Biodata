class GetPersonalDetailsApi {
  bool? response;
  String? successMsg;
  String? errorMsg;
  List<Data>? data;

  GetPersonalDetailsApi(
      {this.response, this.successMsg, this.errorMsg, this.data});

  GetPersonalDetailsApi.fromJson(Map<String, dynamic> json) {
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
  String? label;
  String? value;
  String? static;
  String? param;
  String? type;
  List<dynamic>? options;

  Data(
      {this.label,
      this.value,
      this.static,
      this.param,
      this.type,
      this.options});

  Data.fromJson(Map<String, dynamic> json) {
    label = json["label"];
    value = json["value"];
    static = json["static"];
    param = json["param"];
    type = json["type"];
    options = json["options"] ?? [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["label"] = label;
    _data["value"] = value;
    _data["static"] = static;
    _data["param"] = param;
    _data["type"] = type;
    if (options != null) {
      _data["options"] = options;
    }
    return _data;
  }
}
