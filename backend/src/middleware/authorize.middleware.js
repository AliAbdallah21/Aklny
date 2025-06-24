// backend/src/middleware/authorize.middleware.js
// This middleware provides role-based authorization.

// It takes an array of allowed roles (e.g., ['admin', 'seller']) as an argument.
const authorizeRoles = (allowedRoles) => {
    return (req, res, next) => {
        // Check if req.user exists (meaning authenticateToken middleware ran successfully)
        if (!req.user || !req.user.role) {
            // This scenario should ideally be caught by authenticateToken first,
            // but it's a good safeguard.
            return res.status(401).json({ message: 'User role not found or not authenticated.' });
        }

        // Check if the user's role is included in the allowedRoles array
        if (allowedRoles.includes(req.user.role)) {
            next(); // User has the required role, proceed to the next middleware/route handler
        } else {
            // User does not have the required role, return 403 Forbidden
            res.status(403).json({ message: 'Access denied: Insufficient permissions.' });
        }
    };
};

export default authorizeRoles; // Export the middleware factory function