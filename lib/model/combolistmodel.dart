class ComboListModel {
  dynamic SSNAME;
  ComboListModel({
    this.SSNAME
  });

  factory ComboListModel.fromJson(Map<dynamic, dynamic> json) {
    return ComboListModel(
        SSNAME: json['SSNAME']
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      'SSNAME': SSNAME
    };
  }
}
