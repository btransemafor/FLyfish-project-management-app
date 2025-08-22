const jwt = require('jsonwebtoken'); 
require('dotenv').config(); 
// Generate AccessToken 
const generateToken = (time, [data]) => {
    return jwt.sign(data, process.env.JWT_SECRET_KEY, { expiresIn: '10m'});
}

const authenticateToken = (req, res, next) => {
    // Lay Token tren header
    const authHeader = req.headers['authorization']; // Bearer ...
    // Tach lay phan sau
    const token = authHeader?.split(" ")[1]; // Cần thêm ? để xử lý null;
    console.log('Token:', token);

    // Neu chua cung cap token trong request => 401
    if (!token) {
        return res.status(401).json({ message: "UnAuthorization: No Token Provided" });
    }

    // Verify ...
    jwt.verify(token, process.env.JWT_SECRET_KEY, (error, user) => {
        if (error) {
            if (error.name === "TokenExpiredError") {
                return res.status(401).json({ message: "Token has expired" });
            } else {
                return res.status(403).json({ message: "Invalid token" });
            }
        }
        req.user = user;
        console.log('Decoded user:', user);
        next();
    });
};


// middleware/authJwt.js
const authenticateTokenRefresh = (req, res, next) => {
    const { refreshToken } = req.body;

    if (!refreshToken) {
        return res.status(400).json({ message: "Refresh token required" });
    }

    jwt.verify(refreshToken, process.env.JWT_SECRET_KEY, (error, user) => {
        if (error) {
          
            return res.status(403).json({ message: "Invalid token", success: false});
            
        }
        req.user = user; 
        req.refreshToken = refreshToken; // Gắn vào req để controller dùng
        next();
    });
};

module.exports = {
    authenticateToken, 
    authenticateTokenRefresh
}