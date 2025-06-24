// backend/src/services/user.service.js
// This service handles the business logic for user profile management.

import User from '../models/user.model.js'; // Import the User model
import bcrypt from 'bcryptjs'; // For password hashing

class UserService {
    constructor(pool) {
        this.pool = pool; // The PostgreSQL connection pool
    }

    // Get a user's full profile by ID
    async getUserProfile(userId) {
        const user = await User.findById(this.pool, userId);
        if (!user) {
            throw new Error('User not found.');
        }
        // Exclude sensitive information like password hash before returning
        const { password_hash, ...profile } = user;
        return profile;
    }

    // Update a user's profile details
    async updateProfile(userId, updateData) {
        // Basic validation: ensure updateData is an object and not empty
        if (!updateData || Object.keys(updateData).length === 0) {
            throw new Error('No update data provided.');
        }

        // You might add more specific validation here, e.g., for phone number format, etc.
        // For roles like 'seller' or 'delivery_driver', enforce specific fields if needed
        // For example:
        // if (updateData.role === 'seller' && !updateData.restaurantName) {
        //     throw new Error('Seller profile requires a restaurant name.');
        // }

        const updatedUser = await User.updateProfile(this.pool, userId, updateData);
        if (!updatedUser) {
            throw new Error('User not found or no changes applied.');
        }
        // Exclude sensitive information
        const { password_hash, ...profile } = updatedUser;
        return profile;
    }

    // Change user password (requires current password verification)
    async changePassword(userId, currentPassword, newPassword) {
        const user = await User.findById(this.pool, userId);
        if (!user) {
            throw new Error('User not found.');
        }

        // Verify current password
        const isMatch = await bcrypt.compare(currentPassword, user.password_hash);
        if (!isMatch) {
            throw new Error('Incorrect current password.');
        }

        // Hash the new password
        const salt = await bcrypt.genSalt(10);
        const newPasswordHash = await bcrypt.hash(newPassword, salt);

        // Update password in the database
        const updatedUser = await User.updatePassword(this.pool, userId, newPasswordHash);
        if (!updatedUser) {
            throw new Error('Failed to update password.');
        }
        // Return minimal success confirmation
        return { message: 'Password updated successfully.' };
    }

    // --- Admin/Approval related methods (to be implemented later if needed) ---
    // async approveUser(userId) { ... }
    // async suspendUser(userId) { ... }
}

export default UserService;