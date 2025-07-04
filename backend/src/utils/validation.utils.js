// backend/src/utils/validation.utils.js
// Utility functions for common input validation.

import AppError from './appError.js';

/**
 * Checks if required fields are present in the request body.
 * Throws an AppError if any required field is missing.
 * @param {object} body - The request body object.
 * @param {Array<string>} requiredFields - An array of strings representing the names of required fields.
 */
export const checkRequiredFields = (body, requiredFields) => {
    for (const field of requiredFields) {
        if (!body[field]) {
            throw new AppError(`Missing required field: ${field}`, 400);
        }
    }
};

/**
 * Validates password strength (e.g., minimum length).
 * Throws an AppError if the password does not meet criteria.
 * @param {string} password - The password string to validate.
 * @param {number} minLength - The minimum required length for the password.
 */
export const validatePasswordStrength = (password, minLength = 8) => {
    if (password.length < minLength) {
        throw new AppError(`Password must be at least ${minLength} characters long.`, 400);
    }
    // Add more complex password validation here if needed (e.g., regex for special chars, numbers)
};
