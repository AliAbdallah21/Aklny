// backend/src/config/jwt.config.js
// This file centralizes JWT (JSON Web Token) configuration,
// loading the secret from environment variables.

import dotenv from 'dotenv';
dotenv.config(); // Load environment variables from .env file

export default {
    // The secret key used to sign and verify JWTs.
    // It's crucial this is a strong, random string and kept secret.
    // It's loaded from the JWT_SECRET environment variable.
    secret: process.env.JWT_SECRET || 'your_fallback_super_secret_jwt_key', // Fallback for development if .env is missing
    
    // Default expiration time for JWTs issued by the application.
    expiresIn: '1h' // Example: tokens expire in 1 hour
};
