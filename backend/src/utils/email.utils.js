// backend/src/utils/email.utils.js
// This file contains utility functions for sending emails using Nodemailer.

// IMPORTANT: Ensure dotenv is loaded AT THE VERY TOP to guarantee
// process.env variables are available.
import 'dotenv/config'; 
import nodemailer from 'nodemailer'; // Import nodemailer

// NO LONGER DEFINING TRANSPORTER GLOBALLY.
// It will be created inside the sending functions to ensure
// it always uses the latest environment variables.

/**
 * Sends a verification email to a user.
 * @param {string} to - The recipient's email address.
 * @param {string} token - The unique verification token generated for the user.
 * @param {string} userName - The full name of the user (for personalized greeting).
 */
async function sendVerificationEmail(to, token, userName) {
    // Create the transporter *here* to ensure latest env variables are used
    const transporter = nodemailer.createTransport({
        host: process.env.EMAIL_SERVICE_HOST,
        port: parseInt(process.env.EMAIL_SERVICE_PORT, 10),
        secure: process.env.EMAIL_SERVICE_SECURE === 'true',
        auth: {
            user: process.env.EMAIL_AUTH_USER,
            pass: process.env.EMAIL_AUTH_PASSWORD,
        },
        logger: true, // Enable Nodemailer's internal logging
        debug: true,  // Enable more detailed debug output
    });

    // CRITICAL FIX: Use BACKEND_PUBLIC_URL for the verification link
    // This link will be opened by the user's browser, and it should hit your backend directly.
    const backendPublicUrl = process.env.BACKEND_PUBLIC_URL;
    const verificationLink = `${backendPublicUrl}/api/auth/verify-email?token=${token}`;
    
    const mailOptions = {
        from: process.env.SENDER_EMAIL,
        to: to,
        subject: 'Aklny App - Verify Your Email Address',
        html: `
            <div style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
                <div style="background-color: ${process.env.CADILLAC_COUPE || '#C3332A'}; padding: 20px; text-align: center; border-radius: 8px 8px 0 0;">
                    <h2 style="color: white; margin: 0;">Welcome to Aklny App!</h2>
                </div>
                <div style="padding: 30px; background-color: white; border-radius: 0 0 8px 8px; box-shadow: 0 4px 8px rgba(0,0,0,0.05);">
                    <p style="font-size: 16px;">Hello ${userName},</p>
                    <p style="font-size: 16px;">Thank you for registering with Aklny! To complete your registration and activate your account, please verify your email address by clicking the link below:</p>
                    <p style="text-align: center; margin: 30px 0;">
                        <a href="${verificationLink}" style="display: inline-block; padding: 15px 30px; font-size: 18px; color: white; background-color: ${process.env.ORANGE_CRUSH || '#EC7533'}; border-radius: 8px; text-decoration: none; font-weight: bold;">Verify Your Email</a>
                    </p>
                    <p style="font-size: 14px; color: #555;">This link will expire in 24 hours. If you did not register for an Aklny account, please ignore this email.</p>
                    <p style="font-size: 14px; color: #555;">If the button above does not work, you can copy and paste the following link into your browser:</p>
                    <p style="word-break: break-all; font-size: 14px;"><a href="${verificationLink}" style="color: ${process.env.CADILLAC_COUPE || '#C3332A'}; text-decoration: underline;">${verificationLink}</a></p>
                    <p style="font-size: 16px; margin-top: 40px;">Best regards,<br/>The Aklny Team</p>
                </div>
                <div style="background-color: ${process.env.SQUASH_BLOSSOM || '#F5B43C'}; padding: 15px; text-align: center; font-size: 12px; color: ${process.env.AVOCADO_PEEL || '#39393B'}; border-radius: 0 0 8px 8px; margin-top: 20px;">
                    <p style="margin: 0;">&copy; ${new Date().getFullYear()} Aklny App. All rights reserved.</p>
                </div>
            </div>
        `,
    };

    try {
        const info = await transporter.sendMail(mailOptions);
        console.log(`Verification email sent to ${to}. Message ID: ${info.messageId}`);
        if (nodemailer.getTestMessageUrl(info)) {
            console.log('Preview URL (Mailtrap/Ethereal):', nodemailer.getTestMessageUrl(info));
        }
    } catch (error) {
        console.error(`Failed to send verification email to ${to}:`, error);
        throw new Error('Failed to send verification email. Please check your email configuration.');
    }
}

