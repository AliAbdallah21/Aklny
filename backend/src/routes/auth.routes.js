// backend/src/routes/auth.routes.js
import express from 'express';
import AuthController from '../controllers/auth.controller.js';
import { asyncHandler } from '../utils/errors.utils.js';

// This function now needs jwtSecret to initialize AuthController
const authRoutes = (pool, jwtSecret) => { // <-- ACCEPT jwtSecret
    const router = express.Router();
    const authController = new AuthController(pool, jwtSecret); // <-- PASS jwtSecret
    router.post('/register', asyncHandler(authController.register.bind(authController)));
    router.post('/login', asyncHandler(authController.login.bind(authController)));
    return router;
};
export default authRoutes;