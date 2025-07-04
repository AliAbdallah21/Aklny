// backend/src/utils/appError.js
// Custom error class to include HTTP status codes for consistent error handling.

class AppError extends Error {
    constructor(message, statusCode) {
        super(message);
        this.statusCode = statusCode;
        this.status = `${statusCode}`.startsWith('4') ? 'fail' : 'error';
        this.isOperational = true; // Mark as operational error (expected errors)

        Error.captureStackTrace(this, this.constructor);
    }
}

export default AppError;
