class Location {
  String rsPeerId;
  String rsGpgId;
  String accountName;
  String locationName;
  bool isOnline;

  Location([
    this.rsPeerId,
    this.rsGpgId,
    this.accountName,
    this.locationName,
    this.isOnline = false,
  ]);
}
