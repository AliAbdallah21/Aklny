// backend/src/controllers/user.controller.js
// This controller handles HTTP requests related to user profiles.

import UserService from '../services/user.service.js'; // Import the UserService

class UserController {
    constructor(pool) {
        this.userService = new UserService(pool); // Initialize UserService with the DB pool
    }

    // Controller method to get a user's own profile (protected)
    async getMyProfile(req, res) {
        try {
            // userId comes from the authenticated user's JWT (attached by authenticateToken middleware)
            const userId = req.user.userId;
            const userProfile = await this.userService.getUserProfile(userId);
            res.status(200).json(userProfile);
        } catch (error) {
            res.status(404).json({ message: error.message }); // 404 if user not found, or other errors
        }
    }

    // Controller method to update a user's own profile (protected)
    async updateMyProfile(req, res) {
        try {
            const userId = req.user.userId; // Get userId from authenticated user
            const updateData = req.body; // Update data from the request body

            const updatedProfile = await this.userService.updateProfile(userId, updateData);
            res.status(200).json({ message: 'Profile updated successfully!', user: updatedProfile });
        } catch (error) {
            res.status(400).json({ message: error.message }); // 400 for validation errors or no data
        }
    }

    // Controller method to change a user's own password (protected)
    async changeMyPassword(req, res) {
        try {
            const userId = req.user.userId; // Get userId from authenticated user
            const { currentPassword, newPassword } = req.body; // Passwords from request body

            if (!currentPassword || !newPassword) {
                return res.status(400).json({ message: 'Current password and new password are required.' });
            }

            // Add validation for new password strength (e.g., min length, complexity)
            if (newPassword.length < 8) {
                return res.status(400).json({ message: 'New password must be at least 8 characters long.' });
            }

            const result = await this.userService.changePassword(userId, currentPassword, newPassword);
            res.status(200).json(result); // Should contain a success message
        } catch (error) {
            // Use 401 for incorrect password, 400 for other validation
            if (error.message === 'Incorrect current password.') {
                res.status(401).json({ message: error.message });
            } else {
                res.status(400).json({ message: error.message });
            }
        }
    }

    // --- Admin-specific methods (if needed, e.g., getting any user profile) ---
    // async getUserProfileById(req, res) { ... }
}

export default UserController;