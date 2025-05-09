const mongoose = require('mongoose');

const locationSchema = new mongoose.Schema({
  latitude: { type: Number, required: true },
  longitude: { type: Number, required: true },
}, { _id: false });

const springSchema = new mongoose.Schema({
  ownerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  ownerName: { type: String, required: true },
  location: { type: locationSchema, required: true },
  altitude: { type: Number, required: true },
  municipality: { type: String, required: true },
  reference: { type: String, required: true },
  hasCAR: { type: Boolean, required: true },
  carNumber: { type: String },
  hasAPP: { type: Boolean, required: true },
  appStatus: { type: String, required: true },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Spring', springSchema); 