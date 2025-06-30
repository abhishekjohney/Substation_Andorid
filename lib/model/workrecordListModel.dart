class WorkListModel {
  dynamic RecordID;
  dynamic MAJOR;
  dynamic SSNAME;
  dynamic Project;
  dynamic TR;
  dynamic PACI;
  dynamic SGMAKE;
  dynamic SGTYPE;
  dynamic EntryDate;
  WorkListModel({
    this.RecordID,
    this.MAJOR,
    this.SSNAME,
    this.Project,
    this.TR,
    this.PACI,
    this.SGMAKE,
    this.SGTYPE,
    this.EntryDate
  });

  factory WorkListModel.fromJson(Map<dynamic, dynamic> json) {
    return WorkListModel(
        RecordID: json['RecordID'],
        MAJOR: json['MAJOR'],
        SSNAME: json['SSNAME'],
        Project: json['Project'],
        TR: json['TR'],
        PACI: json['PACI'],
        SGMAKE: json['SGMAKE'],
        SGTYPE: json['SGTYPE'],
        EntryDate: json['EntryDate']
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      'RecordID': RecordID,
      'MAJOR': MAJOR,
      'SSNAME': SSNAME,
      'Project': Project,
      'TR': TR,
      'PACI': PACI,
      'SGMAKE': SGMAKE,
      'SGTYPE': SGTYPE,
      'EntryDate': EntryDate
    };
  }
}




