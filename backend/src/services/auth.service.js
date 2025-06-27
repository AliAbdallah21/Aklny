// backend/src/services/auth.service.js
// This service handles the core business logic for user authentication.

import jwt from 'jsonwebtoken'; // For JWT token generation and verification
import User from '../models/user.model.js'; // Import the User model (note the .js extension)
import { validateRegister } from '../utils/validation.utils.js';
import { hashPassword, comparePassowrd } from '../utils/password.utils.js';

// Get JWT secret from environment variables (loaded by dotenv/config in app.js)
const JWT_SECRET = process.env.JWT_SECRET;

class AuthService {
    constructor(pool) {
        this.pool = pool; // The PostgreSQL connection pool is passed to the service
    }

    // Method to handle user registration
    async register({ email, password, fullName, phoneNumber, role }) {
        // Basic input validation
        if(validateRegister({email,password,fullName,phoneNumber})){
            throw new Error('All required fields must be provided for registration.');
        }

        // Check if a user with the provided email already exists
        const existingUser = await User.findByEmail(this.pool, email);
        if (existingUser) {
            throw new Error('User with this email already exists.');
        }

        // Hash the user's password for secure storage
        const passwordHash = await hashPassword(password); // Hash the password

        // Create the new user record in the database using the User model
        const newUser = await User.create(this.pool, {
            email,
            passwordHash,
            fullName,
            phoneNumber,
            role
        });

        // Note: For 'customer' roles, seller/driver-specific fields will be NULL by default
        // in the database as per your schema. Backend logic for 'seller'/'driver' specific
        // field requirements would be added here or in a separate profile update service later.

        // Return the newly created user's public information (excluding password hash)
        return newUser;
    }

    

    // Method to handle user login
    async login({ email, password }) {
        // Find the user by their email
        const user = await User.findByEmail(this.pool, email);
        if (!user) {
            throw new Error('Invalid credentials.'); // Generic message for security
        }

        // Compare the provided password with the hashed password stored in the database
        if (!comparePassowrd(password, user.password_hash)) {
            throw new Error('Invalid credentials.'); // Generic message for security
        }

        // Generate a JSON Web Token (JWT) for the authenticated user
        const token = jwt.sign(
            { userId: user.user_id, email: user.email, role: user.role }, // Payload of the token
            JWT_SECRET, // The secret key to sign the token
            { expiresIn: '1h' } // Token expiration time (e.g., 1 hour)
        );

        // Destructure to remove the sensitive password hash before sending user info to frontend
        const { password_hash, ...userInfo } = user;
        return { token, user: userInfo }; // Return the token and essential user info
    }

    // Method to verify a JWT token (used for protecting routes)
    async verifyToken(token) {
        try {
            // Verify the token using the secret key
            const decoded = jwt.verify(token, JWT_SECRET);
            return decoded; // Returns the payload (userId, email, role) if valid
        } catch (error) {
            throw new Error('Invalid or expired token.'); // Handle token validation errors
        }
    }
}

// Export an instance of AuthService, or the class itself.
// Exporting the class allows you to create instances where needed, passing the pool.
export default AuthService;