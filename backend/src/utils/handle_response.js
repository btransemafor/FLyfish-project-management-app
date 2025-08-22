const handleServiceResponse = (res, error, result) => {
  if (error) {
    return res.status(500).json({
      error: error.message || "Internal server error",
      code: "INTERNAL_ERROR"
    });
  }

  if (result && result.success === false) {
    const msg = result.message || "";

    if (msg.toLowerCase().includes("not found")) {
      return res.status(404).json({ ...result, code: "NOT_FOUND", details: msg });
    } 
    
    if (
      msg.toLowerCase().includes("not have permission") || 
      msg.toLowerCase().includes("have permission") || 
      msg.toLowerCase().includes("not permission")
    ) {
      return res.status(403).json({ ...result, code: "FORBIDDEN", details: msg });
    }

    // Thêm check riêng cho message “không thể xóa chính mình”
    if (msg.includes("không thể xóa chính mình")) {
      return res.status(403).json({ ...result, code: "SELF_DELETE_FORBIDDEN", details: msg });
    }

    if (msg.toLowerCase().includes("invalid status value")) {
      return res.status(400).json({ ...result, code: "BAD_REQUEST", details: msg });
    }

    // Default
    return res.status(400).json({ ...result, code: "BAD_REQUEST", details: msg });
  }

  return res.status(200).json({ ...result, code: "SUCCESS", message: result.message || "Operation completed successfully" });
};

module.exports = handleServiceResponse; 