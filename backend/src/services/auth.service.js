// backend/src/services/auth.service.js

import bcrypt from 'bcryptjs'; // For password hashing and comparison
import jwt from 'jsonwebtoken'; // For JWT token generation and verification
import { OAuth2Client } from 'google-auth-library'; // For Google ID Token verification
import User from '../models/user.model.js'; // Import the User model for database interactions
import { sendVerificationEmail, sendPasswordResetEmail } from '../utils/email.utils.js'; // Import email sending utility
import { customAlphabet } from 'nanoid'; // For generating unique tokens
import AppError from '../utils/appError.js'; // NEW: Import custom AppError

// Initialize nanoid for generating secure, URL-friendly tokens
const generateNanoId = customAlphabet('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz', 32);

// Define the Android Client ID directly here, as it's static and comes from google-services.json
// This is the 'azp' claim in the ID token.
const ANDROID_CLIENT_ID = 'GOOGLE_CLIENT_ID_ANDROID';

// Initialize Google OAuth2Client.
// The client ID passed to the constructor is typically the primary web client ID.
// The 'audience' parameter in verifyIdToken will then specify all valid client IDs.
const googleOAuthClient = new OAuth2Client(process.env.GOOGLE_CLIENT_ID_WEB);
import jwt from 'jsonwebtoken'; // For JWT token generation and verification
import { v4 as uuidv4 } from 'uuid';
import User from '../models/user.model.js'; // Import the User model (note the .js extension)
import RefreshToken from '../models/refresh_token.model.js';
import { validateRegister } from '../utils/validation.utils.js';
import { hashPassword, comparePassword } from '../utils/password.utils.js';

class AuthService {
    constructor(pool, jwtSecret, jwtRefreshSecret) { // Constructor receives jwtSecret
        this.pool = pool; // The PostgreSQL connection pool
        this.jwtSecret = jwtSecret; // Store the JWT secret passed from the controller/routes
        this.jwtRefreshSecret = jwtRefreshSecret;
    }

    // Method to handle user registration
    async register({ email, password, fullName, phoneNumber }) {
        // Basic input validation
        if (validateRegister({ email, password, fullName, phoneNumber })) {
            throw new Error('All required fields must be provided for registration.');
        }

        // Check if a user with the provided email already exists
        const existingUser = await User.findByEmail(this.pool, email);
        if (existingUser) {
            throw new AppError('User with this email already exists.', 409); // 409 Conflict
        }

        // SECURITY: Always default self-registered users to 'customer' role
        const assignedRole = 'customer';

        // Hash the user's password for secure storage
        const passwordHash = await hashPassword(password); // Hash the password

        // Generate email verification token and its expiry time
        const emailVerificationToken = generateNanoId();
        const emailVerificationTokenExpiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000); // Token valid for 24 hours

        // Create the new user record in the database
        const newUser = await User.create(this.pool, {
            email,
            passwordHash,
            fullName,
            phoneNumber,
            role: assignedRole,
            isVerified: false, // User is initially NOT verified
            emailVerificationToken,
            emailVerificationTokenExpiresAt,
            googleId: null, // No Google ID for traditional registration
        });

        // Send the email verification email to the user
        await sendVerificationEmail(newUser.email, emailVerificationToken, newUser.full_name || newUser.email);

