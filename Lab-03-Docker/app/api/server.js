#!/usr/bin/env node
/**
 * Simple Express API Service for Docker Labs
 */
const express = require('express');
const os = require('os');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());

// Routes
app.get('/', (req, res) => {
  res.json({
    message: 'Docker Lab API Service',
    version: '1.0.0',
    status: 'running'
  });
});

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy', service: 'api' });
});

app.get('/api/info', (req, res) => {
  res.json({
    hostname: os.hostname(),
    platform: os.platform(),
    arch: os.arch(),
    cpus: os.cpus().length,
    memory: {
      total: `${(os.totalmem() / 1024 / 1024 / 1024).toFixed(2)} GB`,
      free: `${(os.freemem() / 1024 / 1024 / 1024).toFixed(2)} GB`
    },
    uptime: os.uptime(),
    environment: process.env.NODE_ENV || 'development'
  });
});

app.get('/api/echo/:message', (req, res) => {
  res.json({
    echo: req.params.message,
    timestamp: new Date().toISOString()
  });
});

// Error handling
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Internal Server Error' });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`API Server running on port ${PORT}`);
  console.log(`Hostname: ${os.hostname()}`);
});
