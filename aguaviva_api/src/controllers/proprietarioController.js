const Proprietario = require('../models/Proprietario');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

exports.criarProprietario = async (req, res) => {
  try {
    // Verifica se já existe proprietário com o mesmo e-mail
    const existe = await Proprietario.findOne({ email: req.body.email });
    if (existe) {
      return res.status(400).json({ message: 'E-mail já cadastrado.' });
    }

    // Criptografa a senha
    const hashedPassword = await bcrypt.hash(req.body.senha, 10);
    
    // Cria o objeto com a senha criptografada
    const proprietarioData = {
      ...req.body,
      senha: hashedPassword
    };
    
    // Cria e salva
    const novo = new Proprietario(proprietarioData);
    await novo.save();
    
    res.status(201).json({ message: 'Proprietário cadastrado com sucesso.' });
  } catch (err) {
    res.status(500).json({ message: 'Erro ao cadastrar proprietário.', error: err });
  }
};

exports.loginProprietario = async (req, res) => {
  try {
    const { email, senha } = req.body;
    
    // Busca o proprietário pelo email
    const proprietario = await Proprietario.findOne({ email });
    if (!proprietario) {
      return res.status(400).json({ message: 'E-mail não encontrado.' });
    }
    
    // Verifica a senha
    const senhaCorreta = await bcrypt.compare(senha, proprietario.senha);
    if (!senhaCorreta) {
      return res.status(400).json({ message: 'Senha incorreta.' });
    }
    
    // Gera o token JWT
    const token = jwt.sign(
      { 
        id: proprietario._id,
        tipo: 'proprietario',
        email: proprietario.email,
        nomeCompleto: proprietario.nomeCompleto
      },
      process.env.JWT_SECRET,
      { expiresIn: '1d' }
    );
    
    // Retorna o token e os dados do proprietário
    res.json({
      token,
      proprietario: {
        id: proprietario._id,
        email: proprietario.email,
        nomeCompleto: proprietario.nomeCompleto,
        tipo: 'proprietario'
      }
    });
  } catch (err) {
    res.status(500).json({ message: 'Erro ao fazer login.', error: err });
  }
}; 