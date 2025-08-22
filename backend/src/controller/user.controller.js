const UserService = require('../services/user.services'); 

const searchUser = (req,res) => {
    const keyword = req.query.keyword; 

    const user = req.user; 
    const user_id = user.userId; 
    

    const data = {keyword,user_id}; 

    UserService.searchUser(data, (err,result) => {
        if (err) {
            return res.status(500).json(err); 
        }
        else {
            return res.status(200).json(result);
        }
    })
}

module.exports = {
    searchUser
}