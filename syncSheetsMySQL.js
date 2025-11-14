// syncSheetsMySQL.js
require("dotenv").config();
const { google } = require("googleapis");
const mysql = require("mysql2/promise");

// =============== ENV CHECK ===============
const requiredVars = [
  "GOOGLE_SERVICE_ACCOUNT_KEY",
  "GOOGLE_SHEET_ID",
  "DB_HOST",
  "DB_USER",
  "DB_PASS",
  "DB_NAME",
];
const missing = requiredVars.filter(v => !process.env[v]);
if (missing.length) {
  console.error("❌ Missing env vars:", missing.join(", "));
  process.exit(1);
}

// =============== SETUP ===============
const auth = new google.auth.GoogleAuth({
  keyFile: process.env.GOOGLE_SERVICE_ACCOUNT_KEY,
  scopes: ["https://www.googleapis.com/auth/spreadsheets"],
});
const sheets = google.sheets({ version: "v4", auth });

const dbConfig = {
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
};

// =============== HELPERS ===============
function normalizeTime(t) {
  if (!t) return null;
  const parts = t.split(":").map(p => p.trim());
  if (parts.length === 1) return null;
  const hh = parts[0].padStart(2, "0");
  const mm = (parts[1] || "00").padStart(2, "0");
  const ss = (parts[2] || "00").padStart(2, "0");
  return `${hh}:${mm}:${ss}`;
}

async function getSheetData() {
  const spreadsheetId = process.env.GOOGLE_SHEET_ID;
  const range = "Sheet1!A2:G"; // A-G: Name, ID, Clock-In, Clock-Out, Status, Type, Date
  try {
    const res = await sheets.spreadsheets.values.get({ spreadsheetId, range });
    const rows = res.data.values || [];
    if (!rows.length) return [];

    return rows.map(r => ({
      name: r[0] ? String(r[0]).trim() : null,
      employee_id: r[1] ? parseInt(r[1], 10) : null,
      clockin_time: normalizeTime(r[2]),
      clockout_time: normalizeTime(r[3]),
      status: r[4] || "OnTime",
      type: r[5] || "Work",
      date: r[6] || new Date().toISOString().split("T")[0],
    }));
  } catch (err) {
    console.error("❌ Error reading from Google Sheets:", err.message);
    return [];
  }
}

// =============== SYNC LOGIC ===============
async function syncToMySQL(rows) {
  let db;
  try {
    db = await mysql.createConnection(dbConfig);
  } catch (err) {
    console.error("❌ Could not connect to MySQL:", err.message);
    return;
  }

  for (const row of rows) {
    if (!row.employee_id) continue;

    try {
      await db.query(
        `INSERT INTO record_backups (employee_id, clockin_time, clockout_time, status, type, date)
         VALUES (?, ?, ?, ?, ?, ?)
         ON DUPLICATE KEY UPDATE
           clockin_time = VALUES(clockin_time),
           clockout_time = VALUES(clockout_time),
           status = VALUES(status),
           type = VALUES(type),
           date = VALUES(date)`,
        [
          row.employee_id,
          row.clockin_time,
          row.clockout_time,
          row.status,
          row.type,
          row.date,
        ]
      );
      console.log(`✅ Synced Employee ID ${row.employee_id}`);
    } catch (err) {
      console.error(`❌ Sync failed for ID ${row.employee_id}:`, err.message);
    }
  }

  await db.end();
  console.log("✅ All Google Sheet data synced to MySQL!");
}

// =============== RUN EVERY MINUTE ===============
async function runSync() {
  console.log("🔄 Starting 1-minute sync cycle...");
  const rows = await getSheetData();
  if (rows.length > 0) await syncToMySQL(rows);
  else console.log("⚠️ No data found in sheet.");
}

// Run immediately, then every 60 seconds
runSync();
setInterval(runSync, 60 * 1000);
