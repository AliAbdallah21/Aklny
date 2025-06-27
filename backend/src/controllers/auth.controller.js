// backend/src/controllers/auth.controller.js
// This controller handles incoming HTTP requests for authentication (register/login).

import AuthService from '../services/auth.service.js'; // Import the AuthService (note .js extension)

class AuthController {
    constructor(pool) {
        // An instance of AuthService is created, receiving the PostgreSQL pool.
        this.authService = new AuthService(pool);
    }

    // Controller method for user registration
    async register(req, res) {
            const { email, password, fullName, phoneNumber, role } = req.body; // Extract data from request body
            // Call the register method from AuthService
            const newUser = await this.authService.register({ email, password, fullName, phoneNumber, role });
            // Send a 201 Created status and the new user's information
            res.status(201).json({ message: 'User registered successfully!', user: newUser });
    }

    // Controller method for user login
    async login(req, res) {
            const { email, password } = req.body; // Extract data from request body
            // Call the login method from AuthService
            const { token, user } = await this.authService.login({ email, password });
            // Send a 200 OK status, a success message, the JWT token, and user info
            res.status(200).json({ message: 'Login successful!', token, user });
    }
}

// Export the AuthController class.
// This will be instantiated in the routes file, passing the pool.
export default AuthController;