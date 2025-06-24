// backend/src/socket/index.js
// This file sets up and manages the WebSocket (Socket.IO) server.

import { Server as SocketIOServer } from 'socket.io';
import jwt from 'jsonwebtoken';
import DeliveryTracking from '../models/delivery_tracking.model.js';
import ChatMessage from '../models/chat_message.model.js'; // <-- IMPORTANT: ADD THIS LINE
import FoodItem from '../models/food_item.model.js'; // Still here for potential future order details
import { pool } from '../app.js'; // PostgreSQL pool for order/user details

const JWT_SECRET = process.env.JWT_SECRET;

const initializeSocketIO = (httpServer) => {
    const io = new SocketIOServer(httpServer, {
        cors: {
            origin: ["http://localhost:3000", "http://localhost:4000", "http://localhost:8080", "http://127.0.0.1:5500", "http://localhost:5000", "http://localhost:8000"],
            methods: ["GET", "POST"]
        }
    });

    io.use(async (socket, next) => {
        const token = socket.handshake.auth.token;
        if (!token) {
            return next(new Error('Authentication error: Token not provided.'));
        }
        try {
            const decoded = jwt.verify(token, JWT_SECRET);
            socket.user = decoded;
            next();
        } catch (err) {
            return next(new Error('Authentication error: Invalid or expired token.'));
        }
    });

    io.on('connection', (socket) => {
        console.log(`User connected: ${socket.id} (User ID: ${socket.user.userId}, Role: ${socket.user.role})`);
        socket.join(`user_${socket.user.userId}`);

        // --- Delivery Tracking Events (Existing) ---

        socket.on('updateLocation', async (data) => {
            const { orderId, latitude, longitude } = data;
            const driverId = socket.user.userId;

            if (socket.user.role !== 'delivery_driver') {
                socket.emit('error', { message: 'Unauthorized to update location.' });
                return;
            }
            if (!orderId || !latitude || !longitude) {
                socket.emit('error', { message: 'Invalid location data.' });
                return;
            }

            try {
                let delivery = await DeliveryTracking.findOneAndUpdate(
                    { orderId: orderId, driverId: driverId },
                    { $set: { location: { latitude, longitude }, timestamp: new Date() } },
                    { upsert: true, new: true, setDefaultsOnInsert: true }
                );

                const orderQuery = 'SELECT customer_id, seller_id, status FROM orders WHERE order_id = $1;';
                const orderResult = await pool.query(orderQuery, [orderId]);
                const order = orderResult.rows[0];

                if (order) {
                    io.to(`order_${orderId}`).emit('locationUpdate', {
                        orderId: order.order_id,
                        location: delivery.location,
                        timestamp: delivery.timestamp,
                        trackingStatus: delivery.trackingStatus,
                        driverId: driverId
                    });
                    io.to(`user_${order.customer_id}`).emit('locationUpdate', {
                        orderId: order.order_id,
                        location: delivery.location,
                        timestamp: delivery.timestamp,
                        trackingStatus: delivery.trackingStatus,
                        driverId: driverId
                    });
                    io.to(`user_${order.seller_id}`).emit('locationUpdate', {
                        orderId: order.order_id,
                        location: delivery.location,
                        timestamp: delivery.timestamp,
                        trackingStatus: delivery.trackingStatus,
                        driverId: driverId
                    });
                    console.log(`Location updated for Order ${orderId} by Driver ${driverId}`);
                } else {
                     console.warn(`Order ${orderId} not found in PostgreSQL for driver ${driverId} location update.`);
                }

            } catch (error) {
                console.error('Error updating location:', error);
                socket.emit('error', { message: 'Failed to update location.' });
            }
        });

        socket.on('joinOrderTracking', async (orderId) => {
            if (isNaN(orderId)) {
                socket.emit('error', { message: 'Invalid Order ID for tracking.' });
                return;
            }

            try {
                const orderQuery = 'SELECT customer_id, seller_id FROM orders WHERE order_id = $1;';
                const orderResult = await pool.query(orderQuery, [orderId]);
                const order = orderResult.rows[0];

                if (!order) {
                    socket.emit('error', { message: 'Order not found.' });
                    return;
                }

                const isAuthorized = (
                    socket.user.role === 'admin' ||
                    (socket.user.role === 'customer' && socket.user.userId === order.customer_id) ||
                    (socket.user.role === 'seller' && socket.user.userId === order.seller_id) ||
                    (socket.user.role === 'delivery_driver' && order.driver_id === socket.user.userId)
                );

                if (isAuthorized) {
                    socket.join(`order_${orderId}`);
                    console.log(`User ${socket.user.userId} (${socket.user.role}) joined tracking for Order ${orderId}`);

                    const currentTracking = await DeliveryTracking.findOne({ orderId: orderId });
                    if (currentTracking) {
                        socket.emit('currentTracking', {
                            orderId: currentTracking.orderId,
                            location: currentTracking.location,
                            timestamp: currentTracking.timestamp,
                            trackingStatus: currentTracking.trackingStatus,
                            driverId: currentTracking.driverId
                        });
                    } else {
                        socket.emit('currentTracking', { orderId: orderId, message: 'No live tracking data available yet.' });
                    }
                } else {
                    socket.emit('error', { message: 'Unauthorized to track this order.' });
                }
            } catch (error) {
                console.error('Error joining order tracking:', error);
                socket.emit('error', { message: 'Failed to join order tracking.' });
            }
        });

        socket.on('updateDeliveryStatus', async (data) => {
            const { orderId, status } = data;
            const driverId = socket.user.userId;

            if (socket.user.role !== 'delivery_driver') {
                socket.emit('error', { message: 'Unauthorized to update delivery status.' });
                return;
            }
            if (!orderId || !status) {
                socket.emit('error', { message: 'Invalid status data.' });
                return;
            }

            try {
                const updatedTracking = await DeliveryTracking.findOneAndUpdate(
                    { orderId: orderId, driverId: driverId },
                    { $set: { trackingStatus: status, timestamp: new Date() } },
                    { new: true }
                );

                let pgOrderStatus = status;
                if (status === 'picked_up') pgOrderStatus = 'out_for_delivery';
                else if (status === 'arrived_customer_location') pgOrderStatus = 'out_for_delivery';
                else if (status === 'delivered') pgOrderStatus = 'delivered';


                const pgUpdateQuery = `
                    UPDATE orders
                    SET status = $1::character varying(50), updated_at = NOW(),
                    delivered_at = CASE WHEN $1 = 'delivered' THEN NOW() ELSE delivered_at END
                    WHERE order_id = $2
                    RETURNING customer_id, seller_id;
                `;
                const pgResult = await pool.query(pgUpdateQuery, [pgOrderStatus, orderId]);
                const orderParticipants = pgResult.rows[0];

                if (updatedTracking && orderParticipants) {
                    io.to(`order_${orderId}`).emit('deliveryStatusUpdate', {
                        orderId: updatedTracking.orderId,
                        trackingStatus: updatedTracking.trackingStatus,
                        timestamp: updatedTracking.timestamp
                    });
                    io.to(`user_${orderParticipants.customer_id}`).emit('deliveryStatusUpdate', {
                        orderId: updatedTracking.orderId,
                        trackingStatus: updatedTracking.trackingStatus,
                        timestamp: updatedTracking.timestamp
                    });
                    io.to(`user_${orderParticipants.seller_id}`).emit('deliveryStatusUpdate', {
                        orderId: updatedTracking.orderId,
                        trackingStatus: updatedTracking.trackingStatus,
                        timestamp: updatedTracking.timestamp
                    });
                    console.log(`Delivery status updated for Order ${orderId} to ${status}`);
                } else {
                     console.warn(`Could not update delivery status for Order ${orderId}. Tracking doc or order not found.`);
                }

            } catch (error) {
                console.error('Error updating delivery status:', error);
                socket.emit('error', { message: 'Failed to update delivery status.' });
            }
        });

        // --- Chat Events --- // <-- IMPORTANT: NEW CHAT SECTION STARTS HERE

        // Client joins a specific chat room
        // roomName could be 'order_123', 'customer_seller_XYZ', 'driver_customer_ABC'
        socket.on('joinChatRoom', async (roomName) => {
            if (!roomName) {
                socket.emit('error', { message: 'Chat room name is required.' });
                return;
            }
            // A user can join multiple rooms.
            socket.join(roomName);
            console.log(`User ${socket.user.userId} (${socket.user.role}) joined chat room: ${roomName}`);

            try {
                // Fetch last N messages for this room
                const messages = await ChatMessage.find({ room: roomName })
                                                  .sort({ createdAt: 1 }) // Oldest first
                                                  .limit(50); // Get last 50 messages
                socket.emit('chatHistory', { room: roomName, messages: messages });
            } catch (error) {
                console.error('Error fetching chat history:', error);
                socket.emit('error', { message: 'Failed to load chat history.' });
            }
        });

        // Client sends a message to a chat room
        socket.on('sendMessage', async (data) => {
            const { room, message, recipientId, messageType = 'text' } = data; // messageType defaults to 'text'
            const senderId = socket.user.userId;

            if (!room || !message || !senderId) {
                socket.emit('error', { message: 'Room, message, and sender ID are required.' });
                return;
            }

            try {
                const newMessage = new ChatMessage({
                    room,
                    senderId,
                    recipientId: recipientId || null, // Allow recipientId to be optional
                    message,
                    messageType
                });
                await newMessage.save(); // Save message to MongoDB

                // Emit message to everyone in the room (including sender)
                io.to(room).emit('receiveMessage', newMessage);
                console.log(`Message sent in room '${room}' by user ${senderId}: '${message}'`);

            } catch (error) {
                console.error('Error sending message:', error);
                socket.emit('error', { message: 'Failed to send message.' });
            }
        });

        // Client marks messages as read
        socket.on('markMessagesRead', async (data) => {
            const { room, senderId } = data; // senderId here refers to the user who sent the messages being marked
            const readerId = socket.user.userId; // The user who is marking messages as read

            if (!room || !senderId) {
                socket.emit('error', { message: 'Room and sender ID are required to mark messages as read.' });
                return;
            }

            try {
                // Update messages in MongoDB that were sent by senderId to readerId in this room and are unread
                await ChatMessage.updateMany(
                    { room: room, senderId: senderId, recipientId: readerId, isRead: false },
                    { $set: { isRead: true } }
                );
                console.log(`User ${readerId} marked messages from ${senderId} in room '${room}' as read.`);
                // Optionally, emit an update to the sender that their messages were read
                // io.to(`user_${senderId}`).emit('messagesReadConfirmation', { room, readerId });
            } catch (error) {
                console.error('Error marking messages as read:', error);
                socket.emit('error', { message: 'Failed to mark messages as read.' });
            }
        });

        // --- General Event: Disconnection (Existing) ---
        socket.on('disconnect', () => {
            console.log(`User disconnected: ${socket.id} (User ID: ${socket.user.userId})`);
        });
    });

    return io;
};

export default initializeSocketIO;