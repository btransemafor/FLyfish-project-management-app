const StatService = require("../services/stats.services");
const getStatsOverviewUser = (req, res) => {
  const user_id = req.user.userId;
  console.log(user_id);

  const data = {
    user_id: user_id,
  };

  StatService.getStatsOverviewUser(data, (error, result) => {
    if (error) {
      return res.status(500).json(error);
    } else if (result.success == false) {
      if (result.message.includes("not found")) {
        return res.status(404).json(result);
      } else if (result.message.includes("not permission")) {
        return res.status(403).json(result);
      }
    }
    return res.status(200).json(result);
  });
};

module.exports = {
    getStatsOverviewUser
}