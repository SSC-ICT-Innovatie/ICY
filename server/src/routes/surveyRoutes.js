const express = require('express');
const {
  getSurveys,
  getDailySurveys,
  getSurveyById,
  createSurvey,
  submitSurveyResponse,
  updateSurveyProgress
} = require('../controllers/surveyController');
const { protect, authorize } = require('../middleware/authMiddleware');

const router = express.Router();

router.use(protect);

// Public routes (for authenticated users)
router.route('/')
  .get(getSurveys)
  .post(authorize('admin'), createSurvey); // Add POST endpoint with admin authorization

router.route('/daily')
  .get(getDailySurveys);

router.route('/:id')
  .get(getSurveyById);

router.route('/:id/submit')
  .post(submitSurveyResponse);

router.route('/:id/progress')
  .post(updateSurveyProgress);

module.exports = router;
