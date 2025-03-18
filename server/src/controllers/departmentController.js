const asyncHandler = require('../middleware/asyncMiddleware');
const Department = require('../models/departmentModel');
const { createError } = require('../utils/errorUtils');
const logger = require('../utils/logger');
const mongoose = require('mongoose'); // Add this import

// Default departments for development
const defaultDepartments = [
  {
    _id: 'dept-1',
    name: 'ICT',
    description: 'Information and Communication Technology Department',
    active: true
  },
  {
    _id: 'dept-2',
    name: 'HR',
    description: 'Human Resources Department',
    active: true
  },
  {
    _id: 'dept-3',
    name: 'Finance',
    description: 'Finance Department',
    active: true
  },
  {
    _id: 'dept-4',
    name: 'Marketing',
    description: 'Marketing Department',
    active: true
  },
  {
    _id: 'dept-5',
    name: 'Operations',
    description: 'Operations Department',
    active: true
  },
  {
    _id: 'dept-6',
    name: 'Sales',
    description: 'Sales Department',
    active: true
  }
];

// @desc    Get all departments
// @route   GET /api/v1/departments
// @access  Public
exports.getDepartments = asyncHandler(async (req, res, next) => {
  try {
    // Development bypass when DB not connected
    if (process.env.NODE_ENV === 'development' && !mongoose.connection.readyState) {
      console.log('[DEV MODE] Returning default departments list');
      return res.status(200).json({
        success: true,
        count: defaultDepartments.length,
        data: defaultDepartments
      });
    }
    
    // Normal flow with DB
    const departments = await Department.find({ active: true }).sort('name');
    
    logger.info(`Retrieved ${departments.length} departments`);
    
    res.status(200).json({
      success: true,
      count: departments.length,
      data: departments
    });
  } catch (error) {
    logger.error(`Error retrieving departments: ${error.message}`, { error });
    return next(error);
  }
});

// @desc    Get single department
// @route   GET /api/v1/departments/:id
// @access  Public
exports.getDepartment = asyncHandler(async (req, res, next) => {
  try {
    const department = await Department.findById(req.params.id);
    
    if (!department) {
      return next(createError(404, `Department not found with id of ${req.params.id}`));
    }
    
    res.status(200).json({
      success: true,
      data: department
    });
  } catch (error) {
    logger.error(`Error retrieving department ${req.params.id}: ${error.message}`, { error });
    return next(error);
  }
});

// @desc    Create new department
// @route   POST /api/v1/departments
// @access  Admin
exports.createDepartment = asyncHandler(async (req, res, next) => {
  try {
    const department = await Department.create(req.body);
    
    logger.info(`Created new department: ${department.name}`);
    
    res.status(201).json({
      success: true,
      data: department
    });
  } catch (error) {
    logger.error(`Error creating department: ${error.message}`, { error });
    return next(error);
  }
});

// @desc    Update department
// @route   PUT /api/v1/departments/:id
// @access  Admin
exports.updateDepartment = asyncHandler(async (req, res, next) => {
  try {
    let department = await Department.findById(req.params.id);
    
    if (!department) {
      return next(createError(404, `Department not found with id of ${req.params.id}`));
    }
    
    department = await Department.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true
    });
    
    logger.info(`Updated department: ${department.name}`);
    
    res.status(200).json({
      success: true,
      data: department
    });
  } catch (error) {
    logger.error(`Error updating department ${req.params.id}: ${error.message}`, { error });
    return next(error);
  }
});

// @desc    Delete department (set inactive)
// @route   DELETE /api/v1/departments/:id
// @access  Admin
exports.deleteDepartment = asyncHandler(async (req, res, next) => {
  try {
    let department = await Department.findById(req.params.id);
    
    if (!department) {
      return next(createError(404, `Department not found with id of ${req.params.id}`));
    }
    
    // Set to inactive instead of deleting
    department = await Department.findByIdAndUpdate(
      req.params.id,
      { active: false },
      { new: true }
    );
    
    logger.info(`Deactivated department: ${department.name}`);
    
    res.status(200).json({
      success: true,
      data: {}
    });
  } catch (error) {
    logger.error(`Error deactivating department ${req.params.id}: ${error.message}`, { error });
    return next(error);
  }
});
