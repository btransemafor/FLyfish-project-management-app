const express = require('express'); 
const cors = require('cors'); 
const {authenticateToken} = require('./middleware/authJwt');
const router = require('./routers/index');
const {unless} = require('express-unless');
const path = require('path');

const app = express(); 
app.use(cors()); 
/* const blockedOrigins = [
  'http://localhost:3000',
  'http://127.0.0.1:3000',
  'http://127.0.0.1:5500',
];

app.use(cors({
  origin: function (origin, callback) {
    if (!origin) return callback(null, true);
    if (blockedOrigins.includes(origin)) {
      return callback(new Error('Blocked by CORS policy'), false);
    }
    return callback(null, true);
  },
})); */

app.use(express.json()); 


// Load Database 
const db = require('./models');

const client = require('./config/redis-conf'); 
client; 

app.use('/uploads', express.static(path.join(__dirname, './uploads')));


authenticateToken.unless = unless; 
app.use(authenticateToken.unless({
    path: [
        { url: "/api/auth/login", methods: ["POST"] }, 
        /// { url: "/api/auth/logout", methods: ["GET"] },
        { url: "/api/auth/register", methods: ["POST"] },
        { url: "/api/auth/request-new-accessToken", methods: ["POST"]}
    ]
}))

app.use('/api', router)
app.get('/', (req, res) => {
    res.send('<h1>Welcome to omgnice</h1>');
})
//app.use('/uploads', express.static(path.join(__dirname, './uploads')));




module.exports = app; 