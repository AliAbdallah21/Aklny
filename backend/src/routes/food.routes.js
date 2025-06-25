// backend/src/routes/food.routes.js
// This file defines the API endpoints for food items.

import express from 'express';
import FoodController from '../controllers/food.controller.js';

// This function now needs authenticateToken and authorizeRoles
const foodRoutes = (pool, authenticateToken, authorizeRoles) => { // ACCEPT middlewares
    const router = express.Router();
    const foodController = new FoodController(pool);

    // --- Public/Customer-facing routes ---
    // Route to get all available food items
    router.get('/', foodController.getAllAvailableFoodItems.bind(foodController)); // <-- CORRECTED NAME
    // Route to get a single food item by ID
    router.get('/:id', foodController.getFoodItemById.bind(foodController));

    // --- Protected routes for sellers (managing their own food items) ---
    // Route to create a new food item (seller only)
    router.post('/seller', authenticateToken, authorizeRoles(['seller']), foodController.createFoodItem.bind(foodController)); // <-- NEW PATH FOR SELLER ACTIONS
    // Route to get all food items owned by the authenticated seller
    router.get('/seller/me', authenticateToken, authorizeRoles(['seller']), foodController.getSellerFoodItems.bind(foodController)); // <-- NEW PATH FOR SELLER ACTIONS
    // Route to update one of the seller's food items
    router.put('/seller/:id', authenticateToken, authorizeRoles(['seller']), foodController.updateSellerFoodItem.bind(foodController)); // <-- CORRECTED NAME
    // Route to delete one of the seller's food items
    router.delete('/seller/:id', authenticateToken, authorizeRoles(['seller']), foodController.deleteSellerFoodItem.bind(foodController)); // <-- CORRECTED NAME

    return router;
};

export default foodRoutes;