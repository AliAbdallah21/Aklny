// backend/src/controllers/food.controller.js
// This controller handles HTTP requests related to food items.

import FoodService from '../services/food.service.js'; // Import the FoodService

class FoodController {
    constructor(pool) {
        this.foodService = new FoodService(pool); // Initialize FoodService with the DB pool
    }

    // --- Seller-specific controller methods ---

    // Controller method for a seller to create a new food item
    // This will be used with a POST request to a route like /api/seller/food
    async createFoodItem(req, res) {
        try {
            // The sellerId comes from the authenticated user's JWT (attached by authenticateToken middleware)
            const sellerId = req.user.userId;
            const foodItemData = req.body; // Food item details from the request body

            const newFoodItem = await this.foodService.createFoodItem(sellerId, foodItemData);
            res.status(201).json({ message: 'Food item created successfully!', foodItem: newFoodItem });
        } catch (error) {
            res.status(400).json({ message: error.message });
        }
    }

    // Controller method for a seller to get all their food items
    // This will be used with a GET request to a route like /api/seller/food
    async getSellerFoodItems(req, res) {
        try {
            const sellerId = req.user.userId; // Get sellerId from authenticated user
            const foodItems = await this.foodService.getSellerFoodItems(sellerId);
            res.status(200).json(foodItems);
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    }

    // Controller method for a seller to update one of their food items
    // This will be used with a PUT request to a route like /api/seller/food/:id
    async updateSellerFoodItem(req, res) {
        try {
            const sellerId = req.user.userId; // Get sellerId from authenticated user
            const foodItemId = parseInt(req.params.id); // Get food item ID from URL parameters
            const updateData = req.body; // Update data from the request body

            const updatedFoodItem = await this.foodService.updateSellerFoodItem(sellerId, foodItemId, updateData);
            if (!updatedFoodItem) {
                return res.status(404).json({ message: 'Food item not found or unauthorized.' });
            }
            res.status(200).json({ message: 'Food item updated successfully!', foodItem: updatedFoodItem });
        } catch (error) {
            res.status(400).json({ message: error.message }); // 400 for validation errors, 403 for unauthorized
        }
    }

    // Controller method for a seller to delete one of their food items
    // This will be used with a DELETE request to a route like /api/seller/food/:id
    async deleteSellerFoodItem(req, res) {
        try {
            const sellerId = req.user.userId; // Get sellerId from authenticated user
            const foodItemId = parseInt(req.params.id); // Get food item ID from URL parameters

            const deletedFoodItem = await this.foodService.deleteSellerFoodItem(sellerId, foodItemId);
            if (!deletedFoodItem) {
                return res.status(404).json({ message: 'Food item not found or unauthorized.' });
            }
            res.status(200).json({ message: 'Food item deleted successfully!', foodItem: deletedFoodItem });
        } catch (error) {
            res.status(400).json({ message: error.message });
        }
    }

    // --- Public/Customer-facing controller methods ---

    // Controller method for customers to get a single food item by ID
    // This will be used with a GET request to a route like /api/food/:id
    async getFoodItemById(req, res) {
        try {
            const foodItemId = parseInt(req.params.id); // Get food item ID from URL parameters
            const foodItem = await this.foodService.getFoodItemById(foodItemId);
            if (!foodItem) {
                return res.status(404).json({ message: 'Food item not found or not available.' });
            }
            res.status(200).json(foodItem);
        } catch (error) {
            res.status(404).json({ message: error.message }); // Use 404 if not found/available
        }
    }

    // Controller method for customers to get all available food items
    // This will be used with a GET request to a route like /api/food
    async getAllAvailableFoodItems(req, res) {
        try {
            const foodItems = await this.foodService.getAllAvailableFoodItems();
            res.status(200).json(foodItems);
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    }
}

export default FoodController;