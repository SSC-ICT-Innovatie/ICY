const User = require("../mongodb_server/models/user");
const ClientMachine = require("../mongodb_server/models/clientMachine");
const jwt = require("jsonwebtoken");
const bcrypt = require("bcryptjs");
const nodemailer = require("nodemailer");
const crypto = require("crypto");
const rateLimit = require("express-rate-limit");
const loadConfig = require("../config");
const mongoose = require("mongoose");

let JWT_SECRET, SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASS;

(async () => {
  const config = await loadConfig();
  JWT_SECRET = config.JWT_SECRET;
  SMTP_HOST = config.SMTP_HOST;
  SMTP_PORT = config.SMTP_PORT;
  SMTP_USER = config.SMTP_USER;
  SMTP_PASS = config.SMTP_PASS;
  console.log("JWT_SECRET:", JWT_SECRET);
})();

const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST,
  port: parseInt(process.env.SMTP_PORT),
  secure: false, // Use STARTTLS
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS,
  },
});


// Verify the connection configuration
transporter.verify(function (error, success) {
  if (error) {
    console.log("SMTP connection error:", error);
  } else {
    console.log("SMTP server is ready to take our messages");
  }
});

function generateCompanyRefId() {
  return "REF-" + crypto.randomBytes(4).toString("hex").toUpperCase();
}

function generateVerificationCode() {
  return crypto.randomBytes(3).toString("hex").toUpperCase();
}

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // Limit each IP to 5 login attempts per window
  message: "Too many login attempts, please try again after 15 minutes",
});

exports.register = async (req, res) => {
  try {
    const { email, password, name } = req.body;
    console.log(`Attempting registration for email: ${email}`);


    if (!email || !password || !name) {
      console.log("Registration failed: Missing required fields");
      return res.status(400).json({ message: "Missing required fields" });
    }
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      console.log(
        `Registration failed: User with email ${email} already exists`,
      );
      return res.status(400).json({ message: "User already exists" });
    }
    const company_id = new mongoose.Types.ObjectId();
    const company_ref_id = generateCompanyRefId();
    const verificationCode = generateVerificationCode();
    const user = new User({
      email,
      password,
      name,
      company_id,
      company_ref_id,
      verificationCode,
      isVerified: false,
    });
    await user.save();

    await transporter.sendMail({
      from: '"SellaOS" <app@sellaos.com>',
      to: email,
      subject: "Verify Your Email",
      text: `Your verification code is: ${verificationCode}. Please do not share it with anyone`,
    });

    console.log(
      `Registration initiated for user ${email}. Verification required.`,
    );
    res
      .status(201)
      .json({
        message:
          "User registered. Please check your email for verification code.",
      });
  } catch (error) {
    console.error("Registration error:", error);
    res.status(400).json({ message: error.message });
  }
};

exports.verifyEmail = async (req, res) => {
  try {
    const { email, verificationCode } = req.body;
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }
    if (user.verificationCode !== verificationCode) {
      return res.status(400).json({ message: "Invalid verification code" });
    }
    user.isVerified = true;
    user.verificationCode = undefined;
    await user.save();

    const token = jwt.sign(
      { userId: user._id, companyId: user.company_id },
      JWT_SECRET,
      { expiresIn: "1d" },
    );
    console.log(`Email verified successfully for user ${email}`);
    res.json({
      message: "Email verified successfully",
      token,
      user: {
        email: user.email,
        name: user.name,
        company_ref_id: user.company_ref_id,
      },
    });
  } catch (error) {
    console.error("Email verification error:", error);
    res.status(500).json({ message: "Internal server error" });
  }
};

exports.login = [
  loginLimiter,
  async (req, res) => {
    try {
      const { email, password } = req.body;
      console.log(`Attempting login for email: ${email}`);
      const user = await User.findOne({ email });
      if (!user) {
        console.log(`Login failed: No user found with email ${email}`);
        return res.status(401).json({ message: "Invalid credentials" });
      }
      if (!user.isVerified) {
        console.log(`Login failed: Email not verified for user ${email}`);
        return res.status(401).json({ message: "Email not verified" });
      }
      const isPasswordValid = await bcrypt.compare(password, user.password);
      if (!isPasswordValid) {
        console.log(`Login failed: Invalid password for user ${email}`);
        return res.status(401).json({ message: "Invalid credentials" });
      }
      const loginCode = generateVerificationCode();
      user.loginCode = loginCode;
      user.loginCodeExpires = Date.now() + 10 * 60 * 1000; // 10 minutes
      await user.save();

      await transporter.sendMail({
      from: '"SellaOS" <app@sellaos.com>',
        to: email,
        subject: "Login Verification Code",
        text: `Your login verification code is: ${loginCode}. Please do not share it with anyone.`,
      });

      console.log(`Login verification code sent to ${email}`);
      res.json({
        message: "Please check your email for login verification code",
      });
    } catch (error) {
      console.error("Login error:", error);
      res.status(500).json({ message: "Internal server error" });
    }
  },
];

