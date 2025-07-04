// backend/src/utils/response.utils.js
// Utility functions for consistent HTTP responses, especially for HTML error pages.

import { renderHtml } from './htmlRenderer.utils.js'; // Assuming htmlRenderer.js is in the same utils directory

/**
 * Renders an HTML error page and sends it as a response.
 * @param {object} res - Express response object.
 * @param {number} statusCode - HTTP status code for the error (e.g., 400, 500).
 * @param {string} errorMessage - The error message to display on the page.
 * @param {string} [templateName='error.html'] - The name of the HTML template to render.
 */
export const sendHtmlError = async (res, statusCode, errorMessage, templateName = 'emailVerificationFailed.html') => {
    try {
        const html = await renderHtml(templateName, { errorMessage: errorMessage || 'An unexpected error occurred.' });
        res.status(statusCode).send(html);
    } catch (renderError) {
        // Fallback if even rendering the error page fails
        console.error('Failed to render HTML error page:', renderError);
        res.status(500).send(`
            <!DOCTYPE html>
            <html lang="en">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Error</title>
                <style>
                    body { font-family: sans-serif; display: flex; justify-content: center; align-items: center; height: 100vh; background-color: #f8f8f8; color: #333; text-align: center; }
                    .container { padding: 20px; border-radius: 8px; background-color: #fff; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
                    h1 { color: #d9534f; }
                </style>
            </head>
            <body>
                <div class="container">
                    <h1>Error</h1>
                    <p>An unexpected error occurred. Please try again later.</p>
                    <p>Details: ${errorMessage}</p>
                </div>
            </body>
            </html>
        `);
    }
};
