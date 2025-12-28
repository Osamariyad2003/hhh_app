/// Hospital model based on schema
class HospitalModel {
  final String id;
  final String name;
  final HospitalContactInfo contactInfo;

  const HospitalModel({
    required this.id,
    required this.name,
    required this.contactInfo,
  });

  factory HospitalModel.fromJson(Map<String, dynamic> json) {
    return HospitalModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String,
      contactInfo: HospitalContactInfo.fromJson(
        json['contactInfo'] as Map<String, dynamic>? ??
            json['contact_info'] as Map<String, dynamic>? ??
            {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contactInfo': contactInfo.toJson(),
    };
  }

  HospitalModel copyWith({
    String? id,
    String? name,
    HospitalContactInfo? contactInfo,
  }) {
    return HospitalModel(
      id: id ?? this.id,
      name: name ?? this.name,
      contactInfo: contactInfo ?? this.contactInfo,
    );
  }
}

class HospitalContactInfo {
  final String? phone;
  final String? email;
  final String address;

  const HospitalContactInfo({
    this.phone,
    this.email,
    required this.address,
  });

  factory HospitalContactInfo.fromJson(Map<String, dynamic> json) {
    return HospitalContactInfo(
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      'address': address,
    };
  }
}

