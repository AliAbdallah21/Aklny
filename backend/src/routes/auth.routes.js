// backend/src/routes/auth.routes.js
import express from 'express';
import AuthController from '../controllers/auth.controller.js';

// This function now needs jwtSecret to initialize AuthController
const authRoutes = (pool, jwtSecret) => { // <-- ACCEPT jwtSecret
    const router = express.Router();
    const authController = new AuthController(pool, jwtSecret); // <-- PASS jwtSecret
    router.post('/register', authController.register.bind(authController));
    router.post('/login', authController.login.bind(authController));
    return router;
};
export default authRoutes;