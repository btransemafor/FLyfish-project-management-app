const jwt = require('jsonwebtoken'); 
const generateOTPRaw = (length) => {
    const digit = '0123456789'; 
    let otp = ''; 
    for (let i = 0; i < length; i++) {
        // Random index [0-9]
        const index = Math.floor(Math.random() * digit.length); 
        otp += digit[index]; 
    }
    return otp; 
}

const encodeOTP = (otpRaw) => {
    const otpEncode = jwt.sign(otpRaw, 'otp-security', {
        'expiresIn': '1m', 
    })
    return otpEncode; 
}
module.exports = {generateOTPRaw, encodeOTP}