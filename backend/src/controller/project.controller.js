const ProjectService = require('../services/project.services'); 
const createProject = (req,res) => {
    // const user = req.user; 
    const dataRaw = req.body; 
/*     const name = dataRaw.name; 
    const description = dataRaw.description; 
    const startDate = dataRaw.startDate; 
    const endDate = dataRaw.endDate; 
    const leader_id = dataRaw.leader_id; 
    const status = dataRaw.status; */
    const  {
        name, 
        description, 
        startDate, 
        endDate, 
        leader_id, 
        status
    } = req.body; 

    const data = {name, description, startDate, endDate, leader_id, status};

    if (!name) {
        return res.status(400).json({message: 'Vui lòng cung cấp đủ thông tin'}); 
    }

    ProjectService.createProject(data, (error, result) => {
        if (error) {
            res.status(500).json(error); 
        }
        return res.status(201).json(result); 
    })
}

const getProjects = (req,res) => {
    const user = req.user; 
    const user_id = user.userId; 

    console.log('USER có id', user_id , ' yêu cầu get project');


    // Get tham so ( neu so )
    const is_leader = req.query.is_leader; 
    const data = {user_id, is_leader};
    ProjectService.getProjects(data, (error, result) => {
        if (error) {
            res.status(500).json(error);
        }
        return res.status(200).json(result); 
    })
}

const addMemberToProject = (req, res) => {
    const user = req.user; 
    const leader_id = user.userId;
    const user_id = req.body.user_id;
    const project_id = req.body.project_id;
    const data = { leader_id, user_id, project_id };

    if (!user_id || !project_id || !leader_id) {
        
        return res.status(400).json({ message: "Missing Dataa" });
    }

    ProjectService.addMemberToProject(data, (error, result) => {
        if (error) {
            return res.status(500).json(error);
        } else if (result.message === 'Project does not exist') {
            return res.status(404).json(result);
        } else if (result.message === "You do not have permission to add members to this project") {
            return res.status(403).json(result);
        } else if (result.message === 'User is already in the project') {
            return res.status(409).json(result);
        }
        
        return res.status(201).json(result);
    });
};


const fetchMemberOfProject = (req,res) => {
    const user = req.user;
    const user_id = user.userId; 
    const project_id = req.params.projectId; 

    const data = {user_id, project_id}
    ProjectService.fetchMembersOfProject(data,(err,result) => {
        if (err) {
            return res.status(500).json(err); 
        }
        else if (result.success == false && result.message.includes('not found'))
        {
            return res.status(404).json(result); 
        }
        else if (result.success == false && result.message.includes('Not Permission')) {
            return res.status(403).json(result); 
        }
        return res.status(200).json(result); 
    })

}

const fetchProjectById = (req,res) => {
    const user = req.user; 
    const user_id = user.userId; 
    const project_id = req.params.project_id; 
    console.log(project_id, user_id); 
    const data = {user_id, project_id}; 

    ProjectService.fetchProjectById(data, (error, result) => {
        if (error ) {
            return res.status(500).json(error); 
        }
        else if (result.message.includes('Not Permission')) {
            return res.status(403).json(result); 
        }
        else if (result.message.includes('Not Found')) {
            return res.status(404).json(result); 
        }
        return res.status(200).json(result)
    })


}

module.exports = {
    createProject, 
    getProjects, 
    addMemberToProject, 
    fetchMemberOfProject, 
    fetchProjectById
}