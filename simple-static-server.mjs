// simple-static-server.js
// This is a simple Node.js script to serve static files (like your HTML test client).

import http from 'http';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

// Get the directory name of the current module
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const port = 5000; // Choose a port that is NOT 3000 (your backend API port)
const staticFilesDirectory = path.join(__dirname, 'frontend_test'); // Path to your frontend_test folder

const server = http.createServer((req, res) => {
    // Construct the file path based on the request URL
    let filePath = path.join(staticFilesDirectory, req.url === '/' ? 'delivery_tracker.html' : req.url);

    // Ensure the path is within the designated static files directory to prevent directory traversal
    if (!filePath.startsWith(staticFilesDirectory)) {
        res.writeHead(403, { 'Content-Type': 'text/plain' });
        res.end('Forbidden');
        return;
    }

    // Determine content type based on file extension
    const extname = String(path.extname(filePath)).toLowerCase();
    const mimeTypes = {
        '.html': 'text/html',
        '.js': 'text/javascript',
        '.css': 'text/css',
        '.json': 'application/json',
        '.png': 'image/png',
        '.jpg': 'image/jpg',
        '.gif': 'image/gif',
        '.svg': 'image/svg+xml',
        '.wav': 'audio/wav',
        '.mp4': 'video/mp4',
        '.woff': 'application/font-woff',
        '.ttf': 'application/font-ttf',
        '.eot': 'application/vnd.ms-fontobject',
        '.otf': 'application/font-otf',
        '.wasm': 'application/wasm'
    };
    const contentType = mimeTypes[extname] || 'application/octet-stream';

    // Read the file and serve it
    fs.readFile(filePath, (error, content) => {
        if (error) {
            if (error.code === 'ENOENT') { // File not found
                res.writeHead(404, { 'Content-Type': 'text/plain' });
                res.end('File Not Found');
            } else { // Server error
                res.writeHead(500, { 'Content-Type': 'text/plain' });
                res.end('Internal Server Error: ' + error.code);
            }
        } else {
            res.writeHead(200, { 'Content-Type': contentType });
            res.end(content, 'utf-8');
        }
    });
});

server.listen(port, () => {
    console.log(`Static file server running at http://localhost:${port}/`);
    console.log(`Access delivery_tracker.html at: http://localhost:${port}/delivery_tracker.html`);
});