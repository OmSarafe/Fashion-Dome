class AuthValidators {
  const AuthValidators._();

  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Enter your email address.';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email address.';
    }
    if (email.length > 50) {
      return 'Email must not exceed 50 characters.';
    }
    return null;
  }

  static String? fullName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Enter your full name.';
    if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(name)) {
      return 'Only alphabetic characters are allowed.';
    }
    if (name.length < 5) return 'Name must be at least 5 characters.';
    if (name.length > 20) return 'Name must not exceed 20 characters.';
    return null;
  }

  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) return 'Enter your password.';
    if (value.length < 8) {
      return 'Password must contain at least 8 characters.';
    }
    return null;
  }

  static String? strongPassword(String? value) {
    if (value == null || value.isEmpty) return 'Enter your password.';
    if (value.length < 8) return 'Password must be at least 8 characters.';
    if (value.length > 20) return 'Password must not exceed 20 characters.';
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter.';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter.';
    }
    if (!RegExp(r'\d').hasMatch(value)) {
      return 'Password must contain at least one digit.';
    }
    if (!RegExp(r'[@#$&*%!]').hasMatch(value)) {
      return 'Password must contain at least one special character.';
    }
    return null;
  }
}
