/// The logged-in account. Distinct from [Member]: [AppUser] is the mock
/// authentication identity, while [Member.memberId] links it to the
/// household member record that expenses and balances are computed against.
class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.memberId,
  });

  final String id;
  final String name;
  final String email;
  final String memberId;
}
