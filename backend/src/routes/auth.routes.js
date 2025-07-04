// backend/src/routes/auth.routes.js
// This file defines the API routes related to authentication (register, login, email verification, password reset, and Google Sign-In).

import express from 'express';
import AuthController from '../controllers/auth.controller.js';
import { asyncHandler } from '../utils/errors.utils.js';

// This function receives the PostgreSQL connection pool and the JWT secret,
// and returns an Express router with authentication-related routes.
const authRoutes = (pool, jwtSecret) => { // Accepts pool and jwtSecret as before
    const router = express.Router();
    const authController = new AuthController(pool, jwtSecret); // <-- PASS jwtSecret

    // Route for email verification (GET request).
    // This is the endpoint that the user will hit when clicking the link in their email.
    // It returns an HTML response directly for browser viewing.
    router.get('/verify-email', authController.verifyEmail.bind(authController));
    
    // Route to resend the email verification link (POST request).
    // This endpoint is typically called by the frontend if the user needs a new verification email.
    // It returns a JSON response.
    router.post('/resend-verification-email', asyncHandler(authController.resendVerificationEmail.bind(authController)));

    // NEW: Route for requesting a password reset link (POST request).
    // This endpoint accepts an email and sends a password reset email.
    router.post('/request-password-reset', asyncHandler(authController.requestPasswordReset.bind(authController)));

    // Route for handling the password reset form submission (POST request).
    // This endpoint receives the new password and token from the HTML form.
    router.post('/reset-password', asyncHandler(authController.resetPassword.bind(authController))); 

    // Existing: Route for serving the password reset form (GET request).
    // This endpoint serves the HTML page containing the password reset form.
    router.get('/reset-password', authController.getPasswordResetForm.bind(authController));
    router.post('/google-login', asyncHandler(authController.googleLogin.bind(authController)));
    router.post('/register', asyncHandler(authController.register.bind(authController)));
    router.post('/login', asyncHandler(authController.login.bind(authController)));
    return router;
};

export default authRoutes;
