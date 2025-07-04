// backend/src/services/auth.service.js
// This service handles the core business logic for user authentication.

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
            throw new Error('User with this email already exists.');
        }

        // IMPORTANT SECURITY FIX: ALWAYS DEFAULT SELF-REGISTERED USERS TO 'customer' ROLE
        // This prevents users from declaring themselves as admin/seller/driver during public registration.
        const assignedRole = 'customer'; // <-- THIS LINE IS CRUCIAL: HARDCODE THE ROLE

        // Hash the user's password for secure storage
        const passwordHash = await hashPassword(password); // Hash the password

        // Create the new user record in the database using the User model
        const newUser = await User.create(this.pool, {
            email,
            passwordHash,
            fullName,
            phoneNumber,
            role: assignedRole // <-- USE THE HARDCODED ROLE HERE, IGNORING THE 'role' FROM REQ.BODY
        });

        // Return the newly created user's public information (excluding password hash)
        return newUser;
    }

    // Method to handle user login
    async login({ email, password }) {
        // Find the user by their email
        const user = await User.findByEmail(this.pool, email);
        if (!user) {
            throw new Error('Invalid Email.'); // Generic message for security
        }

        // Compare the provided password with the hashed password stored in the database
        if (!comparePassword(password, user.password_hash)) {
            throw new Error('Incorrect password'); // Generic message for security
        }

        // Generate a JSON Web Token (JWT) for the authenticated user
        this.generateAccessToken({userID: user.user_id, email: user.email, role: user.role});

        // Destructure to remove the sensitive password hash before sending user info to frontend
        const { password_hash, ...userInfo } = user;
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

    // Method to verify a JWT token (used for protecting routes)
    async verifyAccessToken(token) {
        try {
            const decoded = jwt.verify(token, this.jwtSecret);
            return decoded; // Returns the payload (userId, email, role) if valid
        } catch (error) {
            throw new Error('Invalid or expired token.'); // Handle token validation errors
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