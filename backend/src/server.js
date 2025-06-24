// backend/src/server.js

// Import the Express app and the PostgreSQL pool from app.js
import { app, pool } from './app.js';
import initializeSocketIO from './socket/index.js'; // <-- IMPORTANT: ADD THIS LINE

const PORT = process.env.PORT || 3000;

// Start the Express HTTP server
const httpServer = app.listen(PORT, () => { // <-- CHANGED from app.listen to httpServer = app.listen
  console.log(`Server is running on port ${PORT}`);
  console.log(`Access the backend at: http://localhost:${PORT}`);
});

// Initialize Socket.IO and attach it to the HTTP server
const io = initializeSocketIO(httpServer); // <-- IMPORTANT: ADD THIS LINE

// Handle graceful shutdown: Close the database connection pool and Socket.IO server
process.on('SIGINT', () => {
  console.log('\nShutting down server...');
  // Close Socket.IO connections
  io.close(() => {
    console.log('Socket.IO server closed.');
    // Close PostgreSQL connection pool
    pool.end(() => {
      console.log('PostgreSQL connection pool has been closed.');
      process.exit(0); // Exit the process cleanly
    });
  });
});

// Export the server instance (optional, for testing)
export default httpServer; // <-- CHANGED to export httpServer