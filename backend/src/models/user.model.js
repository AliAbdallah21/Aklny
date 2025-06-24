// backend/src/models/user.model.js
// This class provides methods to interact with the 'users' table for profile management.

class User {
    // Method to find a user by their ID
    static async findById(pool, userId) {
        const query = 'SELECT * FROM users WHERE user_id = $1;';
        const result = await pool.query(query, [userId]);
        return result.rows[0]; // Return the first user found (should be unique by ID)
    }

    // Method to update a user's profile information
    // This method is generic and handles updates for all user roles.
    // It dynamically builds the UPDATE query based on provided fields.
    static async updateProfile(pool, userId, updates) {
        const updateFields = [];
        const values = [];
        let paramIndex = 1;

        // Iterate over the provided updates object
        for (const key in updates) {
            if (updates.hasOwnProperty(key)) {
                // Convert camelCase keys to snake_case for PostgreSQL columns
                const dbColumn = key.replace(/([A-Z])/g, '_$1').toLowerCase();

                // Skip user_id, created_at, updated_at if they are accidentally passed
                if (dbColumn === 'user_id' || dbColumn === 'created_at' || dbColumn === 'updated_at' || dbColumn === 'role' || dbColumn === 'email') {
                    continue; // Do not allow direct update of these core fields via profile update
                }

                updateFields.push(`${dbColumn} = $${paramIndex++}`);
                values.push(updates[key]);
            }
        }

        // If no fields are provided to update, return null
        if (updateFields.length === 0) {
            return null;
        }

        // Add updated_at timestamp automatically
        updateFields.push(`updated_at = NOW()`);
        values.push(userId); // Add userId for the WHERE clause

        const query = `
            UPDATE users
            SET ${updateFields.join(', ')}
            WHERE user_id = $${paramIndex}
            RETURNING *; -- Return the updated user object
        `;

        try {
            const result = await pool.query(query, values);
            return result.rows[0];
        } catch (error) {
            console.error('Error updating user profile:', error.message);
            throw error; // Re-throw the error for the service to handle
        }
    }

    // Method to update a user's password (separate from profile update for security)
    // Note: Password hashing should happen in the service layer, not here.
    static async updatePassword(pool, userId, hashedPassword) {
        const query = `
            UPDATE users
            SET password_hash = $1, updated_at = NOW()
            WHERE user_id = $2
            RETURNING user_id, email; -- Return non-sensitive info
        `;
        const result = await pool.query(query, [hashedPassword, userId]);
        return result.rows[0];
    }

    // Method to fetch a user by email (useful for password reset or unique checks)
    static async findByEmail(pool, email) {
        const query = 'SELECT * FROM users WHERE email = $1;';
        const result = await pool.query(query, [email]);
        return result.rows[0];
    }
}

export default User;