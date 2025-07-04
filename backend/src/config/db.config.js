// backend/src/config/db.config.js
// This file centralizes the PostgreSQL database connection configuration,
// loading sensitive credentials from environment variables.

import dotenv from 'dotenv';
dotenv.config(); // Load environment variables from .env file

// Export the database connection configuration object.
// This object is directly used by the 'pg' Pool constructor.
export default {
    user: process.env.PGUSER,       // PostgreSQL user (e.g., 'postgres')
    host: process.env.PGHOST,       // Database host (e.g., 'localhost' or a remote IP/hostname)
    database: process.env.PGDATABASE, // Database name (e.g., 'aklny_db')
    password: process.env.PGPASSWORD, // Database user's password
    port: process.env.PGPORT ? parseInt(process.env.PGPORT, 10) : 5432, // Database port (default 5432)
    ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false // SSL config for production
};
