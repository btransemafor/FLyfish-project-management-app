const client = require("../config/redis-conf");
const db = require("../models/index");
const Fuse = require('fuse.js');

const searchUser = async (data, callback) => {
  try {
    const keyword = data.keyword.trim();
    console.log("KeyWord: ", keyword);

    const redisKey = `search:user:${keyword}`;
    const cached = await client.get(redisKey);

    if (cached) {
      console.log("Cache hit");
      return callback(null, {
        data: JSON.parse(cached),
        message: "Search Successfully (from cache)",
      });
    }

    // 1. Lấy danh sách user từ DB
    const users = await db.User.findAll({
      attributes: ["id", "fullname", "email", "avatar", "birthday"],
    });

    const userResult = users.map((item) => ({
      id: item.id,
      name: item.fullname,
      email: item.email,
      avatar: item.avatar,
      birthday: item.birthday,
    }));

    // 2. Cấu hình Fuse.js
    const options = {
      keys: ["fullname", "email"],
      threshold: 0.4, // nhỏ hơn thì khớp chặt hơn
      ignoreLocation: true,
    };

    const fuse = new Fuse(userResult, options);
    const result = fuse.search(keyword).map(res => res.item); // chỉ lấy item thay vì full object

    console.log("Search result:", result);

    // 3. Lưu kết quả vào Redis cache (TTL: 60 giây)
    await client.setEx(redisKey, 60, JSON.stringify(result));

    // 4. Trả về client
    return callback(null, {
      data: result,
      message: "Search Successfully",
    });
  } catch (error) {
    return callback(error);
  }
};

module.exports = {
  searchUser,
};
