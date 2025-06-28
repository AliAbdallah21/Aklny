// backend/src/middleware/auth.middleware.js

import jwt from 'jsonwebtoken';



// This is now a factory function that creates the middleware

const authenticateToken = (jwtSecret) => { // <-- ACCEPT jwtSecret here

    // console.log(`[AuthMiddleware FACTORY DEBUG] JWT_SECRET value received: ${jwtSecret ? 'PRESENT' : 'MISSING'}`); // Keep or remove this debug log

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