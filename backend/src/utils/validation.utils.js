// backend/src/utils/validation.utils.js
import AppError from './appError.js';

const checkRequiredFields = (body, requiredFields) => {
    for (const field of requiredFields) {
        if (!body[field]) {
            throw new AppError(`Missing required field: ${field}`, 400);
        }
    }
};

const validatePasswordStrength = (password, minLength = 8) => {
    if (password.length < minLength) {
        throw new AppError(`Password must be at least ${minLength} characters long.`, 400);
    }
    // Add more complex password validation here if needed (e.g., regex for special chars, numbers)
};

const validateRegister = ({ email, password, fullName, phoneNumber}) => {
    if (!email || !password || !fullName || !phoneNumber) {
        return true;
    }
    return false;
};
export { validateRegister, checkRequiredFields, validatePasswordStrength };
