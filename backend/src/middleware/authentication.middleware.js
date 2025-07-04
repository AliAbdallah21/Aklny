// backend/src/middleware/auth.middleware.js

import jwt from 'jsonwebtoken';

// This is now a factory function that creates the middleware
const authenticateToken = (jwtSecret) => { // <-- ACCEPT jwtSecret here
    return (req, res, next) => {
        const authHeader = req.headers['authorization'];
        const token = authHeader && authHeader.split(' ')[1];

        if (!token) {
            return res.status(401).json({ message: 'Authentication token required.' });
        }
        jwt.verify(token, jwtSecret, (err, user) => { // <-- USE jwtSecret here
            if (err) {
                return res.status(403).json({ message: 'Invalid or expired token.' });
            }
            req.user = user;
            next();
        });

    };

};



export default authenticateToken; // Still export the factory function