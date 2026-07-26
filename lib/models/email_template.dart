import 'user_profile.dart';

class PredefinedRoles {
  static const String internSoftwareEngineer = 'intern software engineer';
  static const String internFrontendDeveloper = 'intern frontend developer';
  static const String internFullStackDeveloper = 'intern full stack developer';
  static const String internBackendDeveloper = 'intern backend developer';
  static const String internQaEngineer = 'intern QA engineer';
  static const String other = 'Other (Custom)';

  static const List<String> allRoles = [
    internSoftwareEngineer,
    internFrontendDeveloper,
    internFullStackDeveloper,
    internBackendDeveloper,
    internQaEngineer,
    other,
  ];
}

class EmailTemplate {
  static String generateSubject({
    required String roleTitle,
    String? companyName,
    String? applicantName,
  }) {
    final cleanRole = roleTitle.trim().isEmpty ? 'intern software engineer' : roleTitle.trim();
    final cleanCompany = companyName?.trim() ?? '';
    final cleanName = applicantName?.trim() ?? '';

    if (cleanCompany.isNotEmpty && cleanName.isNotEmpty) {
      return 'Application for $cleanRole - $cleanCompany ($cleanName)';
    } else if (cleanCompany.isNotEmpty) {
      return 'Application for $cleanRole - $cleanCompany';
    } else if (cleanName.isNotEmpty) {
      return 'Application for $cleanRole - $cleanName';
    }
    return 'Application for $cleanRole';
  }

  static String generateBody({
    required String role,
    required UserProfile profile,
    String? companyName,
    String tone = 'standard',
    String? customBodyTemplate,
  }) {
    final effectiveRole = role.trim().isEmpty ? 'intern software engineer' : role.trim();
    final targetCompany = (companyName != null && companyName.trim().isNotEmpty)
        ? companyName.trim()
        : 'your organization';

    if (customBodyTemplate != null && customBodyTemplate.trim().isNotEmpty) {
      return customBodyTemplate
          .replaceAll('{ROLE}', effectiveRole)
          .replaceAll('{COMPANY}', targetCompany)
          .replaceAll('{NAME}', profile.name)
          .replaceAll('{PHONE}', profile.phone)
          .replaceAll('{DEGREE}', profile.degree)
          .replaceAll('{SKILLS}', profile.skills);
    }

    switch (tone.toLowerCase()) {
      case 'formal':
        return '''Dear Hiring Manager & Recruitment Team,

I am writing to formally express my strong interest in the $effectiveRole position at $targetCompany. I am currently pursuing a ${profile.degree}, which has provided me with rigorous academic training and practical foundation in computer science and software development.

My technical profile encompasses expertise in ${profile.skills}. Through project experience, I have developed analytical problem-solving abilities and a disciplined approach to software design, clean coding practices, and system integration.

I have followed $targetCompany's impactful work in the industry with great admiration and am highly motivated to contribute to your engineering objectives. I welcome the opportunity to discuss how my academic background and dedication align with your team's needs.

Please find my curriculum vitae attached for your detailed consideration.

Thank you for your time, consideration, and evaluation of my application.

Sincerely,

${profile.name}
${profile.phone}
${profile.senderEmail}''';

      case 'concise':
        return '''Dear Hiring Manager,

I am applying for the $effectiveRole role at $targetCompany.

I am pursuing a ${profile.degree} and have technical skills in ${profile.skills}. I am passionate about building efficient software and eager to contribute to $targetCompany's current projects.

My CV is attached. I would appreciate the opportunity to discuss my application further.

Thank you for your time.

Best regards,

${profile.name}
Phone: ${profile.phone}
Email: ${profile.senderEmail}''';

      case 'standard':
      default:
        return '''Dear Hiring Manager,

I am writing to express my enthusiastic interest in the $effectiveRole role at $targetCompany. I am currently pursuing a ${profile.degree}, which has equipped me with a solid foundation in programming, software engineering methodologies, and creative problem-solving.

I have hands-on experience in ${profile.skills}, along with strong knowledge of modern development practices, data structures, and application lifecycle management. These competencies enable me to write clean code and build responsive, user-centered applications.

I am particularly drawn to $targetCompany's commitment to innovation and digital excellence. I am eager to contribute to your ongoing projects, collaborate with your team, and accelerate my professional growth through this opportunity.

Please find my CV attached for your review. I would welcome the opportunity to discuss how my background and enthusiasm align with your team's goals.

Thank you for your time and consideration.

Best regards,

${profile.name}
Phone: ${profile.phone}
Email: ${profile.senderEmail}''';
    }
  }
}
