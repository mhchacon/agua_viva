const Assessment = require('../models/Assessment');

exports.createAssessment = async (req, res) => {
  try {
    const assessment = new Assessment(req.body);
    await assessment.save();
    res.status(201).json(assessment);
  } catch (err) {
    res.status(400).json({ message: 'Erro ao criar avaliação', error: err });
  }
};

exports.getAllAssessments = async (req, res) => {
  try {
    const assessments = await Assessment.find();
    res.json(assessments);
  } catch (err) {
    res.status(500).json({ message: 'Erro ao buscar avaliações', error: err });
  }
};

exports.getAssessmentById = async (req, res) => {
  try {
    const assessment = await Assessment.findById(req.params.id);
    if (!assessment) return res.status(404).json({ message: 'Avaliação não encontrada' });
    res.json(assessment);
  } catch (err) {
    res.status(500).json({ message: 'Erro ao buscar avaliação', error: err });
  }
};

exports.getAssessmentsByOwnerCpf = async (req, res) => {
  try {
    const { cpf } = req.params;
    const assessments = await Assessment.find({ ownerCpf: cpf });
    res.json(assessments);
  } catch (err) {
    res.status(500).json({ message: 'Erro ao buscar avaliações do proprietário', error: err });
  }
};

exports.updateAssessment = async (req, res) => {
  try {
    const assessment = await Assessment.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!assessment) return res.status(404).json({ message: 'Avaliação não encontrada' });
    res.json(assessment);
  } catch (err) {
    res.status(400).json({ message: 'Erro ao atualizar avaliação', error: err });
  }
};

exports.deleteAssessment = async (req, res) => {
  try {
    const assessment = await Assessment.findByIdAndDelete(req.params.id);
    if (!assessment) return res.status(404).json({ message: 'Avaliação não encontrada' });
    res.json({ message: 'Avaliação removida com sucesso' });
  } catch (err) {
    res.status(500).json({ message: 'Erro ao remover avaliação', error: err });
  }
}; 