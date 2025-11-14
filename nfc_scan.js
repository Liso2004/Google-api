const readline = require("readline");
const axios = require("axios");

const API_URL = "http://localhost:5000/scan";
const COOLDOWN_MS = 2 * 60 * 1000; // 2 minutes

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

const lastScans = {};

console.log("🚀 NFC Clock-in Terminal Ready");
console.log("📡 Tap a card (or type UID)...\n");

rl.on("line", async (line) => {
  const uid = line.trim();
  if (!uid) return;

  const now = Date.now();
  const lastScan = lastScans[uid] || 0;

  if (now - lastScan < COOLDOWN_MS) {
    const remaining = Math.ceil((COOLDOWN_MS - (now - lastScan)) / 1000);
    console.log(`⏳ Wait ${remaining}s before scanning UID ${uid} again.\n`);
    return;
  }

  lastScans[uid] = now;

  try {
    const res = await axios.post(API_URL, { tag_uid: uid });
    const { owner_name, clockin_time, clockout_time, date, action } = res.data;
    console.log(
      `✅ ${owner_name} (UID: ${uid}) ${action} | Clock In: ${clockin_time || "-"} | Clock Out: ${clockout_time || "-"} | Date: ${date}\n`
    );
  } catch (err) {
    if (err.response?.data?.error) {
      console.error("❌ API Error:", err.response.data.error);
    } else {
      console.error("❌ Request failed:", err.message);
    }
  }

  console.log("📡 Tap next card:");
});
