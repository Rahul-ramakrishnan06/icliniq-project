const { Pool } = require("pg");

const pool = new Pool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  port: process.env.DB_PORT || 5432, 
  max: 10,                     
  idleTimeoutMillis: 30000,  
  connectionTimeoutMillis: 20000      
});

(async () => {
  try {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        email VARCHAR(255) UNIQUE NOT NULL
      );
    `);
    console.log("Users table is ready");
  } catch (err) {
    console.error("Error creating users table:", err);
  }
})();

module.exports = pool;
