import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY");
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

serve(async (req) => {
  try {
    const { pdfUrl, action } = await req.json();
    
    if (!pdfUrl || !action) {
      return new Response(JSON.stringify({ error: "Missing pdfUrl or action" }), { status: 400, headers: { "Content-Type": "application/json" } });
    }

    if (!GEMINI_API_KEY) {
      return new Response(JSON.stringify({ error: "Server missing GEMINI_API_KEY secret configuration." }), { status: 500, headers: { "Content-Type": "application/json" } });
    }

    const urlParts = pdfUrl.split("/pdfs/");
    if (urlParts.length < 2) {
      return new Response(JSON.stringify({ error: "Invalid PDF storage URL format." }), { status: 400, headers: { "Content-Type": "application/json" } });
    }
    const filePath = decodeURIComponent(urlParts[1]);

    const supabaseAdmin = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
    const { data: fileData, error: downloadError } = await supabaseAdmin.storage
      .from("pdfs")
      .download(filePath);

    if (downloadError || !fileData) {
      return new Response(JSON.stringify({ error: `Failed to download PDF: ${downloadError?.message}` }), { status: 400, headers: { "Content-Type": "application/json" } });
    }

    const arrayBuffer = await fileData.arrayBuffer();
    const uint8Array = new Uint8Array(arrayBuffer);
    let binaryString = "";
    const chunkSize = 8192;
    for (let i = 0; i < uint8Array.length; i += chunkSize) {
      const chunk = uint8Array.subarray(i, i + chunkSize);
      binaryString += String.fromCharCode(...chunk);
    }
    const base64Pdf = btoa(binaryString);

    let promptText = "";
    if (action === "notes") {
      promptText = `Analyze this PDF document thoroughly and return ONLY raw, valid JSON matching this exact schema with no extra text or markdown blocks:
      {
        "title": "Document Title",
        "sections": [
          {
            "heading": "...",
            "subheading": "...",
            "keyPoints": ["..."],
            "stickyNotes": ["..."],
            "keywords": ["..."]
          }
        ]
      }`;
    } else if (action === "exam") {
      promptText = `Create an exam prep quiz based entirely on this PDF. Return ONLY raw, valid JSON matching this exact schema with no extra text or markdown blocks:
      {
        "questions": [
          {
            "question": "...",
            "options": ["A", "B", "C", "D"],
            "answer": "Exact correct option string"
          }
        ]
      }`;
    } else if (action === "flashcards") {
      promptText = `Generate study flashcards from this PDF. Return ONLY raw, valid JSON matching this exact schema with no extra text or markdown blocks:
      {
        "flashcards": [
          {
            "front": "Question or concept",
            "back": "Detailed answer or explanation"
          }
        ]
      }`;
    }

    const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-3.6-flash:generateContent?key=${GEMINI_API_KEY}`;
    const geminiPayload = {
      contents: [
        {
          parts: [
            { text: promptText },
            { inlineData: { mimeType: "application/pdf", data: base64Pdf } }
          ]
        }
      ],
      generationConfig: { responseMimeType: "application/json" }
    };

    const apiResponse = await fetch(geminiUrl, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(geminiPayload)
    });

    const data = await apiResponse.json();
    
    if (!apiResponse.ok) {
      return new Response(JSON.stringify({ error: `Gemini API Error: ${JSON.stringify(data)}` }), { status: 500, headers: { "Content-Type": "application/json" } });
    }

    let rawText = data.candidates?.[0]?.content?.parts?.[0]?.text;
    if (!rawText) {
      return new Response(JSON.stringify({ error: "Empty response text from model" }), { status: 500, headers: { "Content-Type": "application/json" } });
    }

    // Aggressive cleaning to strip any markdown code blocks
    rawText = rawText.replace(/```json/gi, "").replace(/```/g, "").trim();
    
    // Fallback: extract the first '{' and last '}' if there is surrounding text
    const firstBrace = rawText.indexOf('{');
    const lastBrace = rawText.lastIndexOf('}');
    if (firstBrace !== -1 && lastBrace !== -1) {
      rawText = rawText.substring(firstBrace, lastBrace + 1);
    }

    const parsedJson = JSON.parse(rawText);

    return new Response(JSON.stringify(parsedJson), {
      headers: { "Content-Type": "application/json" }
    });

  } catch (error) {
    return new Response(JSON.stringify({ error: `Edge Function Exception: ${error.message}` }), { status: 500, headers: { "Content-Type": "application/json" } });
  }
});
