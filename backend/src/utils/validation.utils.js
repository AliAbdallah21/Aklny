const validateRegister = ({ email, password, fullName, phoneNumber}) => {
    if (!email || !password || !fullName || !phoneNumber) {
        return true;
    }
    return false;
};
export { validateRegister };