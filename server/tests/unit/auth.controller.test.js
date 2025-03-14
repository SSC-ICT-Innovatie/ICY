const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const mongoose = require('mongoose');
const { expect } = require('chai');
const sinon = require('sinon');
const { login, register } = require('../../src/controllers/authController');
const User = require('../../src/models/userModel');
const { createError } = require('../../src/utils/errorUtils');

describe('Auth Controller Tests', () => {
  let req;
  let res;
  let next;
  let userFindOneStub;
  let userSaveStub;
  let userCreateStub;
  let bcryptCompareStub;
  let bcryptHashStub;
  let jwtSignStub;

  beforeEach(() => {
    // Setup request and response
    req = {
      body: {}
    };
    res = {
      status: sinon.stub().returnsThis(),
      json: sinon.stub()
    };
    next = sinon.stub();

    // Setup stubs
    userFindOneStub = sinon.stub(User, 'findOne');
    userSaveStub = sinon.stub(User.prototype, 'save');
    userCreateStub = sinon.stub(User, 'create');
    bcryptCompareStub = sinon.stub(bcrypt, 'compare');
    bcryptHashStub = sinon.stub(bcrypt, 'hash');
    jwtSignStub = sinon.stub(jwt, 'sign');
  });

  afterEach(() => {
    sinon.restore();
  });

  describe('login', () => {
    it('should return 401 for invalid email', async () => {
      // Arrange
      req.body = {
        email: 'invalid@example.com',
        password: 'password123'
      };
      userFindOneStub.resolves(null);

      // Act
      await login(req, res, next);

      // Assert
      expect(next.calledOnce).to.be.true;
      expect(next.args[0][0]).to.be.an('error');
      expect(next.args[0][0].statusCode).to.equal(401);
      expect(next.args[0][0].message).to.equal('Invalid email or password');
    });

    it('should return 401 for invalid password', async () => {
      // Arrange
      req.body = {
        email: 'valid@example.com',
        password: 'wrongpassword'
      };
      
      const mockUser = {
        _id: new mongoose.Types.ObjectId(),
        email: 'valid@example.com',
        matchPassword: sinon.stub().resolves(false),
        save: userSaveStub
      };
      
      userFindOneStub.resolves(mockUser);

      // Act
      await login(req, res, next);

      // Assert
      expect(next.calledOnce).to.be.true;
      expect(next.args[0][0]).to.be.an('error');
      expect(next.args[0][0].statusCode).to.equal(401);
    });

    it('should return user and tokens for valid credentials', async () => {
      // Arrange
      req.body = {
        email: 'valid@example.com',
        password: 'correctpassword'
      };
      
      const userId = new mongoose.Types.ObjectId();
      const mockUser = {
        _id: userId,
        email: 'valid@example.com',
        toJSON: () => ({ 
          _id: userId,
          email: 'valid@example.com'
        }),
        matchPassword: sinon.stub().resolves(true),
        save: userSaveStub
      };
      
      userFindOneStub.resolves(mockUser);
      jwtSignStub.onFirstCall().returns('fake-token');
      jwtSignStub.onSecondCall().returns('fake-refresh-token');

      // Act
      await login(req, res, next);

      // Assert
      expect(res.status.calledWith(200)).to.be.true;
      expect(res.json.calledOnce).to.be.true;
      const responseData = res.json.args[0][0];
      expect(responseData.success).to.be.true;
      expect(responseData.token).to.equal('fake-token');
      expect(responseData.refreshToken).to.equal('fake-refresh-token');
      expect(responseData.user).to.exist;
      expect(userSaveStub.calledOnce).to.be.true;
    });
  });

  describe('register', () => {
    it('should return 400 if user already exists', async () => {
      // Arrange
      req.body = {
        email: 'existing@example.com',
        password: 'password123',
        fullName: 'Test User',
        department: 'IT'
      };
      
      userFindOneStub.resolves({ email: 'existing@example.com' });

      // Act
      await register(req, res, next);

      // Assert
      expect(next.calledOnce).to.be.true;
      expect(next.args[0][0]).to.be.an('error');
      expect(next.args[0][0].statusCode).to.equal(400);
      expect(next.args[0][0].message).to.equal('User with this email already exists');
    });

    it('should create new user and return tokens for valid data', async () => {
      // Arrange
      req.body = {
        email: 'new@example.com',
        password: 'password123',
        fullName: 'New User',
        department: 'IT'
      };
      
      userFindOneStub.resolves(null);
      
      const userId = new mongoose.Types.ObjectId();
      const mockNewUser = {
        _id: userId,
        email: 'new@example.com',
        fullName: 'New User',
        department: 'IT',
        toJSON: () => ({
          _id: userId,
          email: 'new@example.com',
          fullName: 'New User',
          department: 'IT'
        }),
        save: userSaveStub
      };
      
      userCreateStub.resolves(mockNewUser);
      jwtSignStub.onFirstCall().returns('fake-token');
      jwtSignStub.onSecondCall().returns('fake-refresh-token');

      // Act
      await register(req, res, next);

      // Assert
      expect(res.status.calledWith(201)).to.be.true;
      expect(res.json.calledOnce).to.be.true;
      const responseData = res.json.args[0][0];
      expect(responseData.success).to.be.true;
      expect(responseData.token).to.equal('fake-token');
      expect(responseData.refreshToken).to.equal('fake-refresh-token');
      expect(responseData.user).to.exist;
      expect(userSaveStub.calledOnce).to.be.true;
    });
  });
});
