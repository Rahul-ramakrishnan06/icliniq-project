const express = require("express");
const pool = require("./db");
const router = express.Router();
const { Worker } = require("worker_threads");
const os = require("os");

router.get("/health", (req, res) => {
  res.status(200).json({ status: "ok" });
});
router.get("/users", async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM users");
    res.json(result.rows); 
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.post("/users", async (req, res) => {
  try {
    const { name, email } = req.body;
    const result = await pool.query(
      "INSERT INTO users (name, email) VALUES ($1, $2) RETURNING id, name, email",
      [name, email]
    );
    res.status(201).json(result.rows[0]); 
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


function runWorker(durationMs, loadPercent) {
  return new Promise((resolve, reject) => {
    const worker = new Worker(
      `
      const { parentPort, workerData } = require("worker_threads");
      const { duration, load } = workerData;

      const end = Date.now() + duration;
      const busyTime = (load / 100) * 100;   // ms busy
      const idleTime = 100 - busyTime;       // ms idle

      function spin(ms) {
        const start = Date.now();
        while (Date.now() - start < ms) {}
      }

      while (Date.now() < end) {
        const start = Date.now();
        while (Date.now() - start < busyTime) {
          Math.sqrt(Math.random() * 1000);
        }
        if (idleTime > 0) spin(idleTime);
      }

      parentPort.postMessage("done");
    `,
      { eval: true, workerData: { duration: durationMs, load: loadPercent } }
    );

    worker.once("message", resolve);
    worker.once("error", reject);
    worker.once("exit", (code) => {
      if (code !== 0) reject(new Error(`Worker exited with code ${code}`));
    });
  });
}

router.get("/cpu-load", async (req, res) => {
  const duration = parseInt(req.query.duration || "5000", 10); 
  const load = parseInt(req.query.load || "85", 10); 
  const cores = os.cpus().length;

  try {
    await Promise.all(
      Array.from({ length: cores }, () => runWorker(duration, load))
    );
    res.json({
      message: `CPU load ~${load}% on ${cores} cores for ${duration / 1000}s`
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
