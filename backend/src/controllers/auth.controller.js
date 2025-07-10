// backend/src/controllers/auth.controller.js
// This file handles incoming HTTP requests related to authentication (registration, login,
// email verification, password reset, and Google Sign-In), acting as the interface between
// routes and the core authentication business logic in auth.service.js.

import AuthService from '../services/auth.service.js'; // Import the authentication service
import { renderHtml } from '../utils/htmlRenderer.utils.js'; // For rendering success HTML pages
import { sendHtmlError } from '../utils/response.utils.js'; // For HTML error rendering utility
import { asyncHandler } from '../utils/errors.utils.js'; // Assuming asyncHandler is imported from error.utils.js
import AppError from '../utils/appError.js'; // Import AppError for consistent error handling

// Helper function to format date for Set-Cookie header (RFC 1123)
// This is the standard format expected by most clients.
function toRFC1123String(date) {
    return date.toUTCString();
}

class AuthController {
    // Constructor receives the PostgreSQL pool and JWT secret from the router.
    // It then instantiates AuthService internally.
    constructor(pool, jwtSecret, jwtRefreshSecret) {
        this.authService = new AuthService(pool, jwtSecret, jwtRefreshSecret);
    }

    // Controller method for user registration (POST /api/auth/register)
    async register(req, res, next) {
        try {
            const { email, password, fullName, phoneNumber } = req.body;
            const newUser = await this.authService.register({ email, password, fullName, phoneNumber });
            res.status(201).json({ message: 'User registered successfully. Please verify your email.', user: newUser });
        } catch (error) {
            next(error);
        }
    }

    // Controller method for user login (POST /api/auth/login)
    async login(req, res, next) {
        try {
            const { email, password } = req.body;
            const { accessToken, refreshToken, user } = await this.authService.login({ email, password });

            const cookieExpiresDate = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // 7 days from now
            const cookieExpiresString = toRFC1123String(cookieExpiresDate); // Format date to RFC 1123 string

            // Construct the Secure attribute conditionally
            // It should only be present if true (for HTTPS), otherwise omitted for HTTP
            const secureAttribute = process.env.NODE_ENV === 'production' ? '; Secure' : '';

            // Directly set the Set-Cookie header for refreshToken
            // This gives explicit control over the date format and attributes
            res.setHeader('Set-Cookie', [
                `refreshToken=${refreshToken}; Path=/; Expires=${cookieExpiresString}; HttpOnly; SameSite=Lax${secureAttribute}`
            ]);

            // --- DEBUG LOG START ---
            // This will log ALL Set-Cookie headers that Express is preparing to send
            const allSetCookieHeaders = res.getHeaders()['set-cookie'];
            console.log('Backend: ALL Set-Cookie headers for Login Response:', allSetCookieHeaders);
            // --- DEBUG LOG END ---

            res.status(200).json({ message: 'Login successful.', token: accessToken, user });
        } catch (error) {
            next(error);
        }
    }

    // Handles Google authentication (POST /api/auth/google-login)
    async googleLogin(req, res, next) {
        try {
            const { idToken } = req.body;
            if (!idToken) {
                throw new AppError('Google ID token is required.', 400);
            }
            const { accessToken, refreshToken, user } = await this.authService.authenticateWithGoogle(idToken);

            const cookieExpiresDate = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // 7 days from now
            const cookieExpiresString = toRFC1123String(cookieExpiresDate); // Format date to RFC 1123 string

            // Construct the Secure attribute conditionally
            const secureAttribute = process.env.NODE_ENV === 'production' ? '; Secure' : '';

            // Directly set the Set-Cookie header for refreshToken
            res.setHeader('Set-Cookie', [
                `refreshToken=${refreshToken}; Path=/; Expires=${cookieExpiresString}; HttpOnly; SameSite=Lax${secureAttribute}`
            ]);

            // --- DEBUG LOG START ---
            const allSetCookieHeaders = res.getHeaders()['set-cookie'];
            console.log('Backend: ALL Set-Cookie headers for Google Login Response:', allSetCookieHeaders);
            // --- DEBUG LOG END ---

            res.status(200).json({ message: 'Google authentication successful.', token: accessToken, user });
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
                throw new AppError('Email is required to resend verification link.', 400);
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
                throw new AppError('Email is required for password reset request.', 400);
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
                throw new AppError('Token and new password are required.', 400);
            }
            const message = await this.authService.resetPassword(token, newPassword);
            res.status(200).json({ message });
        } catch (error) {
            next(error);
        }
    }

    // Controller method for user logout
    async logout(req, res, next) {
        console.log('Logout initiated in AuthController.');
        console.log('Request cookies:', req.cookies);
        const refreshTokenCookie = req.cookies.refreshToken;
        console.log('Refresh Token from cookie (AuthController):', refreshTokenCookie);

        // Construct the Secure attribute conditionally for clearing the cookie
        const secureAttribute = process.env.NODE_ENV === 'production' ? '; Secure' : '';

        // Clear the cookie by setting its expiry to a past date
        res.setHeader('Set-Cookie', [
            `refreshToken=; Path=/; Expires=${toRFC1123String(new Date(0))}; HttpOnly; SameSite=Lax${secureAttribute}`
        ]);

        // --- DEBUG LOG START ---
        const allSetCookieHeaders = res.getHeaders()['set-cookie'];
        console.log('Backend: ALL Set-Cookie headers for Logout Response:', allSetCookieHeaders);
        // --- DEBUG LOG END ---

        if (!refreshTokenCookie) {
            console.log('No refresh token cookie found in AuthController. Returning success message.');
            return res.status(200).json({ message: 'Logout successful (no active session found to revoke).' });
        }

        try {
            await this.authService.logout(refreshTokenCookie);
            console.log('AuthService.logout completed for token in AuthController.');
            return res.status(200).json({ message: 'Logout successful!' });
        } catch (error) {
            console.error("Error during logout process in AuthController:", error);
            next(error);
        }
    }
}

export default AuthController;
