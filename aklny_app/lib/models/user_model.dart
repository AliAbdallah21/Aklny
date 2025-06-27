// lib/models/user_model.dart
// This file defines the User model class for the Flutter application.

class User {
  final int userId;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String role;
  final String? restaurantName; // Nullable for non-seller roles
  final String? restaurantDescription; // Nullable
  final String? addressStreet; // Nullable
  final String? addressCity; // Nullable
  final String? addressCountry; // Nullable
  final String? bankAccountNumber; // Nullable
  final String? bankName; // Nullable
  final bool isApproved;
  final String? profilePictureUrl; // Nullable
  final String? averageRating; // Nullable
  final int? totalReviews; // Nullable
  final int? totalOrdersCompleted; // Nullable
  final String? driverLicenseNumber; // Nullable
  final String? vehicleType; // Nullable
  final String? vehiclePlateNumber; // Nullable
  final bool? isAvailableForDelivery; // Nullable

  User({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.role,
    this.restaurantName,
    this.restaurantDescription,
    this.addressStreet,
    this.addressCity,
    this.addressCountry,
    this.bankAccountNumber,
    this.bankName,
    required this.isApproved,
    this.profilePictureUrl,
    this.averageRating,
    this.totalReviews,
    this.totalOrdersCompleted,
    this.driverLicenseNumber,
    this.vehicleType,
    this.vehiclePlateNumber,
    this.isAvailableForDelivery,
  });

  // Factory constructor to create a User object from a JSON map (e.g., from API response)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] as int,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      phoneNumber: json['phone_number'] as String,
      role: json['role'] as String,
      restaurantName: json['restaurant_name'] as String?,
      restaurantDescription: json['restaurant_description'] as String?,
      addressStreet: json['address_street'] as String?,
      addressCity: json['address_city'] as String?,
      addressCountry: json['address_country'] as String?,
      bankAccountNumber: json['bank_account_number'] as String?,
      bankName: json['bank_name'] as String?,
      isApproved: json['is_approved'] as bool,
      profilePictureUrl: json['profile_picture_url'] as String?,
      averageRating: json['average_rating']?.toString(),
      totalReviews: json['total_reviews'] as int?,
      totalOrdersCompleted: json['total_orders_completed'] as int?,
      driverLicenseNumber: json['driver_license_number'] as String?,
      vehicleType: json['vehicle_type'] as String?,
      vehiclePlateNumber: json['vehicle_plate_number'] as String?,
      isAvailableForDelivery: json['is_available_for_delivery'] as bool?,
    );
  }

  // Method to convert a User object to a JSON map (e.g., for sending to API for updates)
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'role': role,
      'restaurant_name': restaurantName,
      'restaurant_description': restaurantDescription,
      'address_street': addressStreet,
      'address_city': addressCity,
      'address_country': addressCountry,
      'bank_account_number': bankAccountNumber,
      'bank_name': bankName,
      'is_approved': isApproved,
      'profile_picture_url': profilePictureUrl,
      'average_rating': averageRating,
      'total_reviews': totalReviews,
      'total_orders_completed': totalOrdersCompleted,
      'driver_license_number': driverLicenseNumber,
      'vehicle_type': vehicleType,
      'vehicle_plate_number': vehiclePlateNumber,
      'is_available_for_delivery': isAvailableForDelivery,
    };
  }

  // For debugging and logging purposes
  @override
  String toString() {
    return 'User(userId: $userId, email: $email, fullName: $fullName, role: $role)';
  }
}
