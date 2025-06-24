// backend/src/models/delivery_tracking.model.js
// This file defines the Mongoose schema and model for real-time delivery tracking.

import mongoose from 'mongoose'; // Import Mongoose

// Define the schema for a delivery tracking document
// This schema outlines the structure and data types of documents
// that will be stored in the 'delivery_tracking' collection in MongoDB.
const deliveryTrackingSchema = new mongoose.Schema({
    orderId: {
        type: Number, // Corresponds to order_id in PostgreSQL
        required: true,
        unique: true, // Each order should have only one real-time tracking document
        index: true // Index for faster lookups
    },
    driverId: {
        type: Number, // Corresponds to user_id in PostgreSQL (role: delivery_driver)
        required: true,
        index: true // Index for faster lookups
    },
    // Current location of the driver
    location: {
        latitude: { type: Number, required: true },
        longitude: { type: Number, required: true }
    },
    // Timestamp of the last location update
    timestamp: {
        type: Date,
        default: Date.now // Default to current time when a new document is created or updated
    },
    // Optional: Status specific to real-time tracking (e.g., 'en_route', 'arrived_pickup', 'near_customer')
    // This might overlap with PostgreSQL order status but can be more granular for real-time updates.
    trackingStatus: {
        type: String,
        enum: ['pending_pickup', 'picked_up', 'en_route', 'arrived_customer_location', 'delivered'],
        default: 'pending_pickup'
    }
}, {
    timestamps: true // Mongoose automatically adds createdAt and updatedAt fields
});

// Create the Mongoose model from the schema
// The first argument 'DeliveryTracking' is the singular name of the collection.
// Mongoose will automatically pluralize it to 'deliverytrackings' in MongoDB,
// but you can force a specific name with a third argument:
// mongoose.model('DeliveryTracking', deliveryTrackingSchema, 'delivery_tracking_collection');
// For simplicity, Mongoose's pluralization is usually fine.
const DeliveryTracking = mongoose.model('DeliveryTracking', deliveryTrackingSchema);

export default DeliveryTracking; // Export the model for use in services