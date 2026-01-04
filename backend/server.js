import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import { GoogleGenerativeAI } from "@google/generative-ai";

dotenv.config();
const app = express();
app.use(cors());
app.use(express.json());

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

// TEMP SESSION (anonymous)
const userSession = {
  stressLevel: null,
  profile: null,
};

// 🧩 stress → profile mapping via Gemini
async function generateProfile(stress) {
  const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });

  const prompt = `
You are creating an anonymous emotional profile for a student.

Stress Level: ${stress}

Rules:
- Generate ONE anonymous name (soft, human, non-gendered)
- ONE emoji that represents the emotion
- ONE line personality description
- Do NOT mention stress word directly
- Calm, supportive tone

Return ONLY JSON:
{
  "name": "",
  "emoji": "",
  "description": ""
}
`;

  const result = await model.generateContent(prompt);
  const text = result.response.text();

  return JSON.parse(text);
}

// 🔥 SAVE STRESS LEVEL
app.post("/stress", async (req, res) => {
  const { stressLevel } = req.body;

  userSession.stressLevel = stressLevel;

  const profile = await generateProfile(stressLevel);
  userSession.profile = profile;

  res.json({
    success: true,
    stressLevel,
    profile,
  });
});

// 🔁 GET SYNCED DATA (USE EVERYWHERE)
app.get("/session", (req, res) => {
  res.json(userSession);
});

app.listen(5000, () => {
  console.log("🔥 Backend running on http://localhost:5000");
});
