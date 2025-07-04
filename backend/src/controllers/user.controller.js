// backend/src/controllers/user.controller.js
// This controller handles HTTP requests related to user profiles,
// now with improved error handling and validation using utility functions.

import UserService from '../services/user.service.js'; // Import the UserService
import AppError from '../utils/appError.js'; // NEW: Import custom AppError
import { checkRequiredFields, validatePasswordStrength } from '../utils/validation.utils.js'; // NEW: Import validation utilities

class UserController {
    constructor(pool) {
        this.userService = new UserService(pool); // Initialize UserService with the DB pool
    }

    // Controller method to get a user's own profile (protected)
    async getMyProfile(req, res, next) { // Added 'next' parameter
        try {
            // userId comes from the authenticated user's JWT (attached by authenticateToken middleware)
            const userId = req.user.userId;
            const userProfile = await this.userService.getUserProfile(userId);
            res.status(200).json(userProfile);
        } catch (error) {
            // Pass the error to the global error handler
            next(error);
        }
    }

    // Controller method to update a user's own profile (protected)
    async updateMyProfile(req, res, next) { // Added 'next' parameter
        try {
            const userId = req.user.userId; // Get userId from authenticated user
            const updateData = req.body; // Update data from the request body

            // Optional: Add more specific validation for updateData if needed
            if (Object.keys(updateData).length === 0) {
                throw new AppError('No update data provided.', 400);
            }

            const updatedProfile = await this.userService.updateProfile(userId, updateData);
            res.status(200).json({ message: 'Profile updated successfully!', user: updatedProfile });
        } catch (error) {
            // Pass the error to the global error handler
            next(error);
        }
    }

    // Controller method to change a user's own password (protected)
    async changeMyPassword(req, res, next) { // Added 'next' parameter
        try {
            const userId = req.user.userId; // Get userId from authenticated user
            const { currentPassword, newPassword } = req.body; // Passwords from request body

            // Use validation utility
            checkRequiredFields(req.body, ['currentPassword', 'newPassword']);
            validatePasswordStrength(newPassword); // Defaults to 8 characters

            const result = await this.userService.changePassword(userId, currentPassword, newPassword);
            res.status(200).json(result); // Should contain a success message
        } catch (error) {
            // Pass the error to the global error handler.
            // The service layer should throw AppError with appropriate status codes (e.g., 401 for incorrect password).
            next(error);
        }
    }

    // --- Admin-specific methods (if needed, e.g., getting any user profile) ---
    // async getUserProfileById(req, res) { ... }
}

export default UserController;
