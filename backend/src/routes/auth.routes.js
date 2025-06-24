// backend/src/routes/auth.routes.js
// This file defines the API endpoints for authentication.

import express from 'express'; // Import Express to create a router
import AuthController from '../controllers/auth.controller.js'; // Import the AuthController

// This function will create and return an Express router for authentication routes.
// It takes the PostgreSQL connection pool as an argument.
const authRoutes = (pool) => {
    const router = express.Router(); // Create a new Express router
    const authController = new AuthController(pool); // Create an instance of AuthController, passing the pool

    // Define the POST /api/auth/register route
    // When a POST request comes to /api/auth/register, it calls authController.register
    // .bind(authController) ensures that 'this' context inside register method refers to authController instance.
    router.post('/register', authController.register.bind(authController));

    // Define the POST /api/auth/login route
    // When a POST request comes to /api/auth/login, it calls authController.login
    router.post('/login', authController.login.bind(authController));

    return router; // Return the configured router
};

export default authRoutes; // Export the function that creates the router