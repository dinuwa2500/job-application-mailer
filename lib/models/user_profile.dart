class UserProfile {
  final String name;
  final String phone;
  final String senderEmail;
  final String degree;
  final String skills;
  final String? defaultPdfPath;
  final String? defaultPdfName;

  UserProfile({
    required this.name,
    required this.phone,
    required this.senderEmail,
    required this.degree,
    required this.skills,
    this.defaultPdfPath,
    this.defaultPdfName,
  });

  factory UserProfile.defaultProfile() {
    return UserProfile(
      name: 'Lakviru Perera',
      phone: '0704224786',
      senderEmail: '',
      degree: 'BSc (Hons) in Information Technology, specializing in Software Engineering',
      skills: 'Tailwind CSS, the MERN stack (MongoDB, Express.js, React, Node.js), and Java and Python',
      defaultPdfPath: null,
      defaultPdfName: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'senderEmail': senderEmail,
      'degree': degree,
      'skills': skills,
      'defaultPdfPath': defaultPdfPath,
      'defaultPdfName': defaultPdfName,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? 'Lakviru Perera',
      phone: json['phone'] ?? '0704224786',
      senderEmail: json['senderEmail'] ?? '',
      degree: json['degree'] ??
          'BSc (Hons) in Information Technology, specializing in Software Engineering',
      skills: json['skills'] ??
          'Tailwind CSS, the MERN stack (MongoDB, Express.js, React, Node.js), and Java and Python',
      defaultPdfPath: json['defaultPdfPath'],
      defaultPdfName: json['defaultPdfName'],
    );
  }

  UserProfile copyWith({
    String? name,
    String? phone,
    String? senderEmail,
    String? degree,
    String? skills,
    String? defaultPdfPath,
    String? defaultPdfName,
  }) {
    return UserProfile(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      senderEmail: senderEmail ?? this.senderEmail,
      degree: degree ?? this.degree,
      skills: skills ?? this.skills,
      defaultPdfPath: defaultPdfPath ?? this.defaultPdfPath,
      defaultPdfName: defaultPdfName ?? this.defaultPdfName,
    );
  }
}
