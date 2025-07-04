import bcrypt from 'bcryptjs'; // For password hashing

async function hashPassword(password) {
    const salt = await bcrypt.genSalt(10); 
    const passwordHash = await bcrypt.hash(password, salt);
    return passwordHash;
}

async function comparePassword(password, passwordHash) {
    const isMatch = await bcrypt.compare(password, passwordHash);
    return isMatch;
}

export {hashPassword, comparePassword}