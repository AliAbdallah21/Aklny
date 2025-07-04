// backend/src/utils/htmlRenderer.js
// This utility provides a function to render HTML files from the views directory,
// allowing for simple dynamic content injection via placeholders.

import { promises as fs } from 'fs'; // Node.js file system promises API
import path from 'path'; // Node.js path module for resolving file paths
import { fileURLToPath } from 'url'; // For resolving __dirname in ES Modules

// Get __dirname equivalent in ES Modules
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Define the base path for your HTML template files
const VIEWS_BASE_PATH = path.join(__dirname, '../views/auth');

/**
 * Renders an HTML file by replacing placeholders with provided data.
 * Placeholders in the HTML should be in the format {{variableName}}.
 * @param {string} templateName - The name of the HTML template file (e.g., 'emailVerified.html').
 * @param {object} [data={}] - An object containing key-value pairs to replace placeholders.
 * @returns {Promise<string>} A promise that resolves with the rendered HTML string.
 */
export const renderHtml = async (templateName, data = {}) => {
    const templatePath = path.join(VIEWS_BASE_PATH, templateName);

    try {
        let htmlContent = await fs.readFile(templatePath, 'utf8');

        // Replace placeholders in the HTML content with data values
        for (const key in data) {
            if (data.hasOwnProperty(key)) {
                const placeholder = new RegExp(`{{${key}}}`, 'g'); // Create a regex for the placeholder
                htmlContent = htmlContent.replace(placeholder, data[key]);
            }
        }
        return htmlContent;
    } catch (error) {
        console.error(`Error rendering HTML template '${templateName}':`, error);
        // Fallback to a generic error message or re-throw
        throw new Error(`Failed to render HTML template: ${templateName}`);
    }
};
