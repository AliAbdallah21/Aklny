// backend/src/services/auth.service.js
// This service handles the core business logic for user authentication,
// including registration, login, email verification, password reset, and Google Sign-In.
// Now using AppError for consistent error handling with HTTP status codes.
// FIXED: Android Client ID now loaded from environment variables.

import { v4 as uuidv4 } from 'uuid'; // For generating refresh tokens
import { OAuth2Client } from 'google-auth-library'; // For Google ID Token verification
import { sendVerificationEmail, sendPasswordResetEmail } from '../utils/email.utils.js';
import { customAlphabet } from 'nanoid';
import AppError from '../utils/appError.js';
import { hashPassword, comparePassword } from '../utils/password.utils.js'; // For password hashing/comparison
import { checkRequiredFields } from '../utils/validation.utils.js'; // For input validation

import jwt from 'jsonwebtoken'; // For JWT token generation and verification
import User from '../models/user.model.js'; // Import the User model
import RefreshToken from '../models/refresh_token.model.js'; // Import RefreshToken model

// Initialize nanoid for generating secure, URL-friendly tokens
const generateNanoId = customAlphabet('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz', 32);

// Define the Android Client ID by reading it from environment variables
const ANDROID_CLIENT_ID = process.env.GOOGLE_CLIENT_ID_ANDROID; // NOW READ FROM .ENV

// Initialize Google OAuth2Client.
const googleOAuthClient = new OAuth2Client(process.env.GOOGLE_CLIENT_ID_WEB);

class AuthService {
    constructor(pool, jwtSecret, jwtRefreshSecret) { // Constructor receives jwtSecret and jwtRefreshSecret
        this.pool = pool;
        this.jwtSecret = jwtSecret;
        this.jwtRefreshSecret = jwtRefreshSecret;
    }

    // Method to handle user registration
    async register({ email, password, fullName, phoneNumber }) {
        // Use validation utility for required fields
        checkRequiredFields({ email, password, fullName, phoneNumber }, ['email', 'password', 'fullName', 'phoneNumber']);

        // Check if a user with the provided email already exists
        const existingUser = await User.findByEmail(this.pool, email);
        if (existingUser) {
            throw new AppError('User with this email already exists.', 409); // 409 Conflict
        }

        const assignedRole = 'customer';
        const passwordHash = await hashPassword(password); // Hash the password

        const emailVerificationToken = generateNanoId();
        const emailVerificationTokenExpiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000); // Token valid for 24 hours

        const newUser = await User.create(this.pool, {
            email,
            passwordHash,
            fullName,
            phoneNumber,
            role: assignedRole,
            isVerified: false,
            emailVerificationToken,
            emailVerificationTokenExpiresAt,
            googleId: null,
        });

        await sendVerificationEmail(newUser.email, emailVerificationToken, newUser.full_name || newUser.email);

