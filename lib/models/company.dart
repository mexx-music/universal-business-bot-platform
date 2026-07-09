class Company {
  final String id;
  final String name;
  final String industry;
  final String description;
  final String country;
  final String primaryLanguage;
  final String website;
  final String email;
  final String? phone;
  final String address;
  final Map<String, String> socialLinks;
  final String internalNotes;

  const Company({
    required this.id,
    required this.name,
    required this.industry,
    required this.description,
    this.country = '',
    this.primaryLanguage = 'de',
    required this.website,
    required this.email,
    this.phone,
    required this.address,
    this.socialLinks = const {},
    this.internalNotes = '',
  });

  String get companyName => name;
  String get shortDescription => description;
  String get category => industry;
  String get supportEmail => email;
  String get supportPhone => phone ?? '';

  Company copyWith({
    String? name,
    String? industry,
    String? description,
    String? country,
    String? primaryLanguage,
    String? website,
    String? email,
    String? phone,
    String? address,
    Map<String, String>? socialLinks,
    String? internalNotes,
  }) {
    return Company(
      id: id,
      name: name ?? this.name,
      industry: industry ?? this.industry,
      description: description ?? this.description,
      country: country ?? this.country,
      primaryLanguage: primaryLanguage ?? this.primaryLanguage,
      website: website ?? this.website,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      socialLinks: socialLinks ?? this.socialLinks,
      internalNotes: internalNotes ?? this.internalNotes,
    );
  }
}
