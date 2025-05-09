const Spring = require('../models/Spring');

exports.createSpring = async (req, res) => {
  try {
    const spring = new Spring(req.body);
    await spring.save();
    res.status(201).json(spring);
  } catch (err) {
    res.status(400).json({ message: 'Erro ao criar nascente', error: err });
  }
};

exports.getAllSprings = async (req, res) => {
  try {
    const springs = await Spring.find();
    res.json(springs);
  } catch (err) {
    res.status(500).json({ message: 'Erro ao buscar nascentes', error: err });
  }
};

exports.getSpringById = async (req, res) => {
  try {
    const spring = await Spring.findById(req.params.id);
    if (!spring) return res.status(404).json({ message: 'Nascente não encontrada' });
    res.json(spring);
  } catch (err) {
    res.status(500).json({ message: 'Erro ao buscar nascente', error: err });
  }
};

exports.updateSpring = async (req, res) => {
  try {
    const spring = await Spring.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!spring) return res.status(404).json({ message: 'Nascente não encontrada' });
    res.json(spring);
  } catch (err) {
    res.status(400).json({ message: 'Erro ao atualizar nascente', error: err });
  }
};

exports.deleteSpring = async (req, res) => {
  try {
    const spring = await Spring.findByIdAndDelete(req.params.id);
    if (!spring) return res.status(404).json({ message: 'Nascente não encontrada' });
    res.json({ message: 'Nascente removida com sucesso' });
  } catch (err) {
    res.status(500).json({ message: 'Erro ao remover nascente', error: err });
  }
};

exports.getSpringsByOwner = async (req, res) => {
  try {
    const springs = await Spring.find({ ownerId: req.params.ownerId });
    res.json(springs);
  } catch (err) {
    res.status(500).json({ message: 'Erro ao buscar nascentes do proprietário', error: err });
  }
}; 