        const { password_hash, email_verification_token, email_verification_token_expires_at, password_reset_token, password_reset_token_expires_at, ...userInfo } = newUser;
        return userInfo;
    }

    // Method to handle user login
    async login({ email, password }) {
        const user = await User.findByEmail(this.pool, email);
        if (!user) {
            throw new AppError('Invalid Email or Password.', 401); // 401 Unauthorized
        }

        if (!user.is_verified) {
            throw new AppError('Please verify your email address to log in. Check your inbox for a verification link.', 403); // 403 Forbidden
        }

        if (!user.password_hash) {
            // This case handles users who registered via social login and don't have a password_hash
            throw new AppError('This account was registered via social login. Please sign in with Google.', 401);
        }

        if (!await comparePassword(password, user.password_hash)) {
            throw new AppError('Invalid Email or Password.', 401); // 401 Unauthorized
        }

        // Generate Access Token
        const accessToken = this.generateAccessToken({ userId: user.user_id, email: user.email, role: user.role });

        // Generate and Store Refresh Token
        const refreshToken = await this.generateAndStoreRefreshToken(user.user_id);

        const { password_hash, email_verification_token, email_verification_token_expires_at, password_reset_token, password_reset_token_expires_at, ...userInfo } = user;
        return { accessToken, refreshToken, user: userInfo }; // Return both tokens and user info
    }

    async logout(tokenId) {
        // --- DEBUG LOGS START ---
        console.log('AuthService.logout: Received tokenId for revocation:', tokenId);
        // --- DEBUG LOGS END ---

        if (!tokenId) {
            throw new AppError('No refresh token provided for logout.', 400);
        }
        try {
            await RefreshToken.revoke(this.pool, tokenId);
            // --- DEBUG LOGS START ---
            console.log('AuthService.logout: RefreshToken.revoke completed successfully for tokenId:', tokenId);
            // --- DEBUG LOGS END ---
        } catch (error) {
            console.error("Error revoking refresh token in AuthService:", error);
            throw new AppError('Failed to revoke refresh token.', 500); // Or a more specific 400/404 if token not found
        }
    }

    generateAccessToken({ userId, email, role }) {
        const token = jwt.sign(
            { userId, email, role },
            this.jwtSecret,
            { expiresIn: '1h' }
        );
        return token;
    }

    async generateAndStoreRefreshToken(userId) {
        const tokenId = uuidv4(); // Generates the unique refresh token value
        const expiryDate = new Date();
        expiryDate.setDate(expiryDate.getDate() + 7); // Refresh token valid for 7 days

        // --- DEBUG LOGS START ---
        console.log('AuthService.generateAndStoreRefreshToken: Creating new token:', tokenId, 'for user:', userId);
        // --- DEBUG LOGS END ---

        await RefreshToken.create(this.pool, tokenId, userId, expiryDate);

        return tokenId; // The value sent to the client (to be stored in HttpOnly cookie)
    }

    // NEW: Method to handle Google Sign-In/Registration
    async authenticateWithGoogle(idToken) {
        let ticket;
        try {
            const validAudiences = [
                process.env.GOOGLE_CLIENT_ID_WEB,
                ANDROID_CLIENT_ID, // Correctly uses the variable loaded from .env
                process.env.GOOGLE_CLIENT_ID_IOS,
            ].filter(Boolean);

            ticket = await googleOAuthClient.verifyIdToken({
                idToken: idToken,
                audience: validAudiences,
            });
        } catch (error) {
            console.error('Google ID Token verification failed:', error.message);
            throw new AppError('Google authentication failed: Invalid token or network issue.', 401);
        }

        const payload = ticket.getPayload();
        if (!payload) {
            throw new AppError('Google authentication failed: Could not get payload from token.', 401);
        }

        const googleId = payload['sub'];
        const email = payload['email'];
        const fullName = payload['name'] || email;

        if (!email) {
            throw new AppError('Google authentication failed: Email not provided by Google.', 400);
        }

        let user = await User.findByGoogleId(this.pool, googleId);

        if (user) {
            if (!user.is_verified) {
                user = await User.markEmailAsVerified(this.pool, user.user_id);
            }
        } else {
            user = await User.findByEmail(this.pool, email);

            if (user) {
                if (user.password_hash && !user.google_id) {
                    user = await User.updateProfile(this.pool, user.user_id, {
                        googleId: googleId,
                        isVerified: true,
                        emailVerificationToken: null,
                        emailVerificationTokenExpiresAt: null,
                    });
                } else if (!user.password_hash && user.google_id) {
                    throw new AppError('An account with this email is already linked to a different social account.', 409);
                } else {
                    throw new AppError('An account with this email already exists with a password. Please log in with your password and link your Google account in settings, or use password reset if you forgot it.', 409);
                }
            } else {
                user = await User.create(this.pool, {
                    email: email,
                    passwordHash: null,
                    fullName: fullName,
                    phoneNumber: '',
                    role: 'customer',
                    isVerified: true,
                    emailVerificationToken: null,
                    emailVerificationTokenExpiresAt: null,
                    googleId: googleId,
                });
            }
        }

        const accessToken = this.generateAccessToken({ userId: user.user_id, email: user.email, role: user.role });
        const refreshToken = await this.generateAndStoreRefreshToken(user.user_id);

        const { password_hash, email_verification_token, email_verification_token_expires_at, password_reset_token, password_reset_token_expires_at, ...userInfo } = user;
        return { accessToken, refreshToken, user: userInfo };
    }

    // Method to handle email verification when a user clicks the link
    async verifyEmail(token) {
        const user = await User.findByEmailVerificationToken(this.pool, token);

        if (!user) {
            throw new AppError('Invalid or expired verification link.', 400);
        }

        const updatedUser = await User.markEmailAsVerified(this.pool, user.user_id);

        const { password_hash, email_verification_token, email_verification_token_expires_at, password_reset_token, password_reset_token_expires_at, ...userInfo } = updatedUser;
        return userInfo;
    }

    // Method to handle resending verification email
    async resendVerificationEmail(email) {
        const user = await User.findByEmail(this.pool, email);
        if (!user) {
            return 'If an account with that email exists and is not verified, a new verification link has been sent.';
        }

        if (user.is_verified) {
            throw new AppError('Email is already verified for this account.', 409);
        }

        const emailVerificationToken = generateNanoId();
        const emailVerificationTokenExpiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000);

        await User.updateProfile(this.pool, user.user_id, {
            emailVerificationToken: emailVerificationToken,
            emailVerificationTokenExpiresAt: emailVerificationTokenExpiresAt
        });

        await sendVerificationEmail(user.email, emailVerificationToken, user.full_name || user.email);

        return 'If an account with that email exists and is not verified, a new verification link has been sent.';
    }

    // Method to handle a password reset request (Step 1: Send Email with Token)
    async requestPasswordReset(email) {
        const user = await User.findByEmail(this.pool, email);
        if (!user) {
            return 'If an account with that email exists, a password reset link has been sent.';
        }

        const passwordResetToken = generateNanoId();
        const passwordResetTokenExpiresAt = new Date(Date.now() + 60 * 60 * 1000);

        await User.updatePasswordResetToken(this.pool, user.user_id, passwordResetToken, passwordResetTokenExpiresAt);

        await sendPasswordResetEmail(user.email, passwordResetToken, user.full_name || user.email);

        return 'If an account with that email exists, a password reset link has been sent.';
    }

    // Method to perform a quick check for the token's validity for the GET form.
    async findByPasswordResetTokenForForm(token) {
        const user = await User.findByPasswordResetToken(this.pool, token);
        if (!user) {
            throw new AppError('Invalid or expired password reset token.', 400);
        }
        return user;
    }

    // Method to handle the actual password reset (Step 2: Update Password)
    async resetPassword(token, newPassword) {
        const user = await User.findByPasswordResetToken(this.pool, token);

        if (!user) {
            throw new AppError('Invalid or expired password reset link.', 400);
        }

        const newPasswordHash = await hashPassword(newPassword);

        await User.updatePassword(this.pool, user.user_id, newPasswordHash);
        await User.updateProfile(this.pool, user.user_id, {
            passwordResetToken: null,
            passwordResetTokenExpiresAt: null
        });

        // NEW: Invalidate all refresh tokens for this user after a password change
        await RefreshToken.revokeAllByUserId(this.pool, user.user_id);

        return 'Your password has been successfully reset.';
    }

    // Method to verify an Access Token (used for protecting routes)
    async verifyAccessToken(token) {
        try {
            const decoded = jwt.verify(token, this.jwtSecret);
            return decoded;
        } catch (error) {
            if (error instanceof jwt.JsonWebTokenError) {
                throw new AppError('Invalid token.', 401);
            } else if (error instanceof jwt.TokenExpiredError) {
                throw new AppError('Token expired.', 401);
            }
            throw new AppError('Authentication failed.', 401);
        }
    }
}

export default AuthService;
