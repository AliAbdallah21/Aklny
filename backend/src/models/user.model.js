// backend/src/models/user.model.js
// This file defines the User model, handling database operations for user accounts.

// Note: The constructor below is illustrative if you were creating User instances
// to hold fetched data. For direct static database operations, it's not strictly
// necessary unless you convert query results into User objects.

class User {
    // A constructor can be useful if you plan to instantiate User objects from DB rows.
    // For now, we'll primarily use static methods for direct DB interaction.
    constructor(data) {
        this.user_id = data.user_id;
        this.email = data.email;
        this.password_hash = data.password_hash; // Keep sensitive info here, but don't expose outside backend
        this.full_name = data.full_name;
        this.phone_number = data.phone_number;
        this.role = data.role;
        this.created_at = data.created_at;
        this.updated_at = data.updated_at;
        this.restaurant_name = data.restaurant_name;
        this.restaurant_description = data.restaurant_description;
        this.address_street = data.address_street;
        this.address_city = data.address_city;
        this.address_country = data.address_country;
        this.bank_account_number = data.bank_account_number;
        this.bank_name = data.bank_name;
        this.is_approved = data.is_approved;
        this.profile_picture_url = data.profile_picture_url;
        this.average_rating = data.average_rating;
        this.total_reviews = data.total_reviews;
        this.total_orders_completed = data.total_orders_completed;
        this.driver_license_number = data.driver_license_number;
        this.vehicle_type = data.vehicle_type;
        this.vehicle_plate_number = data.vehicle_plate_number;
        this.is_available_for_delivery = data.is_available_for_delivery;
    }

    // --- Static Methods for Database Operations ---

    /**
     * Creates a new user record in the database.
     * @param {object} pool - The PostgreSQL connection pool.
     * @param {object} userData - Object containing user details: email, passwordHash, fullName, phoneNumber, role.
     * @returns {Promise<User>} A new User instance from the created record.
     */
    static async create(pool, { email, passwordHash, fullName, phoneNumber, role }) {
        const query = `
            INSERT INTO users (email, password_hash, full_name, phone_number, role)
            VALUES ($1, $2, $3, $4, $5)
            RETURNING *;
        `;
        const values = [email, passwordHash, fullName, phoneNumber, role];
        try {
            const result = await pool.query(query, values);
            // Return a new User instance, filtering out sensitive data if this were sent directly to frontend
            return new User(result.rows[0]);
        } catch (error) {
            console.error('Error creating user:', error.message);
            throw error; // Re-throw to be caught by service layer
        }
    }

    /**
     * Finds a user by their email address.
     * @param {object} pool - The PostgreSQL connection pool.
     * @param {string} email - The user's email address.
     * @returns {Promise<User|null>} A User instance if found, otherwise null.
     */
    static async findByEmail(pool, email) {
        const query = 'SELECT * FROM users WHERE email = $1;';
        try {
            const result = await pool.query(query, [email]);
            return result.rows.length > 0 ? new User(result.rows[0]) : null;
        } catch (error) {
            console.error('Error finding user by email:', error.message);
            throw error;
        }
    }

    /**
     * Finds a user by their user ID.
     * @param {object} pool - The PostgreSQL connection pool.
     * @param {number} userId - The ID of the user.
     * @returns {Promise<User|null>} A User instance if found, otherwise null.
     */
    static async findById(pool, userId) {
        const query = 'SELECT * FROM users WHERE user_id = $1;';
        try {
            const result = await pool.query(query, [userId]);
            return result.rows.length > 0 ? new User(result.rows[0]) : null;
        } catch (error) {
            console.error('Error finding user by ID:', error.message);
            throw error;
        }
    }

    /**
     * Updates a user's profile information.
     * @param {object} pool - The PostgreSQL connection pool.
     * @param {number} userId - The ID of the user to update.
     * @param {object} updates - Object with fields to update (camelCase, will be converted to snake_case).
     * @returns {Promise<User|null>} The updated User instance, or null if no fields updated/user not found.
     */
    static async updateProfile(pool, userId, updates) {
        const updateFields = [];
        const values = [];
        let paramIndex = 1;

        // Mapping from camelCase in updates object to snake_case in DB columns
        const fieldMap = {
            fullName: 'full_name',
            phoneNumber: 'phone_number',
            restaurantName: 'restaurant_name',
            restaurantDescription: 'restaurant_description',
            addressStreet: 'address_street',
            addressCity: 'address_city',
            addressCountry: 'address_country',
            bankAccountNumber: 'bank_account_number',
            bankName: 'bank_name',
            profilePictureUrl: 'profile_picture_url',
            isApproved: 'is_approved', // Admin-only updates usually, but included for completeness
            isAvailableForDelivery: 'is_available_for_delivery',
            driverLicenseNumber: 'driver_license_number',
            vehicleType: 'vehicle_type',
            vehiclePlateNumber: 'vehicle_plate_number',
            // passwordHash is handled by updatePassword, email/role usually not directly updatable
        };

        for (const key in updates) {
            if (updates.hasOwnProperty(key) && fieldMap[key]) {
                updateFields.push(`${fieldMap[key]} = $${paramIndex++}`);
                values.push(updates[key]);
            }
        }

        if (updateFields.length === 0) {
            return null; // No valid fields to update
        }

        // Always update updated_at timestamp
        updateFields.push(`updated_at = NOW()`);
        values.push(userId); // Last value is for the WHERE clause

        const query = `
            UPDATE users
            SET ${updateFields.join(', ')}
            WHERE user_id = $${paramIndex}
            RETURNING *;
        `;

        try {
            const result = await pool.query(query, values);
            return result.rows.length > 0 ? new User(result.rows[0]) : null;
        } catch (error) {
            console.error('Error updating user profile:', error.message);
            throw error;
        }
    }

    /**
     * Updates a user's password hash in the database.
     * @param {object} pool - The PostgreSQL connection pool.
     * @param {number} userId - The ID of the user whose password to update.
     * @param {string} hashedPassword - The new hashed password.
     * @returns {Promise<boolean>} True if the password was updated, false otherwise.
     */
    static async updatePassword(pool, userId, hashedPassword) {
        const query = `
            UPDATE users
            SET password_hash = $1, updated_at = NOW()
            WHERE user_id = $2
            RETURNING user_id;
        `;
        try {
            const result = await pool.query(query, [hashedPassword, userId]);
            return result.rows.length > 0; // Returns true if a row was updated
        } catch (error) {
            console.error('Error updating password:', error.message);
            throw error;
        }
    }

    /**
     * Deletes a user record from the database.
     * @param {object} pool - The PostgreSQL connection pool.
     * @param {number} userId - The ID of the user to delete.
     * @returns {Promise<boolean>} True if the user was deleted, false otherwise.
     */
    static async delete(pool, userId) {
        const query = 'DELETE FROM users WHERE user_id = $1 RETURNING user_id;';
        try {
            const result = await pool.query(query, [userId]);
            return result.rows.length > 0;
        } catch (error) {
            console.error('Error deleting user:', error.message);
            throw error;
        }
    }
}

export default User;