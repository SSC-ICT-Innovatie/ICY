// const socketIo = require('socket.io');

// let io;

// module.exports = {
//   init: (server) => {
//     io = socketIo(server, {
//       cors: {
//         origin: "*",
//         methods: ["GET", "POST"]
//       }
//     });
//     console.log('Socket.IO initialized');
//     return io;
//   },
//   getIo: () => {
//     if (!io) {
//       throw new Error('Socket.IO not initialized!');
//     }
//     return io;
//   }
// };