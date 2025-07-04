// backend/src/utils/error.utils.js
// This utility provides a centralized way to handle errors
// and send consistent JSON error responses to the client.

/**
 * Global error handling utility for Express.
 * This function catches errors thrown by other routes/middleware and formats them
 * into a standardized JSON error response.
 *
 * @param {Error} err - The error object.
 * @param {object} req - The Express request object.
 * @param {object} res - The Express response object.
 * @param {function} next - The next middleware function in the stack.
 */
const errorHandler = (err, req, res, next) => {
    // Determine the status code. If the error has a 'statusCode' property, use it.
    // Otherwise, default to 500 (Internal Server Error).
    const statusCode = err.statusCode || 500;

    // Log the error for server-side debugging (don't expose sensitive info to client)
    console.error(`[Server Error ${statusCode}]: ${err.message}`);
    // console.error(err.stack); // Uncomment for full stack trace in development

    // Send a JSON response for all errors
    res.status(statusCode).json({
        // Provide a user-friendly message. In production, avoid sending raw error.message directly
        // if it contains sensitive details. For now, it's fine for debugging.
        message: err.message || 'An unexpected error occurred.',
        // Optionally, include the error stack only in development environment
        stack: process.env.NODE_ENV === 'production' ? null : err.stack,
    });
};

export default errorHandler; // Export the utility function