        // Destructure to remove sensitive password hash and tokens before sending user info to frontend
        const { password_hash, email_verification_token, email_verification_token_expires_at, password_reset_token, password_reset_token_expires_at, ...userInfo } = newUser;
        return userInfo; // Return the newly created user's public information
    }

    // Method to handle user login
    async login({ email, password }) {
        // Find the user by their email
        const user = await User.findByEmail(this.pool, email);
        if (!user) {
            throw new AppError('Invalid Email or Password.', 401); // 401 Unauthorized (generic message for security)
        }

        // Check if the user's email is verified before allowing login
        if (!user.is_verified) {
            throw new AppError('Please verify your email address to log in. Check your inbox for a verification link.', 403); // 403 Forbidden
        }

        // Compare the provided password with the hashed password stored in the database
        if (!comparePassword(password, user.password_hash)) {
            throw new Error('Incorrect password'); // Generic message for security
        }

        // Generate a JSON Web Token (JWT) for the authenticated user
        this.generateAccessToken({userID: user.user_id, email: user.email, role: user.role});

        // Destructure to remove sensitive data
        const { password_hash, email_verification_token, email_verification_token_expires_at, password_reset_token, password_reset_token_expires_at, ...userInfo } = user;
        return { token, user: userInfo }; // Return the token and essential user info
    }

    async logout(tokenId) {
        try {
            await this.revokeToken(tokenId)
            return true;
        }
        catch (error) {
            throw new Error('no token was passed.');
            return false;
        }
    }

    async generateAccessToken({ userId, email, role }) {
        const token = jwt.sign(
            {userId, email, role}, // Payload of the token
            this.jwtSecret, // The secret key to sign the token (from constructor)
            { expiresIn: '1h' } // Token expiration time (e.g., 1 hour)
        );
        return token;
    }

    // NEW: Method to handle Google Sign-In/Registration
    async authenticateWithGoogle(idToken) {
        let ticket;
        try {
            // Define the audiences that this token is valid for.
            // This array MUST include:
            // 1. process.env.GOOGLE_CLIENT_ID_WEB (the 'aud' claim in the token, your backend's web client ID)
            // 2. ANDROID_CLIENT_ID (the 'azp' claim in the token, the client that initiated the request)
            const validAudiences = [
                process.env.GOOGLE_CLIENT_ID_WEB,
                ANDROID_CLIENT_ID,
                // Add process.env.GOOGLE_CLIENT_ID_IOS here if you have a real iOS client ID and plan to use it
            ].filter(Boolean); // Filter out any null/undefined values

            console.log('Backend verifying ID token with audiences:', validAudiences); // Debugging line

            ticket = await googleOAuthClient.verifyIdToken({
                idToken: idToken,
                audience: validAudiences, // Use the dynamically created array
            });
        } catch (error) {
            console.error('Google ID Token verification failed:', error.message);
            throw new AppError('Google authentication failed: Invalid token or network issue.', 401); // 401 Unauthorized
        }

        const payload = ticket.getPayload();
        if (!payload) {
            throw new AppError('Google authentication failed: Could not get payload from token.', 401); // 401 Unauthorized
        }

        const googleId = payload['sub']; // Unique Google User ID
        const email = payload['email'];
        const fullName = payload['name'] || email; // Use name if available, fallback to email
        // Google does not provide a phone number directly via ID Token

        if (!email) {
            throw new AppError('Google authentication failed: Email not provided by Google.', 400); // 400 Bad Request
        }

        // 1. Check if user already exists with this Google ID
        let user = await User.findByGoogleId(this.pool, googleId);

        if (user) {
            // User found by Google ID, log them in
            // Ensure their email is marked as verified if it wasn't already
            if (!user.is_verified) {
                user = await User.markEmailAsVerified(this.pool, user.user_id);
            }
        } else {
            // 2. User not found by Google ID, check if an account exists with the same email
            user = await User.findByEmail(this.pool, email);

            if (user) {
                // User found by email.
                // If it's a traditional account (has password_hash) and no google_id linked, link it.
                if (user.password_hash && !user.google_id) {
                    user = await User.updateProfile(this.pool, user.user_id, {
                        googleId: googleId,
                        isVerified: true, // Mark email as verified if linking Google
                        emailVerificationToken: null,
                        emailVerificationTokenExpiresAt: null,
                    });
                } else if (!user.password_hash && user.google_id) {
                    // This case means an account exists with this email AND it's already a social login,
                    // but it wasn't found by findByGoogleId initially. This implies a different Google ID
                    // or a logic error. Prevent linking to avoid overwriting.
                    throw new AppError('An account with this email is already linked to a different social account.', 409); // 409 Conflict
                } else {
                    // This case should ideally not be reached if findByGoogleId was checked first.
                    // It means an account with this email exists, has a password, and might already have a google_id.
                    // If it has a password, we prevent automatic linking to avoid security issues.
                    throw new AppError('An account with this email already exists with a password. Please log in with your password and link your Google account in settings, or use password reset if you forgot it.', 409); // 409 Conflict
                }
            } else {
                // 3. No user found by Google ID or email, create a new user
                user = await User.create(this.pool, {
                    email: email,
                    passwordHash: null, // No password for social login
                    fullName: fullName,
                    phoneNumber: '', // Google ID token does not provide phone number directly
                    role: 'customer', // Default role for new social users
                    isVerified: true, // Email is considered verified via Google
                    emailVerificationToken: null,
                    emailVerificationTokenExpiresAt: null,
                    googleId: googleId,
                });
            }
        }

        // Generate JWT for the authenticated/registered user
        const token = jwt.sign(
            { userId: user.user_id, email: user.email, role: user.role },
            this.jwtSecret,
            { expiresIn: '1h' }
        );

        // Destructure to remove sensitive data before sending user info to frontend
        const { password_hash, email_verification_token, email_verification_token_expires_at, password_reset_token, password_reset_token_expires_at, ...userInfo } = user;
        return { token, user: userInfo };
    }

    // Method to handle email verification when a user clicks the link
    async verifyEmail(token) {
        const user = await User.findByEmailVerificationToken(this.pool, token);

        if (!user) {
            throw new AppError('Invalid or expired verification link.', 400); // 400 Bad Request
        }

        const updatedUser = await User.markEmailAsVerified(this.pool, user.user_id);

        const { password_hash, email_verification_token, email_verification_token_expires_at, password_reset_token, password_reset_token_expires_at, ...userInfo } = updatedUser;
        return userInfo;
    }

    // Method to handle resending verification email
    async resendVerificationEmail(email) {
        const user = await User.findByEmail(this.pool, email);
        if (!user) {
            // For security, always return a generic message to prevent email enumeration
            return 'If an account with that email exists and is not verified, a new verification link has been sent.';
        }

        if (user.is_verified) {
            throw new AppError('Email is already verified for this account.', 409); // 409 Conflict
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
            // For security, always return a generic message to prevent email enumeration
            return 'If an account with that email exists, a password reset link has been sent.';
        }

        const passwordResetToken = generateNanoId();
        const passwordResetTokenExpiresAt = new Date(Date.now() + 60 * 60 * 1000); // Token valid for 1 hour

        await User.updatePasswordResetToken(this.pool, user.user_id, passwordResetToken, passwordResetTokenExpiresAt);

        await sendPasswordResetEmail(user.email, passwordResetToken, user.full_name || user.email);

        return 'If an account with that email exists, a password reset link has been sent.';
    }

    // Method to perform a quick check for the token's validity for the GET form.
    async findByPasswordResetTokenForForm(token) {
        const user = await User.findByPasswordResetToken(this.pool, token);
        if (!user) {
            throw new AppError('Invalid or expired password reset token.', 400); // 400 Bad Request
        }
        return user;
    }

    // Method to handle the actual password reset (Step 2: Update Password)
    async resetPassword(token, newPassword) {
        const user = await User.findByPasswordResetToken(this.pool, token);

        if (!user) {
            throw new AppError('Invalid or expired password reset link.', 400); // 400 Bad Request
        }

        const salt = await bcrypt.genSalt(10);
        const newPasswordHash = await bcrypt.hash(newPassword, salt);

        await User.updatePassword(this.pool, user.user_id, newPasswordHash);
        await User.updateProfile(this.pool, user.user_id, {
            passwordResetToken: null,
            passwordResetTokenExpiresAt: null
        });

        return 'Your password has been successfully reset.';
    }

    // Method to verify a JWT token (used for protecting routes)
    async verifyAccessToken(token) {
        try {
            const decoded = jwt.verify(token, this.jwtSecret);
            return decoded;
        } catch (error) {
            // Specific error for JWT issues
            if (error instanceof jwt.JsonWebTokenError) {
                throw new AppError('Invalid token.', 401); // 401 Unauthorized
            } else if (error instanceof jwt.TokenExpiredError) {
                throw new AppError('Token expired.', 401); // 401 Unauthorized
            }
            throw new AppError('Authentication failed.', 401); // Generic 401 for other token issues
        }
    }



    async generateAndStoreRefreshToken(userId) {
        const tokenId = uuidv4(); // Generates the unique refresh token value
        const expiryDate = new Date();
        expiryDate.setDate(expiryDate.getDate() + 7);

        // This is where it's added to the table!
        await RefreshToken.create(this.pool, tokenId, userId, expiryDate);

        return tokenId; // The value sent to the client
    }

    async revokeRefreshToken(tokenId) {
        try {
            await RefreshToken.revoke(this.pool, tokenId);
        }
        catch (error) {
            throw new Error('Invalid or expired token.');
        }
    }

}


// Export the AuthService class.
// This will be instantiated in the routes file, passing the pool and jwtSecret.
export default AuthService;
