// backend/src/app.js
import express from 'express';
import cors from 'cors';
import pg from 'pg';
import cookieParser from 'cookie-parser';

import authRoutes from './routes/auth.routes.js';
import foodRoutes from './routes/food.routes.js';
import userRoutes from './routes/user.routes.js';

import authorizeRoles from './middleware/authorize.middleware.js';
import { errorHandler } from './utils/errors.utils.js'; // Ensure errorHandler is imported here!

let pool;

const initializeApp = async (jwtSecret, jwtRefreshSecret, authenticateTokenFactory) => {
    const app = express();

    const { Pool } = pg;
    pool = new Pool({
        connectionString: process.env.DATABASE_URL,
        ssl: { rejectUnauthorized: false }
    });

    await pool.query('SELECT NOW()')
        .then(res => console.log('PostgreSQL database connected successfully at:', res.rows[0].now))
        .catch(err => {
            console.error('PostgreSQL Database connection error:', err.stack);
            process.exit(1);
        });

    // Middleware setup
    app.use(cors());
    app.use(express.json());
    app.use(cookieParser());

    const authenticateToken = authenticateTokenFactory(jwtSecret);

    // Basic route for testing server status
    app.get('/', (req, res) => {
        res.status(200).json({ message: 'HomeChefs Connect Backend API is running!' });
    });

    // --- API Routes ---
    app.use('/api/auth', authRoutes(pool, jwtSecret, jwtRefreshSecret));
    app.use('/api/food', foodRoutes(pool, authenticateToken, authorizeRoles));
    app.use('/api/users', userRoutes(pool, authenticateToken));

    // --- Protected Test Routes (for development/testing purposes) ---
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

    // NEW: 404 Not Found Handler
    // This middleware will be hit if no other route matches.
    // It MUST come AFTER all your defined routes but BEFORE your global error handler.
    app.use((req, res, next) => {
        console.warn(`404 Not Found: ${req.method} ${req.originalUrl}`); // Log unmatched requests
        res.status(404).json({ message: `Cannot ${req.method} ${req.originalUrl}. Route not found.` });
    });

    // IMPORTANT: Global error handler - MUST BE LAST
    app.use(errorHandler);

    return app;
};

export { initializeApp, pool };
