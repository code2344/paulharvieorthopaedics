#!/usr/bin/env zsh
set -euo pipefail

cd /Users/ruben_sutton29/paulharvieorthopaedics

mkdir -p hip-surgery/assets \
  hip-surgery/total-hip-replacement \
  hip-surgery/anterior-approach-total-hip-replacement \
  hip-surgery/bikini-incision-total-hip-replacement \
  hip-surgery/patient-specific-total-hip-replacement \
  hip-surgery/bilateral-total-hip-replacement \
  hip-surgery/ceramic-hip-resurfacing

cp hip-surgery/pages/dev-pages.css hip-surgery/assets/hip-pages.css
cp hip-surgery/pages/dev-pages.js hip-surgery/assets/hip-pages.js

for slug in total-hip-replacement anterior-approach-total-hip-replacement bikini-incision-total-hip-replacement patient-specific-total-hip-replacement bilateral-total-hip-replacement ceramic-hip-resurfacing; do
  src="hip-surgery/pages/${slug}.html"
  dst="hip-surgery/${slug}/index.html"

  cp "$src" "$dst"

  sed -i '' 's|href="dev-pages.css"|href="../assets/hip-pages.css"|g' "$dst"
  sed -i '' 's|src="dev-pages.js"|src="../assets/hip-pages.js"|g' "$dst"
  sed -i '' 's|href="../index.html"|href="/hip-surgery/"|g' "$dst"
  sed -i '' 's|href="../../index.html"|href="/"|g' "$dst"

  sed -i '' 's|href="total-hip-replacement.html"|href="/hip-surgery/total-hip-replacement/"|g' "$dst"
  sed -i '' 's|href="anterior-approach-total-hip-replacement.html"|href="/hip-surgery/anterior-approach-total-hip-replacement/"|g' "$dst"
  sed -i '' 's|href="bikini-incision-total-hip-replacement.html"|href="/hip-surgery/bikini-incision-total-hip-replacement/"|g' "$dst"
  sed -i '' 's|href="patient-specific-total-hip-replacement.html"|href="/hip-surgery/patient-specific-total-hip-replacement/"|g' "$dst"
  sed -i '' 's|href="bilateral-total-hip-replacement.html"|href="/hip-surgery/bilateral-total-hip-replacement/"|g' "$dst"
  sed -i '' 's|href="ceramic-hip-resurfacing.html"|href="/hip-surgery/ceramic-hip-resurfacing/"|g' "$dst"
done

cat > hip-surgery/index.html <<'HTML'
<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Hip Surgery | Dr Paul Harvie</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Lato:wght@400;700&family=Montserrat:wght@500;700&display=swap" rel="stylesheet">
  <style>
    body { margin: 0; font-family: "Lato", Arial, sans-serif; background: #f4f8fc; color: #1f2a37; }
    .wrap { max-width: 960px; margin: 0 auto; padding: 40px 20px; }
    h1 { font-family: "Montserrat", Arial, sans-serif; color: #1f5f93; margin: 0 0 10px; }
    p { margin: 0 0 16px; }
    .grid { display: grid; gap: 12px; margin-top: 24px; }
    .card { background: #fff; border: 1px solid #d9e2ec; border-radius: 10px; padding: 16px; }
    .card a { color: #1f5f93; font-weight: 700; text-decoration: none; }
    .card a:hover { text-decoration: underline; }
    .muted { color: #5f6b7a; font-size: 0.95rem; }
    .back a { color: #1f5f93; font-weight: 700; }
  </style>
</head>
<body>
  <div class="wrap">
    <p class="back"><a href="/">Back to Home</a></p>
    <h1>Hip Surgery</h1>
    <p>Total Hip Replacement and Ceramic Hip Resurfacing pages.</p>
    <p class="muted">Approved content prepared for patient review.</p>
    <section class="grid">
      <div class="card"><a href="/hip-surgery/total-hip-replacement/">Total Hip Replacement (Arthroplasty)</a></div>
      <div class="card"><a href="/hip-surgery/anterior-approach-total-hip-replacement/">Anterior Approach Total Hip Replacement</a></div>
      <div class="card"><a href="/hip-surgery/bikini-incision-total-hip-replacement/">Bikini Incision Total Hip Replacement</a></div>
      <div class="card"><a href="/hip-surgery/patient-specific-total-hip-replacement/">Patient-Specific Total Hip Replacement</a></div>
      <div class="card"><a href="/hip-surgery/bilateral-total-hip-replacement/">Bilateral Total Hip Replacement</a></div>
      <div class="card"><a href="/hip-surgery/ceramic-hip-resurfacing/">Ceramic Hip Resurfacing</a></div>
    </section>
  </div>
</body>
</html>
HTML

echo "Hip surgery pages published"
