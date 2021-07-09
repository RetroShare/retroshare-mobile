class Account {
  String locationId;
  String pgpId;
  String locationName;
  String pgpName;

  Account(this.locationId, this.pgpId, this.locationName, this.pgpName);
}

List<Account> accountsList;
Account lastAccountUsed;
Account loggedinAccount;