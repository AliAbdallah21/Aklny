// backend/src/server.js

// IMPORTANT: Load environment variables FIRST and globally accessible
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const envPath = path.resolve(__dirname, '../.env');

console.log(`[dotenv] Attempting to load .env from: ${envPath}`);
const dotenvResult = dotenv.config({ path: envPath });

if (dotenvResult.error) {
  console.error('[dotenv] error:', dotenvResult.error);
  process.exit(1);
} else if (dotenvResult.parsed) {
  console.log('[dotenv] loaded variables:', Object.keys(dotenvResult.parsed));
} else {
    console.log('[dotenv] result:', dotenvResult);
}

const JWT_SECRET = process.env.JWT_SECRET; // Ensure JWT_SECRET is loaded now
console.log('[dotenv] JWT_SECRET after config:', JWT_SECRET ? 'Loaded' : 'NOT LOADED');
console.log('[dotenv] MONGO_URI after config:', process.env.MONGO_URI ? 'Loaded' : 'NOT LOADED');


// Now, import app initialization function and middleware factory
import { initializeApp, pool } from './app.js';
import initializeSocketIO from './socket/index.js';
import authenticateTokenFactory from './middleware/auth.middleware.js'; // The factory


const PORT = process.env.PORT || 3000;
let httpServer;
let appInstance;

(async () => {
    try {
        // Initialize the Express app by passing the JWT_SECRET and authenticateTokenFactory
        appInstance = await initializeApp(JWT_SECRET, authenticateTokenFactory);

        // Start the Express HTTP server
        httpServer = appInstance.listen(PORT, () => {
            console.log(`Server is running on port ${PORT}`);
            console.log(`Access the backend at: http://localhost:${PORT}`);
        });

        // Initialize Socket.IO and attach it to the HTTP server
        let io;
        try {
            io = initializeSocketIO(httpServer);
        } catch (socketError) {
            console.error('Failed to initialize Socket.IO:', socketError.message);
            console.error(socketError.stack);
        }

        // Handle graceful shutdown
        process.on('SIGINT', () => {
            console.log('\nShutting down server...');
            if (io) {
                io.close(() => {
                    console.log('Socket.IO server closed.');
                    pool.end(() => {
                        console.log('PostgreSQL connection pool has been closed.');
                        process.exit(0);
                    });
                });
            } else {
                pool.end(() => {
                    console.log('PostgreSQL connection pool has been closed (Socket.IO not initialized).');
                    process.exit(0);
                });
            }
        });

    } catch (error) {
        console.error('Failed to start server:', error.message);
        console.error(error.stack);
        process.exit(1);
    }
})();