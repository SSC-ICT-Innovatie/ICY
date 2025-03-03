const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    name: { type: String, required: true },
    company_id: { type: mongoose.Schema.Types.ObjectId },
    company_ref_id: { type: String },
    verificationCode: String,
    isVerified: { type: Boolean, default: false },
    loginCode: String,
    loginCodeExpires: Date,
    resetPasswordToken: String,
    resetPasswordExpires: Date,
    refreshToken: String
});

userSchema.pre('save', async function(next) {
    if (this.isModified('password')) {
        this.password = await bcrypt.hash(this.password, 10);
    }
    next();
});

module.exports = mongoose.model('User', userSchema);