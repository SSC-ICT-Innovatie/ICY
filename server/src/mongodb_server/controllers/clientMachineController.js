
const mongoose = require('mongoose');
const loadConfig = require("../../config");
const ClientMachine =  require('../models/clientMachine');


let config;

(async () => {
    try {
        config = await loadConfig();
        const mongodbUrl = `mongodb+srv://${config.DB_USRNAME}:${config.DB_PASS}@${config.DB_HOST}`;
        await mongoose.connect(mongodbUrl);
        console.log('Connected to MongoDB in clientMachineController');
    } catch (error) {
        console.error('Error initializing MongoDB in clientMachineController:', error);
    }
})();

const clientMachineController = {
   addClientMachine: async (req, res) => {
        try {
            const companyId = req.companyId;
            const clientMachineData = { ...req.body, company_id: companyId };
            console.log('Adding new client machine:', clientMachineData);

            const clientMachine = new ClientMachine(clientMachineData);
            const savedClientMachine = await clientMachine.save();
            console.log('New client machine added:', savedClientMachine);
            res.status(201).json(savedClientMachine);
        } catch (error) {
            console.error('Error in addClientMachine:', error);
            res.status(400).json({ message: error.message });
        }
    },

    getClientMachine: async (req, res) => {
        try {
            const { deviceId } = req.params;
            const companyId = req.companyId;
            console.log(`Fetching client machine. DeviceId: ${deviceId}, CompanyId: ${companyId}`);

            const clientMachine = await ClientMachine.findOne({ device_id: deviceId, company_id: companyId });

            if (!clientMachine) {
                console.log('Client machine not found');
                return res.status(404).json({ message: "Client machine not found" });
            }

            console.log('Client machine found:', clientMachine);
            res.json(clientMachine);
        } catch (error) {
            console.error('Error in getClientMachine:', error);
            res.status(500).json({ message: error.message });
        }
    },

    getAllClientMachines: async (req, res) => {
        try {
            const companyId = req.companyId;
            console.log(`Fetching client machines for company ID: ${companyId}`);

            const clientMachines = await ClientMachine.find({ company_id: companyId });

            console.log(`Found ${clientMachines.length} client machines`);
            res.json(clientMachines);
        } catch (error) {
            console.error('Error in getAllClientMachines:', error);
            res.status(500).json({ message: error.message });
        }
    },

    authClient: async (req, res) => {
        try {
            const { deviceId, companyRefId, key } = req.body;
            console.log(`Attempting to authenticate client. DeviceId: ${deviceId}, CompanyRefId: ${companyRefId}`);

            const clientMachine = await ClientMachine.findOne({ company_ref_id: companyRefId, machine_key: key });

            if (!clientMachine) {
                console.log('Authentication failed: No matching client machine found');
                return res.status(401).json({ message: "Authentication failed" });
            }

            console.log('Authentication successful');
            res.json({ message: "Authentication successful", clientMachine });
        } catch (error) {
            console.error('Error in authClient:', error);
            res.status(500).json({ message: error.message });
        }
    },

    updateClientMachine: async (req, res) => {
           try {
               const { deviceId } = req.params;
               const companyId = req.companyId;
               const updatedClientMachine = await ClientMachine.findOneAndUpdate(
                   { device_id: deviceId, company_id: companyId },
                   req.body,
                   { new: true, runValidators: true }
               );

               if (!updatedClientMachine) {
                   return res.status(404).json({ message: "Client machine not found" });
               }
               res.json(updatedClientMachine);
           } catch (error) {
               res.status(400).json({ message: error.message });
           }
       },

       deleteClientMachine: async (req, res) => {
           try {
               const {deviceId } = req.params;
               const companyId = req.companyId;
               const deletedClientMachine = await ClientMachine.findOneAndDelete({ device_id: deviceId, company_id: companyId });

               if (!deletedClientMachine) {
                   return res.status(404).json({ message: "Client machine not found" });
               }
               res.json({ message: "Client machine deleted successfully" });
           } catch (error) {
               res.status(500).json({ message: error.message });
           }
       },

       deleteClientMachines: async (req, res) => {
           try {
               const { deviceIds } = req.body;
               const companyId = req.companyId;

               console.log(`Attempting to delete devices: ${deviceIds} for company: ${companyId}`);

               const result = await ClientMachine.deleteMany({ device_id: { $in: deviceIds }, company_id: companyId });

               console.log(`Successfully deleted ${result.deletedCount} devices`);
               res.json({ message: `Successfully deleted ${result.deletedCount} devices` });
           } catch (error) {
               console.error('Error in deleteClientMachines:', error);
               res.status(400).json({ message: error.message });
           }
       },
};

module.exports = clientMachineController;
