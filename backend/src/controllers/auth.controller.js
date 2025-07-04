// backend/src/controllers/auth.controller.js
// This file handles incoming HTTP requests related to authentication (registration, login,
// email verification, password reset, and Google Sign-In), acting as the interface between
// routes and the core authentication business logic in auth.service.js.

import AuthService from '../services/auth.service.js'; // Import the authentication service
import { renderHtml } from '../utils/htmlRenderer.js'; // Re-added: For rendering success HTML pages
import { sendHtmlError } from '../utils/response.utils.js'; // Import the HTML error rendering utility

class AuthController {
    // Constructor receives the PostgreSQL pool and JWT secret from the router.
    // It then instantiates AuthService internally.
    constructor(pool, jwtSecret) {
        this.authService = new AuthService(pool, jwtSecret);
    }

<<<<<<< HEAD
    // Handles user registration (POST /api/auth/register)
    async register(req, res, next) {
        try {
            const { email, password, fullName, phoneNumber } = req.body;
            const newUser = await this.authService.register({ email, password, fullName, phoneNumber });
            res.status(201).json({ message: 'User registered successfully. Please verify your email.', user: newUser });
        } catch (error) {
            next(error);
        }
    }

    // Handles user login (POST /api/auth/login)
    async login(req, res, next) {
        try {
            const { email, password } = req.body;
            const { token, user } = await this.authService.login({ email, password });
            res.status(200).json({ message: 'Login successful.', token, user });
        } catch (error) {
            next(error);
        }
    }

    // NEW: Handles Google authentication (POST /api/auth/google-login)
    async googleLogin(req, res, next) {
        try {
            const { idToken } = req.body;
            if (!idToken) {
                return res.status(400).json({ message: 'Google ID token is required.' });
            }

            const { token, user } = await this.authService.authenticateWithGoogle(idToken);
            res.status(200).json({ message: 'Google authentication successful.', token, user });
        } catch (error) {
            next(error);
        }
    }

    // Handles email verification (GET /api/auth/verify-email?token=...)
    async verifyEmail(req, res, next) {
        try {
            const { token } = req.query;

            if (!token) {
                return sendHtmlError(res, 400, 'Verification token is missing. Please try again from the app.', 'emailVerificationFailed.html');
            }

            const user = await this.authService.verifyEmail(token);
            const html = await renderHtml('emailVerified.html', { userName: user.full_name || user.email });
            res.status(200).send(html);
        } catch (error) {
            sendHtmlError(res, 400, error.message || 'An unexpected error occurred during verification.', 'emailVerificationFailed.html');
        }
    }

    // Handles resending verification email (POST /api/auth/resend-verification-email)
    async resendVerificationEmail(req, res, next) {
        try {
            const { email } = req.body;
            if (!email) {
                return res.status(400).json({ message: 'Email is required to resend verification link.' });
            }

            const message = await this.authService.resendVerificationEmail(email);
            res.status(200).json({ message });
        } catch (error) {
            next(error);
        }
    }

    // Handles requesting a password reset (POST /api/auth/request-password-reset)
    async requestPasswordReset(req, res, next) {
        try {
            const { email } = req.body;
            if (!email) {
                return res.status(400).json({ message: 'Email is required for password reset request.' });
            }

            const message = await this.authService.requestPasswordReset(email);
            res.status(200).json({ message });
        } catch (error) {
            next(error);
        }
    }

    // Handles GET request to serve the password reset form (GET /api/auth/reset-password?token=...)
    async getPasswordResetForm(req, res, next) {
        try {
            const { token } = req.query;

            if (!token) {
                return sendHtmlError(res, 400, 'Password reset token is missing.', 'passwordResetTokenMissing.html');
            }

            try {
                await this.authService.findByPasswordResetTokenForForm(token);
            } catch (error) {
                return sendHtmlError(res, 400, error.message || 'An unexpected error occurred during token validation.', 'passwordResetFailed.html');
            }

            const html = await renderHtml('passwordResetForm.html', { token });
            res.status(200).send(html);
        } catch (error) {
            sendHtmlError(res, 500, 'An unexpected error occurred while loading the reset form.', 'passwordResetFailed.html');
        }
    }

    // Handles the actual password reset (POST /api/auth/reset-password)
    async resetPassword(req, res, next) {
        try {
            const { token, newPassword } = req.body;
            if (!token || !newPassword) {
                return res.status(400).json({ message: 'Token and new password are required.' });
            }

            const message = await this.authService.resetPassword(token, newPassword);
            res.status(200).json({ message });
        } catch (error) {
            next(error);
        }
=======
    // Controller method for user registration
    async register(req, res) {
            const { email, password, fullName, phoneNumber} = req.body; // Extract data from request body
            // Call the register method from AuthService
            const newUser = await this.authService.register({ email, password, fullName, phoneNumber});
            // Send a 201 Created status and the new user's information
            res.status(201).json({ message: 'User registered successfully!', user: newUser });
    }

    // Controller method for user login
    async login(req, res) {
            const { email, password } = req.body; // Extract data from request body
            // Call the login method from AuthService
            const { token, user } = await this.authService.login({ email, password });
            // Send a 200 OK status, a success message, the JWT token, and user info
            res.status(200).json({ message: 'Login successful!', token, user });
>>>>>>> 65b5a4cf46698eaa9ab4eee5ccefdc4d49e0582e
    }

    async logout(req, res){
        const tokenId = req.cookies.refreshToken;
         res.clearCookie('refreshToken', {
            httpOnly: true,
            secure: process.env.NODE_ENV === 'production', // Set to true in production (requires HTTPS)
            sameSite: 'Lax', // Or 'Strict' depending on your CSRF strategy
            maxAge: 7 * 24 * 60 * 60 * 1000, //max time before expiry
            path: '/' // Ensure the path matches the path the cookie was set with
        });

        if(!tokenId){
            return res.status(200).json({ message: 'Logout successful (no active session found to revoke).' });
        }

        try{
           await this.authService.logout(tokenId)
           return res.status(200).json({ message: 'Logout successful!'});
        }catch(error){
           return res.status(500).json({message: "Logout failed."})
        }
    }
}

export default AuthController;
