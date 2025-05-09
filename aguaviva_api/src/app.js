const express = require('express');
const cors = require('cors');
require('./config/database'); // Faz a conexão com o MongoDB

const userRoutes = require('./routes/userRoutes');
const springRoutes = require('./routes/springRoutes');
const assessmentRoutes = require('./routes/assessmentRoutes');
const authRoutes = require('./routes/authRoutes');

const app = express();

app.use(cors());
app.use(express.json());

app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/springs', springRoutes);
app.use('/api/assessments', assessmentRoutes);

module.exports = app;
