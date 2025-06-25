// backend/src/services/auth.service.js
// This service handles the core business logic for user authentication.

import bcrypt from 'bcryptjs'; // For password hashing
import jwt from 'jsonwebtoken'; // For JWT token generation and verification
import User from '../models/user.model.js'; // Import the User model

class AuthService {
    constructor(pool, jwtSecret) { // Constructor receives jwtSecret
        this.pool = pool; // The PostgreSQL connection pool
        this.jwtSecret = jwtSecret; // Store the JWT secret passed from the controller/routes
        // console.log(`[AuthService CONSTRUCTOR DEBUG] JWT_SECRET value received: ${this.jwtSecret ? 'PRESENT' : 'MISSING'}`);
    }

    // Method to handle user registration
    async register({ email, password, fullName, phoneNumber, role }) {
        // Basic input validation
        if (!email || !password || !fullName || !phoneNumber || !role) {
            throw new Error('All required fields must be provided for registration.');
        }

        // Check if a user with the provided email already exists
        const existingUser = await User.findByEmail(this.pool, email);
        if (existingUser) {
            throw new Error('User with this email already exists.');
        }

        // Hash the user's password for secure storage
        const salt = await bcrypt.genSalt(10); // Generate a salt
        const passwordHash = await bcrypt.hash(password, salt); // Hash the password

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
        const isMatch = await bcrypt.compare(password, user.password_hash);
        if (!isMatch) {
            throw new Error('Invalid credentials.'); // Generic message for security
        }

        // --- ADD THIS DEBUG LOG ---
        console.log(`[AuthService DEBUG] login method: Using JWT_SECRET: ${this.jwtSecret ? 'PRESENT' : 'MISSING'}`);
        // --- END DEBUG LOG ---

        // Generate a JSON Web Token (JWT) for the authenticated user
        const token = jwt.sign(
            { userId: user.user_id, email: user.email, role: user.role }, // Payload of the token
            this.jwtSecret, // The secret key to sign the token (from constructor)
            { expiresIn: '1h' } // Token expiration time (e.g., 1 hour)
        );

        // Destructure to remove the sensitive password hash before sending user info to frontend
        const { password_hash, ...userInfo } = user;
        return { token, user: userInfo }; // Return the token and essential user info
    }

    // Method to verify a JWT token (used for protecting routes)
    async verifyToken(token) {
        try {
            // Verify the token using the secret key (from constructor)
            const decoded = jwt.verify(token, this.jwtSecret);
            return decoded; // Returns the payload (userId, email, role) if valid
        } catch (error) {
            throw new Error('Invalid or expired token.'); // Handle token validation errors
        }
    }
}

// Export the AuthService class.
// This will be instantiated in the routes file, passing the pool and jwtSecret.
export default AuthService;