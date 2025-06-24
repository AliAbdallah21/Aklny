// backend/src/routes/food.routes.js
// This file defines the API endpoints for managing food items.

import express from 'express';
import FoodController from '../controllers/food.controller.js';
import authenticateToken from '../middleware/auth.middleware.js';
import authorizeRoles from '../middleware/authorize.middleware.js';

const foodRoutes = (pool) => {
    const router = express.Router();
    const foodController = new FoodController(pool);

    // --- Public/Customer-facing routes ---
    // Get all available food items (no authentication required)
    router.get('/', foodController.getAllAvailableFoodItems.bind(foodController));

    // --- Seller-specific routes (require authentication and 'seller' role) ---
    // IMPORTANT: Define specific routes like '/seller' BEFORE generic routes like '/:id'
    router.post('/seller', authenticateToken, authorizeRoles(['seller']), foodController.createFoodItem.bind(foodController));
    router.get('/seller', authenticateToken, authorizeRoles(['seller']), foodController.getSellerFoodItems.bind(foodController)); // <-- MOVED UP
    router.put('/seller/:id', authenticateToken, authorizeRoles(['seller']), foodController.updateSellerFoodItem.bind(foodController));
    router.delete('/seller/:id', authenticateToken, authorizeRoles(['seller']), foodController.deleteSellerFoodItem.bind(foodController));

    // Get a single food item by ID (publicly accessible)
    // This must come AFTER any more specific routes that could be misinterpreted as an ':id'
    router.get('/:id', foodController.getFoodItemById.bind(foodController)); // <-- MOVED DOWN

    return router;
};

export default foodRoutes;