import 'user_profile.dart';

class PredefinedRoles {
  static const String internSoftwareEngineer = 'intern software engineer';
  static const String internFrontendDeveloper = 'intern frontend developer';
  static const String internFullStackDeveloper = 'intern full stack developer';
  static const String other = 'Other (Custom)';

  static const List<String> allRoles = [
    internSoftwareEngineer,
    internFrontendDeveloper,
    internFullStackDeveloper,
    other,
  ];
}

class EmailTemplate {
  static String generateSubject(String roleTitle) {
    // Capitalize first letters properly for subject title
    final cleanRole = roleTitle.trim().isEmpty ? 'intern software engineer' : roleTitle.trim();
    return 'Application for $cleanRole';
  }

  static String generateBody({
    required String role,
    required UserProfile profile,
    String? customBodyTemplate,
  }) {
    final effectiveRole = role.trim().isEmpty ? 'intern software engineer' : role.trim();

    if (customBodyTemplate != null && customBodyTemplate.trim().isNotEmpty) {
      return customBodyTemplate
          .replaceAll('{ROLE}', effectiveRole)
          .replaceAll('{NAME}', profile.name)
          .replaceAll('{PHONE}', profile.phone)
          .replaceAll('{DEGREE}', profile.degree)
          .replaceAll('{SKILLS}', profile.skills);
    }

    return '''Dear Sir/Madam
I am writing to express my interest in the $effectiveRole. I am currently pursuing a ${profile.degree}, which has equipped me with a solid foundation in programming, software development methodologies, and problem-solving.

I have hands-on skills in ${profile.skills}, along with strong knowledge of data structures, algorithms, and modern development practices. These skills allow me to build responsive, user-friendly applications while ensuring performance and scalability.

I am particularly inspired by your company’s focus on cutting-edge digital products and emphasis on innovation, diversity, and work-life balance. I am eager to contribute to your projects, collaborate with your team, and continue learning through this internship opportunity.

Please find my CV attached for your review. I would be grateful for the chance to discuss how my skills and enthusiasm can support your team’s success.

Thank you for your time and consideration.


Best regards,
${profile.name}
${profile.phone}''';
  }
}
