// backend/src/routes/user.routes.js
import express from 'express';
import UserController from '../controllers/user.controller.js';
// Removed direct imports of auth middleware. It is now passed as an argument.
// import authenticateToken from '../middleware/auth.middleware.js';

// This function now needs authenticateToken
const userRoutes = (pool, authenticateToken) => { // <-- ACCEPT authenticateToken
    const router = express.Router();
    const userController = new UserController(pool);

    // Route to get the authenticated user's own profile
    router.get('/me', authenticateToken, userController.getMyProfile.bind(userController));

    // Route to update the authenticated user's own profile
    router.put('/me', authenticateToken, userController.updateMyProfile.bind(userController));

    // Route to change the authenticated user's own password
    router.put('/me/password', authenticateToken, userController.changeMyPassword.bind(userController));

    return router;
};

export default userRoutes;