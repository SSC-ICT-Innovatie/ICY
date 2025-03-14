const express = require('express');
const {
  getSurveys,
  getDailySurveys,
  getSurveyById,
  submitSurveyResponse,
  updateSurveyProgress
} = require('../controllers/surveyController');
const { protect } = require('../middleware/authMiddleware');

const router = express.Router();

router.use(protect);

router.route('/')
  .get(getSurveys);

router.route('/daily')
  .get(getDailySurveys);

router.route('/:id')
  .get(getSurveyById);

router.route('/:id/submit')
  .post(submitSurveyResponse);

router.route('/:id/progress')
  .post(updateSurveyProgress);

module.exports = router;
