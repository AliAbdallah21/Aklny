// backend/src/middleware/auth.middleware.js
// This middleware verifies JWT tokens for authentication.

import jwt from 'jsonwebtoken'; // For verifying JWTs

// Get the JWT secret from environment variables
const JWT_SECRET = process.env.JWT_SECRET;

// Middleware function to verify JWT
const authenticateToken = (req, res, next) => {
    // Get the token from the Authorization header (e.g., "Bearer YOUR_TOKEN_HERE")
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Extract the token part

    // If no token is provided, return 401 Unauthorized
    if (!token) {
        return res.status(401).json({ message: 'Authentication token required.' });
    }

    // Verify the token
    jwt.verify(token, JWT_SECRET, (err, user) => {
        if (err) {
            // If token is invalid or expired, return 403 Forbidden
            return res.status(403).json({ message: 'Invalid or expired token.' });
        }
        // If token is valid, attach the decoded user payload to the request object
        // This 'user' object contains { userId, email, role } from the JWT payload
        req.user = user;
        next(); // Proceed to the next middleware or route handler
    });
};

export default authenticateToken; // Export the middleware function