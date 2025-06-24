// backend/src/models/chat_message.model.js
// This file defines the Mongoose schema and model for chat messages.

import mongoose from 'mongoose'; // Import Mongoose

// Define the schema for a chat message document
const chatMessageSchema = new mongoose.Schema({
    // Identifier for the conversation/room
    // This will likely be a combination of participant IDs (e.g., 'userX_userY')
    // or an orderId for order-specific chats. For simplicity, we'll start with a generic room name.
    room: {
        type: String,
        required: true,
        index: true // Index for faster lookups based on room
    },
    senderId: {
        type: Number, // The user_id of the sender from PostgreSQL
        required: true
    },
    recipientId: {
        type: Number, // The user_id of the recipient
        required: false // Can be null for group chats, or if system messages
    },
    message: {
        type: String,
        required: true,
        maxlength: 1000 // Limit message length
    },
    // Indicates if the message has been read by the recipient
    isRead: {
        type: Boolean,
        default: false
    },
    // Type of message (e.g., 'text', 'image', 'system')
    messageType: {
        type: String,
        enum: ['text', 'image', 'system'],
        default: 'text'
    }
}, {
    timestamps: true // Mongoose automatically adds createdAt and updatedAt fields
});

// Create a compound index for efficient querying of messages within a room, ordered by time
chatMessageSchema.index({ room: 1, createdAt: 1 });

// Create the Mongoose model from the schema
const ChatMessage = mongoose.model('ChatMessage', chatMessageSchema);

export default ChatMessage; // Export the model