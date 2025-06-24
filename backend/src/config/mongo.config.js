// backend/src/config/mongo.config.js
// This file manages the connection to your MongoDB database.

import mongoose from 'mongoose'; // Import Mongoose library

// Function to connect to MongoDB
const connectMongoDB = async () => {
  try {
    // Get MongoDB URI from environment variables.
    // It's crucial to define MONGO_URI in your .env file.
    // Example local URI: mongodb://localhost:27017/homechefs_realtime_db
    // Example Atlas URI: mongodb+srv://<user>:<password>@<cluster-url>/<db-name>?retryWrites=true&w=majority
    const mongoURI = process.env.MONGO_URI;

    if (!mongoURI) {
      console.error('MONGO_URI is not defined in .env file.');
      process.exit(1); // Exit if no URI is provided
    }

    // Connect to MongoDB using Mongoose
    await mongoose.connect(mongoURI, {
      // useNewUrlParser and useUnifiedTopology are typically default in newer Mongoose versions,
      // but explicitly adding them for broader compatibility.
      // These options handle connection string parsing and server discovery.
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    console.log('MongoDB connected successfully!');
  } catch (error) {
    console.error('MongoDB connection error:', error.message);
    process.exit(1); // Exit the process if MongoDB connection fails
  }
};

// Export the connection function
export default connectMongoDB;