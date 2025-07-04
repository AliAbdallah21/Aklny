// backend/src/controllers/auth.controller.js
// This controller handles incoming HTTP requests for authentication (register/login).

import AuthService from '../services/auth.service.js'; // Import the AuthService (note .js extension)

class AuthController {
    constructor(pool,jwtsecret) {
        // An instance of AuthService is created, receiving the PostgreSQL pool.
        this.authService = new AuthService(pool,jwtsecret);
    }

    // Controller method for user registration
    async register(req, res) {
            const { email, password, fullName, phoneNumber} = req.body; // Extract data from request body
            // Call the register method from AuthService
            const newUser = await this.authService.register({ email, password, fullName, phoneNumber});
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

    async logout(req, res){
        const tokenId = req.cookies.refreshToken;
         res.clearCookie('refreshToken', {
            httpOnly: true,
            secure: process.env.NODE_ENV === 'production', // Set to true in production (requires HTTPS)
            sameSite: 'Lax', // Or 'Strict' depending on your CSRF strategy
            maxAge: 7 * 24 * 60 * 60 * 1000, //max time before expiry
            path: '/' // Ensure the path matches the path the cookie was set with
        });

        if(!tokenId){
            return res.status(200).json({ message: 'Logout successful (no active session found to revoke).' });
        }

        try{
           await this.authService.logout(tokenId)
           return res.status(200).json({ message: 'Logout successful!'});
        }catch(error){
           return res.status(500).json({message: "Logout failed."})
        }
    }
}

// Export the AuthController class.
// This will be instantiated in the routes file, passing the pool.
export default AuthController;