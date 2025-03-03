const express = require('express');
const router = express.Router(); 
const { createStripeAccount, deleteAccount, getStripeAccountId, getCompanyCountry, getCompanyCurrency } = require('../controllers/companyStripeController');
const authenticateToken = require('../middleware/authenticateToken');

router.post('/create-account',authenticateToken, createStripeAccount);
router.delete('/delete-account/:companyId', deleteAccount);
router.get('/stripe/account-id', authenticateToken, getStripeAccountId);
router.get('/company/country', authenticateToken, getCompanyCountry);
router.get('/company/currency', authenticateToken, getCompanyCurrency);

module.exports = router;