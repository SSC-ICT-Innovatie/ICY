const chai = require('chai');
const { expect } = chai;
const sinon = require('sinon');
const { createError } = require('../../../src/utils/errorUtils');
const User = require('../../../src/models/userModel');
const { Badge } = require('../../../src/models/achievementModel');
const { getUserBadges } = require('../../../src/controllers/achievementController');

describe('Achievement Controller Unit Tests', () => {
  describe('getUserBadges', () => {
    let req, res, next;

    beforeEach(() => {
      req = {
        user: { id: 'userId' },
      };
      res = {
        status: sinon.stub().returnsThis(),
        json: sinon.spy(),
      };
      next = sinon.spy();
    });

    afterEach(() => {
      sinon.restore();
    });

    it('should calculate progress for in-progress badges', async () => {
      const user = {
        _id: 'userId',
        stats: {
          surveysCompleted: 5,
        },
      };

      const allBadges = [
        { _id: 'badge1', conditions: { stat: 'surveysCompleted', target: 10 } },
        { _id: 'badge2', conditions: { stat: 'streak.current', target: 5 } },
      ];

      const earnedBadges = [];

      sinon.stub(User, 'findById').resolves(user);
      sinon.stub(Badge, 'find').resolves(allBadges);
      sinon.stub(require('../../../src/models/achievementModel').UserBadge, 'find').resolves(earnedBadges);

      await getUserBadges(req, res, next);

      expect(res.status.calledWith(200)).to.be.true;
      expect(res.json.calledOnce).to.be.true;

      const response = res.json.firstCall.args[0];
      const inProgress = response.data.inProgress;

      expect(inProgress).to.have.lengthOf(2);
      expect(inProgress[0].progress).to.equal(50); // 5 / 10 * 100
      expect(inProgress[1].progress).to.equal(0); // user.stats.streak is undefined
    });
  });
});

