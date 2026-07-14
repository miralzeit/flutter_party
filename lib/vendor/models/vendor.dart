/// The vendor's own profile, collected once on [SetUpProfileScreen] and
/// editable afterwards from Settings.
class Vendor {
  Vendor({
    required this.fullName,
    this.bio = '',
    this.phone = '',
    this.whatsapp = '',
    this.email = '',
    this.city = '',
    this.hasPhoto = false,
  });

  String fullName;
  String bio;
  String phone;
  String whatsapp;
  String email;
  String city;
  bool hasPhoto;

  /// Riverpod's [StateProvider] only notifies on a genuinely new reference,
  /// but every screen mutates a [Vendor] in place (cascade style) — this
  /// gives the edit-save path something fresh to assign.
  Vendor copy() => Vendor(
        fullName: fullName,
        bio: bio,
        phone: phone,
        whatsapp: whatsapp,
        email: email,
        city: city,
        hasPhoto: hasPhoto,
      );
}
