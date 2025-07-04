// backend/src/utils/error.utils.js
// This utility provides a centralized way to handle errors
// and send consistent JSON error responses to the client.


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

const asyncHandler = (fn) => {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
};

export {errorHandler, asyncHandler}; // Export the utility function
