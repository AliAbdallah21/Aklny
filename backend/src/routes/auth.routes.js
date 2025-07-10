// backend/src/routes/auth.routes.js
// This file defines the API routes related to authentication (register, login, email verification, password reset, and Google Sign-In).

import express from 'express';
import AuthController from '../controllers/auth.controller.js';
import { asyncHandler } from '../utils/errors.utils.js'; // Assuming errors.utils.js exports asyncHandler

// This function receives the PostgreSQL connection pool and the JWT secrets,
// and returns an Express router with authentication-related routes.
const authRoutes = (pool, jwtSecret, jwtRefreshSecret) => {
    const router = express.Router();
    // Pass both secrets to the AuthController constructor
    const authController = new AuthController(pool, jwtSecret, jwtRefreshSecret);

    // Route for email verification (GET request).
    router.get('/verify-email', authController.verifyEmail.bind(authController));

    // Route to resend the email verification link (POST request).
    router.post('/resend-verification-email', asyncHandler(authController.resendVerificationEmail.bind(authController)));

    // Route for requesting a password reset link (POST request).
    router.post('/request-password-reset', asyncHandler(authController.requestPasswordReset.bind(authController)));

    // Route for handling the password reset form submission (POST request).
    router.post('/reset-password', asyncHandler(authController.resetPassword.bind(authController)));

    // Route for serving the password reset form (GET request).
    router.get('/reset-password', authController.getPasswordResetForm.bind(authController));

    // Routes for Google authentication, traditional registration, and login
    router.post('/google-login', asyncHandler(authController.googleLogin.bind(authController)));
    router.post('/register', asyncHandler(authController.register.bind(authController)));
    router.post('/login', asyncHandler(authController.login.bind(authController)));

    // Route for user logout
    router.post('/logout', asyncHandler(authController.logout.bind(authController)));

    return router;
};

export default authRoutes;
