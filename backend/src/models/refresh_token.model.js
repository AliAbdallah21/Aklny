// backend/src/models/refresh_token.model.js
// This model handles all direct database interactions for the 'refresh_tokens' table.

class RefreshToken {
    /**
     * Creates a new refresh token record in the database.
     * @param {object} pool - The PostgreSQL connection pool.
     * @param {string} tokenId - The unique ID of the refresh token (UUID).
     * @param {number} userId - The ID of the user this token belongs to.
     * @param {Date} expiresAt - The expiration timestamp for the token.
     * @returns {Promise<object>} The created refresh token record.
     */
    static async create(pool, tokenId, userId, expiresAt) {
        try {
            const result = await pool.query(
                `INSERT INTO refresh_tokens (token_id, user_id, expires_at)
                 VALUES ($1, $2, $3) RETURNING token_id, user_id, expires_at, is_revoked, created_at`,
                [tokenId, userId, expiresAt]
            );
            return result.rows[0];
        } catch (error) {
            console.error("Error creating refresh token:", error);
            throw error; // Re-throw to be caught by service layer
        }
    }

    /**
     * Finds a refresh token record by its unique ID.
     * @param {object} pool - The PostgreSQL connection pool.
     * @param {string} tokenId - The unique ID of the refresh token.
     * @returns {Promise<object|undefined>} The refresh token record if found, otherwise undefined.
     */
    static async findById(pool, tokenId) {
        try {
            const result = await pool.query(
                `SELECT token_id, user_id, expires_at, is_revoked, created_at
                 FROM refresh_tokens WHERE token_id = $1`,
                [tokenId]
            );
            return result.rows[0];
        } catch (error) {
            console.error(`Error finding refresh token by ID (${tokenId}):`, error);
            throw error;
        }
    }

    /**
     * Marks a specific refresh token as revoked.
     * @param {object} pool - The PostgreSQL connection pool.
     * @param {string} tokenId - The unique ID of the refresh token to revoke.
     * @returns {Promise<void>}
     */
    static async revoke(pool, tokenId) {
        try {
            // --- DEBUG LOGS START ---
            console.log('RefreshToken.revoke: Attempting to update token_id:', tokenId);
            // --- DEBUG LOGS END ---

            const result = await pool.query(
                `UPDATE refresh_tokens SET is_revoked = TRUE WHERE token_id = $1`,
                [tokenId]
            );

            // --- DEBUG LOGS START ---
            console.log(`RefreshToken.revoke: UPDATE query executed. Rows affected: ${result.rowCount}`);
            if (result.rowCount === 0) {
                console.warn(`RefreshToken.revoke: No refresh token found with ID ${tokenId} to revoke.`);
            }
            // --- DEBUG LOGS END ---

        } catch (error) {
            console.error(`Error revoking refresh token by ID (${tokenId}) in model:`, error);
            throw error;
        }
    }

    /**
     * Marks all refresh tokens for a specific user as revoked.
     * This is useful for "log out all devices" or after a password change.
     * @param {object} pool - The PostgreSQL connection pool.
     * @param {number} userId - The ID of the user whose tokens should be revoked.
     * @returns {Promise<void>}
     */
    static async revokeAllByUserId(pool, userId) {
        try {
            // --- DEBUG LOGS START ---
            console.log('RefreshToken.revokeAllByUserId: Attempting to revoke all tokens for user_id:', userId);
            // --- DEBUG LOGS END ---

            const result = await pool.query(
                `UPDATE refresh_tokens SET is_revoked = TRUE WHERE user_id = $1`,
                [userId]
            );
            // --- DEBUG LOGS START ---
            console.log(`RefreshToken.revokeAllByUserId: UPDATE query executed. Rows affected: ${result.rowCount}`);
            // --- DEBUG LOGS END ---
        } catch (error) {
            console.error(`Error revoking all refresh tokens for user (${userId}):`, error);
            throw error;
        }
    }
}

export default RefreshToken;
