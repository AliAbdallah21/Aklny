// backend/src/app.js


import express from 'express';
import cors from 'cors';
import pg from 'pg';

// Import MongoDB connection function (but the call will be inside initializeApp)
import connectMongoDB from './config/mongo.config.js';

// Import route factories (these will now accept dependencies)
import authRoutes from './routes/auth.routes.js';
import foodRoutes from './routes/food.routes.js';
import userRoutes from './routes/user.routes.js';

// Import authorizeRoles (authenticateToken will be passed from server.js)
import authorizeRoles from './middleware/authorize.middleware.js'; // This remains directly imported

// Export the initializeApp function and the pool (which will be defined inside)
let pool; // Declare pool outside to be exported later

const initializeApp = async (jwtSecret, authenticateTokenFactory) => { // <-- IMPORTANT: JWT_SECRET & AUTH_TOKEN FACTORY
    const app = express();

    // Create PostgreSQL Pool and connect to MongoDB *INSIDE* this function
    const { Pool } = pg;
    pool = new Pool({
      user: process.env.PGUSER,
      host: process.env.PGHOST,
      database: process.env.PGDATABASE,
      password: process.env.PGPASSWORD,
      port: process.env.PGPORT,
    });

    // Test the PostgreSQL database connection
    await pool.query('SELECT NOW()')
        .then(res => console.log('PostgreSQL database connected successfully at:', res.rows[0].now))
        .catch(err => {
            console.error('PostgreSQL Database connection error:', err.stack);
            process.exit(1);
        });

    // Connect to MongoDB
    connectMongoDB();

    // Middleware setup
    app.use(cors());
    app.use(express.json());

    // Initialize the actual authenticateToken middleware function here
    const authenticateToken = authenticateTokenFactory(jwtSecret); // <-- CREATE THE MIDDLEWARE INSTANCE

    // Basic route for testing server status
    app.get('/', (req, res) => {
        res.status(200).json({ message: 'HomeChefs Connect Backend API is running!' });
    });

    // --- API Routes ---
    // Authentication routes (publicly accessible for login/register)
    // Pass the jwtSecret to the authRoutes factory so it can create AuthService with the secret
    app.use('/api/auth', authRoutes(pool, jwtSecret)); // <-- PASS jwtSecret

    // Food item routes (includes public and seller-specific endpoints)
    // Pass authenticateToken and authorizeRoles so foodRoutes can apply them
    app.use('/api/food', foodRoutes(pool, authenticateToken, authorizeRoles)); // <-- PASS AUTH MIDDLEWARE & AUTHORIZE

    // User profile routes (protected, /api/users/me, /api/users/me/password)
    // Pass authenticateToken so userRoutes can apply it
    app.use('/api/users', userRoutes(pool, authenticateToken)); // <-- PASS AUTH MIDDLEWARE


    // --- Protected Test Routes (for development/testing purposes) ---
    // Use the passed authenticateToken
    app.get('/api/protected', authenticateToken, (req, res) => {
        res.status(200).json({
            message: 'Welcome to the protected route!',
            user: req.user
        });
    });

    app.get('/api/admin-only', authenticateToken, authorizeRoles(['admin']), (req, res) => {
        res.status(200).json({
            message: 'Welcome, Admin!',
            user: req.user
        });
    });

    app.get('/api/seller-only', authenticateToken, authorizeRoles(['seller']), (req, res) => {
        res.status(200).json({
            message: 'Welcome, Seller!',
            user: req.user
        });
    });

    return app; // Return the configured app instance
};

export { initializeApp, pool }; // Export initializeApp and the now-defined pool