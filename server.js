// Lightweight, zero-dependency local static server for BoviCare
const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = process.env.PORT || 3000;
const PUBLIC_DIR = __dirname;

// Simple zero-dependency .env loader for local development
function loadEnv() {
  const envPath = path.join(PUBLIC_DIR, '.env');
  if (fs.existsSync(envPath)) {
    try {
      const envLines = fs.readFileSync(envPath, 'utf8').split('\n');
      for (const line of envLines) {
        const trimmed = line.trim();
        if (!trimmed || trimmed.startsWith('#')) continue;
        const eqIdx = trimmed.indexOf('=');
        if (eqIdx !== -1) {
          const key = trimmed.slice(0, eqIdx).trim();
          const val = trimmed.slice(eqIdx + 1).trim().replace(/^['"]|['"]$/g, '');
          if (key) {
            process.env[key] = val;
          }
        }
      }
    } catch (e) {
      // Ignore .env read errors
    }
  }
}
loadEnv();

const MIME_TYPES = {
  '.html': 'text/html',
  '.css': 'text/css',
  '.js': 'text/javascript',
  '.json': 'application/json',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.webp': 'image/webp',
  '.svg': 'image/svg+xml'
};

function evaluateAssessmentPayload(payload, mlResult, hasImage) {
  const assessmentId = payload.assessment_id || `ASM-${Date.now().toString().slice(-6)}`;
  const now = new Date().toISOString();
  const bodyTemp = typeof payload.body_temp === 'number' ? payload.body_temp : parseFloat(payload.body_temp) || 38.6;
  const udderTemp = payload.udder_temp ? parseFloat(payload.udder_temp) : null;
  const quarters = Array.isArray(payload.quarters) ? payload.quarters : (payload.quarters ? [payload.quarters] : []);
  const milkAppearance = payload.milk_appearance || 'Normal';
  const swelling = payload.swelling || 'None';
  const cmtScore = payload.cmt_score || 'Negative';
  const milkingPain = payload.milking_pain || 'None';

  // Evaluate clinical severity based on National Mastitis Council criteria
  const hasSevereCmt = cmtScore.includes('3+');
  const hasModCmt = cmtScore.includes('1+') || cmtScore.includes('2+');
  const hasHighFever = bodyTemp >= 39.5;
  const hasClots = milkAppearance.includes('Clots') || milkAppearance.includes('Curds') || milkAppearance.includes('Flakes') || milkAppearance.includes('Discolored');
  const hasSevereSwelling = swelling.includes('Severe') || swelling.includes('Stone-Hard');
  const hasModSwelling = swelling.includes('Moderate') || swelling.includes('Mild') || swelling.includes('Firmness');

  let clinicalRisk = 'Low';
  if (hasSevereCmt || (hasHighFever && hasClots) || hasSevereSwelling) {
    clinicalRisk = 'High';
  } else if (hasModCmt || hasClots || hasModSwelling || bodyTemp > 39.2 || quarters.length > 0) {
    clinicalRisk = 'Moderate';
  }

  // Combined Risk determination
  let finalRisk = clinicalRisk;
  let predictionLabel = clinicalRisk === 'High' ? 'Clinical Mastitis Indicated' : (clinicalRisk === 'Moderate' ? 'Borderline / Monitor' : 'Healthy / Normal');
  let probability = null;
  let confidence = null;
  let normalProb = null;
  let mastitisProb = null;
  let status = hasImage ? 'completed' : 'completed_rules_only';

  if (hasImage) {
    if (mlResult && mlResult.success) {
      mastitisProb = mlResult.mastitis_probability ?? null;
      normalProb = mlResult.normal_probability ?? null;
      probability = mastitisProb;
      confidence = mlResult.confidence ?? null;

      // Synthesize image AI + clinical rules:
      if (mlResult.risk_tier === 'High' || clinicalRisk === 'High') {
        finalRisk = 'High';
        predictionLabel = mlResult.risk_tier === 'High' ? (mlResult.prediction_label || 'Mastitis Indicated') : 'Clinical Mastitis Indicated';
      } else if (mlResult.risk_tier === 'Moderate' || clinicalRisk === 'Moderate') {
        finalRisk = 'Moderate';
        predictionLabel = mlResult.prediction_label || (clinicalRisk === 'Moderate' ? 'Borderline / Monitor' : 'Mastitis Indicated (Early/Mild)');
      } else {
        finalRisk = 'Low';
        predictionLabel = 'Healthy / Normal';
      }
    } else {
      // Image was provided, but ML inference failed or was unavailable!
      // Do NOT default to Healthy / Normal!
      status = mlResult?.status || 'inference_failed';
      finalRisk = clinicalRisk !== 'Low' ? clinicalRisk : 'Inconclusive';
      predictionLabel = clinicalRisk !== 'Low' 
        ? `${clinicalRisk === 'High' ? 'Clinical Mastitis Indicated' : 'Borderline / Monitor'} (Image Inference Failed)` 
        : 'Inference Failed — Unable to Screen Image';
    }
  }

  // Identify missing information
  const missingInfo = [];
  if (!hasImage) {
    missingInfo.push('Udder / strip-cup photograph was not provided (MobileNetV2 computer vision screening unavailable)');
  } else if (!mlResult || !mlResult.success) {
    missingInfo.push(`Image inference could not complete: ${mlResult?.error || 'ML engine execution failed'}`);
  }
  if (!udderTemp) {
    missingInfo.push('Udder surface temperature was not recorded');
  }
  if (!payload.notes || payload.notes.trim().length === 0) {
    missingInfo.push('Milking behavior / cluster attachment history was omitted');
  }

  // Recommendations and follow-up guidance
  let recommendations = '';
  let vetFollowup = '';
  if (status === 'inference_failed' || status === 'model_unavailable' || status === 'invalid_input' || finalRisk === 'Inconclusive') {
    recommendations = 'Image screening could not be verified by the local AI engine. Inspect animal physically for teat hardness, heat, or abnormal foremilk.';
    vetFollowup = 'Consult herd veterinarian or re-capture a clear, well-lit photograph of the affected teat/quarter.';
  } else if (finalRisk === 'High') {
    recommendations = 'Isolate milk from bulk tank discard. Cease mechanical milking on affected quarters. Apply cold compress and prepare for prompt veterinary examination.';
    vetFollowup = 'Immediate veterinary review required within 12 hours. Do not initiate prescription intramammary antibiotics without licensed veterinary prescription.';
  } else if (finalRisk === 'Moderate') {
    recommendations = 'Repeat CMT paddle reaction during the next evening milking. Inspect fore-milk strip-cup closely for fine flakes. Verify milking machine vacuum calibration (42 kPa).';
    vetFollowup = 'Monitor closely for 24-48 hours. Request clinical tele-triage if swelling hardens or rectal temperature rises above 39.2°C.';
  } else {
    recommendations = 'Udder tissue, fore-milk appearance, and physiological measurements within normal baseline. Maintain post-milking teat dip disinfection.';
    vetFollowup = 'Routine herd surveillance. Re-assess if milk yield drops unexpectedly or behavioral restlessness occurs.';
  }

  return {
    success: true,
    status: status,
    assessment_id: assessmentId,
    created_at: now,
    cow_name: payload.cow_name || 'Bovine Patient',
    cow_tag: payload.cow_tag || 'Tag N/A',
    prediction: predictionLabel,
    prediction_label: predictionLabel,
    risk_category: finalRisk,
    risk_tier: finalRisk,
    probability: probability,
    mastitis_probability: mastitisProb,
    normal_probability: normalProb,
    confidence: confidence,
    model_architecture: hasImage ? 'MobileNetV2 (1.00_224) via ONNX Runtime' : 'Standardized Clinical Rules Engine (NMC / VCI)',
    model_version: hasImage ? '1.00_224 ONNX' : 'NMC/VCI Standard 2026',
    model_info: {
      image_model: hasImage ? 'MobileNetV2 (1.00_224) converted from TFLite 2.21.0 to ONNX' : 'No udder/strip-cup photograph provided',
      tabular_model_status: 'EfficientNetB0+SVM and XGBoost models are not trained/serialized in this codebase; clinical rules applied based on standardized CMT and vitals'
    },
    observations: {
      body_temp: `${bodyTemp}°C (${bodyTemp > 39.2 ? 'Elevated Fever' : 'Normal'})`,
      udder_temp: udderTemp ? `${udderTemp}°C` : 'Not recorded',
      affected_quarters: quarters.length > 0 ? quarters.join(', ') : 'None flagged',
      milk_appearance: milkAppearance,
      udder_swelling: swelling,
      cmt_score: cmtScore,
      milking_pain: milkingPain,
      has_image: hasImage
    },
    missing_information: missingInfo,
    recommendations: recommendations,
    veterinary_followup: vetFollowup,
    disclaimer: 'Experimental AI screening tool. Assists but does not replace licensed veterinary clinical evaluation. Do not administer prescription drugs based solely on unconfirmed screening output.'
  };
}

const server = http.createServer((req, res) => {
  const reqPath = decodeURI(req.url.split('?')[0]);

  // Dynamic runtime configuration endpoint (Centralized publishable config)
  if (reqPath === '/env-config.js') {
    loadEnv();
    const supabaseUrl = process.env.SUPABASE_URL || process.env.BOVICARE_SUPABASE_URL || '';
    const supabaseAnonKey = process.env.SUPABASE_ANON_KEY || process.env.BOVICARE_SUPABASE_ANON_KEY || '';
    const configJs = `// Auto-generated runtime environment configuration
window.ENV_SUPABASE_URL = ${JSON.stringify(supabaseUrl)};
window.ENV_SUPABASE_ANON_KEY = ${JSON.stringify(supabaseAnonKey)};
`;
    res.writeHead(200, {
      'Content-Type': 'text/javascript',
      'Cache-Control': 'no-store, no-cache, must-revalidate'
    });
    res.end(configJs, 'utf-8');
    return;
  }

  // Bhashini Language & Voice Services Proxy (Protects private keys on server side)
  if (reqPath === '/api/bhashini/config' && req.method === 'GET') {
    const isConfigured = Boolean(process.env.BHASHINI_API_KEY && process.env.BHASHINI_USER_ID);
    const configData = {
      success: true,
      configured: isConfigured,
      supportedLanguages: [
        { code: 'en', name: 'English', native: 'English' },
        { code: 'mr', name: 'Marathi', native: 'मराठी' },
        { code: 'hi', name: 'Hindi', native: 'हिन्दी' }
      ],
      supportedPairs: ['en-mr', 'mr-en', 'en-hi', 'hi-en', 'mr-hi', 'hi-mr'],
      speechLocales: {
        en: 'en-IN',
        mr: 'mr-IN',
        hi: 'hi-IN'
      },
      services: {
        translation: true,
        speechRecognition: true,
        textToSpeech: true
      },
      notice: isConfigured
        ? 'Bhashini National Language Translation Mission API is active.'
        : 'Running in high-performance localized mode with browser speech synthesis & verified Indic terminology.'
    };
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify(configData));
    return;
  }

  // Clinical Entity Token Protection for Bhashini Machine Translation
  function protectClinicalTokens(text) {
    if (!text || typeof text !== 'string') return { protectedText: text, tokenMap: new Map() };
    const tokenMap = new Map();
    let counter = 0;
    // Protect ear tags, temperatures, dosages, withdrawal hours, and quarter codes
    const tokenRegex = /(\b(?:VCI|MH|TAG|COW)[A-Z0-9\-_]{2,20}\b)|(\b\d{1,2}(?:\.\d)?\s*°?[Cc]\b)|(\b\d+\s*(?:mg|ml|hours?|hrs?|h|days?)\b)|(\b(?:q12h|q24h|IM|SC|LC)\b)|(\b(?:LF|RF|LR|RR)\b)/gi;
    const protectedText = text.replace(tokenRegex, (match) => {
      const key = `__BV_CLIN_${counter++}__`;
      tokenMap.set(key, match);
      return key;
    });
    return { protectedText, tokenMap };
  }

  function restoreClinicalTokens(text, tokenMap) {
    if (!text || !tokenMap || tokenMap.size === 0) return text;
    let restored = text;
    tokenMap.forEach((val, key) => {
      const escaped = key.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&');
      const fuzzyRegex = new RegExp(escaped.split('').join('\\s*'), 'gi');
      restored = restored.replace(fuzzyRegex, val);
    });
    return restored;
  }

  if (reqPath === '/api/bhashini/translate' && req.method === 'POST') {
    let body = '';
    req.on('data', chunk => { body += chunk; });
    req.on('end', () => {
      try {
        const payload = JSON.parse(body || '{}');
        const { text, sourceLang = 'en', targetLang = 'mr' } = payload;
        if (!text || typeof text !== 'string') {
          res.writeHead(400, { 'Content-Type': 'application/json' });
          return res.end(JSON.stringify({ error: 'Missing or invalid text parameter' }));
        }

        const validLangs = ['en', 'mr', 'hi'];
        if (!validLangs.includes(sourceLang) || !validLangs.includes(targetLang)) {
          res.writeHead(400, { 'Content-Type': 'application/json' });
          return res.end(JSON.stringify({ error: `Unsupported language pair: ${sourceLang} -> ${targetLang}. Supported: en, mr, hi.` }));
        }

        if (sourceLang === targetLang) {
          res.writeHead(200, { 'Content-Type': 'application/json' });
          return res.end(JSON.stringify({ success: true, translatedText: text, sourceLang, targetLang }));
        }

        const apiKey = process.env.BHASHINI_API_KEY;
        const userId = process.env.BHASHINI_USER_ID;

        // Protect critical clinical entities before MT processing
        const { protectedText, tokenMap } = protectClinicalTokens(text);

        if (!apiKey || !userId) {
          // Graceful fallback to verified client-side dictionary without faking live translation
          res.writeHead(200, { 'Content-Type': 'application/json' });
          return res.end(JSON.stringify({
            success: false,
            fallback: true,
            message: 'Bhashini server credentials not configured. Utilizing verified local Indic clinical vocabulary.',
            sourceLang,
            targetLang,
            originalText: text,
            protectedTokensCount: tokenMap.size
          }));
        }

        // Forward to official Bhashini Dhruva pipeline endpoint with protected tokens
        const https = require('https');
        const bhashiniReqBody = JSON.stringify({
          pipelineTasks: [
            {
              taskType: 'translation',
              config: {
                language: {
                  sourceLanguage: sourceLang,
                  targetLanguage: targetLang
                }
              }
            }
          ],
          inputData: {
            input: [{ source: protectedText }]
          }
        });

        const sendDhruvaRequest = (retriesLeft = 1) => {
          const bReq = https.request({
            hostname: 'dhruva-api.bhashini.gov.in',
            port: 443,
            path: '/services/inference/pipeline',
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              'Authorization': apiKey,
              'userID': userId,
              'ulcaApiKey': process.env.BHASHINI_INFERENCE_API_KEY || apiKey
            },
            timeout: 7000
          }, (bRes) => {
            let bData = '';
            bRes.on('data', c => { bData += c; });
            bRes.on('end', () => {
              try {
                if (bRes.statusCode >= 500 && retriesLeft > 0) {
                  return setTimeout(() => sendDhruvaRequest(retriesLeft - 1), 600);
                }
                const bJson = JSON.parse(bData);
                const rawTarget = bJson?.pipelineResponse?.[0]?.output?.[0]?.target;
                if (rawTarget) {
                  const finalTranslated = restoreClinicalTokens(rawTarget, tokenMap);
                  res.writeHead(200, { 'Content-Type': 'application/json' });
                  return res.end(JSON.stringify({
                    success: true,
                    translatedText: finalTranslated,
                    sourceLang,
                    targetLang,
                    protectedTokensCount: tokenMap.size,
                    provider: 'bhashini-dhruva'
                  }));
                }
                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ success: false, fallback: true, raw: bJson }));
              } catch (err) {
                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ success: false, fallback: true, error: err.message }));
              }
            });
          });

          bReq.on('timeout', () => {
            bReq.destroy();
            if (retriesLeft > 0) {
              return setTimeout(() => sendDhruvaRequest(retriesLeft - 1), 800);
            }
            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ success: false, fallback: true, error: 'Bhashini pipeline timeout' }));
          });

          bReq.on('error', (e) => {
            if (retriesLeft > 0) {
              return setTimeout(() => sendDhruvaRequest(retriesLeft - 1), 800);
            }
            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ success: false, fallback: true, error: e.message }));
          });

          bReq.write(bhashiniReqBody);
          bReq.end();
        };

        sendDhruvaRequest(1);
      } catch (e) {
        res.writeHead(400, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Invalid JSON request payload' }));
      }
    });
    return;
  }

  // Local AI Mastitis Screening & Assessment Endpoint (Protected, Local MobileNetV2 ONNX Runtime)
  if (req.method === 'POST' && (reqPath === '/api/ai-screen' || reqPath === '/api/ai-assessment')) {
    let body = '';
    req.on('data', chunk => { body += chunk; });
    req.on('end', () => {
      try {
        const payload = JSON.parse(body || '{}');
        const hasImage = Boolean(payload.image_base64 || payload.image_path);
        let targetImagePath = '';

        if (payload.image_base64) {
          const scratchDir = path.join(PUBLIC_DIR, 'scratch');
          if (!fs.existsSync(scratchDir)) fs.mkdirSync(scratchDir, { recursive: true });
          targetImagePath = path.join(scratchDir, `screen_${Date.now()}.jpg`);
          const base64Data = payload.image_base64.replace(/^data:image\/\w+;base64,/, '');
          fs.writeFileSync(targetImagePath, Buffer.from(base64Data, 'base64'));
        } else if (payload.image_path) {
          const resolved = path.resolve(PUBLIC_DIR, payload.image_path);
          if (!resolved.startsWith(PUBLIC_DIR)) {
            res.writeHead(403, { 'Content-Type': 'application/json' });
            return res.end(JSON.stringify({ error: 'Access denied: path outside project' }));
          }
          targetImagePath = resolved;
        }

        const isFullAssessment = Boolean(
          payload.cow_id || payload.cow_name || payload.body_temp || payload.cmt_score ||
          payload.milk_appearance || payload.swelling || payload.quarters
        );

        if (hasImage && targetImagePath) {
          const { execFile } = require('child_process');
          execFile('python3', [path.join(PUBLIC_DIR, 'ml_inference.py'), targetImagePath], (err, stdout) => {
            // Cleanup temp file if created
            if (payload.image_base64 && fs.existsSync(targetImagePath)) {
              try { fs.unlinkSync(targetImagePath); } catch (_) {}
            }

            let mlOutput = null;
            if (stdout) {
              try {
                mlOutput = JSON.parse(stdout);
              } catch (_) {}
            }

            if (err || !mlOutput || !mlOutput.success) {
              const errStatus = mlOutput?.status || (err ? 'inference_failure' : 'invalid_input');
              const errMsg = mlOutput?.error || err?.message || 'Inference execution failure';

              if (isFullAssessment) {
                const failRes = evaluateAssessmentPayload(payload, { success: false, status: errStatus, error: errMsg }, true);
                res.writeHead(200, { 'Content-Type': 'application/json' });
                return res.end(JSON.stringify(failRes));
              }

              // Direct image screening response for failed inference
              res.writeHead(200, { 'Content-Type': 'application/json' });
              return res.end(JSON.stringify(mlOutput || {
                success: false,
                status: errStatus,
                error: errMsg,
                risk_tier: 'Inconclusive',
                prediction_label: 'Inference Failed'
              }));
            }

            if (isFullAssessment) {
              const fullResult = evaluateAssessmentPayload(payload, mlOutput, true);
              res.writeHead(200, { 'Content-Type': 'application/json' });
              return res.end(JSON.stringify(fullResult));
            }

            // Direct image screening response
            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify(mlOutput));
          });
        } else if (isFullAssessment) {
          // Assessment without image: evaluate defensible clinical rules
          const rulesResult = evaluateAssessmentPayload(payload, null, false);
          res.writeHead(200, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify(rulesResult));
        } else {
          res.writeHead(400, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({
            success: false,
            status: 'invalid_input',
            error: 'No image or assessment payload provided.'
          }));
        }
      } catch (e) {
        res.writeHead(400, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Invalid JSON payload' }));
      }
    });
    return;
  }

  let filePath = path.join(PUBLIC_DIR, reqPath);
  if (reqPath === '/' || reqPath === '/landing') {
    filePath = path.join(PUBLIC_DIR, 'landing.html');
  } else if (reqPath === '/login' || reqPath === '/signin') {
    filePath = path.join(PUBLIC_DIR, 'login.html');
  } else if (reqPath === '/app') {
    filePath = path.join(PUBLIC_DIR, 'index.html');
  } else if (reqPath === '/admin') {
    filePath = path.join(PUBLIC_DIR, 'admin.html');
  } else if (filePath === PUBLIC_DIR || filePath.endsWith('/')) {
    filePath = path.join(filePath, 'landing.html');
  }

  const ext = path.extname(filePath).toLowerCase();
  const contentType = MIME_TYPES[ext] || 'application/octet-stream';

  fs.readFile(filePath, (err, content) => {
    if (err) {
      if (err.code === 'ENOENT') {
        res.writeHead(404, { 'Content-Type': 'text/plain' });
        res.end('404 Not Found');
      } else {
        res.writeHead(500, { 'Content-Type': 'text/plain' });
        res.end('500 Internal Server Error: ' + err.code);
      }
    } else {
      res.writeHead(200, { 'Content-Type': contentType });
      res.end(content, 'utf-8');
    }
  });
});

server.listen(PORT, () => {
  console.log(`BoviCare prototype running at http://localhost:${PORT}`);
});
