// backend/src/models/food_item.model.js
// This class provides methods to interact with the 'food_items' table in PostgreSQL.

class FoodItem {
    // Method to create a new food item in the database
    // sellerId is passed separately as it comes from the authenticated user's token
    static async create(pool, { sellerId, name, description, price, category, cuisine, imageUrl, isAvailable, preparationTimeMinutes, ingredients, allergens }) {
        const query = `
            INSERT INTO food_items (
                seller_id, name, description, price, category, cuisine, image_url,
                is_available, preparation_time_minutes, ingredients, allergens
            )
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
            RETURNING *; -- Return all columns of the newly created food item
        `;
        const values = [
            sellerId, name, description, price, category, cuisine, imageUrl,
            isAvailable, preparationTimeMinutes, ingredients, allergens
        ];
        const result = await pool.query(query, values);
        return result.rows[0];
    }

    // Method to find a food item by its ID
    static async findById(pool, foodItemId) {
        const query = 'SELECT * FROM food_items WHERE food_item_id = $1;';
        const result = await pool.query(query, [foodItemId]);
        return result.rows[0];
    }

    // Method to find all food items by a specific seller
    static async findBySellerId(pool, sellerId) {
        const query = 'SELECT * FROM food_items WHERE seller_id = $1 ORDER BY created_at DESC;';
        const result = await pool.query(query, [sellerId]);
        return result.rows;
    }

    // Method to find all available food items (for customer browsing)
    static async findAllAvailable(pool) {
        const query = 'SELECT * FROM food_items WHERE is_available = TRUE ORDER BY created_at DESC;';
        const result = await pool.query(query, []);
        return result.rows;
    }

    // Method to update an existing food item
    static async update(pool, foodItemId, { name, description, price, category, cuisine, imageUrl, isAvailable, preparationTimeMinutes, ingredients, allergens }) {
        // Build the query dynamically to update only provided fields
        const updates = [];
        const values = [];
        let valueIndex = 1;

        if (name !== undefined) { updates.push(`name = $${valueIndex++}`); values.push(name); }
        if (description !== undefined) { updates.push(`description = $${valueIndex++}`); values.push(description); }
        if (price !== undefined) { updates.push(`price = $${valueIndex++}`); values.push(price); }
        if (category !== undefined) { updates.push(`category = $${valueIndex++}`); values.push(category); }
        if (cuisine !== undefined) { updates.push(`cuisine = $${valueIndex++}`); values.push(cuisine); }
        if (imageUrl !== undefined) { updates.push(`image_url = $${valueIndex++}`); values.push(imageUrl); }
        if (isAvailable !== undefined) { updates.push(`is_available = $${valueIndex++}`); values.push(isAvailable); }
        if (preparationTimeMinutes !== undefined) { updates.push(`preparation_time_minutes = $${valueIndex++}`); values.push(preparationTimeMinutes); }
        if (ingredients !== undefined) { updates.push(`ingredients = $${valueIndex++}`); values.push(ingredients); }
        if (allergens !== undefined) { updates.push(`allergens = $${valueIndex++}`); values.push(allergens); }

        // Add updated_at timestamp automatically
        updates.push(`updated_at = NOW()`);

        // Add foodItemId to the end of values array for the WHERE clause
        values.push(foodItemId);

        const query = `
            UPDATE food_items
            SET ${updates.join(', ')}
            WHERE food_item_id = $${valueIndex}
            RETURNING *;
        `;
        const result = await pool.query(query, values);
        return result.rows[0]; // Return the updated food item
    }

    // Method to delete a food item
    static async delete(pool, foodItemId) {
        const query = 'DELETE FROM food_items WHERE food_item_id = $1 RETURNING *;';
        const result = await pool.query(query, [foodItemId]);
        return result.rows[0]; // Return the deleted food item
    }
}

export default FoodItem;