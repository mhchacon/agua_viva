const express = require('express');
const cors = require('cors');
require('./config/database'); // Faz a conexão com o MongoDB

const userRoutes = require('./routes/userRoutes');
const springRoutes = require('./routes/springRoutes');
const assessmentRoutes = require('./routes/assessmentRoutes');
const authRoutes = require('./routes/authRoutes');
const proprietarioRoutes = require('./routes/proprietarioRoutes');

const app = express();

app.use(cors());
app.use(express.json());

// Rota de health check/heartbeat para verificar se o servidor está online
app.get('/api/health', (req, res) => {
  res.status(200).json({ status: 'OK', timestamp: new Date().toISOString() });
});

app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/springs', springRoutes);
app.use('/api/assessments', assessmentRoutes);
app.use('/api/proprietarios', proprietarioRoutes);

module.exports = app;
