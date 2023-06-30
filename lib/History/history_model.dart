class Logs {
  final int AccountID; 
  final int GlocuseLevel;
  final int Timestamp;
  final String Classification;

  Logs(this.AccountID, this.GlocuseLevel, this.Timestamp,
      this.Classification);

  Logs.fromMap(Map<String, dynamic> item)
      : AccountID = item["AccountID"],
        GlocuseLevel = item["GlucoseLevel"],
        Timestamp = item["Timestamp"],
        Classification = item["Classification"];

  Map<String, dynamic> toMap() {
    return {
      'AccountID' : AccountID,
      'GlucoseLevel': GlocuseLevel,
      'Timestamp': Timestamp,
      'Classification': Classification,
    };
  }
}