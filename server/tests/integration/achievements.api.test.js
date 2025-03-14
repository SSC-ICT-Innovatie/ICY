const chai = require('chai');
const chaiHttp = require('chai-http');
const { expect } = chai;
const sinon = require('sinon');
const jwt = require('jsonwebtoken');
const mongoose = require('mongoose');
const { app } = require('../../src/index'); // adjust path if needed
const { Badge, UserBadge } = require('../../src/models/achievementModel');
const User = require('../../src/models/userModel');

chai.use(chaiHttp);

describe('Achievements API Integration Tests', () => {
  let testUser;
  let testToken;
  let badgeIdToTest;

  before(async () => {
    // Setup test user
    testUser = new User({
      username: 'testuser',
      email: 'test.achievements@example.com',
      password: 'password123',
      fullName: 'Test User',
      department: 'Test Department',
    });
    await testUser.save();

    // Create test token
    testToken = jwt.sign(
      { id: testUser._id },
      process.env.JWT_SECRET || 'test_secret',
      { expiresIn: '1h' }
    );

    // Create test badge
    const testBadge = new Badge({
      title: 'Test Badge',
      description: 'A test badge for testing',
      icon: 'star',
      color: '#FF5733',
      xpReward: 100,
      conditions: {
        type: 'login_count',
        count: 5,
      },
    });
    const savedBadge = await testBadge.save();
    badgeIdToTest = savedBadge._id;

    // Assign badge to user
    const userBadge = new UserBadge({
      userId: testUser._id,
      badgeId: badgeIdToTest,
      dateEarned: new Date(),
      xpAwarded: 100,
    });
    await userBadge.save();
  });

  after(async () => {
    // Cleanup test data
    await User.deleteMany({ email: 'test.achievements@example.com' });
    await Badge.deleteMany({ title: 'Test Badge' });
    await UserBadge.deleteMany({ userId: testUser._id });
  });

  describe('GET /api/v1/achievements/badges', () => {
    it('should return all badges', async () => {
      const res = await chai
        .request(app)
        .get('/api/v1/achievements/badges')
        .set('Authorization', `Bearer ${testToken}`);

      expect(res).to.have.status(200);
      expect(res.body.success).to.be.true;
      expect(res.body.data).to.be.an('array');
      expect(res.body.data.length).to.be.greaterThan(0);

      // Check badge properties
      const badge = res.body.data.find(
        (b) => b._id.toString() === badgeIdToTest.toString()
      );
      expect(badge).to.exist;
      expect(badge.title).to.equal('Test Badge');
      expect(badge.description).to.equal('A test badge for testing');
      expect(badge.icon).to.equal('star');
      expect(badge.color).to.equal('#FF5733');
    });

    it('should require authentication', async () => {
      const res = await chai.request(app).get('/api/v1/achievements/badges');

      expect(res).to.have.status(401);
      expect(res.body.message).to.include('Not authorized');
    });
  });

  describe('GET /api/v1/achievements/badges/my', () => {
    it('should return user badges', async () => {
      const res = await chai
        .request(app)
        .get('/api/v1/achievements/badges/my')
        .set('Authorization', `Bearer ${testToken}`);

      expect(res).to.have.status(200);
      expect(res.body.success).to.be.true;
      expect(res.body.data).to.have.property('earned');
      expect(res.body.data).to.have.property('inProgress');
      
      // Check user has the test badge
      expect(res.body.data.earned).to.be.an('array');
      expect(res.body.data.earned.length).to.be.greaterThan(0);
      
      const earnedBadge = res.body.data.earned.find(
        (b) => b.badgeId._id.toString() === badgeIdToTest.toString()
      );
      expect(earnedBadge).to.exist;
      expect(earnedBadge.badgeId.title).to.equal('Test Badge');
      expect(earnedBadge.xpAwarded).to.equal(100);
    });
  });
});
