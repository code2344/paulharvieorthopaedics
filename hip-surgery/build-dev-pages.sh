#!/usr/bin/env zsh
set -euo pipefail

ROOT="/Users/ruben_sutton29/paulharvieorthopaedics/hip-surgery"
PAGES_DIR="$ROOT/pages"
SRC_DIR="$ROOT/source-converted"

mkdir -p "$PAGES_DIR"

cat > "$PAGES_DIR/dev-pages.css" <<'CSS'
:root {
  --ink: #1f2a37;
  --muted: #5f6b7a;
  --brand: #1f5f93;
  --line: #d9e2ec;
  --panel: #ffffff;
}

* { box-sizing: border-box; }

body {
  margin: 0;
  font-family: "Lato", "Helvetica Neue", Arial, sans-serif;
  color: var(--ink);
  background: linear-gradient(160deg, #f3f6fb 0%, #ffffff 55%);
  line-height: 1.68;
}

.page-shell {
  max-width: 1100px;
  margin: 0 auto;
  padding: 32px 20px 60px;
}

.topbar {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 24px;
}

.topbar a {
  color: var(--brand);
  text-decoration: none;
  font-weight: 700;
}

.topbar a:hover { text-decoration: underline; }

.page-card {
  background: var(--panel);
  border: 1px solid var(--line);
  border-radius: 14px;
  overflow: hidden;
  box-shadow: 0 8px 28px rgba(16, 41, 66, 0.08);
}

.hero {
  position: relative;
  min-height: 230px;
  display: flex;
  align-items: end;
  padding: 30px;
  background-size: cover;
  background-position: center;
}

.hero::before {
  content: "";
  position: absolute;
  inset: 0;
  background: linear-gradient(135deg, rgba(11, 37, 59, 0.88), rgba(31, 95, 147, 0.35));
}

.hero h1,
.hero p {
  position: relative;
  color: #fff;
  margin: 0;
}

.hero h1 {
  font-family: "Montserrat", "Helvetica Neue", Arial, sans-serif;
  font-size: clamp(1.5rem, 3vw, 2.4rem);
  margin-bottom: 6px;
}

.hero p { opacity: 0.94; }

.content { padding: 28px; }

.content p {
  margin: 0 0 14px;
  color: var(--ink);
}

.content p:first-child {
  font-family: "Montserrat", "Helvetica Neue", Arial, sans-serif;
  font-size: 1.65rem;
  font-weight: 700;
  color: var(--brand);
}

.content p:nth-child(2) {
  font-size: 1.08rem;
  color: #0f3f6a;
}

.content ul {
  margin: 0 0 16px 20px;
}

.content li {
  margin-bottom: 8px;
}

.content table {
  width: 100%;
  border-collapse: collapse;
  margin: 16px 0 20px;
  font-size: 0.97rem;
}

.content td,
.content th {
  border: 1px solid #cfd9e3;
  padding: 10px;
  vertical-align: top;
}

.image-placeholder {
  border: 2px dashed #8fb4d3;
  background: #f1f7fc;
  color: #285f8d;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.04em;
  text-align: center;
  padding: 16px;
  margin: 18px 0;
  border-radius: 8px;
}

.local-nav {
  margin-top: 28px;
  padding-top: 20px;
  border-top: 1px solid var(--line);
  display: grid;
  gap: 8px;
}

.local-nav h2 {
  margin: 0 0 4px;
  font-size: 1.02rem;
  color: var(--muted);
  text-transform: uppercase;
  letter-spacing: 0.04em;
}

.local-nav a {
  color: var(--brand);
  text-decoration: none;
  font-weight: 700;
}

.local-nav a:hover { text-decoration: underline; }

@media (max-width: 768px) {
  .content { padding: 20px; }
  .hero { min-height: 200px; padding: 20px; }
}
CSS

cat > "$PAGES_DIR/dev-pages.js" <<'JS'
document.addEventListener('DOMContentLoaded', () => {
  const placeholderPattern = /(IMAGE IN THIS SECTION|IMAGES IN THIS SECTION|ENQUIRE NOW|GET IN TOUCH)/i;
  document.querySelectorAll('.content p').forEach((p) => {
    const text = (p.textContent || '').trim();
    if (!text) {
      p.remove();
      return;
    }
    if (placeholderPattern.test(text)) {
      p.classList.add('image-placeholder');
    }
  });
});
JS

extract_body() {
  awk '/<body>/{flag=1;next}/<\/body>/{flag=0}flag' "$1"
}

build_page() {
  local src="$1"
  local out="$2"
  local title="$3"
  local subtitle="$4"
  local hero="$5"

  {
    cat <<EOF
<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${title} | Dev Review</title>
  <link rel="stylesheet" href="dev-pages.css">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Lato:wght@400;700&family=Montserrat:wght@500;700&display=swap" rel="stylesheet">
</head>
<body>
  <div class="page-shell">
    <div class="topbar">
      <a href="../index.html">Back to Hip Surgery Dev Index</a>
      <a href="../../index.html">Main Site Homepage</a>
    </div>
    <article class="page-card">
      <header class="hero" style="background-image:url('${hero}');">
        <div>
          <h1>${title}</h1>
          <p>${subtitle}</p>
        </div>
      </header>
      <section class="content">
EOF
    extract_body "$src"
    cat <<'EOF'
        <nav class="local-nav" aria-label="Hip surgery pages">
          <h2>Related Hip Surgery Pages</h2>
          <a href="total-hip-replacement.html">Total Hip Replacement (Arthroplasty)</a>
          <a href="anterior-approach-total-hip-replacement.html">Anterior Approach Total Hip Replacement</a>
          <a href="bikini-incision-total-hip-replacement.html">Bikini Incision Total Hip Replacement</a>
          <a href="patient-specific-total-hip-replacement.html">Patient-Specific Total Hip Replacement</a>
          <a href="bilateral-total-hip-replacement.html">Bilateral Total Hip Replacement</a>
          <a href="ceramic-hip-resurfacing.html">Ceramic Hip Resurfacing</a>
        </nav>
      </section>
    </article>
  </div>
  <script src="dev-pages.js"></script>
</body>
</html>
EOF
  } > "$out"
}

build_page "$SRC_DIR/3.2.1-total-hip-replacement.html" "$PAGES_DIR/total-hip-replacement.html" "Total Hip Replacement (Arthroplasty)" "Replacing a damaged hip joint to relieve pain and restore movement" "../../3. HIP/3.2 HIP SURGERY/Images/Patient Specific THA.jpg"
build_page "$SRC_DIR/3.2.1.1-anterior-approach.html" "$PAGES_DIR/anterior-approach-total-hip-replacement.html" "Anterior Approach Total Hip Replacement" "A minimally invasive alternative to traditional hip replacements" "../../3. HIP/3.2 HIP SURGERY/Images/Anterior Approach Hip Replacement Surgery.jpg"
build_page "$SRC_DIR/3.2.1.2-bikini-incision.html" "$PAGES_DIR/bikini-incision-total-hip-replacement.html" "Bikini Incision Total Hip Replacement" "A cosmetically positioned anterior hip replacement incision" "../../3. HIP/3.2 HIP SURGERY/Images/Bikini Incision THA.jpg"
build_page "$SRC_DIR/3.2.1.3-patient-specific.html" "$PAGES_DIR/patient-specific-total-hip-replacement.html" "Patient-Specific Total Hip Replacement" "Personalised surgical planning designed around your anatomy" "../../3. HIP/3.2 HIP SURGERY/Images/Patient Specific THA.jpg"
build_page "$SRC_DIR/3.2.1.4-bilateral.html" "$PAGES_DIR/bilateral-total-hip-replacement.html" "Bilateral Total Hip Replacement" "Replacing both hip joints to treat severe arthritis or joint damage" "../../3. HIP/3.2 HIP SURGERY/Images/cyclist-riding-bike-trail-forest-man-cycling-enduro-trail-track-sport-fitness-motivation-inspiration-extreme-sport-concept-selective-focus-high-quality-photo.jpg"
build_page "$SRC_DIR/3.2.3-ceramic-hip-resurfacing.html" "$PAGES_DIR/ceramic-hip-resurfacing.html" "Ceramic Hip Resurfacing" "A bone-preserving alternative to total hip replacement" "../../3. HIP/3.2 HIP SURGERY/Images/Ceramic Hip Resurfacing.jpg"

cat > "$ROOT/index.html" <<'HTML'
<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Hip Surgery Dev Pages</title>
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
  </style>
</head>
<body>
  <div class="wrap">
    <h1>Hip Surgery Dev Pages</h1>
    <p>Converted from approved DOCX content in the 3. HIP source folder.</p>
    <p class="muted">Scope drafted: 3.2.1 Total Hip Replacement set and 3.2.3 Ceramic Hip Resurfacing.</p>
    <section class="grid">
      <div class="card"><a href="pages/total-hip-replacement.html">3.2.1 Total Hip Replacement (Arthroplasty)</a></div>
      <div class="card"><a href="pages/anterior-approach-total-hip-replacement.html">3.2.1.1 Anterior Approach Total Hip Replacement</a></div>
      <div class="card"><a href="pages/bikini-incision-total-hip-replacement.html">3.2.1.2 Bikini Incision Total Hip Replacement</a></div>
      <div class="card"><a href="pages/patient-specific-total-hip-replacement.html">3.2.1.3 Patient-Specific Total Hip Replacement</a></div>
      <div class="card"><a href="pages/bilateral-total-hip-replacement.html">3.2.1.4 Bilateral Total Hip Replacement</a></div>
      <div class="card"><a href="pages/ceramic-hip-resurfacing.html">3.2.3 Ceramic Hip Resurfacing</a></div>
    </section>
  </div>
</body>
</html>
HTML

echo "Build script created at $ROOT/build-dev-pages.sh"