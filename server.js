const http = require('http');
const https = require('https');
const fs = require('fs');
const path = require('path');

// --- Hardcoded Workato Genie credentials (internal/personal use only) ---
// These grant chat access to the configured Genie. Do not share this project
// publicly or deploy it anywhere reachable from outside your machine.
const GENIE_API_KEY = 'a8222816d4143ee00d2e2760df1aac21a2197ffa4cf9007bf6d9eee23cd11721';
const GENIE_ID = 'gin-AbDFw8XJ-9eDWmW-CD';
const IDP_USER_ID = '99v7UEaBK1xwLhGQL7KjMt';
const GENIE_HOST = 'genie-api.workato.com';

const PORT = process.env.PORT || 8787;
const PUBLIC_DIR = path.join(__dirname, 'public');

const MIME = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
};

function genieRequest(pathName, method, body) {
  return new Promise((resolve, reject) => {
    const payload = body !== undefined ? JSON.stringify(body) : null;
    const req = https.request(
      {
        hostname: GENIE_HOST,
        path: pathName,
        method,
        headers: {
          Authorization: `Bearer ${GENIE_API_KEY}`,
          'X-IDP-User-ID': IDP_USER_ID,
          'Content-Type': 'application/json',
          ...(payload ? { 'Content-Length': Buffer.byteLength(payload) } : {}),
        },
      },
      (res) => resolve(res)
    );
    req.on('error', reject);
    if (payload) req.write(payload);
    req.end();
  });
}

function serveStatic(req, res) {
  const urlPath = req.url === '/' ? '/index.html' : req.url;
  const filePath = path.join(PUBLIC_DIR, urlPath);
  if (!filePath.startsWith(PUBLIC_DIR)) {
    res.writeHead(403);
    return res.end('Forbidden');
  }
  fs.readFile(filePath, (err, data) => {
    if (err) {
      res.writeHead(404);
      return res.end('Not found');
    }
    res.writeHead(200, { 'Content-Type': MIME[path.extname(filePath)] || 'application/octet-stream' });
    res.end(data);
  });
}

function readJsonBody(req) {
  return new Promise((resolve, reject) => {
    let raw = '';
    req.on('data', (chunk) => (raw += chunk));
    req.on('end', () => {
      try {
        resolve(raw ? JSON.parse(raw) : {});
      } catch (e) {
        reject(e);
      }
    });
    req.on('error', reject);
  });
}

const server = http.createServer(async (req, res) => {
  try {
    if (req.method === 'POST' && req.url === '/api/start-conversation') {
      const genieRes = await genieRequest(`/api/v1/genies/${GENIE_ID}/chat/conversations`, 'POST', {});
      let body = '';
      genieRes.on('data', (c) => (body += c));
      genieRes.on('end', () => {
        res.writeHead(genieRes.statusCode || 502, { 'Content-Type': 'application/json' });
        res.end(body);
      });
      return;
    }

    if (req.method === 'POST' && req.url === '/api/send-message') {
      let parsed;
      try {
        parsed = await readJsonBody(req);
      } catch {
        res.writeHead(400, { 'Content-Type': 'application/json' });
        return res.end(JSON.stringify({ error: 'Invalid JSON body' }));
      }
      const { conversationId, message } = parsed;
      if (!conversationId || !message) {
        res.writeHead(400, { 'Content-Type': 'application/json' });
        return res.end(JSON.stringify({ error: 'Missing conversationId or message' }));
      }
      const genieRes = await genieRequest(
        `/api/v1/genies/${GENIE_ID}/chat/conversations/${conversationId}/messages`,
        'POST',
        { message, stream: true }
      );
      res.writeHead(genieRes.statusCode || 502, {
        'Content-Type': genieRes.headers['content-type'] || 'text/event-stream',
        'Cache-Control': 'no-cache',
        Connection: 'keep-alive',
      });
      genieRes.pipe(res);
      return;
    }

    if (req.method === 'GET') {
      return serveStatic(req, res);
    }

    res.writeHead(404);
    res.end('Not found');
  } catch (err) {
    res.writeHead(502, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Upstream request failed', detail: String(err && err.message || err) }));
  }
});

server.listen(PORT, () => {
  console.log(`IT Support Portal running at http://localhost:${PORT}`);
});
