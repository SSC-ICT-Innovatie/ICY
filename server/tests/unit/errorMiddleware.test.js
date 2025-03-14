const chai = require('chai');
const sinon = require('sinon');
const { expect } = chai;
const { notFound, errorHandler } = require('../../src/middleware/errorMiddleware');

describe('Error Middleware Tests', () => {
  describe('notFound middleware', () => {
    it('should set status to 404 and pass error to next middleware', () => {
      // Arrange
      const req = {
        originalUrl: '/not-existing-route'
      };
      const res = {
        status: sinon.stub().returnsThis(),
      };
      const next = sinon.spy();

      // Act
      notFound(req, res, next);

      // Assert
      expect(res.status.calledWith(404)).to.be.true;
      expect(next.calledOnce).to.be.true;
      const error = next.args[0][0];
      expect(error).to.be.an('error');
      expect(error.message).to.include('/not-existing-route');
    });
  });

  describe('errorHandler middleware', () => {
    let consoleErrorStub;

    beforeEach(() => {
      // Stub console.error to avoid cluttering test output
      consoleErrorStub = sinon.stub(console, 'error');
    });

    afterEach(() => {
      consoleErrorStub.restore();
    });

    it('should set status from error and return correct JSON response', () => {
      // Arrange
      const error = new Error('Test error message');
      error.statusCode = 400;
      error.stack = 'Test stack trace';

      const req = {
        originalUrl: '/test-url',
        method: 'GET',
        ip: '127.0.0.1'
      };
      const res = {
        statusCode: error.statusCode,
        status: sinon.stub().returnsThis(),
        json: sinon.spy()
      };
      const next = sinon.spy();

      // Store original NODE_ENV
      const originalNodeEnv = process.env.NODE_ENV;
      process.env.NODE_ENV = 'development';

      // Act
      errorHandler(error, req, res, next);

      // Assert
      expect(res.status.calledWith(400)).to.be.true;
      expect(res.json.calledOnce).to.be.true;
      const responseBody = res.json.args[0][0];
      expect(responseBody.message).to.equal('Test error message');
      expect(responseBody.stack).to.equal('Test stack trace');

      // Restore NODE_ENV
      process.env.NODE_ENV = originalNodeEnv;
    });

    it('should hide stack trace in production', () => {
      // Arrange
      const error = new Error('Test error message');
      error.statusCode = 400;
      error.stack = 'Test stack trace';

      const req = {
        originalUrl: '/test-url',
        method: 'GET',
        ip: '127.0.0.1'
      };
      const res = {
        statusCode: error.statusCode,
        status: sinon.stub().returnsThis(),
        json: sinon.spy()
      };
      const next = sinon.spy();

      // Set NODE_ENV to production
      const originalNodeEnv = process.env.NODE_ENV;
      process.env.NODE_ENV = 'production';

      // Act
      errorHandler(error, req, res, next);

      // Assert
      expect(res.status.calledWith(400)).to.be.true;
      expect(res.json.calledOnce).to.be.true;
      const responseBody = res.json.args[0][0];
      expect(responseBody.message).to.equal('Test error message');
      expect(responseBody.stack).to.equal('🥞'); // Production stack emoji

      // Restore NODE_ENV
      process.env.NODE_ENV = originalNodeEnv;
    });

    it('should use default 500 status when res.statusCode is 200', () => {
      // Arrange
      const error = new Error('Internal server error');
      const req = {
        originalUrl: '/test-url',
        method: 'GET',
        ip: '127.0.0.1'
      };
      const res = {
        statusCode: 200, // Default status
        status: sinon.stub().returnsThis(),
        json: sinon.spy()
      };
      const next = sinon.spy();

      // Act
      errorHandler(error, req, res, next);

      // Assert
      expect(res.status.calledWith(500)).to.be.true;
    });
  });
});
