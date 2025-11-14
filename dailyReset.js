require("dotenv").config();
const { google } = require("googleapis");
const cron = require("node-cron");

const SHEET_ID = process.env.GOOGLE_SHEET_ID;
const SHEET_NAME = process.env.GOOGLE_SHEET_NAME || "Sheet1";
const TIMEZONE = "Africa/Johannesburg";

// ============================
// Auth Setup
// ============================
function buildAuth() {
  if (!process.env.GOOGLE_SERVICE_ACCOUNT_KEY) {
    throw new Error("Missing GOOGLE_SERVICE_ACCOUNT_KEY in .env");
  }

  // Handle inline JSON or key file path
  if (process.env.GOOGLE_SERVICE_ACCOUNT_KEY.trim().startsWith("{")) {
    const creds = JSON.parse(process.env.GOOGLE_SERVICE_ACCOUNT_KEY);
    return new google.auth.GoogleAuth({
      credentials: creds,
      scopes: ["https://www.googleapis.com/auth/spreadsheets"],
    });
  }

  return new google.auth.GoogleAuth({
    keyFile: process.env.GOOGLE_SERVICE_ACCOUNT_KEY,
    scopes: ["https://www.googleapis.com/auth/spreadsheets"],
  });
}

const auth = buildAuth();
const sheets = google.sheets({ version: "v4", auth });

// ============================
// Helper: Ensure header row exists
// ============================
async function ensureHeaders() {
  const headers = ["Name", "Employee ID", "Clock In", "Clock Out", "Status", "Type", "Date"];
  try {
    const res = await sheets.spreadsheets.values.get({
      spreadsheetId: SHEET_ID,
      range: `${SHEET_NAME}!A1:G1`,
    });

    const row = res.data.values?.[0] || [];
    if (row.length === 0 || row.some((v) => !v)) {
      await sheets.spreadsheets.values.update({
        spreadsheetId: SHEET_ID,
        range: `${SHEET_NAME}!A1:G1`,
        valueInputOption: "USER_ENTERED",
        requestBody: { values: [headers] },
      });
      console.log("🛠️ Header row restored.");
    }
  } catch (err) {
    console.error("❌ Failed to verify/restore headers:", err.message);
  }
}

// ============================
// Function: Clear sheet below header
// ============================
async function clearBelowHeader() {
  try {
    await ensureHeaders(); // Ensure headers exist first

    const res = await sheets.spreadsheets.values.get({
      spreadsheetId: SHEET_ID,
      range: `${SHEET_NAME}!A:A`,
    });

    const rowCount = res.data.values ? res.data.values.length : 1;
    if (rowCount > 1) {
      await sheets.spreadsheets.values.clear({
        spreadsheetId: SHEET_ID,
        range: `${SHEET_NAME}!A2:Z`,
      });
      console.log("✅ Cleared all data below header at:", new Date().toLocaleString());
    } else {
      console.log("ℹ️ Nothing to clear (only header present).");
    }
  } catch (err) {
    console.error("❌ Error clearing sheet:", err.message);
  }
}

// ============================
// Cron Schedules
// ============================

// 1️⃣ Daily full reset at midnight
cron.schedule(
  "0 0 * * *",
  async () => {
    console.log("🌙 Midnight daily reset triggered:", new Date().toLocaleString());
    await clearBelowHeader();
  },
  { timezone: TIMEZONE }
);

// 2️⃣ Hourly cleanup (1AM–11PM)
cron.schedule(
  "0 1-23 * * *",
  async () => {
    console.log("🕒 Hourly cleanup triggered:", new Date().toLocaleString());
    await clearBelowHeader();
  },
  { timezone: TIMEZONE }
);

console.log("✅ Google Sheets clear jobs scheduled (daily + hourly, header preserved).");
