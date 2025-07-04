// backend/src/routes/auth.routes.js
// Defines API routes for authentication.

import express from 'express';
import AuthController from '../controllers/auth.controller.js';

// This function takes the database pool and JWT secret,
// then creates an instance of AuthController and sets up the routes.
export default (pool, jwtSecret) => {
    const router = express.Router();
    const authController = new AuthController(pool, jwtSecret);

    // User Registration
    router.post('/register', authController.register.bind(authController));

    // User Login
    router.post('/login', authController.login.bind(authController));

    // NEW: Google Authentication Endpoint
    router.post('/google-login', authController.googleLogin.bind(authController));

    // Email Verification
    router.get('/verify-email', authController.verifyEmail.bind(authController));
    router.post('/resend-verification-email', authController.resendVerificationEmail.bind(authController));

    // Password Reset
    router.post('/request-password-reset', authController.requestPasswordReset.bind(authController));
    router.get('/reset-password', authController.getPasswordResetForm.bind(authController)); // For displaying the form
    router.post('/reset-password', authController.resetPassword.bind(authController)); // For submitting the new password

    return router;
};
