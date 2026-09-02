// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$UserStore on UserStoreBase, Store {
  late final _$userCollectionAtom =
      Atom(name: 'UserStoreBase.userCollection', context: context);

  @override
  ObservableMap<String, User> get userCollection {
    _$userCollectionAtom.reportRead();
    return super.userCollection;
  }

  @override
  set userCollection(ObservableMap<String, User> value) {
    _$userCollectionAtom.reportWrite(value, super.userCollection, () {
      super.userCollection = value;
    });
  }

  late final _$searchUserIdsAtom =
      Atom(name: 'UserStoreBase.searchUserIds', context: context);

  @override
  ObservableList<String> get searchUserIds {
    _$searchUserIdsAtom.reportRead();
    return super.searchUserIds;
  }

  @override
  set searchUserIds(ObservableList<String> value) {
    _$searchUserIdsAtom.reportWrite(value, super.searchUserIds, () {
      super.searchUserIds = value;
    });
  }

  late final _$loggedInUserAtom =
      Atom(name: 'UserStoreBase.loggedInUser', context: context);

  @override
  User? get loggedInUser {
    _$loggedInUserAtom.reportRead();
    return super.loggedInUser;
  }

  @override
  set loggedInUser(User? value) {
    _$loggedInUserAtom.reportWrite(value, super.loggedInUser, () {
      super.loggedInUser = value;
    });
  }

  late final _$isLoginLoadingAtom =
      Atom(name: 'UserStoreBase.isLoginLoading', context: context);

  @override
  bool get isLoginLoading {
    _$isLoginLoadingAtom.reportRead();
    return super.isLoginLoading;
  }

  @override
  set isLoginLoading(bool value) {
    _$isLoginLoadingAtom.reportWrite(value, super.isLoginLoading, () {
      super.isLoginLoading = value;
    });
  }

  late final _$isImageUploadingAtom =
      Atom(name: 'UserStoreBase.isImageUploading', context: context);

  @override
  bool get isImageUploading {
    _$isImageUploadingAtom.reportRead();
    return super.isImageUploading;
  }

  @override
  set isImageUploading(bool value) {
    _$isImageUploadingAtom.reportWrite(value, super.isImageUploading, () {
      super.isImageUploading = value;
    });
  }

  late final _$isErrorAtom =
      Atom(name: 'UserStoreBase.isError', context: context);

  @override
  bool get isError {
    _$isErrorAtom.reportRead();
    return super.isError;
  }

  @override
  set isError(bool value) {
    _$isErrorAtom.reportWrite(value, super.isError, () {
      super.isError = value;
    });
  }

  late final _$errorMessageAtom =
      Atom(name: 'UserStoreBase.errorMessage', context: context);

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$recipientAtom =
      Atom(name: 'UserStoreBase.recipient', context: context);

  @override
  String? get recipient {
    _$recipientAtom.reportRead();
    return super.recipient;
  }

  @override
  set recipient(String? value) {
    _$recipientAtom.reportWrite(value, super.recipient, () {
      super.recipient = value;
    });
  }

  late final _$isVerifyingAtom =
      Atom(name: 'UserStoreBase.isVerifying', context: context);

  @override
  bool get isVerifying {
    _$isVerifyingAtom.reportRead();
    return super.isVerifying;
  }

  @override
  set isVerifying(bool value) {
    _$isVerifyingAtom.reportWrite(value, super.isVerifying, () {
      super.isVerifying = value;
    });
  }

  late final _$isListLoadingAtom =
      Atom(name: 'UserStoreBase.isListLoading', context: context);

  @override
  bool get isListLoading {
    _$isListLoadingAtom.reportRead();
    return super.isListLoading;
  }

  @override
  set isListLoading(bool value) {
    _$isListLoadingAtom.reportWrite(value, super.isListLoading, () {
      super.isListLoading = value;
    });
  }

  late final _$isCardLoadingAtom =
      Atom(name: 'UserStoreBase.isCardLoading', context: context);

  @override
  bool get isCardLoading {
    _$isCardLoadingAtom.reportRead();
    return super.isCardLoading;
  }

  @override
  set isCardLoading(bool value) {
    _$isCardLoadingAtom.reportWrite(value, super.isCardLoading, () {
      super.isCardLoading = value;
    });
  }

  late final _$themeModeAtom =
      Atom(name: 'UserStoreBase.themeMode', context: context);

  @override
  ThemeMode get themeMode {
    _$themeModeAtom.reportRead();
    return super.themeMode;
  }

  @override
  set themeMode(ThemeMode value) {
    _$themeModeAtom.reportWrite(value, super.themeMode, () {
      super.themeMode = value;
    });
  }

  late final _$cardListAtom =
      Atom(name: 'UserStoreBase.cardList', context: context);

  @override
  card.GetCardResponse? get cardList {
    _$cardListAtom.reportRead();
    return super.cardList;
  }

  @override
  set cardList(card.GetCardResponse? value) {
    _$cardListAtom.reportWrite(value, super.cardList, () {
      super.cardList = value;
    });
  }

  late final _$meResponseAtom =
      Atom(name: 'UserStoreBase.meResponse', context: context);

  @override
  MeResponse? get meResponse {
    _$meResponseAtom.reportRead();
    return super.meResponse;
  }

  @override
  set meResponse(MeResponse? value) {
    _$meResponseAtom.reportWrite(value, super.meResponse, () {
      super.meResponse = value;
    });
  }

  late final _$isAddingCardAtom =
      Atom(name: 'UserStoreBase.isAddingCard', context: context);

  @override
  bool get isAddingCard {
    _$isAddingCardAtom.reportRead();
    return super.isAddingCard;
  }

  @override
  set isAddingCard(bool value) {
    _$isAddingCardAtom.reportWrite(value, super.isAddingCard, () {
      super.isAddingCard = value;
    });
  }

  late final _$isPaymentLoadingAtom =
      Atom(name: 'UserStoreBase.isPaymentLoading', context: context);

  @override
  bool get isPaymentLoading {
    _$isPaymentLoadingAtom.reportRead();
    return super.isPaymentLoading;
  }

  @override
  set isPaymentLoading(bool value) {
    _$isPaymentLoadingAtom.reportWrite(value, super.isPaymentLoading, () {
      super.isPaymentLoading = value;
    });
  }

  late final _$isWalletLoadingAtom =
      Atom(name: 'UserStoreBase.isWalletLoading', context: context);

  @override
  bool get isWalletLoading {
    _$isWalletLoadingAtom.reportRead();
    return super.isWalletLoading;
  }

  @override
  set isWalletLoading(bool value) {
    _$isWalletLoadingAtom.reportWrite(value, super.isWalletLoading, () {
      super.isWalletLoading = value;
    });
  }

  late final _$walletBalanceAtom =
      Atom(name: 'UserStoreBase.walletBalance', context: context);

  @override
  Balance get walletBalance {
    _$walletBalanceAtom.reportRead();
    return super.walletBalance;
  }

  @override
  set walletBalance(Balance value) {
    _$walletBalanceAtom.reportWrite(value, super.walletBalance, () {
      super.walletBalance = value;
    });
  }

  late final _$isAddingAmountAtom =
      Atom(name: 'UserStoreBase.isAddingAmount', context: context);

  @override
  bool get isAddingAmount {
    _$isAddingAmountAtom.reportRead();
    return super.isAddingAmount;
  }

  @override
  set isAddingAmount(bool value) {
    _$isAddingAmountAtom.reportWrite(value, super.isAddingAmount, () {
      super.isAddingAmount = value;
    });
  }

  late final _$isTransactionLoadingAtom =
      Atom(name: 'UserStoreBase.isTransactionLoading', context: context);

  @override
  bool get isTransactionLoading {
    _$isTransactionLoadingAtom.reportRead();
    return super.isTransactionLoading;
  }

  @override
  set isTransactionLoading(bool value) {
    _$isTransactionLoadingAtom.reportWrite(value, super.isTransactionLoading,
        () {
      super.isTransactionLoading = value;
    });
  }

  late final _$loadMoreDataAtom =
      Atom(name: 'UserStoreBase.loadMoreData', context: context);

  @override
  bool get loadMoreData {
    _$loadMoreDataAtom.reportRead();
    return super.loadMoreData;
  }

  @override
  set loadMoreData(bool value) {
    _$loadMoreDataAtom.reportWrite(value, super.loadMoreData, () {
      super.loadMoreData = value;
    });
  }

  late final _$transactionPageNoAtom =
      Atom(name: 'UserStoreBase.transactionPageNo', context: context);

  @override
  int get transactionPageNo {
    _$transactionPageNoAtom.reportRead();
    return super.transactionPageNo;
  }

  @override
  set transactionPageNo(int value) {
    _$transactionPageNoAtom.reportWrite(value, super.transactionPageNo, () {
      super.transactionPageNo = value;
    });
  }

  late final _$transactionListAtom =
      Atom(name: 'UserStoreBase.transactionList', context: context);

  @override
  List<Transaction> get transactionList {
    _$transactionListAtom.reportRead();
    return super.transactionList;
  }

  @override
  set transactionList(List<Transaction> value) {
    _$transactionListAtom.reportWrite(value, super.transactionList, () {
      super.transactionList = value;
    });
  }

  late final _$isPromocodeLoadingAtom =
      Atom(name: 'UserStoreBase.isPromocodeLoading', context: context);

  @override
  bool get isPromocodeLoading {
    _$isPromocodeLoadingAtom.reportRead();
    return super.isPromocodeLoading;
  }

  @override
  set isPromocodeLoading(bool value) {
    _$isPromocodeLoadingAtom.reportWrite(value, super.isPromocodeLoading, () {
      super.isPromocodeLoading = value;
    });
  }

  late final _$promocodeListAtom =
      Atom(name: 'UserStoreBase.promocodeList', context: context);

  @override
  List<Bonuses> get promocodeList {
    _$promocodeListAtom.reportRead();
    return super.promocodeList;
  }

  @override
  set promocodeList(List<Bonuses> value) {
    _$promocodeListAtom.reportWrite(value, super.promocodeList, () {
      super.promocodeList = value;
    });
  }

  late final _$getSavedThemeAsyncAction =
      AsyncAction('UserStoreBase.getSavedTheme', context: context);

  @override
  Future<void> getSavedTheme() {
    return _$getSavedThemeAsyncAction.run(() => super.getSavedTheme());
  }

  late final _$registerFCMTokenAsyncAction =
      AsyncAction('UserStoreBase.registerFCMToken', context: context);

  @override
  Future<void> registerFCMToken() {
    return _$registerFCMTokenAsyncAction.run(() => super.registerFCMToken());
  }

  late final _$onboardUserAsyncAction =
      AsyncAction('UserStoreBase.onboardUser', context: context);

  @override
  Future<void> onboardUser() {
    return _$onboardUserAsyncAction.run(() => super.onboardUser());
  }

  late final _$getMeAsyncAction =
      AsyncAction('UserStoreBase.getMe', context: context);

  @override
  Future<void> getMe() {
    return _$getMeAsyncAction.run(() => super.getMe());
  }

  late final _$getMeMainPageAsyncAction =
      AsyncAction('UserStoreBase.getMeMainPage', context: context);

  @override
  Future<void> getMeMainPage() {
    return _$getMeMainPageAsyncAction.run(() => super.getMeMainPage());
  }

  late final _$loginAsyncAction =
      AsyncAction('UserStoreBase.login', context: context);

  @override
  Future<LoginResponse> login(LoginContract payload) {
    return _$loginAsyncAction.run(() => super.login(payload));
  }

  late final _$requestCodeAsyncAction =
      AsyncAction('UserStoreBase.requestCode', context: context);

  @override
  Future<void> requestCode(String recipient) {
    return _$requestCodeAsyncAction.run(() => super.requestCode(recipient));
  }

  late final _$updateFCMTokenAsyncAction =
      AsyncAction('UserStoreBase.updateFCMToken', context: context);

  @override
  Future<void> updateFCMToken() {
    return _$updateFCMTokenAsyncAction.run(() => super.updateFCMToken());
  }

  late final _$logoutUserAsyncAction =
      AsyncAction('UserStoreBase.logoutUser', context: context);

  @override
  Future<void> logoutUser({bool ignoreApiCall = false}) {
    return _$logoutUserAsyncAction
        .run(() => super.logoutUser(ignoreApiCall: ignoreApiCall));
  }

  late final _$updateUserAsyncAction =
      AsyncAction('UserStoreBase.updateUser', context: context);

  @override
  Future<void> updateUser(UserDetailsUpdateContract contract) {
    return _$updateUserAsyncAction.run(() => super.updateUser(contract));
  }

  late final _$uploadImageAsyncAction =
      AsyncAction('UserStoreBase.uploadImage', context: context);

  @override
  Future<String> uploadImage(String imagePath) {
    return _$uploadImageAsyncAction.run(() => super.uploadImage(imagePath));
  }

  late final _$signInWithGoogleAsyncAction =
      AsyncAction('UserStoreBase.signInWithGoogle', context: context);

  @override
  Future<void> signInWithGoogle() {
    return _$signInWithGoogleAsyncAction.run(() => super.signInWithGoogle());
  }

  late final _$addCardAsyncAction =
      AsyncAction('UserStoreBase.addCard', context: context);

  @override
  Future<void> addCard(
      {required String cardNumber,
      required String cvv,
      required String cardHolderName,
      required String expiryDate}) {
    return _$addCardAsyncAction.run(() => super.addCard(
        cardNumber: cardNumber,
        cvv: cvv,
        cardHolderName: cardHolderName,
        expiryDate: expiryDate));
  }

  late final _$getCardAsyncAction =
      AsyncAction('UserStoreBase.getCard', context: context);

  @override
  Future<void> getCard() {
    return _$getCardAsyncAction.run(() => super.getCard());
  }

  late final _$deleteCardAsyncAction =
      AsyncAction('UserStoreBase.deleteCard', context: context);

  @override
  Future<void> deleteCard(String cardId) {
    return _$deleteCardAsyncAction.run(() => super.deleteCard(cardId));
  }

  late final _$makeDirectPaymentAsyncAction =
      AsyncAction('UserStoreBase.makeDirectPayment', context: context);

  @override
  Future<bool> makeDirectPayment(num amount) {
    return _$makeDirectPaymentAsyncAction
        .run(() => super.makeDirectPayment(amount));
  }

  late final _$initializePaymentAsyncAction =
      AsyncAction('UserStoreBase.initializePayment', context: context);

  @override
  Future<Map<String, dynamic>> initializePayment(num amount) {
    return _$initializePaymentAsyncAction
        .run(() => super.initializePayment(amount));
  }

  late final _$addWalletAmountAsyncAction =
      AsyncAction('UserStoreBase.addWalletAmount', context: context);

  @override
  Future<void> addWalletAmount(num amount) {
    return _$addWalletAmountAsyncAction
        .run(() => super.addWalletAmount(amount));
  }

  late final _$getWalletAsyncAction =
      AsyncAction('UserStoreBase.getWallet', context: context);

  @override
  Future<void> getWallet() {
    return _$getWalletAsyncAction.run(() => super.getWallet());
  }

  late final _$getTransactionListAsyncAction =
      AsyncAction('UserStoreBase.getTransactionList', context: context);

  @override
  Future<void> getTransactionList() {
    return _$getTransactionListAsyncAction
        .run(() => super.getTransactionList());
  }

  late final _$getAllPromocodeAsyncAction =
      AsyncAction('UserStoreBase.getAllPromocode', context: context);

  @override
  Future<void> getAllPromocode() {
    return _$getAllPromocodeAsyncAction.run(() => super.getAllPromocode());
  }

  late final _$UserStoreBaseActionController =
      ActionController(name: 'UserStoreBase', context: context);

  @override
  void setThemeMode(ThemeMode mode) {
    final _$actionInfo = _$UserStoreBaseActionController.startAction(
        name: 'UserStoreBase.setThemeMode');
    try {
      return super.setThemeMode(mode);
    } finally {
      _$UserStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setListLoading(bool isLoading) {
    final _$actionInfo = _$UserStoreBaseActionController.startAction(
        name: 'UserStoreBase.setListLoading');
    try {
      return super.setListLoading(isLoading);
    } finally {
      _$UserStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCardLoading(bool isLoading) {
    final _$actionInfo = _$UserStoreBaseActionController.startAction(
        name: 'UserStoreBase.setCardLoading');
    try {
      return super.setCardLoading(isLoading);
    } finally {
      _$UserStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLoggedInUser(User? user) {
    final _$actionInfo = _$UserStoreBaseActionController.startAction(
        name: 'UserStoreBase.setLoggedInUser');
    try {
      return super.setLoggedInUser(user);
    } finally {
      _$UserStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setRecipient(String recipient) {
    final _$actionInfo = _$UserStoreBaseActionController.startAction(
        name: 'UserStoreBase.setRecipient');
    try {
      return super.setRecipient(recipient);
    } finally {
      _$UserStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setIsVerifying(bool isVerifying) {
    final _$actionInfo = _$UserStoreBaseActionController.startAction(
        name: 'UserStoreBase.setIsVerifying');
    try {
      return super.setIsVerifying(isVerifying);
    } finally {
      _$UserStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setIsLoginLoading(bool isLoading) {
    final _$actionInfo = _$UserStoreBaseActionController.startAction(
        name: 'UserStoreBase.setIsLoginLoading');
    try {
      return super.setIsLoginLoading(isLoading);
    } finally {
      _$UserStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setIsImageUploading(bool isLoading) {
    final _$actionInfo = _$UserStoreBaseActionController.startAction(
        name: 'UserStoreBase.setIsImageUploading');
    try {
      return super.setIsImageUploading(isLoading);
    } finally {
      _$UserStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setIsError(bool error) {
    final _$actionInfo = _$UserStoreBaseActionController.startAction(
        name: 'UserStoreBase.setIsError');
    try {
      return super.setIsError(error);
    } finally {
      _$UserStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setErrorMessage(String? message) {
    final _$actionInfo = _$UserStoreBaseActionController.startAction(
        name: 'UserStoreBase.setErrorMessage');
    try {
      return super.setErrorMessage(message);
    } finally {
      _$UserStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addUsers(List<User> users, [bool addSearchIds = false]) {
    final _$actionInfo = _$UserStoreBaseActionController.startAction(
        name: 'UserStoreBase.addUsers');
    try {
      return super.addUsers(users, addSearchIds);
    } finally {
      _$UserStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearSearchUsersId() {
    final _$actionInfo = _$UserStoreBaseActionController.startAction(
        name: 'UserStoreBase.clearSearchUsersId');
    try {
      return super.clearSearchUsersId();
    } finally {
      _$UserStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
userCollection: ${userCollection},
searchUserIds: ${searchUserIds},
loggedInUser: ${loggedInUser},
isLoginLoading: ${isLoginLoading},
isImageUploading: ${isImageUploading},
isError: ${isError},
errorMessage: ${errorMessage},
recipient: ${recipient},
isVerifying: ${isVerifying},
isListLoading: ${isListLoading},
isCardLoading: ${isCardLoading},
themeMode: ${themeMode},
cardList: ${cardList},
meResponse: ${meResponse},
isAddingCard: ${isAddingCard},
isPaymentLoading: ${isPaymentLoading},
isWalletLoading: ${isWalletLoading},
walletBalance: ${walletBalance},
isAddingAmount: ${isAddingAmount},
isTransactionLoading: ${isTransactionLoading},
loadMoreData: ${loadMoreData},
transactionPageNo: ${transactionPageNo},
transactionList: ${transactionList},
isPromocodeLoading: ${isPromocodeLoading},
promocodeList: ${promocodeList}
    ''';
  }
}