exports.verifyLogin = async (req, res) => {
  try {
    const { email, loginCode } = req.body;
    const user = await User.findOne({
      email,
      loginCode,
      loginCodeExpires: { $gt: Date.now() },
    });
    if (!user) {
      return res.status(401).json({ message: "Invalid or expired login code" });
    }
    const accessToken = jwt.sign(
      { userId: user._id, companyId: user.company_id },
      JWT_SECRET,
      { expiresIn: "7d" },
    );
    const refreshToken = jwt.sign({ userId: user._id }, JWT_SECRET, {
      expiresIn: "7d",
    });
    user.refreshToken = refreshToken;
    user.loginCode = undefined;
    user.loginCodeExpires = undefined;
    await user.save();
    console.log(`Login successful for user ${email}`);
    res.json({
      accessToken,
      refreshToken,
      user: {
        email: user.email,
        name: user.name,
        company_ref_id: user.company_ref_id,
      },
    });
  } catch (error) {
    console.error("Login verification error:", error);
    res.status(500).json({ message: "Internal server error" });
  }
};

exports.deviceLogin = async (req, res) => {
  try {
    const { company_ref_id, machine_key, device_id } = req.body;
    const user = await User.findOne({ company_ref_id });
    if (!user) {
      return res.status(401).json({ message: "Invalid company reference ID" });
    }
    const clientMachine = await ClientMachine.findOne({
      company_id: user.company_id,
      machine_key: machine_key,
      device_id: device_id,
    });
    if (!clientMachine) {
      return res
        .status(401)
        .json({ message: "Invalid machine key or device ID" });
    }
    const token = jwt.sign(
      { userId: user._id, companyId: user.company_id, deviceId: device_id },
      JWT_SECRET,
      { expiresIn: "1d" },
    );
    res.json({ token });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.refreshToken = async (req, res) => {
  const { refreshToken } = req.body;
  if (!refreshToken) {
    return res.status(401).json({ message: "Refresh token required" });
  }
  try {
    const decoded = jwt.verify(refreshToken, JWT_SECRET);
    const user = await User.findById(decoded.userId);
    if (!user || user.refreshToken !== refreshToken) {
      return res.status(401).json({ message: "Invalid refresh token" });
    }
    const accessToken = jwt.sign(
      { userId: user._id, companyId: user.company_id },
      JWT_SECRET,
      { expiresIn: "15m" },
    );
    res.json({ accessToken });
  } catch (error) {
    console.error("Refresh token error:", error);
    res.status(401).json({ message: "Invalid refresh token" });
  }
};

exports.forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }
    const resetToken = crypto.randomBytes(20).toString("hex");
    user.resetPasswordToken = resetToken;
    user.resetPasswordExpires = Date.now() + 3600000; // 1 hour
    await user.save();

    const resetUrl = `http://app.sellaos.com/reset-password/${resetToken}`;
    await transporter.sendMail({
      from: '"SellaOS" <app@sellaos.com>',
      to: email,
      subject: "Password Reset",
      text: `To reset your password, click this link: ${resetUrl}`,
    });

    res.json({ message: "Password reset email sent" });
  } catch (error) {
    console.error("Forgot password error:", error);
    res.status(500).json({ message: "Internal server error" });
  }
};

exports.resetPassword = async (req, res) => {
  try {
    const { token, newPassword } = req.body;
    const user = await User.findOne({
      resetPasswordToken: token,
      resetPasswordExpires: { $gt: Date.now() },
    });
    if (!user) {
      return res
        .status(400)
        .json({ message: "Invalid or expired reset token" });
    }
    user.password = newPassword;
    user.resetPasswordToken = undefined;
    user.resetPasswordExpires = undefined;
    await user.save();
    res.json({ message: "Password reset successful" });
  } catch (error) {
    console.error("Reset password error:", error);
    res.status(500).json({ message: "Internal server error" });
  }
};

exports.getCurrentUser = async (req, res) => {
  try {
    const userId = req.user.userId;
    const user = await User.findById(userId).select("-password");
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }
    res.json(user);
  } catch (error) {
    console.error("Error getting current user:", error);
    res.status(500).json({ message: "Internal server error" });
  }
};
