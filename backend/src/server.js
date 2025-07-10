// backend/src/server.js
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';

// --- ADD THIS UNIQUE LOG HERE ---
console.log('### AKLNY BACKEND STARTING UP! ###');
// --- END UNIQUE LOG ---

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const envPath = path.resolve(__dirname, '../.env');


const dotenvResult = dotenv.config({ path: envPath });

const JWT_SECRET = process.env.JWT_SECRET; // Ensure JWT_SECRET is loaded now
const REFRESH_TOKEN_SECRET = process.env.REFRESH_TOKEN_SECRET

// Now, import app initialization function and middleware factory
import { initializeApp, pool } from './app.js';
import initializeSocketIO from './socket/index.js';
import authenticateTokenFactory from './middleware/authentication.middleware.js'; // The factory


const PORT = process.env.PORT || 3000;
let httpServer;
let appInstance;

(async () => {
    try {
        // Initialize the Express app by passing the JWT_SECRET and authenticateTokenFactory
        appInstance = await initializeApp(JWT_SECRET, REFRESH_TOKEN_SECRET, authenticateTokenFactory);

        // Start the Express HTTP server
        httpServer = appInstance.listen(PORT, () => {
            console.log(`Server is running on port ${PORT}`);
            console.log(`Access the backend at: http://localhost:${PORT}`);
        });

        // (Socket.IO and graceful shutdown commented out for now, as per previous state)

    } catch (error) {
        console.error('Failed to start server:', error.message);
        console.error(error.stack);
        process.exit(1);
    }
})();
