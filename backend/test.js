const otpGenerator = require('otp-generator')
// Generate a 6-digit numeric OTP
// const otp = otpGenerator.generate(6, { upperCaseAlphabets: false, specialChars: false });

//console.log('Generated OTP:', otp);
const speakeasy = require('speakeasy');
const jwt = require('jsonwebtoken'); 
require('dotenv').config(); 
// Generate a Time-based OTP (TOTP)
const otp = speakeasy.totp({
  secret: 'your-secret-key', // Replace with a secure secret
  encoding: 'base32'
});
console.log('Generated OTP:', otp);
/* 
function generateOTP(length) {
  const digits = '0123456789';
  let otp = '';
  for (let i = 0; i < length; i++) {
    otp += digits[Math.floor(Math.random() * digits.length)];
  }
  return otp;
}
const otp = generateOTP(6); // Generate a 6-digit OTP
console.log('Generated OTP:', otp); */

console.log(Math.floor(Math.random() * 10))
// Math.floor() => Round down to the nearest whole number 
/* console.log(Math.floor(3.5)) // 3 
Math.random() // Generate random a floating point number between 0 and 1 
console.log('Generate random a floating point number between 0 and 1: ', Math.floor(Math.random()*10)); 

 */
/* 
const generateOTP = (length) => {
    let otp = ''; 
    const digit = '0123456789'; 
    for (let i = 0; i < length; i++) {
        // Objective: random index [0-9]
        const index = Math.floor(Math.random() * digit.length);  // floating point number 0 - 1 
        otp += digit[index]
    }
    return otp; 
}

console.log(generateOTP(10)); 

// Create payload
const payload = {
  userId: 123,
  name: "Alice",
  role: "admin"
};


const token = jwt.sign(payload, process.env.JWT_SECRET_KEY, {
  algorithm: 'HS256', 
  expiresIn: '30s',
  issuer: 'my-app'
});

console.log(token); 

// Verify Token 

// Them header vao token 
const verify = jwt.verify(token,process.env.JWT_SECRET_KEY); 

if (verify) {
    console.log('Verify Successfully'); 
}
else {
    console.log('Failed')
} */

const Sequelize = require('sequelize'); 
const sequelize = new Sequelize(
  process.env.DB_DATABASE || 'todo_db',
  process.env.DB_USERNAME || 'your_username',
  process.env.DB_PASSWORD || 'your_password',
  {
    dialect: 'postgres',
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    logging: false,
    dialectOptions: {
      ssl: process.env.DB_SSL === 'true' ? { require: true, rejectUnauthorized: false } : false,
      clientMinMessages: 'notice',
    },
  }
);

// Khoi tao user model 

const User = require('../backend/src/models/user.model'); 

const user = new User()

