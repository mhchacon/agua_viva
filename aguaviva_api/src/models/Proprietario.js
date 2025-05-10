const mongoose = require('mongoose');

const ProprietarioSchema = new mongoose.Schema({
  nomeCompleto: { type: String, required: true },
  cpf: { type: String, required: true },
  numeroCAR: { type: String, required: true },
  dadosPropriedade: { type: String },
  temNascente: { type: Boolean, required: true },
  quantidadeNascentes: { type: Number },
  disponibilidadeAgua: { type: String, required: true },
  usosNascente: [{ type: String }],
  vegetacaoAoRedor: { type: String, required: true },
  temProtecao: { type: Boolean, required: true },
  testeVazaoRealizado: { type: Boolean, required: true },
  valorVazao: { type: Number },
  dataVazao: { type: Date },
  analiseQualidadeRealizada: { type: Boolean, required: true },
  parametrosAnalise: { type: String },
  dataAnalise: { type: Date },
  corAgua: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  senha: { type: String, required: true },
}, { timestamps: true });

module.exports = mongoose.model('Proprietario', ProprietarioSchema); 