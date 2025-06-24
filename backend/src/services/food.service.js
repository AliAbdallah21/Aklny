// backend/src/services/food.service.js
// This service handles the business logic for food items.

import FoodItem from '../models/food_item.model.js'; // Import the FoodItem model

class FoodService {
    constructor(pool) {
        this.pool = pool; // The PostgreSQL connection pool
    }

    // --- Seller-specific operations ---

    // Create a new food item (only by a seller)
    async createFoodItem(sellerId, foodItemData) {
        // Ensure sellerId is explicitly set from the authenticated user's token
        if (!sellerId) {
            throw new Error('Seller ID is required to create a food item.');
        }
        // Add sellerId to the foodItemData for the model
        foodItemData.sellerId = sellerId;

        // Basic validation (can be expanded)
        if (!foodItemData.name || !foodItemData.price || !foodItemData.category) {
            throw new Error('Name, price, and category are required for a food item.');
        }

        // Create the food item using the model
        const newFoodItem = await FoodItem.create(this.pool, foodItemData);
        return newFoodItem;
    }

    // Get all food items belonging to a specific seller
    async getSellerFoodItems(sellerId) {
        const foodItems = await FoodItem.findBySellerId(this.pool, sellerId);
        return foodItems;
    }

    // Update a specific food item owned by a seller
    async updateSellerFoodItem(sellerId, foodItemId, updateData) {
        // First, verify that the food item exists and belongs to this seller
        const existingFoodItem = await FoodItem.findById(this.pool, foodItemId);
        if (!existingFoodItem) {
            throw new Error('Food item not found.');
        }
        if (existingFoodItem.seller_id !== sellerId) {
            throw new Error('Unauthorized: You do not own this food item.');
        }

        // Update the food item using the model
        const updatedFoodItem = await FoodItem.update(this.pool, foodItemId, updateData);
        return updatedFoodItem;
    }

    // Delete a specific food item owned by a seller
    async deleteSellerFoodItem(sellerId, foodItemId) {
        // First, verify that the food item exists and belongs to this seller
        const existingFoodItem = await FoodItem.findById(this.pool, foodItemId);
        if (!existingFoodItem) {
            throw new Error('Food item not found.');
        }
        if (existingFoodItem.seller_id !== sellerId) {
            throw new Error('Unauthorized: You do not own this food item.');
        }

        // Delete the food item using the model
        const deletedFoodItem = await FoodItem.delete(this.pool, foodItemId);
        return deletedFoodItem;
    }

    // --- Public/Customer operations ---

    // Get a single food item by ID (publicly accessible)
    async getFoodItemById(foodItemId) {
        const foodItem = await FoodItem.findById(this.pool, foodItemId);
        if (!foodItem || !foodItem.is_available) { // Only return if available for customers
            throw new Error('Food item not found or not available.');
        }
        return foodItem;
    }

    // Get all available food items (for public browsing)
    async getAllAvailableFoodItems() {
        const foodItems = await FoodItem.findAllAvailable(this.pool);
        return foodItems;
    }
}

export default FoodService;