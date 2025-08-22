const e = require("express");
const authService = require("../services/auth.services");
const authenticateTokenRefresh = require("../middleware/authJwt");
const register = (req, res) => {
  const userData = req.body;
  console.log(typeof userData);
  const data = {
    email: userData.email,
    password: userData.password,
    name: userData.name,
    phone: userData.phone,
    avatar: userData.avatar,
    birthday: userData.birthday,
  };

  authService.register(data, (error, result) => {
    if (error) {
      return res.status(500).json({ message: "Server Error Internal" });
    } else if (!result.success) {
      return res.status(409).json(result);
    }
    return res.status(200).json(result);
  });
};

const login = (req, res) => {
  const { email, password } = req.body;

  console.log(email);

  authService.login({ email, password }, (error, result) => {
    if (error) {
      console.log("Loi gi nua di troi");
      return res.status(500).json({ message: "Internal Server Error" });
    }

    if (!result.success) {
      // Lỗi xác thực tài khoản, ví dụ: sai email hoặc mật khẩu
      return res.status(401).json({ message: "Unauthorized" });
    }

    // Đăng nhập thành công
    return res.status(200).json(result);
  });
};

const requireAccessToken = (req, res) => {
  const user_id = req.user.userId;
  console.log('[USER] ', user_id);

  const data = {
    user_id: user_id,
  };

  if (!user_id) {
    return res.status(400).json({ message: "bad request" });
  }

  authService.requireAccessToken(data, (error, result) => {
    if (error) {
      return res.status(500).json(error);
    } else if (!result.success) {
      if (result.message.includes("not found")) {
        return res.status(404).json(result);
      }
    }
    return res.status(200).json(result);
  });
};

const logOut = (req, res) => {
  const user_id = req.user.userId;
  console.log(user_id)
  const data = {
    user_id: user_id
  }
  authService.logOut(data, (error, result) => {
    if (error) {
      return res.status(500).json(error);
    } else if (!result.success) {
      if (result.message.includes("not found")) {
        return res.status(404).json(result);
      }
    }
    return res.status(200).json(result);
  });
};

module.exports = {
  register,
  login,
  requireAccessToken,
  logOut
};
