require("dotenv").config();
const express = require("express");
const cors = require("cors");
const mysql = require("mysql2/promise");
const { google } = require("googleapis");
const cron = require("node-cron");

const app = express();
app.use(cors());
app.use(express.json());

// =========================
// ENVIRONMENT & DB SETUP
// =========================
if (!process.env.GOOGLE_SERVICE_ACCOUNT_KEY || !process.env.GOOGLE_SHEET_ID) {
  console.error("❌ Missing GOOGLE_SERVICE_ACCOUNT_KEY or GOOGLE_SHEET_ID in .env");
  process.exit(1);
}

const dbConfig = {
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
};

// =========================
// GOOGLE SHEETS SETUP
// =========================
const auth = new google.auth.GoogleAuth({
  keyFile: process.env.GOOGLE_SERVICE_ACCOUNT_KEY,
  scopes: ["https://www.googleapis.com/auth/spreadsheets"],
});
const sheets = google.sheets({ version: "v4", auth });
const SHEET_ID = process.env.GOOGLE_SHEET_ID;
const SHEET_NAME = "Sheet1";

// =========================
// GOOGLE SHEET HELPERS
// =========================
async function ensureHeaders() {
  const headers = ["Full Name", "Employee ID", "Clock In", "Clock Out", "Date"];
  try {
    const res = await sheets.spreadsheets.values.get({
      spreadsheetId: SHEET_ID,
      range: `${SHEET_NAME}!A1:E1`,
    });
    const current = res.data.values?.[0] || [];
    if (current.length === 0 || current.some((v) => !v)) {
      await sheets.spreadsheets.values.update({
        spreadsheetId: SHEET_ID,
        range: `${SHEET_NAME}!A1:E1`,
        valueInputOption: "USER_ENTERED",
        requestBody: { values: [headers] },
      });
      console.log("🛠️ Header row restored.");
    }
  } catch (err) {
    console.error("❌ Failed to verify/restore headers:", err.message);
  }
}

async function findRowIndexByEmployeeId(employee_id) {
  const result = await sheets.spreadsheets.values.get({
    spreadsheetId: SHEET_ID,
    range: `${SHEET_NAME}!A2:E`,
  });
  const rows = result.data.values || [];
  const rowIndex = rows.findIndex((r) => r[1] == employee_id);
  return rowIndex >= 0 ? rowIndex + 2 : null; // +2 for header offset
}

async function upsertSheetRow(full_name, employee_id, clockin_time, clockout_time, date) {
  await ensureHeaders();
  const rowIndex = await findRowIndexByEmployeeId(employee_id);
  const values = [full_name, employee_id, clockin_time || "", clockout_time || "", date || ""];

  if (rowIndex) {
    await sheets.spreadsheets.values.update({
      spreadsheetId: SHEET_ID,
      range: `${SHEET_NAME}!A${rowIndex}:E${rowIndex}`,
      valueInputOption: "USER_ENTERED",
      requestBody: { values: [values] },
    });
  } else {
    await sheets.spreadsheets.values.append({
      spreadsheetId: SHEET_ID,
      range: `${SHEET_NAME}!A2:E`,
      valueInputOption: "USER_ENTERED",
      requestBody: { values: [values] },
    });
  }
}

// =========================
// CRON: CLEAR SHEET DAILY
// =========================
cron.schedule(
  "0 0 * * *",
  async () => {
    console.log("🌙 Daily reset triggered:", new Date().toLocaleString());
    try {
      await ensureHeaders();
      await sheets.spreadsheets.values.clear({
        spreadsheetId: SHEET_ID,
        range: `${SHEET_NAME}!A2:E`,
      });
      console.log("✅ Sheet cleared below header.");
    } catch (err) {
      console.error("❌ Sheet clear error:", err.message);
    }
  },
  { timezone: "Africa/Johannesburg" }
);

// =========================
// /SCAN (NFC CLOCK-IN/CLOCK-OUT)
// =========================
app.post("/scan", async (req, res) => {
  const { tag_uid } = req.body;
  if (!tag_uid) return res.status(400).json({ error: "tag_uid required" });

  let db;
  try {
    db = await mysql.createConnection(dbConfig);

    const [tagRows] = await db.execute(
      "SELECT employee_id, owner_name FROM nfctag_storage WHERE tag_uid = ?",
      [tag_uid]
    );

    if (tagRows.length === 0) {
      await db.end();
      return res.status(404).json({ error: `No employee linked to tag UID ${tag_uid}` });
    }

    const { employee_id, owner_name } = tagRows[0];
    const now = new Date();
    const date = now.toLocaleDateString("en-CA", { timeZone: "Africa/Johannesburg" });
    const time = now.toLocaleTimeString("en-GB", { hour12: false });

    // Check if employee already clocked in today
    const [recordRows] = await db.execute(
      "SELECT clockin_time, clockout_time FROM record_backups WHERE employee_id=? AND date=?",
      [employee_id, date]
    );

    let clockin_time = null;
    let clockout_time = null;
    let action = "";

    if (recordRows.length === 0) {
      // First tap → clock in
      clockin_time = time;
      await db.execute(
        "INSERT INTO record_backups (employee_id, full_name, clockin_time, date) VALUES (?, ?, ?, ?)",
        [employee_id, owner_name, clockin_time, date]
      );
      action = "clocked in";
    } else if (recordRows[0].clockout_time === null || recordRows[0].clockout_time === "") {
      // Second tap → clock out
      clockin_time = recordRows[0].clockin_time;
      clockout_time = time;
      await db.execute(
        "UPDATE record_backups SET clockout_time=? WHERE employee_id=? AND date=?",
        [clockout_time, employee_id, date]
      );
      action = "clocked out";
    } else {
      // Already clocked out
      clockin_time = recordRows[0].clockin_time;
      clockout_time = recordRows[0].clockout_time;
      action = "already clocked out";
    }

    // Update Google Sheet
    await upsertSheetRow(owner_name, employee_id, clockin_time, clockout_time, date);

    await db.end();
    res.json({ ok: true, employee_id, owner_name, clockin_time, clockout_time, date, action });
  } catch (err) {
    if (db) await db.end();
    console.error("❌ NFC Scan error:", err.message);
    res.status(500).json({ error: "Internal server error" });
  }
});

// =========================
// START SERVER
// =========================
const port = process.env.PORT || 5000;
app.listen(port, () => console.log(`🚀 Attendance API running on http://localhost:${port}`));