/**
 * Sends a password reset email to a user.
 * @param {string} to - The recipient's email address.
 * @param {string} token - The unique password reset token.
 * @param {string} userName - The name of the user.
 */
async function sendPasswordResetEmail(to, token, userName) {
    // Create the transporter *here* to ensure latest env variables are used
    const transporter = nodemailer.createTransport({
        host: process.env.EMAIL_SERVICE_HOST,
        port: parseInt(process.env.EMAIL_SERVICE_PORT, 10),
        secure: process.env.EMAIL_SERVICE_SECURE === 'true',
        auth: {
            user: process.env.EMAIL_AUTH_USER,
            pass: process.env.EMAIL_AUTH_PASSWORD,
        },
        logger: true,
        debug: true,
    });

    // Use BACKEND_PUBLIC_URL for reset links as well
    const backendPublicUrl = process.env.BACKEND_PUBLIC_URL;
    const resetLink = `${backendPublicUrl}/api/auth/reset-password?token=${token}`; // Assuming a backend route for password reset initially

    const mailOptions = {
        from: process.env.SENDER_EMAIL,
        to: to,
        subject: 'Aklny App - Password Reset Request',
        html: `
            <div style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
                <div style="background-color: ${process.env.CADILLAC_COUPE || '#C3332A'}; padding: 20px; text-align: center; border-radius: 8px 8px 0 0;">
                    <h2 style="color: white; margin: 0;">Aklny App Password Reset</h2>
                </div>
                <div style="padding: 30px; background-color: white; border-radius: 0 0 8px 8px; box-shadow: 0 4px 8px rgba(0,0,0,0.05);">
                    <p style="font-size: 16px;">Hello ${userName},</p>
                    <p style="font-size: 16px;">We received a request to reset the password for your Aklny account. To proceed, please click the link below:</p>
                    <p style="text-align: center; margin: 30px 0;">
                        <a href="${resetLink}" style="display: inline-block; padding: 15px 30px; font-size: 18px; color: white; background-color: ${process.env.ORANGE_CRUSH || '#EC7533'}; border-radius: 8px; text-decoration: none; font-weight: bold;">Reset Your Password</a>
                    </p>
                    <p style="font-size: 14px; color: #555;">This link will expire in 1 hour. If you did not request a password reset, please ignore this email.</p>
                    <p style="font-size: 14px; color: #555;">If the button above does not work, you can copy and paste the following link into your browser:</p>
                    <p style="word-break: break-all; font-size: 14px;"><a href="${resetLink}" style="color: ${process.env.CADILLAC_COUPE || '#C3332A'}; text-decoration: underline;">${resetLink}</a></p>
                    <p style="font-size: 16px; margin-top: 40px;">Best regards,<br/>The Aklny Team</p>
                </div>
                <div style="background-color: ${process.env.SQUASH_BLOSSOM || '#F5B43C'}; padding: 15px; text-align: center; font-size: 12px; color: ${process.env.AVOCADO_PEEL || '#39393B'}; border-radius: 0 0 8px 8px; margin-top: 20px;">
                    <p style="margin: 0;">&copy; ${new Date().getFullYear()} Aklny App. All rights reserved.</p>
                </div>
            </div>
        `,
    };

    try {
        const info = await transporter.sendMail(mailOptions);
        console.log(`Password reset email sent to ${to}. Message ID: ${info.messageId}`);
        if (nodemailer.getTestMessageUrl(info)) {
            console.log('Preview URL (Mailtrap/Ethereal):', nodemailer.getTestMessageUrl(info));
        }
    } catch (error) {
        console.error(`Failed to send password reset email to ${to}:`, error);
        throw new Error('Failed to send password reset email. Please check your email configuration.');
    }
}

// Export the functions to be used by other modules
export {
    sendVerificationEmail,
    sendPasswordResetEmail
};
