const express = require("express");
// const pool = require("./db");
const router = express.Router();

// Health check route
router.get("/health", (req, res) => {
  res.status(200).json({ status: "ok" });
});

// Get all users
// router.get("/users", async (req, res) => {
//   try {
//     const [rows] = await pool.query("SELECT * FROM users");
//     res.json(rows);
//   } catch (err) {
//     res.status(500).json({ error: err.message });
//   }
// });

// // Create a new user
// router.post("/users", async (req, res) => {
//   try {
//     const { name, email } = req.body;
//     const [result] = await pool.query(
//       "INSERT INTO users (name, email) VALUES (?, ?)",
//       [name, email]
//     );
//     res.status(201).json({ id: result.insertId, name, email });
//   } catch (err) {
//     res.status(500).json({ error: err.message });
//   }
// });

module.exports = router;
