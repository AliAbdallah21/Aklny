const validateRegister = ({ email, password, fullName, phoneNumber, role }) => {
    if (!email || !password || !fullName || !phoneNumber || !role) {
        return true;
    }
    return false;
};
export { validateRegister };