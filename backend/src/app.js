// backend/src/app.js
import dotenv from 'dotenv';
import path from 'path'; // <-- IMPORTANT: ADD THIS LINE
import { fileURLToPath } from 'url'; // <-- IMPORTANT: ADD THIS LINE

// Get __dirname equivalent for ES Modules to build absolute path
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Construct the absolute path to the .env file in the backend/ directory
const envPath = path.resolve(__dirname, '../.env'); // <-- This resolves to C:\Aklny\backend\.env

console.log(`Attempting to load .env from: ${envPath}`); // <-- DEBUG LOG
const dotenvResult = dotenv.config({ path: envPath }); // <-- IMPORTANT: Use absolute path

if (dotenvResult.error) { // <-- DEBUG LOG
  console.error('dotenv error:', dotenvResult.error);
} else if (dotenvResult.parsed) { // <-- DEBUG LOG
  console.log('dotenv loaded variables:', Object.keys(dotenvResult.parsed));
} else { // <-- DEBUG LOG
    console.log('dotenv result:', dotenvResult);
}

console.log('MONGO_URI after dotenv.config():', process.env.MONGO_URI); // <-- DEBUG LOG

import express from 'express';
import cors from 'cors';
import pg from 'pg';

// Import MongoDB connection function
import connectMongoDB from './config/mongo.config.js';

// Import authentication routes
import authRoutes from './routes/auth.routes.js';

// Import food item routes
import foodRoutes from './routes/food.routes.js';

// Import authentication and authorization middleware
import authenticateToken from './middleware/auth.middleware.js';
import authorizeRoles from './middleware/authorize.middleware.js';

const { Pool } = pg;

const app = express();

// Middleware setup
app.use(cors());
app.use(express.json());

// PostgreSQL Database Connection Pool
const pool = new Pool({
  user: process.env.PGUSER,
  host: process.env.PGHOST,
  database: process.env.PGDATABASE,
  password: process.env.PGPASSWORD,
  port: process.env.PGPORT,
});

// Test the PostgreSQL database connection when the application starts
pool.query('SELECT NOW()', (err, res) => {
  if (err) {
    console.error('PostgreSQL Database connection error:', err.stack);
    process.exit(1);
  } else {
    console.log('PostgreSQL database connected successfully at:', res.rows[0].now);
  }
});

// Connect to MongoDB
connectMongoDB();


// Basic route for testing server status
app.get('/', (req, res) => {
  res.status(200).json({ message: 'HomeChefs Connect Backend API is running!' });
});

// --- API Routes ---
// Authentication routes (publicly accessible for login/register)
app.use('/api/auth', authRoutes(pool));

// Food item routes (includes public and seller-specific endpoints)
app.use('/api/food', foodRoutes(pool));

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

// Export the configured Express app and the PostgreSQL connection pool
export { app, pool };