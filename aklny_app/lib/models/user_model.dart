// lib/models/user_model.dart
// This file defines the comprehensive User model class for the Flutter application,
// including fields for various roles (customer, seller, driver), email verification status,
// and correctly handling nullable fields for social logins.

class User {
  final int userId;
  final String email;
  final String? fullName; // CHANGED: Made nullable for social logins
  final String? phoneNumber; // CHANGED: Made nullable for social logins
  final String role;
  final bool isVerified; // Field to indicate if email is verified

  // Seller-specific fields
  final String? restaurantName;
  final String? restaurantDescription;

  // Address fields (can be associated with customer or seller)
  final String? addressStreet;
  final String? addressCity;
  final String? addressCountry;

  // Bank details (primarily for sellers to receive payments)
  final String? bankAccountNumber;
  final String? bankName;

  // Approval status (for sellers/drivers pending admin review)
  final bool isApproved; // Not nullable, defaults to false on backend

  // Profile picture
  final String? profilePictureUrl;

  // Seller metrics
  final String?
  averageRating; // Stored as decimal in DB, converting to String in Flutter for simplicity if decimal(2,1)
  final int? totalReviews;
  final int? totalOrdersCompleted;

  // Delivery driver-specific fields
  final String? driverLicenseNumber;
  final String? vehicleType;
  final String? vehiclePlateNumber;
  final bool?
  isAvailableForDelivery; // Nullable as it might not apply to all users or always be set

  User({
    required this.userId,
    required this.email,
    this.fullName, // CHANGED: No longer 'required'
    this.phoneNumber, // CHANGED: No longer 'required'
    required this.role,
    this.isVerified =
        false, // Set a default value for safety, backend will control
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
      fullName: json['full_name'] as String?, // CHANGED: Cast as String?
      phoneNumber: json['phone_number'] as String?, // CHANGED: Cast as String?
      role: json['role'] as String,
      isVerified:
          json['is_verified'] as bool? ??
          false, // Handle nullable from backend, default to false
      restaurantName: json['restaurant_name'] as String?,
      restaurantDescription: json['restaurant_description'] as String?,
      addressStreet: json['address_street'] as String?,
      addressCity: json['address_city'] as String?,
      addressCountry: json['address_country'] as String?,
      bankAccountNumber: json['bank_account_number'] as String?,
      bankName: json['bank_name'] as String?,
      isApproved:
          json['is_approved'] as bool? ??
          false, // Handle nullable from backend, default to false
      profilePictureUrl: json['profile_picture_url'] as String?,
      averageRating: json['average_rating']
          ?.toString(), // Convert num/double from JSON to String
      totalReviews: json['total_reviews'] as int?,
      totalOrdersCompleted: json['total_orders_completed'] as int?,
      driverLicenseNumber: json['driver_license_number'] as String?,
      vehicleType: json['vehicle_type'] as String?,
      vehiclePlateNumber: json['vehicle_plate_number'] as String?,
      isAvailableForDelivery: json['is_available_for_delivery'] as bool?,
    );
  }

  // Method to convert a User object to a JSON map (e.g., for sending to API for updates)
  // Only include fields that are typically updated via API. 'password_hash' and tokens should NEVER be here.
  Map<String, dynamic> toJson() {
    return {
      'user_id':
          userId, // Often not needed for PUT/PATCH unless it's part of the URL
      'email': email, // Often not updated via profile screen
      'full_name': fullName,
      'phone_number': phoneNumber,
      'role': role, // Role usually not changed by user
      'is_verified':
          isVerified, // Backend will manage, but included for completeness if needed
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

  // Helper method for copying an existing User object with some updated fields
  User copyWith({
    int? userId,
    String? email,
    String? fullName, // CHANGED: Made nullable
    String? phoneNumber, // CHANGED: Made nullable
    String? role,
    bool? isVerified,
    String? restaurantName,
    String? restaurantDescription,
    String? addressStreet,
    String? addressCity,
    String? addressCountry,
    String? bankAccountNumber,
    String? bankName,
    bool? isApproved,
    String? profilePictureUrl,
    String? averageRating,
    int? totalReviews,
    int? totalOrdersCompleted,
    String? driverLicenseNumber,
    String? vehicleType,
    String? vehiclePlateNumber,
    bool? isAvailableForDelivery,
  }) {
    return User(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      restaurantName: restaurantName ?? this.restaurantName,
      restaurantDescription:
          restaurantDescription ?? this.restaurantDescription,
      addressStreet: addressStreet ?? this.addressStreet,
      addressCity: addressCity ?? this.addressCity,
      addressCountry: addressCountry ?? this.addressCountry,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankName: bankName ?? this.bankName,
      isApproved: isApproved ?? this.isApproved,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      totalOrdersCompleted: totalOrdersCompleted ?? this.totalOrdersCompleted,
      driverLicenseNumber: driverLicenseNumber ?? this.driverLicenseNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      vehiclePlateNumber: vehiclePlateNumber ?? this.vehiclePlateNumber,
      isAvailableForDelivery:
          isAvailableForDelivery ?? this.isAvailableForDelivery,
    );
  }

  // For debugging and logging purposes
  @override
  String toString() {
    // Handle nullable fullName gracefully in toString
    return 'User(userId: $userId, email: $email, fullName: ${fullName ?? 'N/A'}, role: $role, isVerified: $isVerified)';
  }
}
