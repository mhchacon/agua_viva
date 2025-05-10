const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const User = require('../models/User');
require('dotenv').config();

async function createDefaultUsers() {
  try {
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/agua_viva');
    console.log('Conectado ao MongoDB');

    // Lista de usuários padrão
    const defaultUsers = [
      {
        name: 'Administrador',
        email: 'admin@agua-viva.com',
        password: 'admin123',
        role: 'admin'
      },
      {
        name: 'Avaliador',
        email: 'avaliador@agua-viva.com',
        password: 'avaliador123',
        role: 'evaluator'
      },
      {
        name: 'Proprietário',
        email: 'proprietario@agua-viva.com',
        password: 'proprietario123',
        role: 'owner'
      }
    ];

    // Criar usuários
    for (const userData of defaultUsers) {
      const userExists = await User.findOne({ email: userData.email });
      
      if (!userExists) {
        const hashedPassword = await bcrypt.hash(userData.password, 10);
        const user = new User({
          name: userData.name,
          email: userData.email,
          password: hashedPassword,
          role: userData.role
        });
        
        await user.save();
        console.log(`Usuário ${userData.name} criado com sucesso`);
      } else {
        console.log(`Usuário ${userData.name} já existe`);
      }
    }

    console.log('Processo concluído');
    process.exit(0);
  } catch (error) {
    console.error('Erro:', error);
    process.exit(1);
  }
}

createDefaultUsers(); 