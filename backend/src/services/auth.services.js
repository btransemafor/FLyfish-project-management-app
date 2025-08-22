const db = require("../models/index");
const crypto = require("crypto");
const jwt = require("jsonwebtoken");
require("dotenv").config();
// Generate AccessToken
const generateToken = (time, data = {}) => {
  return jwt.sign(data, process.env.JWT_SECRET_KEY, { expiresIn: `${time}` });
};

function hashPassword(password, digest = "sha512") {
  const salt = crypto.randomBytes(32).toString("base64");
  const iterations = 10000;
  const keylen = 64;

  const hash = crypto
    .pbkdf2Sync(password, salt, iterations, keylen, digest)
    .toString("hex");

  return {
    salt,
    hash,
    iterations,
  };
}

function isPasswordCorrect(
  savedHash,
  savedSalt,
  savedIterations,
  passwordAttempt,
  digest = "sha512"
) {
  const keylen = 64;

  const hashAttempt = crypto
    .pbkdf2Sync(passwordAttempt, savedSalt, savedIterations, keylen, digest)
    .toString("hex");

  return savedHash === hashAttempt;
}

const register = async (data, callback) => {
  try {
    const email = data.email;
    const phone = data.phone;
    const password = data.password;
    const name = data.name;
    const avatar = data.avatar;
    const birthday = data.birthday;

    console.log(name);

    // Kiem tra email có tồn tại chưa ?
    const isExistUser = await db.User.findOne({ where: { email } });
    console.log(isExistUser);
    if (isExistUser) {
      return callback(null, {
        success: false,
        message: "email or phone đã tồn tại",
      });
    }

    console.log("Hash Password");

    // Nếu chưa tồn tại thì salt password
    const hashedPassword = hashPassword(password);
    // Save DB
    console.log(hashedPassword.salt);

    const newUser = await db.User.create({
      email: email,
      hash: hashedPassword.hash,
      salt: hashedPassword.salt,
      iterations: hashedPassword.iterations,
      phone: phone,
      birthday: birthday,
      avatar:
        avatar ||
        "https://res.cloudinary.com/dehehzz2t/image/upload/v1754380108/z6875846732207_42d1b4240a1cb3a27f03f8ccf4b45030_ap9iai.jpg",
      fullname: name || "No Name",
    });

    const result = {
      id: newUser.id,
      phone: newUser.phone,
      email: newUser.email,
      name: newUser.fullname,
      avatar: newUser.avatar,
      birthday: newUser.birthday,
      active: newUser.active ?? false,
    };

    return callback(null, {
      success: true,
      message: "Created New user Successfully",
      data: result,
    });
  } catch (error) {
    return callback(error);
  }
};

const login = async ({ email, password }, callback) => {
  try {
    const user = await db.User.findOne({ where: { email } });

    console.log(email);

    if (!user) {
      return callback(null, {
        message: "Email or password is not valid",
        success: false,
      });
    }

    if (!isPasswordCorrect(user.hash, user.salt, user.iterations, password)) {
      return callback(null, {
        message: "Email or password is not valid!",
        success: false,
      });
    }
    console.log("password khop: ", user.id);

    await db.Token.destroy({
      where: {
        userId: user.id,
      },
    });

    // Generate tokens
    const accessToken = generateToken("1m", { userId: user.id });
    const refreshToken = generateToken("30d", { userId: user.id });

    // Get today
    const expired = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000);

    await db.Token.create({
      token: refreshToken,
      expiresAt: expired,
      isRevoked: false,
      userId: user.id,
    });
    // await db.RefreshToken.create({ token: refreshToken, userId: user.id });
    console.log("Helloo.....");

    const result = {
      id: user.id,
      phone: user.phone,
      email: user.email,
      avatar: user.avatar,
      name: user.fullname,
      birthday: user.birthday,
      accessToken,
      refreshToken,
    };

    console.log(result.accessToken);

    return callback(null, {
      message: "Login Successfully",
      data: result,
      success: true,
    });
  } catch (error) {
    return callback(error);
  }
};

const requireAccessToken = async (data, callback) => {
  const user_id = data.user_id;
  console.log('[USER] : ', user_id);
  const user = db.User.findByPk(user_id);
  if (!user) {
    return callback(null, {
      message: "user not found",
      success: false
    });
  }

  /// Generate AccessToken
  const accessToken = generateToken("10m", { userId: user_id });

  return callback(null, {
    message: "required new accesstoken successfully",
    success: true,
    data: accessToken,
  });
};

const logOut = async (data, callback) => {
  const user_id = data.user_id;
  console.log("User_id", user_id)
  const user = await db.User.findByPk(user_id);  // thêm await
  if (!user) {
    return callback(null, {
      message: "user not found",
    });
  }

  console.log("userId before destroy:", user_id);
  await db.Token.destroy({
    where: {
      userId: user_id,
    },
  });

  // Có thể trả về callback thành công nếu cần
  return callback(null, {
    message: "Logout successful",
    success: true
  });
};

module.exports = {
  register,
  login,
  requireAccessToken,
  logOut,
};
