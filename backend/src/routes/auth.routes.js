// backend/src/routes/auth.routes.js
// This file defines the API routes related to authentication (register, login, email verification, password reset, and Google Sign-In).

import express from 'express';
import AuthController from '../controllers/auth.controller.js';

// This function receives the PostgreSQL connection pool and the JWT secret,
// and returns an Express router with authentication-related routes.
const authRoutes = (pool, jwtSecret) => { // Accepts pool and jwtSecret as before
    const router = express.Router();
    // Instantiate AuthController, passing the pool and jwtSecret to its constructor
    const authController = new AuthController(pool, jwtSecret); 

    // Route for user registration (POST request)
    router.post('/register', authController.register.bind(authController));
    
    // Route for user login (POST request)
    router.post('/login', authController.login.bind(authController));
    
    // Route for email verification (GET request).
    // This is the endpoint that the user will hit when clicking the link in their email.
    // It returns an HTML response directly for browser viewing.
    router.get('/verify-email', authController.verifyEmail.bind(authController));
    
    // Route to resend the email verification link (POST request).
    // This endpoint is typically called by the frontend if the user needs a new verification email.
    // It returns a JSON response.
    router.post('/resend-verification-email', authController.resendVerificationEmail.bind(authController));

    // NEW: Route for requesting a password reset link (POST request).
    // This endpoint accepts an email and sends a password reset email.
    router.post('/request-password-reset', authController.requestPasswordReset.bind(authController));

    // Route for handling the password reset form submission (POST request).
    // This endpoint receives the new password and token from the HTML form.
    router.post('/reset-password', authController.resetPassword.bind(authController)); 

    // Existing: Route for serving the password reset form (GET request).
    // This endpoint serves the HTML page containing the password reset form.
    router.get('/reset-password', authController.getPasswordResetForm.bind(authController));


    router.post('/google-login', authController.googleLogin.bind(authController));

    return router;
};

export default authRoutes;
