// backend/src/models/user.model.js
// This file defines the User model, handling database operations for user accounts,
// now including email verification, password reset, and Google ID fields.

class User {
    // Constructor to map database row data to a User object.
    // Ensure all relevant fields from the 'users' table are mapped here.
    constructor(data) {
        this.user_id = data.user_id;
        this.email = data.email;
        this.password_hash = data.password_hash; // Keep sensitive info here, but don't expose outside backend
        this.full_name = data.full_name;
        this.phone_number = data.phone_number;
        this.role = data.role;
        this.created_at = data.created_at;
        this.updated_at = data.updated_at;

        // Email Verification Fields
        this.is_verified = data.is_verified;
        this.email_verification_token = data.email_verification_token;
        this.email_verification_token_expires_at = data.email_verification_token_expires_at;

        // Password Reset Fields
        this.password_reset_token = data.password_reset_token;
        this.password_reset_token_expires_at = data.password_reset_token_expires_at;

        // NEW: Google ID Field
        this.google_id = data.google_id;
        this.profile_picture_url = data.profile_picture_url; // NEW: Add profile_picture_url here

        // Seller-specific fields
        this.restaurant_name = data.restaurant_name;
        this.restaurant_description = data.restaurant_description;
        this.address_street = data.address_street;
        this.address_city = data.address_city;
        this.address_country = data.address_country;
        this.bank_account_number = data.bank_account_number;
        this.bank_name = data.bank_name;
        this.is_approved = data.is_approved;
        // this.profile_picture_url = data.profile_picture_url; // This was here, moved to common Google fields above
        this.average_rating = data.average_rating;
        this.total_reviews = data.total_reviews;
        this.total_orders_completed = data.total_orders_completed;

        // Delivery Driver specific fields
        this.driver_license_number = data.driver_license_number;
        this.vehicle_type = data.vehicle_type;
        this.vehicle_plate_number = data.vehicle_plate_number;
        this.is_available_for_delivery = data.is_available_for_delivery;
    }

    // --- Static Methods for Database Operations ---

    /**
     * Creates a new user record in the database.
     * @param {object} pool - The PostgreSQL connection pool.
     * @param {object} userData - Object containing user details:
     * email, passwordHash, fullName, phoneNumber, role,
     * isVerified, emailVerificationToken, emailVerificationTokenExpiresAt,
     * googleId (NEW), profilePictureUrl (NEW).
     * @returns {Promise<User>} A new User instance from the created record.
     */
    static async create(pool, {
        email,
        passwordHash, // Can be null for social logins initially
        fullName,
        phoneNumber,
        role,
        isVerified,
        emailVerificationToken,
        emailVerificationTokenExpiresAt,
        googleId, // NEW: Add googleId here
        profilePictureUrl // NEW: Add profilePictureUrl here
    }) {
        const query = `
            INSERT INTO users (
                email,
                password_hash,
                full_name,
                phone_number,
                role,
                is_verified,
                email_verification_token,
                email_verification_token_expires_at,
                google_id, -- NEW COLUMN
                profile_picture_url -- NEW COLUMN
            )
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
            RETURNING *;
        `;
        const values = [
            email,
            passwordHash,
            fullName,
            phoneNumber,
            role,
            isVerified,
            emailVerificationToken,
            emailVerificationTokenExpiresAt,
            googleId, // NEW VALUE
            profilePictureUrl // NEW VALUE
        ];
        try {
            const result = await pool.query(query, values);
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
     * NEW: Finds a user by their Google ID.
     * @param {object} pool - The PostgreSQL connection pool.
     * @param {string} googleId - The user's Google ID.
     * @returns {Promise<User|null>} A User instance if found, otherwise null.
     */
    static async findByGoogleId(pool, googleId) {
        const query = 'SELECT * FROM users WHERE google_id = $1;';
        try {
            const result = await pool.query(query, [googleId]);
            return result.rows.length > 0 ? new User(result.rows[0]) : null;
        } catch (error) {
            console.error('Error finding user by Google ID:', error.message);
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
            isApproved: 'is_approved',
            isAvailableForDelivery: 'is_available_for_delivery',
            driverLicenseNumber: 'driver_license_number',
            vehicleType: 'vehicle_type',
            vehiclePlateNumber: 'vehicle_plate_number',
            isVerified: 'is_verified',
            emailVerificationToken: 'email_verification_token',
            emailVerificationTokenExpiresAt: 'email_verification_token_expires_at',
            passwordResetToken: 'password_reset_token',
            passwordResetTokenExpiresAt: 'password_reset_token_expires_at',
            googleId: 'google_id' // Already here
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
     * Finds a user by their email verification token.
     * This is used when the user clicks the verification link.
     * @param {object} pool - The PostgreSQL connection pool.
     * @param {string} token - The email verification token.
     * @returns {Promise<User|null>} The user object if found and token is valid/not expired, otherwise null.
     */
    static async findByEmailVerificationToken(pool, token) {
        const query = `
            SELECT * FROM users
            WHERE email_verification_token = $1 AND email_verification_token_expires_at > NOW();
        `;
        try {
            const result = await pool.query(query, [token]);
            return result.rows.length > 0 ? new User(result.rows[0]) : null;
        } catch (error) {
            console.error('Error finding user by email verification token:', error.message);
            throw error;
        }
    }

    /**
     * Finds a user by their password reset token.
     * @param {object} pool - The PostgreSQL connection pool.
     * @param {string} token - The password reset token.
     * @returns {Promise<User|null>} The user object if found and token is valid/not expired, otherwise null.
     */
    static async findByPasswordResetToken(pool, token) {
        const query = `
            SELECT * FROM users
            WHERE password_reset_token = $1 AND password_reset_token_expires_at > NOW();
        `;
        try {
            const result = await pool.query(query, [token]);
            return result.rows.length > 0 ? new User(result.rows[0]) : null;
        } catch (error) {
            console.error('Error finding user by password reset token:', error.message);
            throw error;
        }
    }

    /**
     * Updates a user's password reset token and its expiry.
     * @param {object} pool - The PostgreSQL connection pool.
     * @param {number} userId - The ID of the user to update.
     * @param {string} token - The new password reset token.
     * @param {Date} expiresAt - The expiration timestamp for the token.
     * @returns {Promise<User>} The updated user object.
     */
    static async updatePasswordResetToken(pool, userId, token, expiresAt) {
        const query = `
            UPDATE users
            SET password_reset_token = $1, password_reset_token_expires_at = $2, updated_at = NOW()
            WHERE user_id = $3
            RETURNING *;
        `;
        try {
            const result = await pool.query(query, [token, expiresAt, userId]);
            if (result.rows.length === 0) {
                throw new Error('User not found or not updated with reset token.');
            }
            return new User(result.rows[0]);
        } catch (error) {
            console.error('Error updating password reset token:', error.message);
            throw error;
        }
    }

    /**
     * Marks a user's email as verified and clears the token fields.
     * @param {object} pool - The PostgreSQL connection pool.
     * @param {number} userId - The ID of the user to verify.
     * @returns {Promise<User>} The updated user object.
     */
    static async markEmailAsVerified(pool, userId) {
        const query = `
            UPDATE users
            SET is_verified = TRUE, email_verification_token = NULL, email_verification_token_expires_at = NULL, updated_at = NOW()
            WHERE user_id = $1
            RETURNING *;
        `;
        try {
            const result = await pool.query(query, [userId]);
            if (result.rows.length === 0) {
                throw new Error('User not found or not updated for email verification.');
            }
            return new User(result.rows[0]);
        } catch (error) {
            console.error('Error marking email as verified:', error.message);
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
