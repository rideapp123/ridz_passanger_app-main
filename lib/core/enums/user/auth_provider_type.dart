enum AuthProviderType {
  email('email'),
  google('google'),
  mobile('mobile');

  const AuthProviderType(this.message);
  final String message;
}
