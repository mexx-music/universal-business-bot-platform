class Company {
  final String id;
  final String name;
  final String industry;
  final String description;
  final String website;
  final String email;
  final String phone;
  final String address;

  const Company({
    required this.id,
    required this.name,
    required this.industry,
    required this.description,
    required this.website,
    required this.email,
    required this.phone,
    required this.address,
  });

  Company copyWith({
    String? name,
    String? industry,
    String? description,
    String? website,
    String? email,
    String? phone,
    String? address,
  }) {
    return Company(
      id: id,
      name: name ?? this.name,
      industry: industry ?? this.industry,
      description: description ?? this.description,
      website: website ?? this.website,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }
}
